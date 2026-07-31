# Windows：带 Cache 的流水线 CoreMark 下板流程

本包用于 Windows 10/11 + Vivado 2023.2 + EGO1。

工程已经预装正式 CoreMark 镜像，不需要 Linux 服务器，也不需要重新编译 C 程序：

- CPU：五级流水线 RV32IM，50 MHz；
- ICache/DCache：64 line、direct-mapped、16-byte line；
- DCache：write-through、no-write-allocate；
- Cache refill：AXI INCR burst，`ARLEN=3`，4 个 32-bit beat；
- MMIO：`0xFFFF_xxxx` 强制 Uncached；
- CoreMark：700 次迭代；
- 学号：`2024311081_2024311453`。

2026-07-31 使用本包 Cache RTL 在 EGO1 上实测：14 秒完成 700 次迭代，
四组 CRC 正确，输出 `Correct operation validated` 和 `FINISH`，得到
48.814 CoreMark、0.976 CoreMark/MHz。包内
`CACHE_COREMARK_RESULT_20260731.md` 保存完整串口抄录和与无 Cache 基线的对比。

## 1. 解压并校验

建议解压到纯英文短路径，例如：

```text
C:\fpga\miniRV_pipeline_axi_ego1
```

不要覆盖以前的无 Cache 工程，也不要在压缩包内部直接打开工程。

双击：

```text
verify_cache_coremark_windows.cmd
```

末尾必须看到：

```text
PASS: ICache and DCache are enabled
PASS: cpu_top instantiates both caches
PASS: AXI cache-line burst refill is present
Windows Cache CoreMark package verification passed.
```

## 2. 生成 Cache 版 bitstream

### Vivado 图形界面

1. 使用 Vivado 2023.2 打开 `miniRV.xpr`；
2. 在底部 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

3. 等待控制台出现 `EGO1 build finished.`。

如果 Vivado 已加入 Windows `PATH`，也可以双击：

```text
build_cache_coremark_windows.cmd
```

构建后必须检查：

```text
WNS >= 0
TNS = 0
Number of Failing Endpoints = 0
```

烧录本次新生成的：

```text
outputs\vivado\miniRV_pipeline_axi_ego1.bit
```

不能沿用普通流水线或无 Cache CoreMark 的旧 `.bit`。`main.mem` 会在生成 bitstream
时固化到 IROM/DRAM Block RAM，单独复制 `main.mem` 不会改变旧 `.bit`。

## 3. Windows 串口记录

先在“设备管理器 → 端口 (COM 和 LPT)”中确认板卡端口，例如 `COM5`。然后执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\capture_coremark_serial.ps1 -Port COM5
```

参数为 `115200 8N1`、无流控。内容同时保存为：

```text
coremark_uart_YYYYMMDD_HHMMSS.log
```

CoreMark 不需要键盘输入。开始记录后，按下并松开 `S6 RST`，不要按 `S5 PROG#`。

也可以使用 PuTTY、Tera Term 或 MobaXterm：`115200 8N1`、Flow control 为
`None`、Local echo 为 `Off`。

## 4. 成功判据

启动阶段：

```text
LED：C001
数码管：C0010000
```

串口开头：

```text
miniRV Pipeline AXI EGO1 CoreMark
Student IDs: 2024311081_2024311453
CPU clock: 50 MHz
CoreMark 1.0
```

最终必须同时出现：

```text
Iterations       : 700
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 :
CoreMark/MHz :
FINISH
```

板卡最终状态：

```text
LED：C0A5
数码管：C0DE600D
```

出现 CRC `ERROR!`、`Errors detected`、`Cannot validate operation`、`E0xx`，
或者没有到达 `FINISH`，都不能记为通过。

## 5. 保存证据

1. Vivado 构建完成与 Timing Summary；
2. 串口开头的标题、两位学号和 50 MHz；
3. 串口末尾的 700 次、校验通过、分数和 `FINISH`；
4. LED `C0A5` 与数码管 `C0DE600D`。

同时保存：

```text
outputs\vivado\miniRV_pipeline_axi_ego1.bit
outputs\vivado\timing_summary.rpt
outputs\vivado\utilization.rpt
outputs\vivado\implementation_drc.rpt
coremark_uart_YYYYMMDD_HHMMSS.log
```

包校验只能证明工程、镜像和 RTL 结构正确；实际综合、时序和 EGO1 结果必须以本次
Windows Vivado 生成的报告、串口日志和照片为准。
