# 流水线 SoC ILA 板级定位

## 目标

用于定位以下已确认现象：

- Vivado 综合、实现、时序和烧录均成功；
- 启动探针镜像也无法点亮 LED0 或显示 `11111111`；
- 因此需要直接观察时钟锁定、复位、PC、AXI 取指和 AXI 写事务。

本调试版不需要 Linux 服务器。ILA 使用 50 MHz `sys_clk`，采样深度为
2048，探针宽度为 187 bit。

## 构建

将 ILA 补丁覆盖到完整的 `miniRV_pipeline_axi_ego1/` 工程后，用 Vivado
2023.2 打开 `miniRV.xpr`，在 Tcl Console 只执行：

```tcl
source rebuild_ego1_ila.tcl
```

不要再执行普通的 `rebuild_ego1.tcl`。等待终端打印：

```text
ILA u_ila_boot connected
EGO1 build finished.
```

输出文件为：

```text
outputs/vivado/miniRV_pipeline_axi_ego1_ila.bit
outputs/vivado/miniRV_pipeline_axi_ego1_ila.ltx
```

## 烧录

1. Hardware Manager → Open Target → Auto Connect。
2. Program Device。
3. Program file 选择 `miniRV_pipeline_axi_ego1_ila.bit`。
4. Probes file 选择 `miniRV_pipeline_axi_ego1_ila.ltx`。
5. Program。

若烧录后 Hardware Manager 没有出现 `hw_ila_1` 或 `u_ila_boot`，保存完整
Tcl 日志。ILA 的采样时钟来自 `sys_clk`；在 bit 和 ltx 匹配的前提下，
ILA 完全不可见本身就是时钟/Debug Hub 方向的重要证据。

## 探针位定义

| ILA 位 | 信号 |
|---|---|
| `[186]` | FPGA 原始 `rx` 引脚 |
| `[185]` | UART 两级同步后的 `rx_sync[1]` |
| `[184:183]` | UART RX 状态机 |
| `[182]` | `uart_rx_valid` |
| `[181:174]` | `uart_rx_data` |
| `[173]` | `pll_lock` |
| `[172]` | `sys_rst` |
| `[171:140]` | CPU `pc` |
| `[139]` | `ifetch_req` |
| `[138]` | `ifetch_valid` |
| `[137:106]` | `m_axi_araddr` |
| `[105:74]` | `m_axi_rdata` |
| `[73]` | `m_axi_arvalid` |
| `[72]` | `m_axi_arready` |
| `[71]` | `m_axi_rvalid` |
| `[70]` | `m_axi_rready` |
| `[69:38]` | `m_axi_awaddr` |
| `[37:6]` | `m_axi_wdata` |
| `[5]` | `m_axi_awvalid` |
| `[4]` | `m_axi_awready` |
| `[3]` | `m_axi_wvalid` |
| `[2]` | `m_axi_wready` |
| `[1]` | `m_axi_bvalid` |
| `[0]` | `m_axi_bready` |

在波形窗口把 `probe0`/`ila_probe` 的 radix 设置为 Hex。

## 捕获复位释放

1. 按住 `S6 RST` 不松开。
2. 在 Trigger Setup 中设置 `ila_probe[172] == 0`。
3. 点击 Run Trigger。
4. 松开 `S6 RST`。
5. 等待捕获完成。

若一直等待不触发，先停止捕获并执行一次 Immediate Trigger，查看
`pll_lock` 和 `sys_rst` 的静态值。

## 捕获 UART RX

1. 保持诊断程序运行在 `600D600D`，关闭占用串口的其他终端。
2. 在 Trigger Setup 中设置 `ila_probe[186] == 0`，捕获原始 RX 的起始位。
3. 点击 Run Trigger。
4. 在 Ubuntu 中向正确的串口设备发送 `A`。
5. 捕获后展开 `[186:174]`。

判断方法：

- `[186]` 始终为 1：PC 发送数据没有到达 FPGA，检查串口设备选择、线缆和
  N5 RX 引脚。
- `[186]` 跳变但 `[185]` 不跳变：RX 输入同步路径异常。
- `[185]` 跳变且 `[184:183]` 状态变化，但 `[182]` 不产生脉冲：UART
  采样时序或停止位判定异常。
- `[182]=1` 且 `[181:174]=41`：UART 接收器正确收到 `A`，继续检查 CPU
  对 UART 状态/数据寄存器的 AXI 读取。

## 快速判定

- `[173]=0`：时钟向导没有锁定，优先检查 P17 输入时钟、Clock Wizard 和
  板卡时钟。
- `[173]=1`，松开 S6 后 `[172]` 仍为 1：CPU 一直处于复位，检查 P15、
  S6 极性和 `reset_sync`。
- `[172]=0`，PC 始终为 0，`arvalid=0`：CPU/AXI Master 未发出第一条取指。
- `arvalid=1`、`arready=0`：板级 AXI Slave 未接受地址。
- `arvalid/arready` 已握手，但 `rvalid` 始终为 0：IROM/板级读响应路径故障。
- `rvalid/rready` 已握手，但 `ifetch_valid=0`：检查流水线取指待决地址过滤。
- PC 正常前进，但启动探针没有写出：查看写地址是否出现 `FFFF1000` 和
  `FFFF2000`，再依次检查 AW/W/B 三个通道的握手。

完成后至少保存：

- 整个 ILA 窗口截图；
- `pll_lock/sys_rst/pc` 展开后的截图；
- AXI AR/R 与 AW/W/B 握手截图；
- 本次 `_ila.bit`、`.ltx` 和完整 Vivado Tcl 日志。
