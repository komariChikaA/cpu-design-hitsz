# 流水线 AXI EGO1 实板验收结果

验收日期：2026-07-29
板卡：EGO1，`xc7a35tcsg324-1`
CPU：miniRV 五级流水线 AXI，RV32IM，50 MHz
小组学号：`2024311081_2024311453`

## 1. 流水线基础回归

实板终端输出确认：

```text
miniRV Pipeline AXI EGO1 Test
<Phase 0> M-extension self-test: PASS
<Phase 1> UART input test
Input received: A
Test ended.
```

板级结果：

```text
M 扩展通过：数码管 600D600D
UART 输入 A：数码管 00000041
```

这项测试覆盖流水线 M 扩展长延迟指令、AXI 访存、UART 收发、LED 和数码管 MMIO。

## 2. CoreMark

实板串口结果：

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
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 21.250
CoreMark/MHz : 0.425
FINISH
```

最终数码管显示 `C0DE600D`。运行时间超过 CoreMark 有效结果要求的 10 秒，且没有
CRC 错误或 `Errors detected`。

## 3. Vivado 实现结果

流水线 AXI EGO1 的 Post-Implementation 截图记录：

```text
WNS：1.702 ns
TNS：0 ns
Number of Failing Endpoints：0
LUT：23%
LUTRAM：3%
FF：13%
BRAM：96%
IO：29%
BUFG：9%
PLL：20%
Total On-Chip Power：0.221 W
```

该截图来自带 ILA 的验收构建，因此 BRAM 使用率高于普通构建。实现无时序违例。

## 4. 关键 RTL 修复

实板调试发现：长延迟 load/M 指令进入 EX 时，如果 IF 因
`load_entering_id`/`mul_entering_id` 被暂停，同一条指令会继续留在 ID；操作完成后
再次进入 EX，形成重复执行。UART 状态轮询因此可能把已读取的数据前递为下一次访问的
基址。

最终修复位于 `src/rtl/cpu_core.v`：

- IF 仅在真实数据相关、相邻同类长延迟操作或活动操作冻结时暂停；
- 使用 `load_duplicate`、`mul_duplicate` 阻止真正的重复发射；
- AXI 实板模式对已发生的跳转始终执行重定向；
- Trace 模式保留课程 Trace 的零延迟目标指令去重行为。

修复后的全系统仿真、流水线 M 扩展/UART 实板测试和 CoreMark 实板测试均通过。

## 5. 证据位置与边界

用于 PR 审阅和报告复核的证据保存在：

```text
docs/course-report/board-evidence/pipeline/
docs/course-report/board-evidence/coremark/
```

目录中保存原始照片和实现状态截图；可重新生成的 bitstream、仿真可执行文件和工具缓存
不进入 Git。

目前流水线照片目录没有保存实验室生成的最终 `.bit`、`.ltx` 和 `.rpt` 文件。提交报告
前应从实验室电脑补回 CoreMark 构建的 bitstream、Timing Summary、Utilization 和
Power 报告，避免只有截图而没有原始报告。
