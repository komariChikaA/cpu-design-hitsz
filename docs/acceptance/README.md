# miniRV 五项验收讲稿

> 适用项目：单周期 AXI、五级流水线 Basic、五级流水线 AXI、单周期
> C_TEST0～2、流水线 CoreMark
> 小组学号：`2024311081_2024311453`
> 推荐现场入口：双击同目录的 `open-acceptance.cmd`，默认打开最终 CoreMark 版
> [`coremark-pipeline.html`](./coremark-pipeline.html)。严格代码追问看
> [`COREMARK_PIPELINE_AXI_DEFENSE.md`](./COREMARK_PIPELINE_AXI_DEFENSE.md)，波形追问看
> [`WAVEFORM_DEFENSE.md`](./WAVEFORM_DEFENSE.md)。五项完整留档仍在
> [`index.html`](./index.html)。每项验收与具体代码、原始 VCD、标注图和结果证据的
> 对照关系见
> [`module-waveforms.html`](./module-waveforms.html)，其可打印 Markdown 版本为
> [`MODULE_WAVEFORM_MATRIX.md`](./MODULE_WAVEFORM_MATRIX.md)。下一次验收前用于系统
> 学习最终 CoreMark 版本的材料见
> [`training/miniRV_CoreMark流水线AXI_代码与波形自学手册.html`](./training/miniRV_CoreMark流水线AXI_代码与波形自学手册.html)
> 和
> [`training/miniRV_CoreMark流水线AXI_代码与波形自学手册.pdf`](./training/miniRV_CoreMark流水线AXI_代码与波形自学手册.pdf)。

## 0. 验收目标与顺序

本次不是只展示“程序能跑”，而是按 **结构 → 代码 → 波形/Trace → 实板结果**
形成证据闭环：

| 顺序 | 验收项 | 核心证明 | 已有证据 |
|---:|---|---|---|
| 1 | 单周期 AXI Trace | 单周期 CPU 经无 Cache AXI Master 正确取指、读写 | 45/45 Trace 日志、AXI 状态机与读写波形 |
| 2 | 流水线 Basic Trace | 五级流水、前递、暂停、冲刷和 M 扩展正确 | 45/45 Trace 日志、数据通路图、load-use 波形 |
| 3 | 流水线 AXI Trace | 流水线在 AXI 延迟下不会重复提交或接受过期取指 | 45/45 Trace 日志、AXI 波形、关键修复代码 |
| 4 | 单周期 C_TEST0～2 | CPU、AXI、BRAM、UART、LED、数码管和计时器在 EGO1 上联调通过 | 三项实板照片、终端截图、Timing/Utilization/Power 报告 |
| 5 | 流水线 CoreMark | RV32IM 流水线持续执行、长延迟运算、AXI/MMIO 与计时正确 | CoreMark 有效结果、实板照片、实现状态截图 |

推荐总时长约 15 分钟：

1. 1 分钟：总览两条数据通路；
2. 2 分钟：单周期 AXI Trace；
3. 3 分钟：流水线 Basic Trace；
4. 3 分钟：流水线 AXI Trace；
5. 3 分钟：单周期 C_TEST0～2；
6. 2 分钟：流水线 CoreMark；
7. 1 分钟：总结与回答问题。

现场总原则：

- Trace 证明 RTL 功能，不等同于 Vivado 或实板通过；
- 实板照片证明曾经跑通，现场仍要准备工程、匹配源码的 bitstream 和串口；
- 本设计目前 **没有 Cache**，AXI 图解释为总线读写，不能说成 Cache miss；
- 先讲数据通路，再打开代码和波形，最后给出 PASS/实板结果。

上传前在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File docs/acceptance/verify-acceptance-bundle.ps1
```

脚本必须显示 `Raw VCD files: 47` 和最终 `PASS`，这样可确认验收模块、Trace
报告、47 份原始波形以及关键图片全部存在并已被 Git 跟踪。

## 1. 总体结构怎么讲

先打开：

- [单周期数据通路图](../course-report/figures/01_singlecycle_datapath.png)
- [流水线数据通路图](../course-report/figures/04_pipeline_datapath.png)

讲解词：

> 单周期版本在一条指令的控制周期内完成译码、运算和访存请求；CPU 外部使用
> ifetch/daccess 请求响应接口，再由 AXI Master 转成五通道握手。流水线版本把执行
> 分成 IF、ID、EX、MEM、WB 五级，增加四组带 valid 的流水寄存器，以及前递、暂停
> 和冲刷逻辑。AXI 仍被隔离在 cpu_top/axi_master 一侧，cpu_core 不直接处理五通道，
> 因此 Basic 和 AXI 两种后端可以分别验收。

如果老师问“你们主要做了什么”，回答：

> 我们完成了单周期 AXI 接入、五级流水化、流水线 AXI 集成和 EGO1 板级 SoC。
> 最难的不是连线，而是处理总线延迟和流水线状态的组合：load-use 冒险、M 扩展长延迟、
> 分支后的过期取指响应，以及 AXI 响应拍内旧请求重复发起。我们用三组 45/45 Trace、
> 定向波形、C_TEST0～2 和 CoreMark 实板结果交叉验证。

## 2. 单周期 AXI Trace

### 2.1 现场操作

先按 [`miniRV_singlecycle_axi/README.md`](../../miniRV_singlecycle_axi/README.md)
中的 AXI Trace 三步准备 RTL，再在 Linux 服务器执行：

```bash
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

如果现场只复核已有结果，打开：

- [`trace_test/miniRV_AXI_report.md`](../../trace_test/miniRV_AXI_report.md)
- [`trace_test/miniRV_AXI_run_all_tests.log`](../../trace_test/miniRV_AXI_run_all_tests.log)

通过判据：汇总显示 `Passed Tests (45)`、`Failed Tests (0)`，并且使用的是
AXI Trace 的 `bram_axi` 层级。

### 2.2 代码入口

按这个顺序打开：

1. [`miniRV_singlecycle_axi/src/rtl/cpu_core.v`](../../miniRV_singlecycle_axi/src/rtl/cpu_core.v)：
   产生 ifetch/daccess 请求；
2. [`miniRV_singlecycle_axi/src/rtl/cpu_top.v`](../../miniRV_singlecycle_axi/src/rtl/cpu_top.v)：
   CPU 与 AXI Master 的边界；
3. [`miniRV_singlecycle_axi/src/rtl/axi_master.v`](../../miniRV_singlecycle_axi/src/rtl/axi_master.v)：
   `ST_IDLE`、`ST_RADDR`、`ST_RDATA`、`ST_WSEND`、`ST_WRESP`；
4. [`miniRV_singlecycle_axi/src/rtl/miniRV_SoC.v`](../../miniRV_singlecycle_axi/src/rtl/miniRV_SoC.v)：
   Trace 下的 `bram_axi U_bram` 层级。

### 2.3 波形怎么解释

打开：

- [无 Cache AXI 读事务](../course-report/figures/06b_no_cache_axi_read.png)
- [无 Cache AXI 写事务](../course-report/figures/06c_no_cache_axi_write.png)
- [AXI Master 状态机](../course-report/figures/05_axi_state_machine.png)

读事务讲解：

> CPU 给出读地址后，Master 在 `ST_RADDR` 保持 `ARVALID`，直到与 `ARREADY`
> 握手；随后进入 `ST_RDATA`，保持 `RREADY` 等待 `RVALID`。只有读数据握手完成
> 才产生一次 CPU 侧响应。总线等待期间地址和控制保持稳定。

写事务讲解：

> AXI 的 AW 和 W 是独立通道，所以 `ST_WSEND` 分别记录地址与数据是否握手，
> 两者都完成后才进入 `ST_WRESP` 等待 `BVALID`。`WSTRB` 由 sb/sh/sw 决定，
> 写响应完成才算一次架构写操作结束。

### 2.4 一句话结论

> 单周期 AXI Trace 45/45 证明完整 RV32IM 指令集合在无 Cache、可等待的 AXI
> 访存路径上功能正确。

## 3. 流水线 Basic Trace

### 3.1 现场操作

```bash
bash miniRV_pipeline/prepare_trace.sh ~/cdp-tests
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

已有结果：

- [`trace_test/miniRV_pipeline_report.md`](../../trace_test/miniRV_pipeline_report.md)
- [`trace_test/miniRV_pipeline_run_all_tests.log`](../../trace_test/miniRV_pipeline_run_all_tests.log)

通过判据：`45/45`、`Failed Tests (0)`；工程中没有 `axi_master/bram_axi`，
因此这是 Basic Trace。

### 3.2 五级流水与关键代码

先用[流水线数据通路图](../course-report/figures/04_pipeline_datapath.png)说明：

```text
IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM → MEM/WB → WB
```

然后打开：

- [`miniRV_pipeline/src/rtl/pipeline/pipeline_regs.v`](../../miniRV_pipeline/src/rtl/pipeline/pipeline_regs.v)：
  四组带 `valid` 的流水寄存器；
- [`miniRV_pipeline/src/rtl/pipeline/forward_unit.v`](../../miniRV_pipeline/src/rtl/pipeline/forward_unit.v)：
  EX/MEM、MEM/WB 前递选择；
- [`miniRV_pipeline/src/rtl/cpu_core.v`](../../miniRV_pipeline/src/rtl/cpu_core.v)：
  `load_use_hazard`、`stall_*`、`flush` 和写回提交；
- [`miniRV_pipeline/src/rtl/pipeline/ALU_multicycle.v`](../../miniRV_pipeline/src/rtl/pipeline/ALU_multicycle.v)：
  多周期乘除法。

### 3.3 load-use 波形怎么解释

打开 [load-use 冒险波形](../course-report/figures/06a_pipeline_load_use_hazard.png)。

讲解词：

> 当前一条 load 还在 EX、下一条指令在 ID 立即使用其 rd 时，数据尚未能从
> EX/MEM 前递，因此 `load_use_hazard` 拉高。PC 与 IF/ID 保持一拍，ID/EX 写入
> 空泡。load 到达 MEM/WB 后，下一条指令重新进入 EX，并从写回路径取得正确值。
> 普通 ALU 相关不需要停顿，由前递单元直接解决。

分支讲解：

> 分支或 JAL/JALR 在 EX 得到重定向结果，`flush` 清除错误路径上的年轻指令，
> PC 转向目标地址。提交级 Trace 来自 MEM/WB，因此被冲刷的指令不会被报告为退休。

### 3.4 一句话结论

> Basic Trace 45/45 证明流水级划分、前递、暂停、冲刷和 RV32IM 提交语义正确。

## 4. 流水线 AXI Trace

### 4.1 现场操作

```bash
bash miniRV_pipeline_axi/prepare_trace.sh ~/cdp-tests
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

本地定向回归：

```bash
bash miniRV_pipeline_axi/tests/run_iverilog.sh
```

已有结果：

- [`trace_test/miniRV_pipeline_axi_report.md`](../../trace_test/miniRV_pipeline_axi_report.md)
- [`trace_test/miniRV_pipeline_axi_run_all_tests.log`](../../trace_test/miniRV_pipeline_axi_run_all_tests.log)

通过判据：AXI Trace `45/45`，`Failed Tests (0)`。

### 4.2 为什么不能只把 AXI Master 接上

讲解词：

> Basic 存储器近似零延迟，而 AXI 响应可能晚很多拍。等待期间流水线必须冻结；
> 分支发生时可能还有旧 PC 的取指在途；AXI Master 返回 IDLE 与 CPU 撤销请求之间
> 还有一个时钟边界，如果不屏蔽就会重复发起同一笔事务。所以 AXI 集成的关键是
> “请求只接受一次、响应只提交一次、过期响应必须丢弃”。

代码入口：

1. [`miniRV_pipeline_axi/src/rtl/cpu_core.v`](../../miniRV_pipeline_axi/src/rtl/cpu_core.v)：
   `memory_freeze`、`effective_freeze`，写事务仅在 `daccess_wresp` 时产生
   `debug_mem_we`；
2. [`miniRV_pipeline_axi/src/rtl/cpu_top.v`](../../miniRV_pipeline_axi/src/rtl/cpu_top.v)：
   响应脉冲期间屏蔽旧请求，校验在途取指是否仍属于当前 PC；
3. [`miniRV_pipeline_axi/src/rtl/axi_master.v`](../../miniRV_pipeline_axi/src/rtl/axi_master.v)：
   单事务 AXI 状态机；
4. [`miniRV_pipeline_axi/src/rtl/pipeline/forward_unit.v`](../../miniRV_pipeline_axi/src/rtl/pipeline/forward_unit.v)：
   AXI 等待解除后继续使用正确操作数。

### 4.3 用什么波形回答老师

再次打开 AXI 读写波形：

- 读：地址握手后等待数据，流水线保持；
- 写：AW/W 可不同拍握手，B 响应到达才释放；
- load-use：这是流水线内部数据冒险；
- AXI wait：这是外部存储器未完成，冻结范围比单个 load-use 气泡更大。

如果问“第一次为什么只有 41 项”，回答：

> sh、start、sw、sb 暴露了重复事务。AXI 响应出现时 Master 已能回到 IDLE，
> 但流水线在下一时钟沿才撤销旧请求，导致同一 store 可能再次被接受。修复后在响应
> 脉冲屏蔽旧请求，并让 `debug_mem_we` 只在写响应完成时脉冲一次，最终 45/45。

### 4.4 一句话结论

> 流水线 AXI Trace 45/45 证明流水线在可变 AXI 延迟、分支重定向和字节写场景下
> 仍保持精确的一次提交语义。

## 5. 单周期 C_TEST0～2

### 5.1 共用构建流程

程序已经用双学号编译。重新生成时：

```bash
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 0_uart_test
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 1_formatIO_test
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 2_sort_test
```

实验室 Windows 工程中每次选择一个程序：

```powershell
.\prepare_program.ps1 0_uart_test
```

然后在 Vivado Tcl Console：

```tcl
source rebuild_ego1.tcl
```

确认 `EGO1 build finished.`、`WNS >= 0`、`TNS = 0`、Failing Endpoints 为 0，
再烧录 `miniRV.runs/impl_1/miniRV_SoC.bit`。串口为 `115200 8N1`、无流控，
按 `S6 RST`，不要按 `S5 PROG#`。

板级代码入口：

- [`miniRV_singlecycle_axi_ego1/src/rtl/axi_board_soc.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/axi_board_soc.v)：
  BRAM 与 MMIO 地址译码；
- [`miniRV_singlecycle_axi_ego1/src/rtl/simple_uart.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/simple_uart.v)：
  UART 收发；
- [`miniRV_singlecycle_axi_ego1/src/rtl/sevenseg_display.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/sevenseg_display.v)：
  八位数码管；
- [`miniRV_singlecycle_axi_ego1/src/rtl/axi_master.v`](../../miniRV_singlecycle_axi_ego1/src/rtl/axi_master.v)：
  CPU 请求到 AXI 的桥接。

### 5.2 C_TEST0：UART 与基础 MMIO

程序：
[`software/c_test/0_uart_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/0_uart_test/main.c)

操作与判据：

1. 任意拨码开关置 1，复位；
2. 串口出现双学号、`Test #0`、`Hello World!`；
3. 输入 `A`，回显 `Input received: A`；
4. 数码管为 `00000041`，LED 显示 ASCII 低位；
5. 拨码全部置 0，再输入字符，出现 `Test ended.`。

证据：

- [串口终端](../course-report/board-evidence/singlecycle/ctest0/uart-terminal.png)
- [板卡与串口同框](../course-report/board-evidence/singlecycle/ctest0/uart-running.jpg)
- [实现状态](../course-report/board-evidence/singlecycle/ctest0/implementation-status-1.png)

### 5.3 C_TEST1：格式化输入输出

程序：
[`software/c_test/1_formatIO_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/1_formatIO_test/main.c)

依次输入：

```text
123 x hello
-42 y again
0 q end
```

判据：

- `123` 时数码管 `0000007B`；
- `-42` 时最低位 LED 点亮、数码管 `0000002A`；
- `0 q end` 后输出 `Test ended.`。

证据：

- [C_TEST1 终端](../course-report/board-evidence/singlecycle/ctest1/terminal.png)
- [C_TEST1 板卡](../course-report/board-evidence/singlecycle/ctest1/board-2.jpg)
- [C_TEST1 实现状态](../course-report/board-evidence/singlecycle/ctest1/implementation-status-1.png)

### 5.4 C_TEST2：排序、计时与动态内存

程序：
[`software/c_test/2_sort_test/main.c`](../../miniRV_singlecycle_axi_ego1/software/c_test/2_sort_test/main.c)

固定数组输入：

```text
8 3 -1 7 0 2 5 4
```

应输出 `-1 0 2 3 4 5 7 8` 和排序用时。动态数组阶段输入 `16`，应完成生成、
排序与打印，并显示 `malloc released.`。

证据：

- [固定数组与计时](../course-report/board-evidence/singlecycle/ctest2/terminal-1.png)
- [动态数组](../course-report/board-evidence/singlecycle/ctest2/terminal-2.png)
- [释放完成](../course-report/board-evidence/singlecycle/ctest2/terminal-3.png)
- [C_TEST2 实现状态](../course-report/board-evidence/singlecycle/ctest2/implementation-status-1.png)

### 5.5 一句话结论

> C_TEST0～2 把单周期 CPU、AXI、统一 BRAM、UART 双向通信、LED/数码管 MMIO、
> 计时器、格式化 I/O、排序和动态内存放到真实 EGO1 上联调，三项均有实板与实现证据。

## 6. 流水线 CoreMark

### 6.1 现场流程

完整步骤见
[`miniRV_pipeline_axi_ego1/START_COREMARK_ACCEPTANCE.md`](../../miniRV_pipeline_axi_ego1/START_COREMARK_ACCEPTANCE.md)。

重新选择 CoreMark：

```bash
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 4_coremark
```

Vivado Tcl Console：

```tcl
source rebuild_ego1.tcl
```

烧录后按 `S6 RST`，串口 `115200 8N1`。等待约 32 秒，直到输出 `FINISH`，
数码管应显示 `C0DE600D`。

### 6.2 结果怎么讲

实板结果：

```text
CoreMark Size    : 666
Total ticks      : 1647025964
Total time (secs): 32
Iterations/Sec   : 21
Iterations       : 700
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x65c5
Correct operation validated.
CoreMark 1.0 : 21.250
CoreMark/MHz : 0.425
FINISH
```

解释：

> 有效性比单一分数更重要。运行超过 10 秒，迭代数为 700，四组 CRC 与参考值一致，
> 输出 `Correct operation validated`，没有 `Errors detected`。这说明流水线在较长
> 连续负载下，控制流、访存、乘除法、计时器和 UART 输出均保持正确。当前 50 MHz
> 得分是 21.250，CoreMark/MHz 为 0.425。

证据：

- [CoreMark 串口完整结果](../course-report/board-evidence/coremark/serial-result.png)
- [CoreMark 板卡状态 1](../course-report/board-evidence/coremark/board-1.jpg)
- [CoreMark 板卡状态 2](../course-report/board-evidence/coremark/board-2.jpg)
- [流水线实现状态](../course-report/board-evidence/pipeline/implementation-status.png)

代码入口：

- [`core_main.c`](../../miniRV_pipeline_axi_ego1/software/c_test/4_coremark/src/coremark/src/core_main.c)：
  workload、CRC 校验和结果输出；
- [`core_portme.c`](../../miniRV_pipeline_axi_ego1/software/c_test/4_coremark/src/coremark/core_portme.c)：
  计时与平台适配；
- [`sc_print.c`](../../miniRV_pipeline_axi_ego1/software/c_test/4_coremark/src/common/sc_print.c)：
  UART MMIO 输出；
- [`cpu_core.v`](../../miniRV_pipeline_axi_ego1/src/rtl/cpu_core.v)：
  流水线冻结、去重发射和一次提交；
- [`axi_master.v`](../../miniRV_pipeline_axi_ego1/src/rtl/axi_master.v)：
  AXI 等待与响应。

### 6.3 实现结果与边界

带 ILA 构建的现有截图记录：

```text
WNS 1.702 ns，TNS 0 ns，Failing Endpoints 0
LUT 23%，FF 13%，BRAM 96%，Total On-Chip Power 0.221 W
```

当前仓库保留了实现状态截图和实板照片，但流水线/CoreMark 最终 `.bit`、`.ltx`
以及原始 Timing/Utilization/Power 报告尚未从实验室电脑补回。现场验收前应把这些
原始文件放进独立留档目录；它们不是当前功能结论的替代品，但能增强可复核性。

## 7. 老师常见追问

### 单周期和流水线下板有什么区别？

单周期 C_TEST0～2 证明单周期 SoC 和板级外设联调；流水线 CoreMark 还要求五级流水、
冒险处理、长延迟 M 扩展和 AXI 等待在持续负载下同时正确。前者对应“良好”中的
单周期 C_TEST，下板 CoreMark 对应“优秀”目标中的流水线 SoC。

### Basic Trace、AXI Trace 和上板为什么都要做？

- Basic Trace 隔离验证 CPU/流水线本身；
- AXI Trace 验证带等待和握手的总线路径；
- 上板验证 Vivado 实现、时钟复位、BRAM、UART 和真实引脚。

三者定位不同，不能相互替代。

### 为什么没有 Cache？

当前目标是无 Cache AXI SoC。CPU 侧接口和 AXI Master 已解耦，为后续插入
ICache/DCache 保留边界，但这次验收不声称已经实现 Cache。

### CoreMark 分数为什么不高？

当前设计是单发射五级流水，访存直接经过单事务 AXI/BRAM，且 M 扩展采用多周期单元，
没有 Cache。分数首先用于证明长时间正确执行；提升主频、增加 Cache、改善 AXI
吞吐和优化乘除法才是后续性能方向。

### 波形中最值得指出的信号是什么？

- 流水线：`valid`、`stall_*`、`flush`、前递选择、PC 和写回；
- AXI 读：`ARVALID/ARREADY`、`RVALID/RREADY`；
- AXI 写：`AWVALID/AWREADY`、`WVALID/WREADY`、`BVALID/BREADY`；
- 提交：写回寄存器号/数据、`debug_mem_we`，确认每条架构操作只提交一次。

## 8. 结束时的总结

> 我们按由局部到系统的顺序完成了三层验证：三类 Trace 均为 45/45；单周期
> C_TEST0～2 在 EGO1 上验证了完整板级外设；流水线 CoreMark 运行 32 秒、700 次
> 迭代并通过 CRC 校验。代码、数据通路图、定向波形、Trace 日志、Vivado 截图和
> 实板照片可以相互对应，形成完整验收闭环。

## 9. 现场文件检查

验收前确认：

- [ ] `docs/acceptance/index.html` 可离线打开，所有图片可放大；
- [ ] 三份 Trace 日志可打开，并能搜索 `Passed Tests (45)`；
- [ ] Vivado 工程与当前源码一致；
- [ ] C_TEST0、1、2 和 CoreMark 的 bitstream 分开命名；
- [ ] 串口线、JTAG 线、EGO1 和电源正常；
- [ ] 串口 `115200 8N1`、无流控；
- [ ] 流水线/CoreMark 原始 `.bit/.ltx/.rpt` 从实验室电脑补回；
- [ ] 两名同学都能分别解释流水线冒险和 AXI 握手。
