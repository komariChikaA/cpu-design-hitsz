# 流水线 AXI EGO1 正式拍照验收

本工程包含已通过 UART 实板验证的流水线长延迟指令修复，以及正式的流水线
M 扩展/UART 综合验收程序。

## 镜像信息

```text
程序：1_pipeline_mext_test
main.mem 字数：38400
main.mem SHA256：93B66CA2089D480F6EA813E79C20B283C947B2313760A1947BD53673A6B2EAB3
```

程序覆盖：

- `MUL/MULH/MULHU`
- `DIV/DIVU/REM/REMU`
- 除零行为
- 有符号溢出行为
- UART 发送、接收与回显
- LED、数码管和拨码开关 MMIO

## 重新生成 bitstream

旧 bitstream 中是 UART 直接诊断程序，不能只替换 `main.mem` 后继续使用。解压本包，
用 Vivado 2023.2 打开新的 `miniRV.xpr`，在 Tcl Console 执行：

```tcl
source rebuild_ego1_ila.tcl
```

必须等到：

```text
EGO1 build finished.
```

烧录同一次构建生成的：

```text
outputs/vivado/miniRV_pipeline_axi_ego1_ila.bit
outputs/vivado/miniRV_pipeline_axi_ego1_ila.ltx
```

## 上板前设置

1. 串口设置为 `115200 8N1`、无流控。
2. 建议把 16 个拨码开关全部拨到 `0`，这样输入一次字符后程序会显示
   `Test ended.`，终端画面更适合拍照。
3. 烧录完成后按下并松开 S6。

## 成功输出

终端首先应完整显示：

```text
miniRV Pipeline AXI EGO1 Test
<Phase 0> M-extension self-test: PASS
<Phase 1> UART input test
Enter a char:
```

此时板卡应为：

```text
LED：00A5
数码管：600D600D
```

输入大写 `A` 后，终端继续显示：

```text
Input received: A
Test ended.
```

板卡变为：

```text
LED：0041
数码管：00000041
```

如果拨码开关不是全零，程序会再次显示 `Enter a char:`，这不是失败。

## 建议拍照

1. **构建证据**：Vivado Tcl Console 中的 `EGO1 build finished.`，以及 Timing
   Summary 的 `WNS >= 0`。
2. **M 扩展通过**：终端完整显示标题和
   `<Phase 0> M-extension self-test: PASS`；同时拍到 LED `00A5` 与数码管
   `600D600D`。
3. **UART 交互通过**：终端显示 `Input received: A` 和 `Test ended.`；同时拍到
   LED `0041` 与数码管 `00000041`。

拍摄时尽量让板卡、串口终端窗口和电脑日期时间进入同一画面；如果画面太小，可分别
拍终端近照和板卡近照，并在报告中并排放置。

## 离线回归结果

修复后的完整 CPU/AXI/MMIO/UART 仿真已经逐字验证上述全部终端输出，并确认：

```text
M-extension PASS 标志：LED 00A5
输入 A 后：LED 0041
RX FIFO：已读取并清除
PASS: formal pipeline/M-extension/UART acceptance
```
