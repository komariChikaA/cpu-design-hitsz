# CoreMark 实验室下板与拍照验收

本包已预装正式的 50 MHz、RV32IM、700 次迭代 CoreMark 镜像。你不需要 Linux 服务器来
重新编译 C 程序，只需要在实验室 Ubuntu 的 Vivado 中重新生成并烧录 bitstream。

## 1. 解压后先确认

进入工程目录，确认能看到：

```text
miniRV.xpr
rebuild_ego1.tcl
src/coe/main.mem
software/c_test/4_coremark/
COREMARK_BUILD_INFO.md
```

不要把本包覆盖进之前的工程目录；请在新目录中完整解压。

## 2. Vivado 重新生成 bitstream

使用 Vivado 2023.2 打开 `miniRV.xpr`，在 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

等待完成，必须看到：

```text
EGO1 build finished.
```

同时检查 Timing Summary：

```text
WNS >= 0
TNS = 0
Number of Failing Endpoints = 0
```

烧录本次新生成的：

```text
outputs/vivado/miniRV_pipeline_axi_ego1.bit
```

`main.mem` 会被固化进 Block RAM，因此不能继续使用之前流水线测试生成的旧 bit。

## 3. Ubuntu 串口记录

先找串口：

```bash
ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
```

假设串口是 `/dev/ttyUSB1`，CoreMark 不需要键盘输入，推荐直接记录：

```bash
stty -F /dev/ttyUSB1 115200 cs8 -cstopb -parenb -ixon -ixoff -crtscts raw -echo
stdbuf -o0 cat /dev/ttyUSB1 | tee coremark_uart_20260729.log
```

如果提示权限不足：

```bash
sudo usermod -aG dialout "$USER"
```

然后注销并重新登录。也可以临时用 `sudo` 执行 `stty` 和 `cat`。

## 4. 启动与等待

1. 烧录完成后启动串口记录。
2. 按下并松开 `S6 RST`，不要按 `S5 PROG#`。
3. 启动阶段板卡显示：

```text
LED：C001
数码管：C0010000
```

4. 串口开头应显示：

```text
miniRV Pipeline AXI EGO1 CoreMark
Student IDs: 2024311081_2024311453
CPU clock: 50 MHz
CoreMark 1.0
```

5. 等待程序自然运行到 `FINISH`。700 次迭代可能需要几分钟；运行过程中不要再次复位、
   重烧录或关闭串口记录。

## 5. 唯一的正式成功判据

串口末尾必须同时包含：

```text
Iterations       : 700
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 :
CoreMark/MHz :
FINISH
```

并且：

```text
LED：C0A5
数码管：C0DE600D
```

以下任一情况都不能记为 CoreMark 通过：

- 出现 `ERROR! Must execute for at least 10 secs`
- 出现任何 CRC `ERROR!`
- 出现 `Errors detected`
- 出现 `Cannot validate operation`
- LED 或数码管以 `E0` 开头
- 没有等到 `FINISH`

实际 CoreMark 分数以你这次实板串口打印值为准，不能用仿真值或他人结果代替。

## 6. 必拍照片

建议至少保留四组证据：

1. **构建和时序**：Vivado 显示 `EGO1 build finished.`，Timing Summary 同时拍到
   `WNS >= 0`、`TNS = 0`、失败端点为 0。
2. **身份和配置**：串口开头拍到项目标题、两位学号、`CPU clock: 50 MHz`。
3. **CoreMark 最终结果**：串口末尾完整拍到 `Iterations : 700`、
   `Correct operation validated`、CoreMark 分数、`CoreMark/MHz` 和 `FINISH`。
4. **板级通过状态**：板卡近照拍清 LED `C0A5`、数码管 `C0DE600D`；最好让板卡与
   串口最终结果同时入镜。

另外保存：

```text
outputs/vivado/miniRV_pipeline_axi_ego1.bit
outputs/vivado/timing_summary.rpt
outputs/vivado/utilization.rpt
outputs/vivado/implementation_drc.rpt
coremark_uart_20260729.log
```

## 7. 出问题时的最短判断

- 连开头四行都没有：先查串口号、115200 8N1、S6 复位和是否烧录了本包新 bit。
- 停在中途但 PC 在运行：继续等待，700 次迭代本来就慢。
- 最终出现 CRC 错误或 `E0xx`：保留日志，不要当作通过；再用 ILA 包定位。
- 只有分数没有 `Correct operation validated`：不是有效验收结果。

实板跑完后，把终端最终输出、板卡照片和 Timing Summary 发回来，再把项目 README 的
CoreMark 项目标记为已完成。
