# AXI 长延迟指令重复执行修复

## 结论

此前板卡能够写 LED、数码管，也能从 UART 发出第一个字符，但会卡在 UART
状态轮询；FPGA 已经收到输入字节 `0x41`，CPU 却始终不读取 RX FIFO。问题不在
Ubuntu 串口软件、引脚或 C 程序，而在流水线对 AXI 长延迟指令的停顿处理。

修复位于：

```text
src/rtl/cpu_core.v
```

## 根因

旧逻辑在一条 load/store 或 M 扩展指令刚进入 EX 时，同时停住 IF，使同一条指令
继续留在 ID。长延迟操作完成后，这条 ID 指令会再次进入 EX。

UART 状态轮询第一次正确读取：

```text
lw ..., 0xFFFF3008
```

重复执行时，WB 前递把刚读到的状态值 `0x00000008` 当成基址，下一次读地址变成
`0x00000008`。之后又会把读到的指令字当地址，形成错误的连续读，CPU 再也不会
回到 UART 状态寄存器。

新逻辑让刚进入 EX 的长延迟指令从 ID 被正常消费，只在真实相关、相邻同类长延迟
操作或正在冻结时停顿，从而避免同一条指令重放。

## 全系统回归证据

测试覆盖真实的：

```text
cpu_core -> cpu_top -> axi_master -> axi_board_soc -> simple_uart
```

并启动板上使用的原始 UART RX 程序镜像。

修复前：

```text
LED=0x00A5
RX_DATA=0x41
RX_VALID=1
MMIO_READ_CYCLES=1
```

修复后：

```text
LED=0x0041
RX_DATA=0x41
RX_VALID=0
MMIO_READ_CYCLES=622
PASS: full UART CPU/AXI/MMIO path
```

这表示 CPU 持续读取正确的 UART MMIO 地址，成功取走 `0x41`，更新 LED，并清除
RX 有效位。

## 实板验证

RTL 已经改变，旧 bitstream 不能验证本修复。必须在 Vivado Tcl Console 重新运行：

```tcl
source rebuild_ego1_ila.tcl
```

等待：

```text
EGO1 build finished.
```

然后绑定并烧录同一次构建产生的：

```text
outputs/vivado/miniRV_pipeline_axi_ego1_ila.bit
outputs/vivado/miniRV_pipeline_axi_ego1_ila.ltx
```

按下并松开 S6 后，预期先看到：

```text
UART: R
LED:  00A5
数码管: 600D600D
```

从 Ubuntu 串口发送大写 `A` 后，预期：

```text
UART: 板卡回显 A
LED:  0041
数码管: 00000041
```

`screen` 默认不做本地回显，因此键盘上的 `A` 不一定立即显示；LED、数码管和板卡
回显才是发送与接收成功的依据。
