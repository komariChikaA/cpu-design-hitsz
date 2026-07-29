# 最终版流水线 AXI 波形答辩手册

> 对应 RTL：`miniRV_pipeline_axi_ego1/`
> 对应 VCD：
> `docs/course-report/vcd/06_pipeline_load_use_hazard.vcd`
> `docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd`
> `docs/course-report/vcd/06_no_cache_axi_transaction.vcd`
> `docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd`

## 1. 波形必须按时钟沿解释

Verilog 时序寄存器使用非阻塞赋值。读波形时以一个上升沿为界：

1. 上升沿前的组合信号决定本次要锁存什么；
2. 上升沿到来时，各级寄存器同时采样旧值；
3. 非阻塞赋值在该时间步末更新；
4. 上升沿后的整段周期里，新的级内寄存器值再经过组合逻辑产生下一组信号。

因此不要说“看到地址变化就已经取到指令”。正确说法是：

> 地址和请求先出现；VALID/READY 同拍表示地址被接受；RVALID/RREADY 同拍表示
> 数据返回；CPU 侧 ifetch_valid 高的周期结束时，IF/ID 才在上升沿锁存该指令；
> 随后一个周期 ID 的组合译码信号才对应这条指令。

## 2. 先加入哪些信号

### 2.1 第一组：时钟、复位和取指

```text
clk
rst / cpu_rst
pc
ifetch_req
ifetch_addr
ifetch_valid
ifetch_inst
```

解释目的：CPU 是否脱离复位、当前请求哪个 PC、请求何时被接受、返回哪条指令。

### 2.2 第二组：五级跟踪

```text
id_valid  id_pc  id_inst
ex_valid  ex_pc  ex_rs1  ex_rs2  ex_rd  ex_alu_op
mem_valid mem_pc mem_rd  mem_alu_c  mem_ram_rop  mem_ram_wop
wb_valid  wb_pc  wb_rd   wb_rf_we   wb_rf_wsel  rf_wD
```

先看 `*_valid`，再解释 `*_pc`。valid=0 时，旁边保存的旧 PC/控制值不能当真实指令。

### 2.3 第三组：冒险与前递

```text
load_use_hazard
load_duplicate
mul_duplicate
memory_freeze
effective_freeze
stall_if
stall_id
stall_ex
stall_mem
flush
forward_a_sel
forward_b_sel
id_valid_for_ex
```

### 2.4 第四组：访存与 AXI

```text
daccess_ren  daccess_wen  daccess_addr  daccess_wdata
daccess_rvalid  daccess_rdata  daccess_wresp

ARADDR ARVALID ARREADY
RDATA  RVALID  RREADY
AWADDR AWVALID AWREADY
WDATA  WSTRB   WVALID WREADY
BVALID BREADY
axi_master.state
```

### 2.5 第五组：分支与 M 扩展

```text
ex_bj_taken
ex_bj_target
ex_bj_f
br
ex_mul_div_busy
operation_start
operation_issued
mul_busy / div_busy
```

## 3. 每一级“什么时候发生”

| 事件 | 波形判据 | 代码 |
|---|---|---|
| 提出取指地址 | `ifetch_req=1`，`ifetch_addr=PC` | `cpu_core.v:429-439` |
| AXI 接受读地址 | `ARVALID && ARREADY` | `axi_master.v:149-154` |
| AXI 返回指令 | `RVALID && RREADY` | `axi_master.v:157-168` |
| CPU 得到指令 | `ifetch_valid=1`，`ifetch_inst` 有效 | `cpu_top.v:95-97` |
| 进入 ID | 上升沿后 `id_valid=1`、`id_pc/id_inst` 更新 | `pipeline_regs.v:104-118` |
| ID 译码 | 同一周期观察 opcode、alu_op、ram_rop/wop、rf_wsel | `Controller.v` |
| 进入 EX | 下一上升沿后 `ex_valid=1`、`ex_pc` 等于该指令 PC | `pipeline_regs.v:154-207` |
| EX 运算 | 同周期观察 `alu_a/alu_b/alu_c`、前递选择、分支信号 | `cpu_core.v:327-384` |
| 进入 MEM | 下一上升沿后 `mem_valid=1`、`mem_pc` 对应指令 | `pipeline_regs.v:231-255` |
| 发出 load/store | `daccess_ren!=0` 或 `daccess_wen!=0` | `cpu_core.v:392-415` |
| 访存完成 | `daccess_rvalid=1` 或 `daccess_wresp=1` | `cpu_core.v:247-256` |
| 进入 WB | 完成后的上升沿后 `wb_valid=1` | `pipeline_regs.v:275-295` |
| 写寄存器 | 上升沿前 `wb_valid && wb_rf_we`，`wb_rd/rf_wD` 有效 | `RF.v:23-29` |

## 4. 取指到译码的完整解释

以地址 `0x00000008` 的 `addi x3,x2,1` 为例：

1. `pc/ifetch_addr=00000008`，`ifetch_req=1`；
2. Master 在 IDLE 接受 instruction read，锁存对齐地址，拉高 ARVALID；
3. `ARVALID && ARREADY` 的上升沿后进入 RDATA；
4. 等待期间 ARVALID 已撤销，RREADY 保持，流水线不能假设指令已到；
5. `RVALID && RREADY` 时，Master 锁存 RDATA=`00110193`，产生 CPU 侧
   `ifetch_valid` 单周期脉冲；
6. 该脉冲结束的上升沿，IF/ID 锁存：
   `id_pc=00000008`、`id_inst=00110193`、`id_valid=1`；
7. 接下来这个周期，Controller 组合译码：
   opcode=`0010011`，funct3=`000`，rs1=`x2`，rd=`x3`，EXT_I=1，
   ALU=ADD，WB=ALU；
8. 下一个上升沿后，`ex_pc=00000008`、`ex_rs1=2`、`ex_rd=3`，
   这条指令才进入 EX。

老师问“哪一拍译码”时，回答：

> 指令被 IF/ID 锁存后的整个周期进行组合译码；到下一上升沿，译码结果和操作数被
> ID/EX 锁存。译码不是一个额外独立的时钟沿脉冲。

## 5. 现有 load-use VCD 的指令

测试程序位于 `tests/pipeline_hazard_tb.v:62-68`：

| PC | 机器码 | 汇编 | 预期 |
|---:|---:|---|---:|
| `0x00` | `01000093` | `addi x1,x0,16` | x1=16 |
| `0x04` | `0000A103` | `lw x2,0(x1)` | x2=42 |
| `0x08` | `00110193` | `addi x3,x2,1` | x3=43 |
| `0x0C` | `00218213` | `addi x4,x3,2` | x4=45 |
| `0x10` | `0000006F` | `jal x0,0` | 原地循环 |

## 6. load-use 波形逐周期

阶段关系用逻辑周期表示，AXI 等待拍数用 `W` 表示：

| 周期 | IF | ID | EX | MEM | WB | 关键波形 |
|---|---|---|---|---|---|---|
| C1 | addi x1 |  |  |  |  | `ifetch_addr=0` |
| C2 | lw | addi x1 |  |  |  | ID 译码 ADDI |
| C3 | addi x3 | lw | addi x1 |  |  | lw 在 ID 读 x1 |
| C4 | 保持 | addi x3 | lw | addi x1 |  | `load_use_hazard=1`，`stall_if=1`，EX 下拍注入 bubble |
| C5 | 保持 | addi x3 | bubble | lw | addi x1 | `daccess_ren=F`，地址 0x10，进入 AXI 等待 |
| W1..Wn | 保持 | 保持 | 保持 | lw | 保持 | `memory_freeze=1`，`stall_if/id/ex/mem=1` |
| R | 恢复 | addi x3 | bubble | lw 完成 |  | `daccess_rvalid=1`，数据 42 |
| C6 | 下一条 |  | addi x3 |  | lw | `forward_a_sel=10`，从 WB 取得 x2=42 |
| C7 |  |  | addi x4 | addi x3 |  | `forward_a_sel=01`，从 MEM 取得 x3=43 |
| C8 |  |  |  | addi x4 | addi x3 | x3 写回 |
| C9 |  |  |  |  | addi x4 | x4 写回 45 |

必须指出的区别：

- C4 的 load-use：`stall_if=1`，但通过 `id_valid_for_ex=0` 向 EX 注入 bubble；
- W 阶段的 AXI wait：`effective_freeze=1`，活动流水级整体保持；
- C6 的 `forward_a_sel=10`：load 数据从 WB 前递；
- C7 的 `forward_a_sel=01`：普通 ALU 结果从 MEM 前递。

推荐波形图：
[流水线 load-use](../course-report/figures/06a_pipeline_load_use_hazard.png)。

## 7. 普通前递波形

直接打开：
`docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd`。

例子：

```asm
add  x3,x1,x2
sub  x4,x3,x5
and  x6,x7,x3
```

读图：

- sub 在 EX、add 在 MEM：`mem_rd=3`、`ex_rs1=3`、`mem_rf_we=1`，
  `forward_a_sel=01`；
- 如果生产者已到 WB：`wb_rd=3` 命中，`forward_a_sel=10`；
- MEM 与 WB 同时命中时选择 `01`，因为 MEM 是更新的生产者；
- `mem_is_load=1` 时 MEM 前递条件被禁止。

## 8. taken branch 波形

同样使用
`docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd`，其程序包含
taken `beq` 和一条必须被冲刷的错误路径 `addi x5,x0,99`。

建议分组：

```text
ex_pc ex_valid ex_npc_op
alu_a alu_b br
ex_bj_taken ex_bj_target ex_bj_f
flush
id_pc id_valid
ifetch_addr pc
ic_pending_word_addr ic_axi_valid ic2cpu_valid
```

逐步解释：

1. branch 到 EX，比较操作数已经过前递；
2. `br` 和 `ex_bj_taken` 在该周期组合产生；
3. `ex_bj_f=1` 后，`ifetch_addr` 组合选择 target；
4. 下一上升沿，PC 锁存 target，IF/ID 和 ID/EX 的 valid 被清 0；
5. 原来顺序路径的 AXI 取指可能仍返回；
6. `ic_pending_word_addr != cpu2ic_addr[31:2]`，所以 `ic2cpu_valid=0`；
7. target 的新请求被接受后，正常进入流水线。

不要把 `RVALID=1` 直接说成“旧指令执行了”。只有通过 pending-address 过滤并产生
`ifetch_valid`，再被 IF/ID 锁存，才会进入 core。

## 9. AXI 读波形

推荐图：[无 Cache AXI 读](../course-report/figures/06b_no_cache_axi_read.png)。

### 地址阶段

- 请求出现后，Master 锁存并对齐地址；
- `ARVALID=1` 表示地址有效；
- 若 `ARREADY=0`，ARADDR 和 ARVALID 必须保持；
- `ARVALID && ARREADY` 的上升沿完成地址握手。

### 数据阶段

- 地址握手后 `ARVALID` 撤销、`RREADY=1`；
- `RVALID=0` 可以等待任意拍；
- `RVALID && RREADY` 时 RDATA 才有本事务意义；
- Master 按 `read_is_data` 把数据送到取指或 load 端；
- CPU 侧 valid 是单拍脉冲。

老师若问“地址什么时候取”：说“ARVALID/ARREADY 握手时从机接受地址”，不是只看
ARADDR 改变。

## 10. AXI 写波形

推荐图：[无 Cache AXI 写](../course-report/figures/06c_no_cache_axi_write.png)。

1. Master 同时准备 AWADDR、WDATA、WSTRB，并拉 AWVALID/WVALID；
2. AWREADY 与 WREADY 可以不同拍；
3. 哪个先握手，哪个 VALID 先撤销，另一个通道继续保持；
4. 两个都完成后进入 WRESP，拉 BREADY；
5. `BVALID && BREADY` 表示写事务架构完成；
6. `daccess_wresp` 产生单拍，解除 memory freeze；
7. Trace 的 `debug_mem_we` 只在这拍脉冲一次。

数据有效性：

- 只在 `WVALID && WREADY` 讨论 WDATA/WSTRB；
- 只在 `AWVALID && AWREADY` 讨论 AWADDR；
- AW/W 先后顺序不改变它们属于同一笔单事务。

## 11. sb/sh/sw 波形

以地址低两位 offset 为准：

| 指令 | offset | WSTRB 示例 | WDATA 处理 |
|---|---:|---:|---|
| `sb` | 0/1/2/3 | 0001/0010/0100/1000 | 低 8 位移到对应 lane |
| `sh` | 0/1/2 | 0011/0110/1100 | 低 16 位移到对应 lane |
| `sw` | 0 | 1111 | 原 32 位 |

Master 的 AWADDR 清低两位，字节位置由 WSTRB 表示。

## 12. M 扩展波形

推荐分组：

```text
ex_pc ex_valid active_alu_op
fwd_a fwd_b
operation_start operation_issued
mul_busy/div_busy ex_mul_div_busy
stall_if stall_id stall_ex
alu_c
mem_pc mem_valid mem_alu_c
wb_pc wb_valid wb_rd rf_wD
```

解释顺序：

1. M 指令到 EX，源操作数先完成前递；
2. `operation_start=1` 的启动周期，`ex_mul_div_busy` 立即为 1；
3. 启动沿锁存 op、a、b，流水线被冻结，不能把旧 ALU 结果送入 EX/MEM；
4. worker busy 维持约 32 拍；
5. 完成后 worker busy 下降，`operation_issued` 仍让 ALU 输出本次结果；
6. 解除 stall 的下一上升沿，EX/MEM 锁存结果；
7. `operation_issued` 清零，允许下一条相同 M 指令启动；
8. dependent 指令从 MEM/WB 前递。

## 13. UART MMIO 波形

直接打开：
`docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd`。该定向测试同时包含
LED、数码管、switch、timer、UART TX `0x55` 和 UART RX `0x41`。

### 发送字符

软件向 `0xFFFF3004` store：

1. MEM 发 data write；
2. AWADDR=`FFFF3004`；
3. WDATA 低 8 位为字符，如 A=`41`；
4. WSTRB 至少 bit0=1；
5. board slave 在 write_accept 时产生 `uart_tx_start`；
6. simple_uart 发送低起始位、8 位 LSB-first 数据、高停止位；
7. `tx_busy` 期间状态寄存器 bit3=1，软件轮询等待。

### 接收字符

1. 原始 RX 出现低起始位；
2. 两级同步后的 `rx_sync[1]` 跟随；
3. RX 状态 IDLE→START→DATA→STOP；
4. 每个 bit 中部采样，A 得到 `rx_data=41`；
5. `rx_valid=1`，状态 bit0/bit1 置 1；
6. CPU 先 load `FFFF3008` 看到非空；
7. 再 load `FFFF3000`，slave 返回 41 并产生 `rx_pop`；
8. rx_valid 清零。

## 14. WB 和“指令完成”怎么判断

取指 PC 不是退休 PC。真正判断寄存器指令完成要看：

```text
wb_valid=1
wb_rf_we=1
wb_pc = 该指令 PC
wb_rd = 目标寄存器
rf_wD = 最终结果
```

store 没有 rd，判断完成看 `daccess_wresp`；Trace 中看
`debug_mem_we!=0` 的单拍。branch 通常不写寄存器，判断它的架构效果看重定向和
错误路径 valid 被清除。

## 15. 波形常见误读

### valid=0 时还看到旧控制信号

这是级间寄存器保持过的旧位，不代表指令有效。必须先看 valid。最终版还用
`active_alu_op = ex_valid ? ex_alu_op : ALU_ADD` 防止 bubble 重启 M 指令。

### PC 暂停就是死机

不一定。若 `memory_freeze=1` 或 `ex_mul_div_busy=1`，PC 正确保持。死机要看响应是否
最终到来，以及 stall 是否解除。

### RDATA 变化就是读完成

错误。只有 `RVALID && RREADY` 的拍才有效。

### WDATA 正确就代表写完成

错误。还要 AW/W 都握手，并收到 B 响应。

### `ifetch_valid=0` 就一定是存储器坏了

不一定。分支后过期 R 响应会被 cpu_top 故意过滤。

### `stall_if=1` 就等于所有级都停

不一定。load-use 时只保持前端并向 EX 注 bubble；`effective_freeze` 才让
ID/EX/MEM 相关级整体保持。

## 16. 严格验收回答模板

老师指某个波形区域时，按五句回答：

1. **当前是哪条指令**：用 stage PC + valid + inst/控制确认；
2. **现在在哪一级**：ID/EX/MEM/WB 的 PC 和 valid；
3. **为什么信号变化**：对应译码、冒险或 AXI 握手条件；
4. **下一个时钟沿会锁存什么**：明确哪个级保持、前进、注 bubble 或 flush；
5. **如何确认最终正确**：WB 写回、store response、target PC 或 CRC/测试结果。

示例：

> 这里 PC=8 的 `addi x3,x2,1` 在 ID，PC=4 的 lw 在 EX，rd=2 与当前 rs1=2
> 命中，所以 load_use_hazard 拉高。当前上升沿后 IF/ID 保持，ID/EX 的 valid 被
> 置 0 注入 bubble；lw 继续到 MEM 发 AXI 读。R 响应回来后 lw 到 WB，addi 在 EX
> 通过 forward_a_sel=10 取到 42，最终 WB 写 x3=43。
