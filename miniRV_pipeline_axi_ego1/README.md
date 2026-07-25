# miniRV 五级流水线 AXI EGO1 工程

本目录是流水线 AXI 的独立板级工程，供 Vivado 2023.2 综合、实现、生成
bitstream 和 EGO1 实板验收使用。它由两条已经验证的基线组合而成：

- `miniRV_pipeline_axi/`：45/45 AXI Trace、定向 RTL 回归和云端 CI 均通过；
- `miniRV_singlecycle_axi_ego1/`：时钟、复位、Block Memory、UART、拨码、
  LED、数码管和 XDC 已在 EGO1 上验证。

当前仓库已经完成板级工程准备和离线结构检查，但本目录的 Vivado 时序及实板结果
必须在实验室实际生成，不能用 AXI Trace 或单周期上板结果替代。

## 目录内容

- `miniRV.xpr`：EGO1 工程，器件为 `xc7a35tcsg324-1`。
- `src/rtl/`：流水线 AXI CPU、板级 AXI 从设备和外设。
- `src/rtl/pipeline/`：流水寄存器、前递和 Trace/FPGA 两套 ALU。
- `src/rtl/ip/`：`IROM`、`DRAM`、`clk_wiz_0` 三个可重新生成的 XCI。
- `src/xdc/`：EGO1 引脚、I/O 电平和时钟约束。
- `src/coe/main.mem`：38,400 × 32 bit 的统一程序映像。
- `rebuild_ego1.tcl`：重新生成 IP、综合、实现、时序检查和 bitstream。
- `tests/run_iverilog.sh`：不依赖 Vivado 的流水线 AXI RTL 回归。
- `LAB_QUICK_START.md`：到实验室后可以直接照做的最短操作清单。
- `BOARD_BRINGUP.md`：实验室逐步操作清单。
- `BOARD_VALIDATION_TEMPLATE.md`：需要带回仓库的验收记录。

## 默认程序与流水线专项程序

仓库当前的 `main.mem` 与 `0_uart_test/main.coe` 对应，可直接用于第一次 UART、
拨码、LED 和数码管基线测试。

流水线还应运行 `1_pipeline_mext_test/main.c`。该程序会先执行真实的
`MUL/MULH/MULHU/DIV/DIVU/REM/REMU`、除零和有符号溢出指令，再进入 UART
交互。由于生成 RISC-V 程序需要 Linux 工具链，去实验室前在 Linux 服务器运行：

```bash
cd ~/miniRV_pipeline_axi_ego1
bash prepare_program.sh 1_pipeline_mext_test
```

脚本会调用目录中的 `compile.sh`，然后把结果转换为 38,400 行
`src/coe/main.mem`。若只想恢复原 UART 程序：

```bash
bash prepare_program.sh 0_uart_test
```

## 本机预检查

Windows PowerShell 中执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verify_package.ps1
```

有 Icarus Verilog 的 Linux 环境还可执行：

```bash
bash tests/run_iverilog.sh
```

## Vivado 一键重建

1. 把整个 `miniRV_pipeline_axi_ego1/` 带到实验室电脑。
2. 用 Vivado 2023.2 打开 `miniRV.xpr`。
3. 在 Tcl Console 中执行：

```tcl
source rebuild_ego1.tcl
```

脚本会拒绝错误器件、`RUN_TRACE`、旧单周期源文件、旧多周期 ALU、大型推断数组、
过期 IP cache、BRAM 超量和负 WNS。成功后产物集中在：

```text
outputs/vivado/
├── miniRV_pipeline_axi_ego1.bit
├── post_synth_utilization.rpt
├── post_synth_drc.rpt
├── utilization.rpt
├── timing_summary.rpt
├── implementation_drc.rpt
└── clock_utilization.rpt
```

完整操作和预期现象见 [BOARD_BRINGUP.md](./BOARD_BRINGUP.md)。

## 验收边界

满足以下条件后才能称为流水线 AXI EGO1 验收通过：

- Vivado Synthesis、Implementation、Generate Bitstream 全部成功；
- `RAMD64E` 没有再次大规模出现，BRAM/LUT 未超量；
- `WNS >= 0`，Timing Summary 中没有未约束关键时钟；
- Hardware Manager 成功烧录；
- 流水线 M 扩展专项程序打印 `PASS`；
- UART 输入 `A` 后回显，数码管显示 `00000041`；
- LED、拨码开关和 S6 复位行为符合说明。

不要按 `S5 PROG#` 进行 CPU 复位；它会清除 FPGA 配置。CPU 复位使用 `S6 RST`。
