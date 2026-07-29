# 最终版流水线 AXI CoreMark 源码与波形自学讲义

> 唯一学习对象：`miniRV_pipeline_axi_ego1/`
>
> 目标不是背答案，而是能完成：
> **功能说明 → 找到文件 → 指出具体代码 → 找到波形信号 → 沿时钟解释 → 给出结果证据**。

## 1. 先建立完整层级

```text
miniRV_SoC
├─ clk_wiz_0                     生成 50 MHz 系统时钟
├─ reset_sync                    S6/PLL lock 后同步释放复位
├─ cpu_top
│  ├─ cpu_core                   五级 RV32IM 流水线
│  │  ├─ pipeline_regs           IF/ID、ID/EX、EX/MEM、MEM/WB
│  │  ├─ Controller              指令译码
│  │  ├─ RF                      32 个通用寄存器
│  │  ├─ SEXT                    I/S/B/U/J 立即数
│  │  ├─ forward_unit            MEM/WB 前递选择
│  │  ├─ ALU
│  │  │  ├─ ALU_multicycle       实板组合 ALU + 多周期 M 扩展
│  │  │  └─ ALU_trace            Trace 专用组合实现
│  │  ├─ MREQ                    load/store byte lane 与 WSTRB
│  │  └─ MEXT                    load 对齐和符号/零扩展
│  └─ axi_master                 CPU 简单请求转 AXI 五通道
├─ axi_board_soc                 AXI Slave + MMIO 地址译码
│  ├─ board_bram                 50 KiB IROM + 100 KiB DRAM
│  ├─ simple_uart                115200 8N1 UART
│  └─ sevenseg_display           八位数码管动态扫描
└─ ila_probe                     PC、AXI、复位、UART RX 实板观测
```

记忆主线：

```text
一条指令
  → cpu_core 的 IF/ID/EX/MEM/WB
  → cpu_top 请求防重/过期取指过滤
  → axi_master 五通道握手
  → axi_board_soc 的 BRAM 或 MMIO
  → 响应返回后继续流水或写回
```

## 2. 为什么需要这些层，而不是把所有代码写在一起

| 层 | 解决的问题 | 老师问时打开 |
|---|---|---|
| `miniRV_SoC` | Trace/实板后端选择、PLL、复位、ILA | `src/rtl/miniRV_SoC.v` |
| `cpu_top` | core 简单接口和 AXI 的时序差异 | `src/rtl/cpu_top.v` |
| `cpu_core` | 指令怎样经过五级、怎样处理冒险 | `src/rtl/cpu_core.v` |
| `pipeline_regs` | 每个上升沿哪些数据进入下一段 | `src/rtl/pipeline/pipeline_regs.v` |
| `axi_master` | CPU 请求怎样变成五通道握手 | `src/rtl/axi_master.v` |
| `axi_board_soc` | 地址怎样落到 BRAM/UART/LED/timer | `src/rtl/axi_board_soc.v` |

如果把 AXI 状态机直接放进 core：

- Basic Trace 无法复用核心；
- CPU 必须理解五个 AXI 通道；
- 冒险逻辑和总线握手会混在一起；
- 换成课程 `bram_axi` 或板级 Slave 会更困难。

现在的边界让 `cpu_core` 只理解：

```text
取指：req + addr → valid + inst
读数：ren + addr → rvalid + rdata
写数：wen + addr + wdata → wresp
```

## 3. 一条普通 ADDI 怎样经过五段

示例：

```asm
addi x2, x1, 3
```

### 3.1 IF：取指

文件：`cpu_core.v`

关键代码：

```verilog
assign ifetch_req  = resume_ifetch | !pause_ifetch;
assign ifetch_addr = ex_bj_f ? ex_bj_target : pc;
```

含义：

1. 没有 hazard/AXI/M 扩展等待时，`ifetch_req=1`；
2. 正常地址是 `pc`；
3. taken branch 当拍优先请求 `ex_bj_target`；
4. `cpu_top` 和 `axi_master` 完成 AXI AR/R；
5. `ifetch_valid=1` 表示指令真正返回。

PC 只在两种情况下更新：

```verilog
if (ex_bj_f)
    pc <= ex_bj_target;
else if (ifetch_valid && !stall_if)
    pc <= pc + 4;
```

所以“地址线上出现一个值”不代表已经取指，必须同时看返回 `ifetch_valid`。

### 3.2 IF/ID 上升沿

文件：`pipeline/pipeline_regs.v`

```verilog
if (!stall_if) begin
    id_pc_r    <= if_pc;
    id_inst_r  <= if_inst;
    id_valid_r <= if_valid_in;
end
```

在上升沿满足：

```text
ifetch_valid=1
stall_if=0
flush=0
```

指令才从 IF 进入 ID。波形中上升沿后看到：

```text
id_pc    = 该指令 PC
id_inst  = 00308113
id_valid = 1
```

### 3.3 ID：译码、读寄存器、扩展立即数

文件：

- `Controller.v`
- `RF.v`
- `SEXT.v`

`Controller` 识别：

```text
opcode=0010011
funct3=000
→ ADDI
→ alu_op=ALU_ADD
→ alua_sel=RS1
→ alub_sel=EXT
→ sext_op=EXT_I
→ rf_we=1
→ rf_wsel=WB_ALU
```

`RF` 用 `id_rs1=1` 读 x1，`SEXT` 把 imm=3 扩展为 32 位。

同拍 WB 若也在写 x1，`cpu_core` 的 `wb_fwd_rs1` 直接选 `rf_wD`，避免寄存器堆
同地址读写行为不确定。

### 3.4 ID/EX 上升沿

同一个上升沿必须一起保存：

- `ex_pc`
- `ex_rf_rd1/ex_rf_rd2`
- `ex_ext`
- `ex_rs1/ex_rs2/ex_rd`
- `ex_alu_op`
- `ex_alua_sel/ex_alub_sel`
- `ex_rf_we/ex_rf_wsel`
- `ex_valid`

数据和控制必须属于同一条指令。只保存数据、不保存控制会发生“上一条指令的控制操作
下一条指令的数据”。

### 3.5 EX：前递、选择操作数、ALU

`forward_unit` 输出：

```text
00：使用 ID/EX 保存值
01：从 MEM 前递
10：从 WB 前递
```

然后：

```verilog
alu_a = ex_alua_sel ? ex_pc  : fwd_a;
alu_b = ex_alub_sel ? ex_ext : fwd_b;
```

ADDI 得到：

```text
alu_a = x1 最新值
alu_b = 3
alu_c = x1 + 3
```

### 3.6 EX/MEM、MEM、MEM/WB

ADDI 不访问内存，但仍经过 MEM：

```text
ex_alu_c → mem_alu_c → wb_alu_c
```

`mem_valid/wb_valid` 与它一起流动。

### 3.7 WB：提交

```verilog
case (wb_rf_wsel)
    WB_ALU: rf_wD = wb_alu_c;
    WB_RAM: rf_wD = wb_ram_ext;
    WB_PC4: rf_wD = wb_pc + 4;
    WB_EXT: rf_wD = wb_ext;
endcase
```

寄存器堆写使能为：

```verilog
wb_rf_we && wb_valid
```

所以 bubble 即使保留 `wb_rf_we=1` 的旧值，也不会产生写回。

## 4. 五段在代码中的确切位置

| 段 | 主要文件 | 输入 | 核心工作 | 输出/边界 |
|---|---|---|---|---|
| IF | `cpu_core.v`、`cpu_top.v`、`axi_master.v` | `pc` | 产生取指请求、等待 AXI 返回 | `if_pc/if_inst/if_valid` |
| ID | `Controller.v`、`RF.v`、`SEXT.v` | `id_inst` | 译码、读寄存器、扩展立即数 | ID/EX 全部数据和控制 |
| EX | `forward_unit.v`、`ALU*.v` | `ex_*` | 前递、ALU、分支目标和比较 | EX/MEM |
| MEM | `MREQ.v`、`MEXT.v` | `mem_*` | AXI 数据请求、对齐、扩展 | MEM/WB |
| WB | `cpu_core.v`、`RF.v` | `wb_*` | 四选一并按序写 rd | 架构状态提交 |

现场判断某条指令在哪一级，只看：

```text
id_valid  + id_pc
ex_valid  + ex_pc
mem_valid + mem_pc
wb_valid  + wb_pc
```

不要用 ALU 结果猜级，因为 invalid bubble 也可能留下旧数据。

## 5. 数据冒险怎样实现

## 5.1 MEM/WB 前递

文件：`pipeline/forward_unit.v`

匹配条件：

```text
写回使能为 1
rd != x0
rd == 当前 EX 的 rs1 或 rs2
```

MEM 比 WB 更新，所以优先 MEM。

MEM 中若是 load，不能选择 MEM 前递，因为 `mem_alu_c` 是地址，不是 load 数据：

```verilog
mem_is_load = mem_ram_rop != RAM_EXT_N;
fwd_a_ex = mem_rf_we && !mem_is_load && mem_rd == ex_rs1;
```

load 要等数据进入 WB 后用选择码 `10` 前递。

## 5.2 Load-use

示例：

```asm
lw   x2, 0(x1)
addi x3, x2, 1
```

命中逻辑：

```text
EX 是有效 load
EX rd 非 0
ID 真实使用 rs1/rs2
EX rd == ID rs
```

处理方法：

```text
stall_if=1        保持 PC 和 IF/ID
id_valid_for_ex=0 向 ID/EX 注入 bubble
load 继续进入 MEM
AXI 返回后 load 进入 WB
addi 恢复，并从 WB 前递 x2
```

为什么不是只前递：

```text
load 地址在 EX 末尾才算出
数据还必须完成 AXI AR/R
下一条 addi 同拍 EX 时数据不存在
```

## 5.3 Store 数据前递

```asm
addi x5,x0,0x55
sw   x5,0(x1)
```

store 的 rs2 不是 ALU 地址操作数，但仍是要写入内存的数据，所以使用：

```verilog
fwd_store_data
```

并把它锁存为 `mem_rf_rd2`，再交给 `MREQ`。

## 5.4 同拍 ID/WB 旁路

当一条指令在 WB 写 x1，另一条恰好在 ID 读 x1：

```text
wb_fwd_rs1=1 → rf_rd1_fwd=rf_wD
```

这与 EX 前递不同，它发生在 ID，解决寄存器堆同地址读写时序问题。

## 6. 控制冒险怎样实现

分支/JAL/JALR 到 EX 才确定。

目标：

```text
JALR：{alu_c[31:1],1'b0}
branch/JAL：ex_pc + ex_ext
```

taken：

```text
(branch && br) || JAL || JALR
```

实板模式：

```text
ex_bj_f = ex_bj_taken
flush   = ex_bj_f
```

`pipeline_regs` 收到 flush 后：

- IF/ID valid 清零；
- ID/EX valid 清零；
- MEM/WB 不清，因为它们比当前分支更老，必须完成。

同时：

```text
pc = ex_bj_target
ifetch_addr = ex_bj_target
```

旧路径 AXI 取指若后来返回，由 `cpu_top` 的 `ic_pending_word_addr` 比较丢弃。

## 7. 多周期 M 扩展怎样实现

`ALU.v` 在实板模式选择 `ALU_multicycle`。

### 7.1 普通操作

ADD/SUB/AND/OR/shift/compare 是组合逻辑，单次 EX 完成。

### 7.2 乘除法

启动条件：

```text
当前 op 是 M 指令
operation_issued=0
所有 worker busy=0
```

启动当拍：

```text
operation_start=1
busy=1
锁存 op、符号、原始 a/b
启动 multiplier/divider
```

迭代期间：

```text
ex_mul_div_busy=1
effective_freeze=1
stall_if/id/ex=1
```

完成后 worker busy 降为 0，结果在 EX/MEM 锁存，`operation_issued` 清除，下一条 M
指令可启动。

必须包含“启动当拍 busy”：

```verilog
busy = operation_start | unit_busy;
```

否则启动 worker 的同一个上升沿，EX/MEM 会先锁存旧结果。

## 8. AXI 数据访问怎样冻结流水线

访存进入 EX 后：

```text
ex_is_ld_st=1
ld_st_suspend=1
```

完成条件：

```text
load：daccess_rvalid=1
store：daccess_wresp=1
```

等待时：

```text
memory_freeze=1
stall_if=1
stall_id=1
stall_ex=1
stall_mem=1
```

核心保持同一条访存指令和地址/写数据，直到响应。`cpu_top` 在响应拍屏蔽原请求，防止
Master 回到 IDLE 后把同一个请求接受第二次。

## 9. AXI Master 五通道

文件：`axi_master.v`

状态：

```text
ST_IDLE
├─ data write → ST_WSEND → ST_WRESP → ST_IDLE
├─ data read  → ST_RADDR → ST_RDATA → ST_IDLE
└─ inst read  → ST_RADDR → ST_RDATA → ST_IDLE
```

## 9.1 读事务

1. CPU 请求在 `ST_IDLE` 被接受；
2. 锁存并 4 字节对齐地址；
3. `ARVALID=1` 保持到 `ARREADY=1`；
4. 地址握手后 `RREADY=1`；
5. `RVALID && RREADY` 时接收 `RDATA`；
6. 按 `read_is_data` 返回取指口或数据口；
7. CPU 侧 `rvalid` 只拉高一拍。

## 9.2 写事务

1. CPU `wen!=0`；
2. 同时发出 AWVALID 和 WVALID；
3. AW 和 W 可以不同拍握手，各自握手后只清自己的 VALID；
4. 两者都完成后进入 WRESP；
5. `BVALID && BREADY` 后向 CPU 产生 `wresp`。

AXI 规则：

```text
VALID 由发送方产生
READY 由接收方产生
只有 VALID && READY 的上升沿才算传输
等待期间 VALID、地址、数据必须保持稳定
```

## 10. 外设和存储器怎样实现

文件：`axi_board_soc.v`

| 地址 | 读 | 写 | 代码 |
|---|---|---|---|
| `0x00000000...` | IROM/DRAM | DRAM byte write | `board_bram` |
| `0xFFFF0000` | 16-bit switch | - | `PERI_ADDR_SWITCH` |
| `0xFFFF1000` | - | 16-bit LED | `led_reg` |
| `0xFFFF2000` | - | 32-bit digled | `digled_reg` |
| `0xFFFF3000` | UART RX data | - | `uart_rx_data/pop` |
| `0xFFFF3004` | - | UART TX data | `uart_tx_data/start` |
| `0xFFFF3008` | UART status | - | `uart_status` |
| `0xFFFF300C` | - | UART clear | `tx_clear/rx_clear` |
| `0xFFFF4000` | timer low | - | `timer[31:0]` |
| `0xFFFF4008` | timer high | - | `timer[63:32]` |

## 10.1 BRAM

`board_bram`：

- IROM 12,800 words；
- DRAM 25,600 words；
- 总计 38,400 words = 150 KiB；
- AXI 字节地址 `[17:2]` 变成 BRAM 字地址；
- BMG 同步读延迟 1 拍，所以 `memory_read_pending` 记录未返回读。

## 10.2 LED 和数码管

LED 写：

```text
AWADDR=FFFF1000
WVALID/AWVALID/READY 握手
根据 WSTRB 更新 led_reg 对应字节
led = led_reg
```

数码管：

```text
AWADDR=FFFF2000 → digled_reg
sevenseg_display 用 scan_counter[15:13] 轮流选择 8 位
每位取 value 的 4-bit，译成段码
```

## 10.3 UART

发送：

```text
软件轮询 UART+8 bit3
写 UART+4
axi_board_soc 产生 tx_start 单拍
simple_uart 锁存 {stop,data,start}
每 CLKS_PER_BIT 推进一位
```

接收：

```text
rx 两级同步
下降沿 → RX_START
半 bit 后确认仍为 0
每个 bit 中心采样 8 位
停止位为 1 → rx_data、rx_valid
软件读 UART+0 → rx_pop 清 valid
```

## 11. CoreMark 软件在做什么

不修改 CoreMark 官方算法源码，避免改变基准口径。需要理解以下入口：

| 文件 | 作用 |
|---|---|
| `software/c_test/4_coremark/Makefile` | 选择编译器、源文件和链接脚本 |
| `src/common/init_asm.S` | 设置栈、清 BSS、跳到 C 入口 |
| `src/common/ram.lds` | 定义程序/数据/栈地址 |
| `src/common/sc_print.c/.h` | UART 输出和基础格式化 |
| `src/coremark/core_portme.c/.h` | timer、迭代次数、平台适配 |
| `src/coremark/src/core_main.c` | CoreMark 主控、CRC 和最终报告 |
| `core_list_join.c` | 链表 workload |
| `core_matrix.c` | 矩阵 workload |
| `core_state.c` | 状态机 workload |
| `core_util.c` | CRC/工具函数 |
| `main.mem` | 编译后的 38,400-word 板级存储镜像 |

完整正确性不是只看“有输出”，而是：

```text
四组 CRC 与参考值一致
Correct operation validated
CoreMark 21.250
CoreMark/MHz 0.425
FINISH
数码管 C0DE600D
```

## 12. 最终版每个 RTL 文件做什么

| 文件 | 必须会说的一句话 |
|---|---|
| `defines.vh` | 全工程控制码、写回选择、访存宽度和 MMIO 地址 |
| `miniRV_SoC.v` | Trace/实板双后端、PLL/复位、ILA 和顶层连线 |
| `cpu_top.v` | core/AXI 适配、响应拍防重、过期取指过滤 |
| `cpu_core.v` | 五级流水、冒险、冻结、分支、MEM、WB |
| `pipeline/pipeline_regs.v` | 四组级间寄存器及 stall/flush/valid |
| `Controller.v` | opcode/funct 到全部控制信号 |
| `RF.v` | ID 双读、WB 单写、x0 恒 0 |
| `SEXT.v` | I/S/B/U/J 立即数拼接 |
| `pipeline/forward_unit.v` | MEM/WB RAW 前递，禁止 load 的 MEM 地址误前递 |
| `ALU.v` | Trace/FPGA ALU 选择器 |
| `pipeline/ALU_trace.v` | Trace 组合 RV32IM 运算 |
| `pipeline/ALU_multicycle.v` | 实板组合 ALU、多周期 worker 和 freeze busy |
| `multiplier.v` | 32 拍移位加法乘法 |
| `divider.v` | 32 拍恢复除法 |
| `MREQ.v` | store WSTRB/写数据对齐和 load 读请求 |
| `MEXT.v` | load 返回数据的 byte offset 和符号扩展 |
| `axi_master.v` | 三路 CPU 请求到 AXI 五通道 |
| `axi_board_soc.v` | BRAM/MMIO AXI Slave |
| `board_bram.v` | IROM/DRAM 两个 BMG 的连续地址适配 |
| `simple_uart.v` | 115200 8N1 TX/RX |
| `sevenseg_display.v` | 8 位十六进制动态扫描 |

## 13. 原始波形一键生成

必须在有 `iverilog` 和 `vvp` 的 Ubuntu/Linux 服务器执行：

```bash
cd ~/miniRV_pipeline_axi_ego1
sudo apt install -y iverilog   # 已安装可跳过
bash tests/generate_report_vcd.sh
```

输出：

```text
docs/course-report/vcd/06_pipeline_load_use_hazard.vcd
docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd
docs/course-report/vcd/06_no_cache_axi_transaction.vcd
docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd
```

终端必须出现：

```text
PASS: pipeline_hazard_tb
PASS: pipeline_flow_tb
PASS: axi_master_tb
PASS: board_peripheral_tb
```

上述四个 testbench 已在 Ubuntu GitHub Actions/Icarus 回归
[`30446791756`](https://github.com/komariChikaA/cpu-design-hitsz/actions/runs/30446791756)
中实际执行并全部通过。仓库内四份 VCD 就是该次构建产物：

| VCD | 字节数 | SHA-256 |
|---|---:|---|
| `06_pipeline_load_use_hazard.vcd` | 41,172 | `81a4ea95274f7cefbfb6249941472417b3cd4f4e2ec9f016f0a01f6682ef3965` |
| `07_pipeline_five_stage_forward_branch.vcd` | 38,357 | `604f751f34215df13d82bc4b2bded61a64eb4d0d35c4f89702b384bef2f25df8` |
| `06_no_cache_axi_transaction.vcd` | 4,979 | `773e05a8c059d3c7b8bfec58bc9f13bb12e978e703a051fc8ec39f7f9262957e` |
| `09_board_peripheral_mmio_uart.vcd` | 633,295 | `bd517134842eeba48e14f41ab553f40d17575d4dec1217288e808f68a40697fc` |

## 14. 在 Surfer/GTKWave 中现场找信号

### 14.1 基本操作

1. File → Open，选择 `.vcd`；
2. 左侧 Scope 展开 testbench，再展开 `dut`；
3. 搜索信号名并双击/Add to Wave；
4. PC、地址、指令和数据设为 Hex；
5. valid/ready/stall/flush 设为 Binary；
6. 先加 `clk`，把光标放在上升沿；
7. 每解释一拍，都按“沿前条件 → 沿后寄存器变化”说。

不要把绿色粗条当成高电平。总线频繁变化、缩放太远时也会显示成粗条，必须放大并看 Value。

### 14.2 五级流动与分支波形

打开：

```text
07_pipeline_five_stage_forward_branch.vcd
```

Scope：

```text
pipeline_flow_tb / dut
```

加入：

```text
clk rst
ifetch_addr ifetch_valid ifetch_inst
id_pc id_inst id_valid
ex_pc ex_valid ex_rs1 ex_rs2 ex_rd
mem_pc mem_valid mem_rd
wb_pc wb_valid wb_rd
forward_a_sel forward_b_sel
alu_a alu_b alu_c
ex_bj_taken ex_bj_target ex_bj_f flush
stall_if stall_id stall_ex stall_mem
```

重点找：

1. PC 0/4/8 的三条算术指令同时占据不同级；
2. `forward_a_sel/forward_b_sel` 从 00 变 01/10；
3. PC=0x0c 的 BEQ 在 EX 时 `ex_bj_f=1`；
4. 下一上升沿 `id_valid/ex_valid` 对错误路径变 0；
5. PC=0x10 的 x5=99 不得到 WB 提交。

### 14.3 Load-use 波形

打开：

```text
06_pipeline_load_use_hazard.vcd
```

加入：

```text
id_pc id_valid ex_pc ex_valid mem_pc mem_valid wb_pc wb_valid
load_use_hazard
stall_if stall_id stall_ex stall_mem
id_valid_for_ex
ld_st_suspend ld_st_done memory_freeze
daccess_ren daccess_addr daccess_rvalid daccess_rdata
forward_a_sel rf_wD
```

重点找：

1. `lw` 在 EX、相关 `addi` 在 ID；
2. `load_use_hazard=1`；
3. IF/ID 保持而 ID/EX valid=0；
4. AXI 模型等待期间 `memory_freeze=1`；
5. `daccess_rvalid=1` 后 load 进入 WB；
6. addi 恢复且 `forward_a_sel=10`。

### 14.4 AXI 波形

打开：

```text
06_no_cache_axi_transaction.vcd
```

Scope：

```text
axi_master_tb / dut
```

加入：

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

重点找：

- ARVALID 等待 ARREADY 时地址保持；
- RVALID/RREADY 同拍才返回 CPU；
- AW 已握手后 AWVALID 清零，但 WVALID 在 backpressure 下保持；
- WDATA/WSTRB 在 WREADY=0 时不变；
- B 握手后才产生 `dc_dev_wresp`。

### 14.5 外设波形

打开：

```text
09_board_peripheral_mmio_uart.vcd
```

Scope：

```text
board_peripheral_tb / dut
```

加入：

```text
s_axi_awaddr s_axi_awvalid s_axi_awready
s_axi_wdata s_axi_wstrb s_axi_wvalid s_axi_wready
s_axi_bvalid s_axi_bready
s_axi_araddr s_axi_arvalid s_axi_arready
s_axi_rdata s_axi_rvalid s_axi_rready
write_accept write_is_memory read_is_memory
led_reg digled_reg timer
uart_tx_start uart_tx_data uart_tx_busy
uart_rx_pop uart_rx_data uart_rx_valid uart_status
U_uart/tx_active U_uart/tx_bit_index U_uart/tx_shift
U_uart/rx_state U_uart/rx_clock_count U_uart/rx_bit_index U_uart/rx_shift
```

按地址找：

```text
FFFF1000 → LED=00A5
FFFF2000 → digled=600D600D
FFFF0000 → switch=1234
FFFF4000 → timer low
FFFF3004 → UART TX 55
FFFF3008 → UART status
FFFF3000 → UART RX 41 并 pop
```

## 15. 在 Vivado 仿真器中现场找波形

如果老师不接受预先截图，可直接在 Vivado 打开 testbench：

1. Flow Navigator → Simulation → Run Behavioral Simulation；
2. Simulation Settings 把顶层设为：
   - `pipeline_flow_tb`
   - `pipeline_hazard_tb`
   - `axi_master_tb`
   - `board_peripheral_tb`
3. Scopes 中展开 `dut`；
4. Objects 中搜索上面清单的信号；
5. 右键 Add to Wave Window；
6. Restart；
7. Run All；
8. 右键数据总线 → Radix → Hexadecimal；
9. Zoom Fit 后再放大到目标上升沿。

如果这些 testbench 没加入 Vivado Simulation Sources：

```text
Add Sources
→ Add or create simulation sources
→ 选择 miniRV_pipeline_axi_ego1/tests/*.v
```

只加入当前要看的 testbench，避免多个 top 同时运行。

## 16. 实板 ILA 能看什么

当前 `ila_probe[186:0]` 位于 `miniRV_SoC.v`，适合板级定位：

| 位 | 信号 |
|---|---|
| 186 | 原始 `rx` |
| 185 | UART 同步后 rx |
| 184:183 | UART RX state |
| 182 | UART RX valid |
| 181:174 | UART RX data |
| 173 | PLL lock |
| 172 | sys_rst |
| 171:140 | PC |
| 139 | ifetch_req |
| 138 | ifetch_valid |
| 137:106 | ARADDR |
| 105:74 | RDATA |
| 73:70 | AR/R valid-ready |
| 69:38 | AWADDR |
| 37:6 | WDATA |
| 5:0 | AW/W/B valid-ready |

ILA 看不到当前完整的 ID/EX/MEM/WB 内部信号，所以：

- 五级、前递、load-use、flush：用 Behavioral Simulation/VCD；
- 板上是否复位、PC 是否前进、AXI 是否握手、UART RX 是否收到：用 ILA。

不要在老师面前声称 ILA 截图中存在没有探出的 `id_pc/ex_pc`。

## 17. 波形回答固定模板

每次回答只按五句话：

1. **哪条指令**：用 stage PC + valid 确认；
2. **在哪一级**：ID/EX/MEM/WB；
3. **为什么变化**：译码、相关、分支或 AXI 握手条件；
4. **这个上升沿做什么**：保持、推进、bubble 或 flush；
5. **怎样证明正确**：WB、store response、目标 PC、UART/CRC/测试 PASS。

示例：

> 当前 PC=4 的 lw 在 EX，PC=8 的 addi 在 ID，ex_rd=2 与 id_rs1=2 命中，
> 所以 load_use_hazard 拉高。这个上升沿 IF/ID 保持，ID/EX valid 清零形成
> bubble，lw 继续进入 MEM 并等待 AXI。R 响应后 lw 进入 WB，addi 恢复到 EX，
> forward_a_sel=10 选择 WB 的 42，最终写 x3=43。

## 18. 下一次验收前必须自己完成的练习

不看讲义，分别对着源代码回答：

1. 从 `miniRV_SoC` 找到 UART TX 引脚最终由哪个 always block驱动；
2. 从 `cpu_core` 找到 `lw -> addi` 的暂停条件和 bubble 注入位置；
3. 从 `pipeline_regs` 说明 flush 为什么只影响 IF/ID 与 ID/EX；
4. 从 `forward_unit` 说明为什么 MEM load 不能前递；
5. 从 `axi_master` 指出 AW/W 不同拍握手的代码；
6. 从 `axi_board_soc` 指出 `0xFFFF3008` 的返回值；
7. 在 VCD 中找到同一逻辑的信号变化；
8. 用五句话模板完整解释，不使用“这里大概是”“应该是”。
