# 实板证据索引

| 测试 | 目录 | 主要证据 |
|---|---|---|
| 单周期 C_TEST0 | `singlecycle/ctest0/` | UART 输出/输入、结束状态、板卡、Timing/Utilization/Power |
| 单周期 C_TEST1 | `singlecycle/ctest1/` | 格式化输入输出、板卡、Timing/Utilization/Power |
| 单周期 C_TEST2 | `singlecycle/ctest2/` | 排序、动态内存、计时器、Timing/Utilization/Power |
| 流水线基础回归 | `pipeline/` | M 扩展 PASS、UART 输入 `A`、实现状态 |
| 流水线 CoreMark 无 Cache 基线 | `coremark/serial-result.png`、`board-*.jpg` | 21.250、0.425/MHz、`C0DE600D` |
| 流水线 CoreMark Cache 版 | `coremark/cache-result.md` | 48.814、0.976/MHz、CRC validated、`FINISH` |

照片仅作为已完成实板测试的留档。现场验收仍应准备可打开的 Vivado 工程、匹配当前
源码的 bitstream，并能重新运行相应程序。

Cache 版原始串口 PNG、Timing/Utilization/DRC、bitstream 和板卡显示照片尚待从
实验室 Windows 电脑补回；旧无 Cache 图片不得替代这些材料。
