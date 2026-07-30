# 流水线 A/B 组验收讲解脚本

> 唯一讲解对象：`miniRV_pipeline_axi_ego1/` 最终 CoreMark 流水线 AXI 版本。
>
> A 组负责：理想五级流水划分，以及数据、控制、结构和长延迟冒险的处理。
>
> B 组负责：ICache/DCache 侧接口、AXI Master、BRAM 和外设的连接关系。

## 0. 两组都必须先说清的设计边界

当前版本是 **带 ICache/DCache** 的五级流水线 AXI SoC。

代码中存在：

- `cpu2ic/ic2cpu`：CPU 与 ICache 的取指请求/响应；
- `cpu2dc/dc2cpu`：CPU 与 DCache 的数据请求/响应；
- `ENABLE_ICACHE/ENABLE_DCACHE`：当前均开启；
- `ICache.v/DCache.v`：tag、data、valid、hit/miss 和 refill 状态机；
- `axi_master.v`：将四个 AXI R beat 拼成 128-bit cache line。

本实现采用 direct-mapped、64 line、16-byte line。DCache 是
write-through/no-write-allocate，所以不需要 dirty bit 和 write-back FSM；不能因为
没有 dirty bit 就说它“不是 Cache”。B 组应说：

> 取指和普通数据 read 命中时不进入 AXI；miss 时对齐到 16 byte，并以
> `ARLEN=3` 读取四拍。store 始终 write-through；`0xFFFF_xxxx` MMIO 保持
> Uncached 单拍访问。

代码证据：

- `src/rtl/defines.vh`：Cache 开关、line 数量、Cacheable 地址上限；
- `src/rtl/cpu_top.v`：`U_core → U_icache/U_dcache → U_aximaster`；
- `src/rtl/ICache.v`、`DCache.v`：实际数组和状态机；
- `CACHE_IMPLEMENTATION_AND_DEFENSE.md`：逐状态代码、指令和波形讲解。

## 1. 两组衔接用的一张总图

```text
              A 组讲解范围
┌───────────────────────────────────────────────┐
│ cpu_core                                     │
│ IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM │
│                                   → MEM/WB → WB
│      forward / load-use / stall / flush      │
└──────────────────┬────────────────────────────┘
                   │ ifetch_* / daccess_*
                   ▼
              B 组讲解范围
┌───────────────────────────────────────────────┐
│ cpu_top                                      │
│ ICache：read-only、4-word refill             │
│ DCache：read allocate、write-through、MMIO   │
│                    ↓                         │
│ axi_master：D write > D read > I read       │
│                    ↓ AXI AR/R/AW/W/B          │
│ axi_board_soc：BRAM + 地址译码 + MMIO 外设    │
└───────────────────────────────────────────────┘
```

A 组结束语：

> 当 MEM 级形成 `daccess_ren/wen/addr/wdata`，流水线内部工作告一段落；请求怎样通过
> I/D 侧接口进入 AXI、再访问 BRAM 或外设，由 B 组继续说明。

B 组开场语：

> B 组从 A 组给出的 `ifetch_*` 和 `daccess_*` 接口接着讲。先判断 Cache
> hit/miss，再讲 miss 如何通过 AXI burst refill；最后讲 MMIO 为什么绕过 Cache。

## 2. A 组：理想五级流水划分

### 2.1 30 秒总述

> 本设计是单发射、按序、五级 RV32IM 流水线。IF 提出 PC 并等待指令；ID 译码、
> 读寄存器并扩展立即数；EX 做前递选择、ALU 和分支判断；MEM 形成 load/store 请求
> 并等待返回；WB 从 ALU、RAM、PC+4 或立即数中选择结果写回。四组级间寄存器携带
> 数据、控制和 valid，使多条指令能并行占据不同级。理想情况下流水线填满后每拍
> 完成一条指令，实际会因冒险、AXI 等待和多周期乘除法停顿。

### 2.2 五级和代码一一对应

| 级 | 主要工作 | 必须打开的代码 | 波形主信号 |
|---|---|---|---|
| IF | PC、取指请求、顺序或跳转地址 | `cpu_core.v:43-56, 521-534` | `ifetch_addr/req/valid/inst` |
| IF/ID | 锁存指令、PC、valid | `pipeline_regs.v:114-141` | `id_pc/id_inst/id_valid` |
| ID | Controller、RF、SEXT、相关寄存器号 | `cpu_core.v:109-117, 216-296` | `id_rs1/id_rs2/alu_op/ram_*` |
| ID/EX | 锁存操作数、控制和 rs/rd | `pipeline_regs.v:145-239` | `ex_pc/ex_rs1/ex_rs2/ex_rd/ex_valid` |
| EX | 前递、ALU、分支目标和 taken | `cpu_core.v:339-466` | `forward_*_sel/alu_*/ex_bj_*` |
| EX/MEM | 锁存 ALU 结果和 store 数据 | `pipeline_regs.v:241-293` | `mem_pc/mem_alu_c/mem_valid` |
| MEM | MREQ、MEXT、数据请求与等待 | `cpu_core.v:475-500` | `daccess_*`、`memory_freeze` |
| MEM/WB | 锁存 load 扩展结果和写回控制 | `pipeline_regs.v:295-329` | `wb_pc/wb_rd/wb_valid` |
| WB | 四选一写回 RF | `cpu_core.v:505-518`、`RF.v:29-35` | `rf_wD/wb_rf_we/wb_rd` |

回答“为什么是五级但有四组寄存器”：

> 五个是组合处理阶段；相邻阶段之间需要四个寄存器边界。PC 是 IF 自己的状态，
> 寄存器堆写口位于 WB。

回答“为什么必须有 valid”：

> stall 时寄存器可能保留旧数据，flush/bubble 后数据位也不一定立即清零；只有
> valid=1 才表示这些 PC、指令和控制属于真实在途指令。

## 3. A 组：冒险冲突和对应处理

### 3.1 ALU RAW：前递，不暂停

例子：

```asm
add x3, x1, x2
sub x4, x3, x5
```

实现：

- `forward_unit.v:25-39` 比较 `mem_rd/wb_rd` 与 `ex_rs1/ex_rs2`；
- `01` 选较近的 MEM 级结果，`10` 选 WB 的 `rf_wD`；
- MEM 优先于 WB；
- MEM 中的 load 被排除，因为此时只有地址，数据尚未返回；
- `cpu_core.v:425-434` 同时处理 ALU A/B 和 store 写数据前递。

波形：

```text
ex_rs1 ex_rs2 mem_rd wb_rd
forward_a_sel forward_b_sel
alu_a alu_b alu_c
```

### 3.2 Load-use：保持 IF/ID，向 ID/EX 注入 bubble

例子：

```asm
lw   x2, 0(x1)
addi x3, x2, 1
```

检测在 `cpu_core.v:288-296`：

```text
EX 是有效 load
AND ex_rd != x0
AND ID 确实使用同一个 rs1 或 rs2
```

处理：

1. `stall_if=1`：PC 和 IF/ID 保持；
2. `id_valid_for_ex=0`：相关指令暂时不进入 EX，形成 bubble；
3. load 继续进入 MEM；
4. AXI 未返回时 `memory_freeze=1`；
5. `daccess_rvalid=1` 后 load 进入 WB；
6. dependent 指令恢复进入 EX，并从 WB 前递。

不能回答成“所有级一起停一拍”。第一拍的 load-use 必须让老 load 继续前进，同时只
阻止年轻 dependent 指令进入 EX。

### 3.3 Store 数据相关：单独前递 rs2

`sw` 的 rs1 是地址基址，rs2 是写入数据。地址走 `fwd_a`，数据走
`fwd_store_data`，再由 `pipeline_regs` 锁存到 `mem_rf_rd2`。

关键位置：

- `cpu_core.v:167-168`；
- `cpu_core.v:433-434`；
- `MREQ.v`：按照地址低两位形成 `WSTRB` 和对齐后的 `WDATA`。

### 3.4 控制冒险：EX 判定，flush 年轻指令

分支、JAL、JALR 在 EX 得到：

```text
ex_bj_taken
ex_bj_target
ex_bj_f
```

`flush=ex_bj_f` 后：

- IF/ID valid 清零；
- ID/EX valid 清零；
- EX/MEM 和 MEM/WB 不清，因为它们比当前分支更老；
- PC 改为目标地址；
- `cpu_top` 丢弃分支前已经发出但后来才返回的旧取指响应。

关键位置：

- `cpu_core.v:339-393`；
- `pipeline_regs.v:124-141, 181-239`；
- `cpu_top.v:98-110`。

### 3.5 AXI 长延迟：freeze，而不是普通 bubble

load/store 请求已经在途时，地址和控制不能变化：

```text
memory_freeze = ld_st_suspend && !ld_st_done
effective_freeze = memory_freeze || ex_mul_div_busy
```

因此保持 IF、ID、EX；MEM/WB 在数据事务未结束时也保持。收到
`daccess_rvalid` 或 `daccess_wresp` 后解除。

### 3.6 M 扩展长延迟

`ALU_multicycle` 在启动边沿锁存已经前递后的操作数；`busy` 从启动拍拉高，防止
EX/MEM 采到旧结果。`operation_issued` 防止同一条 MUL/DIV 在冻结期间重复启动。

关键位置：

- `ALU_multicycle.v:100-144`；
- `cpu_core.v:443-462`；
- `cpu_core.v:366-385`。

### 3.7 A 组必须现场打开的波形

#### 理想流动、前递、分支

打开 `07_pipeline_five_stage_forward_branch.vcd`，加入：

```text
clk
ifetch_addr ifetch_valid ifetch_inst
id_pc id_valid ex_pc ex_valid mem_pc mem_valid wb_pc wb_valid
forward_a_sel forward_b_sel alu_a alu_b alu_c
ex_bj_taken ex_bj_target ex_bj_f flush
stall_if stall_id stall_ex stall_mem
```

#### Load-use

打开 `06_pipeline_load_use_hazard.vcd`，加入：

```text
clk
id_pc id_valid ex_pc ex_valid mem_pc mem_valid wb_pc wb_valid
load_use_hazard id_valid_for_ex
stall_if stall_id stall_ex stall_mem
ld_st_suspend ld_st_done memory_freeze
daccess_ren daccess_addr daccess_rvalid daccess_rdata
forward_a_sel rf_wD
```

A 组讲波形固定顺序：

> 先用 PC+valid 指认是哪条指令，再说明相关条件，然后说上升沿执行保持、推进、
> bubble 或 flush，最后用 WB/目标 PC 证明结果正确。

## 4. B 组：I/D 侧接口、AXI 和外设连接

### 4.1 30 秒总述

> `cpu_core` 不直接处理 AXI 五通道，只提供取指侧 `ifetch_*` 和数据侧
> `daccess_*` 请求响应接口。`cpu_top` 中 ICache/DCache 先检查 tag/valid：hit
> 直接返回，read miss 以 4-word line 请求 `axi_master`。Master 按数据写、数据读、
> 取指读的优先级仲裁，再转换成 AXI AR/R/AW/W/B。DCache 对 `0xFFFF_xxxx`
> 标记 Uncached，因此外设仍每次真实访问。`axi_board_soc` 最后按地址选择
> 150 KiB BRAM 或 switch、LED、数码管、UART、timer。

### 4.2 ICache：取指 hit 和 refill

通路：

```text
PC
→ cpu_core.ifetch_req / ifetch_addr
→ cpu_top.cpu2ic_rreq / cpu2ic_addr
→ ICache tag/valid 比较
  ├─ hit → 选择 line 内 word
  └─ miss → dev_ren / line-aligned dev_raddr
           → axi_master → AXI ARLEN=3 / 四个 R beat
           → 128-bit dev_rdata → 安装 tag/data/valid
→ cpu_top.ic2cpu_inst / ic2cpu_valid
→ IF/ID
```

地址分解为 tag=`[31:10]`、index=`[9:4]`、word offset=`[3:2]`。miss 经过
`ST_IDLE → ST_REQ → ST_WAIT → ST_IDLE`。taken branch 改变 PC 时，旧 line 可以
完成安装，但 ICache 回 IDLE 后重新检查当前地址，不会把旧指令交给 core。

关键位置：

- `cpu_top.v` 的 `U_icache`；
- `ICache.v` 的 `cpu_hit`、`miss_line_addr` 和三态 FSM；
- `cpu_top_fetch_tb.v` 的 redirect-during-refill 定向测试。

### 4.3 DCache：read、write-through 和 Uncached

通路：

```text
MEM 的 ALU 地址/操作类型/store 数据
→ MREQ：ren/wen/addr/wdata
→ cpu_core.daccess_*
→ cpu_top.cpu2dc_* / dc2cpu_*
→ DCache
  ├─ cached read hit：直接返回
  ├─ cached read miss：四拍 refill
  ├─ store：write-through；命中时按 byte lane 更新副本
  └─ MMIO read：Uncached 单拍
→ axi_master
→ AXI
→ BRAM 或 MMIO
```

`ren/wen` 是 4 位 byte lane。读回后 `MEXT` 根据地址低两位选择 byte/half/word，
并进行符号或零扩展。

DCache 使用五态 FSM：`IDLE/RREQ/RWAIT/WREQ/WWAIT`。write-through 表示每个 store
都发 AXI 写；no-write-allocate 表示写不命中不先读整条 line。MMIO 地址满足
`cpu_cacheable=0`，`dev_uncached=1`，不会更新数组。

### 4.4 I/D 请求怎样共享一个 AXI Master

`axi_master.v` 的优先级：

```text
data write > data read > instruction read
```

这解决共享端口的结构冲突。Master 一次只处理一个事务，状态机为：

```text
读：IDLE → RADDR → RDATA → IDLE
写：IDLE → WSEND → WRESP → IDLE
```

读通道：

1. ARVALID/ARREADY 接受地址；
2. Master 进入 RDATA；
3. Cache refill 时 `ARLEN=3`；Uncached 时 `ARLEN=0`；
4. 每次 RVALID/RREADY 接受一个 beat，写入 `read_buffer`；
5. RLAST 时根据 `read_is_data` 把完整 line 送给 ICache 或 DCache。

写通道：

1. AWVALID 和 WVALID 同时提出；
2. AW 与 W 可以在不同拍分别握手；
3. 两者均完成后进入 WRESP；
4. BVALID/BREADY 完成写响应；
5. `dc_dev_wresp` 通知流水线 store 完成。

### 4.5 AXI 怎样连接 BRAM 和外设

`miniRV_SoC.v`：

```text
cpu_top U_cpu
    ↓ AXI 五通道
axi_board_soc U_board_soc
```

`axi_board_soc` 的地址译码：

| 地址 | 读 | 写 |
|---|---|---|
| `0x00000000` 起的 150 KiB | BRAM | BRAM，按 WSTRB |
| `0xFFFF0000` | switch | - |
| `0xFFFF1000` | - | LED |
| `0xFFFF2000` | - | 八位数码管 |
| `0xFFFF3000` | UART RX，读后 pop | - |
| `0xFFFF3004` | - | UART TX |
| `0xFFFF3008` | UART status | - |
| `0xFFFF300C` | - | UART clear |
| `0xFFFF4000/+8` | 64 位 timer 低/高字 | - |

板端读状态由 `read_active/read_addr_reg/read_len_reg/read_beat_reg` 保存。BRAM
burst 每次地址加 4，最后一拍产生 `RLAST`；外设读要求 `ARLEN=0`。

### 4.6 B 组必须现场打开的波形

#### Cache miss/refill/hit

打开 `10_cache_refill_hit_uncached.vcd`，加入：

```text
U_icache.cpu_ren cpu_raddr cpu_hit state
U_icache.miss_line_addr dev_ren dev_rrdy dev_rvalid
U_dcache.cpu_ren cpu_addr cpu_hit cpu_cacheable
U_dcache.req_uncached dev_uncached
U_dcache.cpu_wen dev_wen dev_wresp
```

#### AXI cache-line burst

打开 `08_axi_cacheline_burst.vcd`，加入：

```text
state read_is_data read_len read_beat read_buffer
m_axi_araddr m_axi_arlen m_axi_arvalid m_axi_arready
m_axi_rdata m_axi_rvalid m_axi_rready m_axi_rlast
m_axi_awaddr m_axi_awvalid m_axi_awready
m_axi_wdata m_axi_wstrb m_axi_wvalid m_axi_wready
m_axi_bvalid m_axi_bready
```

先指出 `ARLEN=3`，再数四次 R 握手，最后指出 `RLAST` 和整条 line 返回。

#### 板端 BRAM burst

打开 `11_board_bram_burst.vcd`，加入：

```text
s_axi_araddr s_axi_arlen s_axi_arvalid s_axi_arready
s_axi_rdata s_axi_rvalid s_axi_rready s_axi_rlast
read_active read_addr_reg read_len_reg read_beat_reg
memory_read_pending
```

#### Uncached 外设

打开 `09_board_peripheral_mmio_uart.vcd`，加入：

```text
s_axi_awaddr s_axi_wdata s_axi_wstrb
s_axi_awvalid s_axi_awready s_axi_wvalid s_axi_wready
s_axi_bvalid s_axi_bready
s_axi_araddr s_axi_arvalid s_axi_arready
s_axi_rdata s_axi_rvalid s_axi_rready
write_accept read_is_memory write_is_memory
led_reg digled_reg timer
uart_tx_start uart_tx_data uart_tx_busy tx
uart_rx_valid uart_rx_data uart_rx_pop rx
```

B 组讲波形固定顺序：

> 先说 hit 还是 miss；miss 时指出对齐 line 地址和 Cache FSM；再数 AR/R burst；
> 最后用 Cache hit、写响应或外设寄存器变化证明事务完成。

## 5. 老师最可能追问

### A 组

1. 为什么流水线提高吞吐但不一定减少单条指令延迟？
2. stall、bubble 和 flush 有什么区别？
3. 为什么 ALU 结果能从 MEM 前递，而 load 数据不能？
4. load-use 时为什么不把所有级一起停住？
5. `sw` 的地址和写数据分别怎样解决相关？
6. 分支为什么只 flush IF/ID 和 ID/EX？
7. AXI wait 和 load-use bubble 有什么区别？
8. 连续 MUL/DIV 为什么不会重复启动？

### B 组

1. tag/index/offset 各是哪几位，hit 条件是什么？
2. 为什么 `ARLEN=3` 是四拍，`RLAST` 在哪一拍？
3. 为什么 DCache 选 write-through/no-write-allocate？
4. MMIO 为什么必须 Uncached，代码怎样判断？
5. 取指和数据读同时 miss 时谁优先？
6. 为什么 AW 和 W 必须分别记录握手？
7. WSTRB 怎样更新 DCache 副本和内存 byte lane？
8. 分支发生在 ICache refill 中间会怎样？
9. blocking Cache 为什么一次只能处理一个 miss？
10. UART 的 status、TX data 和 RX data 地址分别是什么？

## 6. 两组都必须能回答的交叉问题

- A 组至少要能从 `daccess_*` 解释到“请求交给 B 组的 AXI 接口”；
- B 组至少要知道 `daccess_rvalid/wresp` 会解除 A 组的 `memory_freeze`；
- 两组都必须知道 hit 只影响 B 组访存延迟，load-use 检测仍属于 A 组；
- 两组都必须会用 valid 判断波形中的 PC 是否属于真实指令；
- 两组都不能只背文件名，必须能在现场搜索信号并指出握手或寄存器更新条件。

## 7. 建议现场时间

| 时间 | 内容 | 主讲 |
|---:|---|---|
| 0:00-0:40 | 总体层级和 Cache 参数 | 两组任一人 |
| 0:40-3:30 | 理想五级、级间寄存器、valid | A |
| 3:30-6:30 | 前递、load-use、flush、freeze | A |
| 6:30-7:30 | A 组两份波形 | A |
| 7:30-10:00 | I/D Cache、refill 和 AXI 状态机 | B |
| 10:00-12:00 | BRAM、MMIO、UART、timer | B |
| 12:00-13:30 | B 组 Cache/AXI/外设波形 | B |
| 13:00 后 | 老师随机追问 | 被问到的人先答，另一人定位代码 |
