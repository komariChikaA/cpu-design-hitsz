# 单周期 AXI EGO1 Vivado 上板问题记录

## 1. 记录范围

- 记录日期：2026-07-24
- 工程目录：`miniRV_singlecycle_axi_ego1/`
- Vivado 版本：2023.2
- 目标器件：`xc7a35tcsg324-1`
- 目标：完成单周期 CPU 的 AXI Trace、Vivado 综合/实现、bitstream 生成和 EGO1 实板验证

本文件记录首次把单周期 AXI 工程移到另一台 Windows 电脑并进行 Vivado
综合、实现时遇到的问题。AXI Trace 测试记录见
[`../trace_test/miniRV_AXI_report.md`](../trace_test/miniRV_AXI_report.md)。

## 2. 当前结论

- 单周期 AXI Trace 已通过 45/45 个测试点。
- 最初的存储器推断方案会耗尽 EGO1 的 BRAM 或 LUT，不能用于上板。
- 板级存储器已改为显式实例化 Xilinx Block Memory Generator：
  - `IROM`：12,800 × 32 bit，50 KiB；
  - `DRAM`：25,600 × 32 bit，100 KiB，支持字节写使能。
- 修正后手动运行 Synthesis 和 Implementation 未出现失败，并成功生成 bitstream。
- `rebuild_ego1.tcl` 中两处自动化判断错误已经修正。
- Hardware Manager 已成功烧录 EGO1；UART 输入字符 `A` 后，数码管显示
  `00000041`。拨码非零时可连续测试，拨码全零时处理当前字符后结束。

## 3. 问题、根因与处理

### 3.1 复制工程后找不到 IP 生成目录

现象：

```text
[filemgmt 56-3] IPUserFilesDir: Could not find the directory
'.../miniRV.ip_user_files'

[Project 1-509] GeneratedRun file for 'clk_wiz_0_synth_1' not found
```

根因：

Vivado 的 IP 输出产物和独立综合运行目录没有随工程复制，或者仍引用原电脑的生成目录。

处理：

`rebuild_ego1.tcl` 对 `IROM`、`DRAM` 和 `clk_wiz_0` 重新执行
`reset_target`、`generate_target`、`export_ip_user_files` 和 IP OOC 综合。

### 3.2 Clock Wizard 端口不匹配

现象：

```text
[Synth 8-11365] for the instance 'U_clkgen' of module 'clk_wiz_0',
named port connection 'reset' does not exist
```

根因：

当前 `clk_wiz_0` 配置为 `USE_RESET=false`，生成的模块不存在 `reset` 端口，
但板级顶层仍连接了该端口。

处理：

删除 `U_clkgen` 实例上不存在的 `.reset(...)` 连接。CPU/SoC 复位仍由
板级复位同步逻辑处理。

### 3.3 综合运行目录找不到初始化文件

现象：

```text
[Synth 8-4445] could not open $readmem data file 'src/coe/main.mem'
```

根因：

`$readmemh` 的相对路径按 Vivado 综合运行目录解析，而不是稳定地按工程根目录解析。

处理：

板级方案不再依赖大型 Verilog 数组的 `$readmemh`。`main.mem` 由重建脚本拆为：

```text
src/coe/board_irom.coe
src/coe/board_dram.coe
```

两个 COE 文件分别交给 `IROM` 和 `DRAM` IP。

### 3.4 150 KiB Verilog 数组无法推断为 RAM

现象：

```text
[Synth 8-3391] Unable to infer a block/distributed RAM for 'memory_reg'
because the memory pattern used is not supported
```

同时 Vivado 尝试把 1,228,800 bit 的存储器拆成普通逻辑，并提示提高
`dissolveMemorySizeLimit`。

根因：

原数组的访问模板、深度和读写方式不能稳定映射到目标器件的 Block RAM。

处理：

没有提高 `dissolveMemorySizeLimit`，因为将大存储器拆成寄存器/LUT 不能在
EGO1 上实现。改为显式 Block Memory Generator。

### 3.5 拆成两个推断 RAM 后 BRAM 超限

现象：

```text
[Synth 8-7048] Resources of type BRAM have been overutilized
Used = 128, Available = 100
```

根因：

将存储器简单拆成 32,768 字和 5,632 字两个 Verilog 数组后，Vivado 对深度和
端口结构进行了不利的资源映射，最终需要 128 个 RAMB18 等价资源。

处理：

按照 C_TEST 链接布局的真实边界划分为 12,800 字 IROM 和 25,600 字 DRAM，
并使用已配置准确深度的 BMG IP。

### 3.6 推断 RAM 被实现为大量分布式 RAM

现象：

```text
RAMD64E                 Used 38400, Available 9600
LUT as Memory           Used 38448, Available 9600
Slice LUTs              Used 48230, Available 20800
MUXF7 / F7 Muxes        Used 20456, Available 16300
```

根因：

拆分后的 Verilog 存储器仍被映射成 `RAMD64E` 分布式 RAM，而不是 Block RAM。
关闭 LUT 资源 DRC 不能创造额外硬件资源，因此不能解决问题。

处理：

`src/rtl/board_bram.v` 现在直接实例化：

```verilog
IROM U_program_memory (...);
DRAM U_data_memory (...);
```

AXI 从设备同时加入一个周期的同步存储器读等待。重建脚本在综合后统计
`RAMD64E`、`RAMB18E1` 和 `RAMB36E1`；若仍存在超过 1,000 个 `RAMD64E`，
脚本会停止，不再运行旧网表的 Implementation。

### 3.7 IP 配置属性设置到了错误对象

现象：

```text
[Common 17-142] Invalid property name 'CONFIG.Load_Init_File'
```

根因：

脚本把 `CONFIG.Load_Init_File` 和 `CONFIG.Coe_File` 设置到了
`get_files` 返回的 `.xci` 文件对象上。

处理：

改为设置到 `get_ips` 返回的 IP 对象上：

```tcl
set_property -dict \
    [list CONFIG.Load_Init_File true CONFIG.Coe_File $irom_coe] \
    [get_ips IROM]
```

`DRAM` 同样处理。

### 3.8 缓存 IP 被脚本误判为失败

现象：

```text
IROM_synth_1 finished
IROM_synth_1 failed: Using cached IP results
```

根因：

`Using cached IP results` 表示 Vivado 成功复用了 IP 综合结果，但旧脚本只把
状态中包含 `Complete` 的运行判定为成功。

处理过程：

最初修正为同时接受 `*Complete*` 和 `*cached IP results*`，因为缓存状态本身
不代表综合运行失败。但后续实板发现程序没有启动，因此对于包含程序初始化内容的
IROM/DRAM，不能只判断结构综合成功，还必须保证本次 COE 内容进入 DCP。当前脚本
已改为禁用 IP cache，并把意外出现的 `cached IP results` 视为板级映像重建失败。

### 3.9 Bitstream 可下载，但 CPU/UART 程序没有启动

现场现象：

- FPGA 配置灯 `D24` 正常点亮；
- 按 `S6 RST` 时数码管短暂熄灭，松开后恢复为全零；
- COM4 可以打开，但没有启动文本；
- 发送字符 `A` 后数码管、LED 均不变化；
- 拨码开关不会单独改变数码管。

判断：

数码管扫描、时钟、FPGA 配置和外部复位路径已经工作，但 CPU 没有执行到
UART 测试程序。拨码开关在当前 `main.c` 中只会在收到字符后决定是否退出，
因此单独拨动开关没有显示变化是正常行为。

当时首要怀疑是 `IROM_synth_1` 的 `Using cached IP results`：IROM/DRAM 的
综合 DCP 包含初始化映像，若复用了为旧 COE 文件生成的缓存结果，Vivado 仍可
生成结构正确的 bitstream，但 CPU 启动内容不是本次 `main.coe`。

处理：

`rebuild_ego1.tcl` 现在在生成存储器 IP 前执行：

```tcl
config_ip_cache -disable_cache
```

随后重新生成并综合 `IROM`、`DRAM`，再重新运行主工程 Synthesis、
Implementation 和 Generate Bitstream。

实板复测结果（2026-07-24）：

- 新 bitstream 下载成功；
- EGO1 可以正常运行；
- 串口输入字符 `A` 后，八位数码管显示 `00000041`；
- `0x41` 与字符 `A` 的 ASCII 编码一致。

该结果证明本次程序映像已进入 IROM，且 CPU、AXI 取指/访存、UART 接收和
数码管写外设链路均已跑通。本问题已解决。

## 4. 当前仍存在但不阻塞的警告

### 4.1 无关板卡库警告

```text
[Board 49-26] cannot add Board Part xilinx.com:kc705:part0:1.6
```

这是本机 Vivado Board Store 中 KC705 定义与已安装器件不匹配。当前工程直接
指定 `xc7a35tcsg324-1`，因此该警告与 EGO1 设计无直接关系。

### 4.2 CPU 综合警告

已观察到：

```text
[Synth 8-7137] Register daccess_addr_reg ... has both Set and reset
[Synth 8-7129] Port ic_cpu_raddr[1] ... is either unconnected or has no load
[Synth 8-3936] ... alu_c_r_reg ... is trimmed
```

这些警告当前没有阻止综合和实现。后续应分别检查复位优先级、未使用地址低位和
被裁剪的 ALU 结果位，但不应在首次上板前进行大范围 CPU 行为修改。

### 4.3 时钟约束重复

```text
[Constraints 18-619] A clock with name 'fpga_clk' already exists
[Synth 8-565] redefining clock 'fpga_clk'
```

`src/xdc/clock.xdc` 和 `src/xdc/miniRV_SoC.xdc` 都定义了 `fpga_clk`。
该问题当前表现为覆盖警告；后续应只保留一处 `create_clock`。

### 4.4 REQP-1839

```text
[DRC 23-804] Only the first 20 REQP-1839 messages were issued
```

该规则提示带异步复位的寄存器正在驱动 Block RAM 的地址或控制输入。当前输出是
警告而不是 Implementation 失败。首次实板验证完成后，应把相关地址/控制寄存器
改为同步复位或移除不必要的复位，并重新执行 Trace 和 Vivado 回归。

## 5. 推荐重建方法

打开 `miniRV.xpr`，在 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

脚本应输出类似：

```text
EGO1 rebuild board memory source: .../src/rtl/board_bram.v
IROM_synth_1 ready: Synthesis Complete!
```

若程序存储器 IP 意外返回 `Using cached IP results`，脚本会停止，避免旧 COE
初始化映像进入 bitstream。此时应按脚本提示重新生成 IROM/DRAM，而不是把缓存
状态当作本次板级映像已经更新。

主工程综合后还应输出：

```text
Post-synthesis memory primitives:
RAMD64E=... RAMB18E1=... RAMB36E1=...
```

如果自动化脚本因 Vivado 运行状态或缓存状态中止，但手动 Synthesis 和
Implementation 均成功，可保留手动结果并继续 Generate Bitstream，不必因为
脚本问题丢弃已经完成的实现。

## 6. 最终验收清单

- [x] AXI Trace：45/45。
- [x] 不再出现 38,400 个 `RAMD64E` 的资源超限。
- [x] 现场手动 Synthesis 未报告失败。
- [x] 现场手动 Implementation 未报告失败。
- [x] Generate Bitstream 成功。
- [x] Hardware Manager 识别 EGO1 并成功烧录。
- [x] UART 115200 8N1 接收字符 `A`。
- [x] 数码管显示 `00000041`，与字符 `A` 的 ASCII 编码一致。
- [x] 拨码不全为零时允许连续字符测试。
- [x] 拨码全部为零时只处理当前字符，然后结束测试。

以下内容属于后续报告归档材料，不影响已经完成的功能验收：

- [ ] 保存 post-synthesis utilization，确认 Block RAM 与 LUT 使用量。
- [ ] 保存 Timing Summary，确认 `WNS >= 0`、`TNS = 0`。
- [ ] 保存完整 UART 启动文本和字符回显截图。
- [ ] 保存 LED 显示照片。

## 7. 相关文件

- `BOARD_BRINGUP.md`：完整上板步骤。
- `rebuild_ego1.tcl`：IP 与 Vivado 自动重建脚本。
- `src/rtl/board_bram.v`：IROM/DRAM 适配层。
- `src/rtl/axi_board_soc.v`：EGO1 AXI 从设备及外设。
- `src/coe/main.mem`：150 KiB 统一程序映像。
- `src/coe/board_irom.coe`、`src/coe/board_dram.coe`：BMG 初始化文件。
