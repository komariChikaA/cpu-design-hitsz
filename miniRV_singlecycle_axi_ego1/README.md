# miniRV 单周期 AXI EGO1 工程

本目录是 `miniRV_singlecycle_axi/` 的独立上板工程。原 AXI Trace 工程和
`miniRV_pipeline/` 流水线工程均保持独立，不在本目录中混合开发。

## 最终状态

截至 2026-07-24，本阶段已完成：

- 单周期 CPU 接入单事务 AXI4 Master；
- AXI Trace 45/45 通过；
- Vivado 2023.2 Synthesis、Implementation 和 bitstream 生成；
- EGO1 Hardware Manager 下载；
- 50 MHz 板级时钟和 S6 低有效复位；
- UART 115200 8N1；
- 串口输入字符 `A` 后，数码管显示 `00000041`；
- 拨码不全为零时可以连续输入测试；
- 拨码全部为零时，程序处理当前字符后打印 `Test ended.` 并结束。

详细上板步骤见 [BOARD_BRINGUP.md](./BOARD_BRINGUP.md)，完整问题与修复记录见
[VIVADO_BRINGUP_ISSUES.md](./VIVADO_BRINGUP_ISSUES.md)。

## 板级结构

- `src/rtl/axi_master.v`：取指、数据读和数据写请求仲裁，支持单拍 AXI4、
  总线等待和字节写使能。
- `src/rtl/axi_board_soc.v`：AXI 存储器/外设从设备。
- `src/rtl/board_bram.v`：显式连接 Xilinx `IROM` 和 `DRAM` Block Memory
  Generator，避免大数组被映射成 LUT RAM。
- `src/rtl/simple_uart.v`：115200 baud 板级 UART。
- `src/rtl/sevenseg_display.v`：八位十六进制数码管扫描显示。
- `rebuild_ego1.tcl`：从 `main.mem` 生成两个 COE，禁用旧 IP cache，重新生成
  IP、综合、实现并生成 bitstream。

存储器布局：

| 地址范围 | 容量 | 实现 |
| --- | ---: | --- |
| `0x0000_0000`–`0x0000_C7FF` | 50 KiB | `IROM`，12,800 × 32 bit |
| `0x0000_C800`–`0x0002_57FF` | 100 KiB | `DRAM`，25,600 × 32 bit |

外设地址：

| 地址 | 功能 |
| --- | --- |
| `0xFFFF_0000` | 拨码开关（读） |
| `0xFFFF_1000` | LED（写） |
| `0xFFFF_2000` | 数码管（写） |
| `0xFFFF_3000/+4/+8/+C` | UART RX/TX/状态/控制 |
| `0xFFFF_4000/+8` | 64 位计时器低/高 32 位（读） |

## 程序和 Vivado 重建

最终验收程序位于：

```text
software/c_test/0_uart_test/
```

其中 `main.coe` 是服务器编译结果，`src/coe/main.mem` 是固定补齐为 38,400 个
32 位字的统一映像。替换程序后先重新生成 `main.mem`：

```powershell
python .\tools\bin2mem.py `
  .\software\c_test\0_uart_test\main.coe `
  .\src\coe\main.mem
```

然后打开 `miniRV.xpr`，在 Vivado Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

仓库只保留 `IROM.xci`、`DRAM.xci` 和 `clk_wiz_0.xci`，不保留可再生成的
DCP/MIF/仿真网表。新电脑首次打开工程时出现 IP output products 未生成提示是
预期现象，运行上述脚本即可重建。

必须看到 IROM/DRAM 实际完成综合，而不是 `Using cached IP results`。最终
bitstream 通常位于：

```text
miniRV.runs/impl_1/miniRV_SoC.bit
```

## 与流水线组员的后续衔接

当前单周期 AXI/EGO1 阶段已经完成，不再继续改动 CPU 行为。下一步只需等待组员
完成 `miniRV_pipeline/` 的 Basic Trace。

收到流水线结果后再进行下一阶段：

1. 核对流水线工程的 Basic Trace 报告和 RTL 层级。
2. 保留本工程已经验证的 AXI Master、板级 AXI 从设备、IROM/DRAM、UART 和约束。
3. 将流水线 CPU 的取指/访存接口接入 AXI 路径，不直接覆盖本目录。
4. 依次回归 Basic Trace、AXI Trace、Vivado 和 EGO1 上板。

在组员结果到达前，不需要继续修改本目录。
