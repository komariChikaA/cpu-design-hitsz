# 实板证据索引

| 测试 | 目录 | 主要证据 |
|---|---|---|
| 单周期 C_TEST0 | `singlecycle/ctest0/` | UART 输出/输入、结束状态、板卡、Timing/Utilization/Power |
| 单周期 C_TEST1 | `singlecycle/ctest1/` | 格式化输入输出、板卡、Timing/Utilization/Power |
| 单周期 C_TEST2 | `singlecycle/ctest2/` | 排序、动态内存、计时器、Timing/Utilization/Power |
| 流水线基础回归 | `pipeline/` | M 扩展 PASS、UART 输入 `A`、实现状态 |
| 流水线 CoreMark | `coremark/` | 完整串口结果、`C0DE600D` 板卡同框照片 |

照片仅作为已完成实板测试的留档。现场验收仍应准备可打开的 Vivado 工程、匹配当前
源码的 bitstream，并能重新运行相应程序。
