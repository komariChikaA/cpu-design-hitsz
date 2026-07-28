# 流水线 AXI EGO1 实验室操作清单

## 一、去实验室之前

建议先在 Linux 服务器生成流水线专项程序：

```bash
cd ~/miniRV_pipeline_axi_ego1
bash prepare_program.sh 1_pipeline_mext_test
wc -l src/coe/main.mem
```

最后一条必须输出 `38400`。把更新后的整个
`miniRV_pipeline_axi_ego1/` 文件夹带到实验室，不要只带 `.xpr`。

Windows 上再运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verify_package.ps1
```

看到所有项目均为 `PASS` 后再复制到 U 盘或实验室电脑。

## 二、Vivado 综合与 bitstream

1. 启动 Vivado 2023.2。
2. 打开 `miniRV_pipeline_axi_ego1/miniRV.xpr`。
3. 确认器件为 `xc7a35tcsg324-1`，Top 为 `miniRV_SoC`。
4. 不要在工程里添加 `RUN_TRACE` 宏。
5. 在 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

脚本运行期间必须看到：

```text
IP synthesis cache disabled for the board-image rebuild.
IROM_synth_1 ready: Synthesis Complete!
DRAM_synth_1 ready: Synthesis Complete!
clk_wiz_0_synth_1 ready: Synthesis Complete!
Post-synthesis memory primitives: ...
Implementation WNS: ... ns
EGO1 build finished.
```

若脚本中止，不要继续使用旧 bitstream。先按
[VIVADO_BRINGUP_ISSUES.md](./VIVADO_BRINGUP_ISSUES.md) 排查。

成功后检查 `outputs/vivado/`：

- `miniRV_pipeline_axi_ego1.bit` 存在且时间为本次构建；
- `timing_summary.rpt` 中 `WNS >= 0`；
- `utilization.rpt` 中 LUT、BRAM 均未超量；
- `implementation_drc.rpt` 没有 Error；
- 没有大量 `RAMD64E`、`LUT as Memory` 或 `MUXF7`。

## 三、连接开发板

1. 关闭会占用串口的旧软件。
2. 用 USB 连接 EGO1，打开电源。
3. 设备管理器确认新增 COM 端口。
4. Vivado 打开 Hardware Manager。
5. 选择 `Open Target`、`Auto Connect`。
6. 右击 `xc7a35t_0`，选择 `Program Device`。
7. 选择 `outputs/vivado/miniRV_pipeline_axi_ego1.bit`。

## 四、串口设置

使用 MobaXterm、PuTTY、Tera Term 或其他串口终端：

```text
Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
Flow control: None
```

COM 端口打不开时，先关闭其他串口窗口和 Vivado Serial Terminal，再重新插拔 USB。
串口终端打开后不能输入文字并不代表异常；程序只有在输出 `Enter a char:` 后才等待输入。

## 五、复位与预期现象

拨高至少一个拨码开关，按下并松开 `S6 RST`。

流水线专项程序应输出：

```text
miniRV Pipeline AXI EGO1 Test
<Phase 0> M-extension self-test: PASS
<Phase 1> UART input test
Enter a char:
```

进入 Phase 1 前：

- LED 显示低 16 位 `00A5`；
- 数码管显示 `600D600D`。

输入 `A` 后：

- 串口回显 `A`；
- 数码管显示 `00000041`；
- LED 显示字符低位。

拨码不全为零时可以继续输入。把拨码全部置零后再输入一个字符，程序处理该字符并打印
`Test ended.`。

若 Phase 0 失败，数码管显示 `E000000x`，LED 最高位点亮且低位给出测试编号。
记录编号，不要只重新烧录。

## 六、按键注意事项

- `S6 RST`：CPU 低有效复位，按下后数码管可能短暂熄灭。
- `S5 PROG#`：清除 FPGA 配置，不是 CPU 复位。

误按 S5 后数码管和 LED 会熄灭，需要重新执行 Program Device。

## 七、离开实验室前保存

填写 [BOARD_VALIDATION_TEMPLATE.md](./BOARD_VALIDATION_TEMPLATE.md)，并保存：

- `outputs/vivado/*.rpt`；
- 本次 `.bit`；
- Vivado Messages 或 `vivado.log`；
- UART 完整输出截图；
- 数码管、LED 和拨码照片；
- 使用的 `main.c`、`main.coe`、`main.mem`；
- 当前 Git commit。
