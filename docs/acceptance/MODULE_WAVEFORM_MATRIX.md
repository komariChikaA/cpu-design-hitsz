# 验收模块—代码—波形一体化索引

> 用途：老师指定某一项验收后，从同一小节依次打开“实现代码 → 原始 VCD →
> 标注图 → PASS/实板证据”，避免代码、波形和结论互相脱节。
>
> 完整性检查：在仓库根目录运行
> `powershell -ExecutionPolicy Bypass -File docs/acceptance/verify-acceptance-bundle.ps1`。

## 0. 证据使用原则

1. 原始 `.vcd` 是可复核的仿真证据，PNG/SVG 是便于讲解的标注图；
2. Trace 日志证明整套 RTL 对指令测试的最终结果，单条 VCD 用来解释某条指令；
3. C_TEST 和 CoreMark 是长程序，不把一小段定向仿真冒充完整程序全程波形；
4. C_TEST 用相关的 load/store、AXI、UART/MMIO 波形解释机制，以串口和实板照片证明结果；
5. CoreMark 用流水线冒险、AXI、M 扩展波形解释机制，以 CRC validated 和实板结果证明运行；
6. 单周期与历史流水线 AXI 项仍使用无 Cache 证据；最终 EGO1 流水线分支已实现
   ICache/DCache，必须使用新增 Cache/AXI burst VCD，并把旧实板结果标为基线。

## 1. 单周期 AXI Trace

### 1.1 验收模块

- [`miniRV_singlecycle_axi/src/rtl/cpu_core.v`](../../miniRV_singlecycle_axi/src/rtl/cpu_core.v)：
  单周期译码、执行和访存请求；
- [`miniRV_singlecycle_axi/src/rtl/cpu_top.v`](../../miniRV_singlecycle_axi/src/rtl/cpu_top.v)：
  CPU 请求与 AXI Master 的边界；
- [`miniRV_singlecycle_axi/src/rtl/axi_master.v`](../../miniRV_singlecycle_axi/src/rtl/axi_master.v)：
  AR/R、AW/W/B 五通道状态机；
- [`miniRV_singlecycle_axi/src/rtl/miniRV_SoC.v`](../../miniRV_singlecycle_axi/src/rtl/miniRV_SoC.v)：
  Trace 测试顶层。

### 1.2 与本项绑定的波形

- 45 份单指令 VCD：见本文末尾“原始 VCD 全清单”；
- [`06_no_cache_axi_transaction.vcd`](../course-report/vcd/06_no_cache_axi_transaction.vcd)：
  AXI 地址、数据、响应握手机制；
- [AXI 读标注图](../course-report/figures/06b_no_cache_axi_read.png)；
- [AXI 写标注图](../course-report/figures/06c_no_cache_axi_write.png)。

说明：45 份单指令 VCD负责解释译码、ALU、访存宽度和写回；AXI 定向 VCD负责解释
总线协议；[单周期 AXI Trace 日志](../../trace_test/miniRV_AXI_run_all_tests.log)
才是本模块端到端 45/45 的判据。不要把其中任意一份定向波形单独说成整套 AXI
Trace。

### 1.3 现场讲解链

1. 在单指令 VCD 中指出 `PC`、指令、寄存器源操作数、ALU 结果和写回；
2. 对 load/store 再指出地址、写数据、字节使能和读回数据；
3. 切到 AXI VCD，按 `VALID && READY` 解释地址/数据握手；
4. 最后打开 [45/45 报告](../../trace_test/miniRV_AXI_report.md)。

## 2. 流水线 Basic Trace

### 2.1 验收模块

- [`miniRV_pipeline/src/rtl/cpu_core.v`](../../miniRV_pipeline/src/rtl/cpu_core.v)：
  五级控制、冒险、暂停与冲刷；
- [`pipeline_regs.v`](../../miniRV_pipeline/src/rtl/pipeline/pipeline_regs.v)：
  IF/ID、ID/EX、EX/MEM、MEM/WB；
- [`forward_unit.v`](../../miniRV_pipeline/src/rtl/pipeline/forward_unit.v)：
  MEM/WB 前递优先级；
- [`ALU_multicycle.v`](../../miniRV_pipeline/src/rtl/pipeline/ALU_multicycle.v)：
  M 扩展长延迟冻结。

### 2.2 与本项绑定的波形

- [`06_pipeline_load_use_hazard.vcd`](../course-report/vcd/06_pipeline_load_use_hazard.vcd)；
- [load-use 标注图](../course-report/figures/06a_pipeline_load_use_hazard.png)；
- 具体普通指令可从本文末尾打开对应的单指令 VCD，辅助解释运算语义；
- [流水线数据通路图](../course-report/figures/04_pipeline_datapath.png)。

### 2.3 现场讲解链

1. 先看每一级 `valid + PC`，判断真实指令处在哪一级；
2. PC=4 的 `lw x2,0(x1)` 在 EX，PC=8 的 `addi x3,x2,1` 在 ID；
3. `load_use_hazard=1` 后 PC 和 IF/ID 保持，ID/EX 注入 invalid bubble；
4. load 数据到 WB 后，`forward_a_sel=10` 将 42 前递给 addi；
5. 最后打开 [Basic Trace 45/45 报告](../../trace_test/miniRV_pipeline_report.md)。

## 3. 流水线 AXI Trace

### 3.1 验收模块

- [`miniRV_pipeline_axi/src/rtl/cpu_core.v`](../../miniRV_pipeline_axi/src/rtl/cpu_core.v)：
  流水线核心；
- [`miniRV_pipeline_axi/src/rtl/cpu_top.v`](../../miniRV_pipeline_axi/src/rtl/cpu_top.v)：
  AXI 响应拍防重和取指请求管理；
- [`miniRV_pipeline_axi/src/rtl/axi_master.v`](../../miniRV_pipeline_axi/src/rtl/axi_master.v)：
  读写状态机与仲裁；
- [`miniRV_pipeline_axi/src/rtl/miniRV_SoC.v`](../../miniRV_pipeline_axi/src/rtl/miniRV_SoC.v)：
  AXI Trace 顶层。

### 3.2 与本项绑定的波形

- [`06_pipeline_load_use_hazard.vcd`](../course-report/vcd/06_pipeline_load_use_hazard.vcd)：
  core 内部停顿和恢复；
- [`06_no_cache_axi_transaction.vcd`](../course-report/vcd/06_no_cache_axi_transaction.vcd)：
  AXI 读写五通道握手；
- [AXI 读标注图](../course-report/figures/06b_no_cache_axi_read.png)；
- [AXI 写标注图](../course-report/figures/06c_no_cache_axi_write.png)；
- [AXI 状态机图](../course-report/figures/05_axi_state_machine.png)。

### 3.3 现场讲解链

1. core 发出 `ifetch_req` 或 `daccess_req`，但请求不等于已完成；
2. `ARVALID && ARREADY` 接受读地址，`RVALID && RREADY` 接受读数据；
3. 写事务分别观察 AW、W、B 三次握手，AW/W 不要求同拍；
4. 数据访问等待期间冻结需要保持的流水级；
5. taken branch 后，`cpu_top` 用 pending 地址过滤旧路径取指响应；
6. 最后打开 [流水线 AXI Trace 45/45 报告](../../trace_test/miniRV_pipeline_axi_report.md)。

## 4. 单周期 C_TEST0～2

### 4.1 验收模块

- [`axi_board_soc.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/axi_board_soc.v)：
  BRAM、UART、LED、数码管和计时器地址译码；
- [`simple_uart.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/simple_uart.v)：
  115200 baud 收发；
- [`0_uart_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/0_uart_test/main.c)；
- [`1_formatIO_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/1_formatIO_test/main.c)；
- [`2_sort_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/2_sort_test/main.c)。

### 4.2 与本项绑定的波形和实板证据

| 验收 | 机制波形 | 最终结果证据 |
|---|---|---|
| C_TEST0 UART | [`sb.vcd`](../../waveform/single/sb.vcd)、[`lw.vcd`](../../waveform/single/lw.vcd)、[AXI 写](../course-report/figures/06c_no_cache_axi_write.png)、[AXI 读](../course-report/figures/06b_no_cache_axi_read.png) | [串口终端](../course-report/board-evidence/singlecycle/ctest0/uart-terminal.png)、[板卡运行](../course-report/board-evidence/singlecycle/ctest0/uart-running.jpg) |
| C_TEST1 格式化 I/O | [`div.vcd`](../../waveform/single/div.vcd)、[`rem.vcd`](../../waveform/single/rem.vcd)、[`sw.vcd`](../../waveform/single/sw.vcd) | [终端结果](../course-report/board-evidence/singlecycle/ctest1/terminal.png)、[板卡结果](../course-report/board-evidence/singlecycle/ctest1/board-3.jpg) |
| C_TEST2 排序/动态内存 | [`lw.vcd`](../../waveform/single/lw.vcd)、[`sw.vcd`](../../waveform/single/sw.vcd)、[`blt.vcd`](../../waveform/single/blt.vcd) | [终端 1](../course-report/board-evidence/singlecycle/ctest2/terminal-1.png)、[终端 2](../course-report/board-evidence/singlecycle/ctest2/terminal-2.png)、[终端 3](../course-report/board-evidence/singlecycle/ctest2/terminal-3.png) |

C_TEST 是长程序，现有仓库没有三份“程序全程 VCD”。验收时应把上表波形称作该程序
所依赖机制的定向证据，把串口、LED、数码管和报告称作完整程序结果证据。

## 5. 流水线 CoreMark

### 5.1 验收模块

- [`miniRV_pipeline_axi_ego1/src/rtl/cpu_core.v`](../../miniRV_pipeline_axi_ego1/src/rtl/cpu_core.v)；
- [`cpu_top.v`](../../miniRV_pipeline_axi_ego1/src/rtl/cpu_top.v)；
- [`ICache.v`](../../miniRV_pipeline_axi_ego1/src/rtl/ICache.v)；
- [`DCache.v`](../../miniRV_pipeline_axi_ego1/src/rtl/DCache.v)；
- [`axi_master.v`](../../miniRV_pipeline_axi_ego1/src/rtl/axi_master.v)；
- [`axi_board_soc.v`](../../miniRV_pipeline_axi_ego1/src/rtl/axi_board_soc.v)；
- [`pipeline_regs.v`](../../miniRV_pipeline_axi_ego1/src/rtl/pipeline/pipeline_regs.v)；
- [`forward_unit.v`](../../miniRV_pipeline_axi_ego1/src/rtl/pipeline/forward_unit.v)；
- [`ALU_multicycle.v`](../../miniRV_pipeline_axi_ego1/src/rtl/pipeline/ALU_multicycle.v)。

### 5.2 与本项绑定的波形和实板证据

- 流水线相关：[`06_pipeline_load_use_hazard.vcd`](../course-report/vcd/06_pipeline_load_use_hazard.vcd)；
- Cache 内部：[`10_cache_refill_hit_uncached.vcd`](../course-report/vcd/10_cache_refill_hit_uncached.vcd)；
- AXI 四拍 refill：[`08_axi_cacheline_burst.vcd`](../course-report/vcd/08_axi_cacheline_burst.vcd)；
- 板端 burst/MMIO：[`09_board_peripheral_mmio_uart.vcd`](../course-report/vcd/09_board_peripheral_mmio_uart.vcd)；
- M 扩展：[`mul.vcd`](../../waveform/single/mul.vcd)、
  [`mulh.vcd`](../../waveform/single/mulh.vcd)、
  [`mulhu.vcd`](../../waveform/single/mulhu.vcd)、
  [`div.vcd`](../../waveform/single/div.vcd)、
  [`divu.vcd`](../../waveform/single/divu.vcd)、
  [`rem.vcd`](../../waveform/single/rem.vcd)、
  [`remu.vcd`](../../waveform/single/remu.vcd)；
- [无 Cache CoreMark 串口结果](../course-report/board-evidence/coremark/serial-result.png)；
- [Cache CoreMark 结果抄录](../course-report/board-evidence/coremark/cache-result.md)；
- [无 Cache C0DE600D 板卡结果](../course-report/board-evidence/coremark/board-2.jpg)；
- [无 Cache 实现状态与 WNS](../course-report/board-evidence/pipeline/implementation-status.png)。

CoreMark 全程波形会非常大，当前没有上传。Cache 定向 VCD证明机制，当前 Cache
课程 AXI Trace 已通过 45/45；Cache 版实板 CoreMark 已得到 48.814 CoreMark、
0.976 CoreMark/MHz，CRC validated 并到达 `FINISH`。旧 `serial-result.png`、
`C0DE600D` 照片和 WNS 1.702 ns 仍只证明无 Cache 基线；Cache 版原始串口 PNG、
Timing/Utilization/DRC、bitstream 和板卡照片尚待归档。

## 6. 原始 VCD 全清单（52/52）

以下链接均指向 Git 跟踪的原始 VCD，不是只有截图。

### 6.1 启动、控制转移和比较（12）

- [`start.vcd`](../../waveform/single/start.vcd)
- [`auipc.vcd`](../../waveform/single/auipc.vcd)
- [`lui.vcd`](../../waveform/single/lui.vcd)
- [`jal.vcd`](../../waveform/single/jal.vcd)
- [`jalr.vcd`](../../waveform/single/jalr.vcd)
- [`beq.vcd`](../../waveform/single/beq.vcd)
- [`bne.vcd`](../../waveform/single/bne.vcd)
- [`blt.vcd`](../../waveform/single/blt.vcd)
- [`bltu.vcd`](../../waveform/single/bltu.vcd)
- [`bge.vcd`](../../waveform/single/bge.vcd)
- [`bgeu.vcd`](../../waveform/single/bgeu.vcd)
- [`slt.vcd`](../../waveform/single/slt.vcd)

### 6.2 整数运算与立即数（18）

- [`add.vcd`](../../waveform/single/add.vcd)
- [`addi.vcd`](../../waveform/single/addi.vcd)
- [`sub.vcd`](../../waveform/single/sub.vcd)
- [`and.vcd`](../../waveform/single/and.vcd)
- [`andi.vcd`](../../waveform/single/andi.vcd)
- [`or.vcd`](../../waveform/single/or.vcd)
- [`ori.vcd`](../../waveform/single/ori.vcd)
- [`xor.vcd`](../../waveform/single/xor.vcd)
- [`xori.vcd`](../../waveform/single/xori.vcd)
- [`sll.vcd`](../../waveform/single/sll.vcd)
- [`slli.vcd`](../../waveform/single/slli.vcd)
- [`srl.vcd`](../../waveform/single/srl.vcd)
- [`srli.vcd`](../../waveform/single/srli.vcd)
- [`sra.vcd`](../../waveform/single/sra.vcd)
- [`srai.vcd`](../../waveform/single/srai.vcd)
- [`sltu.vcd`](../../waveform/single/sltu.vcd)
- [`slti.vcd`](../../waveform/single/slti.vcd)
- [`sltiu.vcd`](../../waveform/single/sltiu.vcd)

### 6.3 Load/store（8）

- [`lb.vcd`](../../waveform/single/lb.vcd)
- [`lbu.vcd`](../../waveform/single/lbu.vcd)
- [`lh.vcd`](../../waveform/single/lh.vcd)
- [`lhu.vcd`](../../waveform/single/lhu.vcd)
- [`lw.vcd`](../../waveform/single/lw.vcd)
- [`sb.vcd`](../../waveform/single/sb.vcd)
- [`sh.vcd`](../../waveform/single/sh.vcd)
- [`sw.vcd`](../../waveform/single/sw.vcd)

### 6.4 M 扩展（7）

- [`mul.vcd`](../../waveform/single/mul.vcd)
- [`mulh.vcd`](../../waveform/single/mulh.vcd)
- [`mulhu.vcd`](../../waveform/single/mulhu.vcd)
- [`div.vcd`](../../waveform/single/div.vcd)
- [`divu.vcd`](../../waveform/single/divu.vcd)
- [`rem.vcd`](../../waveform/single/rem.vcd)
- [`remu.vcd`](../../waveform/single/remu.vcd)

### 6.5 流水线、AXI 和外设定向波形（4）

- [`06_pipeline_load_use_hazard.vcd`](../course-report/vcd/06_pipeline_load_use_hazard.vcd)
- [`07_pipeline_five_stage_forward_branch.vcd`](../course-report/vcd/07_pipeline_five_stage_forward_branch.vcd)
- [`06_no_cache_axi_transaction.vcd`](../course-report/vcd/06_no_cache_axi_transaction.vcd)
- [`09_board_peripheral_mmio_uart.vcd`](../course-report/vcd/09_board_peripheral_mmio_uart.vcd)

## 7. 老师临时指定指令时怎么用

例如老师问 `lw x2,0(x1)`：

1. 打开 [`lw.vcd`](../../waveform/single/lw.vcd)，解释立即数扩展、地址计算、读数据和写回；
2. 打开 [`06_pipeline_load_use_hazard.vcd`](../course-report/vcd/06_pipeline_load_use_hazard.vcd)，
   解释下一条使用 x2 时为何必须 bubble；
3. 打开 [`06_no_cache_axi_transaction.vcd`](../course-report/vcd/06_no_cache_axi_transaction.vcd)，
   解释地址请求怎样通过 AR/R 返回；
4. 根据当前验收项打开对应 `cpu_core.v`、`cpu_top.v` 和 `axi_master.v`；
5. 最后用相应的 45/45 日志或实板结果收尾。

这样一条具体指令同时覆盖了“指令语义、流水级、冒险、总线和最终证据”。
