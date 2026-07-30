# 流水线 A/B 组验收讲解脚本

> 唯一讲解对象：`miniRV_pipeline_axi_ego1/` 最终 CoreMark 流水线 AXI 版本。
>
> A 组负责：理想五级流水划分，以及数据、控制、结构和长延迟冒险的处理。
>
> B 组负责：ICache/DCache 侧接口、AXI Master、BRAM 和外设的连接关系。

## 0. 两组都必须先说清的设计边界

当前版本是 **无 Cache** 的五级流水线 AXI SoC。

代码中存在：

- `cpu2ic/ic2cpu`：CPU 的取指侧请求/响应接口；
- `cpu2dc/dc2cpu`：CPU 的数据侧请求/响应接口；
- `ENABLE_ICACHE/ENABLE_DCACHE`：为兼容和后续扩展保留的宏。

但当前工程不存在 Cache 必需的 tag array、data array、valid/dirty、hit/miss、
替换策略和 refill/write-back 状态机。因此 B 组应说：

> 当前保留 ICache/DCache 侧接口边界，但请求直接进入 `axi_master`，每次只传输一个
> 32 位字。这里讲的是接口和未来 Cache 插入位置，不声称已经实现 Cache。

代码证据：

- `src/rtl/defines.vh:8-10`：两个 Cache 宏保持关闭；
- `src/rtl/cpu_top.v:58-72`：I/D 两侧请求响应信号；
- `src/rtl/cpu_top.v:114-167`：`cpu_core` 直接连接 `axi_master`；
- `src/rtl/axi/README.md`：明确说明当前为无 Cache 配置。

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
│ I-side / D-side 接口、防重、过期取指过滤      │
│                    ↓                         │
│ axi_master：data write > data read > ifetch │
│                    ↓ AXI AR/R/AW/W/B          │
│ axi_board_soc：BRAM + 地址译码 + MMIO 外设    │
└───────────────────────────────────────────────┘
```

A 组结束语：

> 当 MEM 级形成 `daccess_ren/wen/addr/wdata`，流水线内部工作告一段落；请求怎样通过
> I/D 侧接口进入 AXI、再访问 BRAM 或外设，由 B 组继续说明。

B 组开场语：

> B 组从 A 组给出的 `ifetch_*` 和 `daccess_*` 接口接着讲。当前接口后面没有真正
> Cache，而是由 `cpu_top` 做适配后直接进入 AXI Master。

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
> `daccess_*` 请求响应接口。`cpu_top` 把它们命名为 I-side 和 D-side 接口，并负责
> 屏蔽响应拍的旧请求以及过滤分支后的过期取指。当前没有真正 ICache/DCache，请求
> 直接交给 `axi_master`；Master 按数据写、数据读、取指读的优先级仲裁，再转换成
> AXI AR/R/AW/W/B。`axi_board_soc` 最后按地址选择 150 KiB BRAM 或
> switch、LED、数码管、UART、timer。

### 4.2 ICache 侧接口：当前是无 Cache 取指通路

通路：

```text
PC
→ cpu_core.ifetch_req / ifetch_addr
→ cpu_top.cpu2ic_rreq / cpu2ic_addr
→ axi_master.ic_cpu_ren / ic_cpu_raddr
→ AXI AR/R
→ ic_dev_rdata / ic_dev_rvalid
→ cpu_top.ic2cpu_inst / ic2cpu_valid
→ IF/ID
```

`cpu_top` 在 AXI 接受取指时记录 `ic_pending_word_addr`。响应回来时，只有该地址仍然
等于 core 当前请求地址才产生 `ic2cpu_valid`，从而过滤 taken branch 后的旧响应。

关键位置：

- `cpu_core.v:22-25, 531-534`；
- `cpu_top.v:58-61, 98-120`；
- `axi_master.v:154-183`。

### 4.3 DCache 侧接口：当前是无 Cache 数据通路

通路：

```text
MEM 的 ALU 地址/操作类型/store 数据
→ MREQ：ren/wen/addr/wdata
→ cpu_core.daccess_*
→ cpu_top.cpu2dc_* / dc2cpu_*
→ axi_master.dc_cpu_*
→ AXI
→ BRAM 或 MMIO
```

`ren/wen` 是 4 位 byte lane。读回后 `MEXT` 根据地址低两位选择 byte/half/word，
并进行符号或零扩展。

`cpu_top.v:89-91` 还在 response 当拍屏蔽旧请求，避免 Master 回到 IDLE 后把未及时
撤销的同一请求再次接受。

### 4.4 I/D 请求怎样共享一个 AXI Master

`axi_master.v:139-160` 的优先级：

```text
data write > data read > instruction read
```

这解决的是共享端口的结构冲突。当前 Master 一次只处理一个事务，状态机为：

```text
读：IDLE → RADDR → RDATA → IDLE
写：IDLE → WSEND → WRESP → IDLE
```

读通道：

1. ARVALID/ARREADY 接受地址；
2. Master 进入 RDATA；
3. RVALID/RREADY 接受返回数据；
4. 根据 `read_is_data` 把响应送给 I-side 或 D-side。

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

写路径在 `axi_board_soc.v:126-220`，读路径在 `axi_board_soc.v:243-261`。

### 4.6 B 组必须现场打开的波形

#### AXI 五通道

打开 `06_no_cache_axi_transaction.vcd`，加入：

```text
clk rst state read_is_data
ic_cpu_ren ic_dev_rrdy ic_dev_rvalid
dc_cpu_ren dc_dev_rrdy dc_dev_rvalid
dc_cpu_wen dc_dev_wrdy dc_dev_wresp
m_axi_araddr m_axi_arvalid m_axi_arready
m_axi_rdata m_axi_rvalid m_axi_rready
m_axi_awaddr m_axi_awvalid m_axi_awready
m_axi_wdata m_axi_wstrb m_axi_wvalid m_axi_wready
m_axi_bvalid m_axi_bready
```

#### BRAM 与外设

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

> 先说 CPU 发的是取指、数据读还是数据写；再指出 Master 接受请求和当前 state；
> 接着找对应 AXI 握手；最后用返回 valid、写响应或外设寄存器变化证明事务完成。

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

1. 你们是否真的实现了 ICache/DCache？
2. I-side 和 D-side 为什么要分开？
3. 如果未来加入 Cache，应插在哪里？
4. 取指和数据读同时请求时谁优先？
5. 为什么 AW 和 W 必须分别记录握手？
6. WSTRB 怎样实现 byte/half store？
7. BRAM 和外设怎样共用同一 AXI 地址空间？
8. 分支后的旧取指响应为什么不能直接交给 CPU？
9. UART 的 status、TX data 和 RX data 地址分别是什么？

## 6. 两组都必须能回答的交叉问题

- A 组至少要能从 `daccess_*` 解释到“请求交给 B 组的 AXI 接口”；
- B 组至少要知道 `daccess_rvalid/wresp` 会解除 A 组的 `memory_freeze`；
- 两组都必须知道当前无 Cache；
- 两组都必须会用 valid 判断波形中的 PC 是否属于真实指令；
- 两组都不能只背文件名，必须能在现场搜索信号并指出握手或寄存器更新条件。

## 7. 建议现场时间

| 时间 | 内容 | 主讲 |
|---:|---|---|
| 0:00-0:40 | 总体层级和无 Cache 边界 | 两组任一人 |
| 0:40-3:30 | 理想五级、级间寄存器、valid | A |
| 3:30-6:30 | 前递、load-use、flush、freeze | A |
| 6:30-7:30 | A 组两份波形 | A |
| 7:30-10:00 | I/D 侧接口和 AXI 状态机 | B |
| 10:00-12:00 | BRAM、MMIO、UART、timer | B |
| 12:00-13:00 | B 组两份波形 | B |
| 13:00 后 | 老师随机追问 | 被问到的人先答，另一人定位代码 |
