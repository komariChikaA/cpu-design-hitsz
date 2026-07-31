# Cache 版流水线 CoreMark 实板结果

- 测试日期：2026-07-31
- 板卡：EGO1，`xc7a35tcsg324-1`
- CPU：miniRV 五级流水线 AXI，RV32IM，50 MHz
- Cache：64-line ICache + 64-line DCache，16-byte line
- 小组学号：`2024311081_2024311453`

## 串口截图抄录

以下内容来自 Windows MobaXterm 的 `COM4` 实板串口截图：

```text
miniRV Pipeline AXI EGO1 CoreMark
Student IDs: 2024311081_2024311453
CPU clock: 50 MHz
CoreMark 1.0
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 717005179
Total time (secs): 14
Iterations/Sec   : 50
Iterations       : 700
Compiler version : GCC12.2.0
Compiler flags   : -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las -march=rv32im
Memory location  : STATIC
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x65c5
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 48.814
CoreMark/MHz : 0.976
FINISH
```

## 与无 Cache 基线对比

| 指标 | 无 Cache 基线 | Cache 版 | 对比 |
|---|---:|---:|---:|
| CPU 主频 | 50 MHz | 50 MHz | 相同 |
| 迭代次数 | 700 | 700 | 相同 |
| 运行时间 | 32 s | 14 s | 减少约 56.3% |
| CoreMark | 21.250 | 48.814 | 约 2.30 倍 |
| CoreMark/MHz | 0.425 | 0.976 | 约 2.30 倍 |
| CRC | 全部正确 | 全部正确 | 均通过 |

两次测试的主频、迭代次数、seedcrc 和四组最终 CRC 一致，因此可以直接比较性能。
Cache 版保持相同架构正确性，同时显著减少重复取指和数据读取对 AXI/BRAM 的访问。

## 成功判据

- 700 次迭代；
- 运行时间超过 CoreMark 要求的 10 秒；
- 四组 CRC 与已知正确值一致；
- 输出 `Correct operation validated`；
- 输出正式 CoreMark 和 CoreMark/MHz；
- 最终输出 `FINISH`。

## 证据边界

本文件已经按用户提供的实板串口截图逐项抄录，足以记录串口数值和通过判据。由于当前
对话图片没有暴露本地附件路径，原始 PNG 尚未复制进仓库。提交报告前仍需把原图保存为：

```text
docs/course-report/board-evidence/coremark/cache-serial-result.png
```

还应补回同一次 Cache 构建的 Timing Summary、Utilization、DRC、最终 `.bit`，
以及 LED `C0A5`/数码管 `C0DE600D` 板卡照片。未取得这些文件前，不能沿用旧无 Cache
构建的 WNS、资源占用或板卡照片冒充 Cache 版证据。
