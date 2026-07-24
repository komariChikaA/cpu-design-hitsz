# miniRV 单周期 AXI EGO1 上板说明

首次综合、实现过程中出现的问题及对应修复记录见
[`VIVADO_BRINGUP_ISSUES.md`](./VIVADO_BRINGUP_ISSUES.md)。

## 当前存储器方案

板级顶层使用项目自带的两个 Xilinx Block Memory Generator：

- `IROM`：12,800 × 32 bit（50 KiB），映射 `0x0000_0000` 至 `0x0000_C7FF`。
- `DRAM`：25,600 × 32 bit（100 KiB），映射 `0x0000_C800` 至 `0x0002_57FF`，支持字节写使能。

两部分合计 38,400 个字，正好对应 C_TEST 链接脚本的 150 KiB 地址空间。
不要改回大型 Verilog 数组，也不要通过关闭资源 DRC 强行实现；大型数组在 EGO1
目标器件上可能被综合为 `RAMD64E` 分布式 RAM，从而耗尽 LUT 和 MUXF7。

## 生成并导入程序

服务器上已生成的 `main.coe` 放在：

```text
software/c_test/0_uart_test/main.coe
```

如需重新转换，在本目录运行：

```powershell
python .\tools\bin2mem.py `
  .\software\c_test\0_uart_test\main.coe `
  .\src\coe\main.mem
```

确认 `main.mem` 是 38,400 行：

```powershell
(Get-Content .\src\coe\main.mem | Measure-Object -Line).Lines
```

## Vivado 重建

使用 Vivado 2023.2 打开 `miniRV.xpr`，在 Tcl Console 中运行：

```tcl
source rebuild_ego1.tcl
```

脚本会自动完成：

1. 把 `main.mem` 拆成 `board_irom.coe` 和 `board_dram.coe`。
2. 更新并重新生成 `IROM`、`DRAM`、`clk_wiz_0` 输出产物。
3. 重新运行综合、实现和 bitstream。
4. 输出 `timing_summary.rpt` 和 `utilization.rpt`。

成功生成的 bitstream 通常位于：

```text
miniRV.runs/impl_1/miniRV_SoC.bit
```

检查利用率报告时，`RAMD64E` 和大量 `LUT as Memory` 不应再出现；BRAM 使用量
必须低于器件可用数量。时序报告应满足 `WNS >= 0`、`TNS = 0`。

## EGO1 烧录与验证

1. 连接 USB-JTAG 并打开开发板电源。
2. Vivado 中打开 Hardware Manager，选择 `Open Target`、`Auto Connect`。
3. 右击 `xc7a35t_0`，选择 `Program Device`，烧录 `miniRV_SoC.bit`。
4. 串口设置为 115200 baud、8 data bits、no parity、1 stop bit、no flow control。
5. 拨高至少一个拨码开关，按下并松开 `S6 RST`。

不要把 `S5 PROG#` 当作 CPU 复位。`S5` 会清除当前 FPGA 配置；误按后需要
重新执行 Program Device。

预期串口打印 `miniRV AXI EGO1 Test #0` 和 `Hello World!`。输入字符后应回显，
LED 和数码管显示字符的 ASCII 值；把拨码全部置零，再输入字符后程序打印
`Test ended.`。拨码不全为零时可以连续输入；拨码全部为零时仍会处理当前输入
一次，然后结束测试。实板验收中输入字符 `A`，数码管已正确显示 `00000041`。

保存综合/实现成功截图、时序与资源利用率、UART 输出、开发板现象，以及本次
使用的 `main.c`、`main.coe`、`main.mem` 和 bitstream。
