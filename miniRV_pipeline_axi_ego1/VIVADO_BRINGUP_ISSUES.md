# 流水线 AXI EGO1 常见问题

## `clk_wiz_0_synth_1`、IROM 或 DRAM 显示 cached IP results

程序映像可能没有进入本次 bitstream。必须从 Tcl Console 运行
`source rebuild_ego1.tcl`。脚本会禁用 IP cache；若仍返回 cached 状态会主动停止。

## 找不到 `ip_user_files` 或 GeneratedRun

这是工程复制到另一台电脑后的生成目录丢失。不要手工复制旧 `.runs` 或
`.ip_user_files`，直接运行重建脚本重新生成三个 XCI 的输出产物。

## 找不到 `main.mem`

必须携带整个工程目录。文件应位于：

```text
src/coe/main.mem
```

若刚编译程序，运行：

```bash
bash prepare_program.sh 1_pipeline_mext_test
```

并确认文件正好 38,400 行。

## BRAM 超量或出现数万个 RAMD64E

说明工程使用了旧的大型 Verilog 数组，或者同时加入了两套存储器。当前工程只能使用：

```text
board_bram U_memory
├── IROM U_program_memory
└── DRAM U_data_memory
```

不要关闭资源 DRC 强行实现。检查 Sources 中不存在 `Inst_ROM.v`、`Data_RAM.v`，
并重新运行脚本。

## REQP-1839

本工程已经把 BRAM-facing AXI Master 和板级 AXI 从设备改为同步复位。若仍出现
REQP-1839，请保存完整 DRC 文本及涉及的寄存器层级，不要直接把它降级为 warning。

## WNS 为负

脚本会在负 WNS 时停止。保存 `timing_summary.rpt`，重点记录最差路径起点、终点和
逻辑级数。不要通过删除时钟约束或伪造 false path 让报告变绿。

可先确认：

- 使用的确实是 50 MHz `clk_wiz_0` 输出；
- 没有定义 `RUN_TRACE`，否则组合乘除法会进入 FPGA；
- Sources 里只有一份 CPU 和一份 AXI Master；
- 时钟约束只创建一次 `fpga_clk`。

## Bitstream 成功但串口没有输出

依次检查：

1. bitstream 时间是否为本次构建；
2. IROM/DRAM 三个 IP run 是否重新完成；
3. 串口是否为正确 COM、115200 8N1、无流控；
4. 是否误按 S5 清除了配置；
5. 按下并松开 S6；
6. 交换 RX/TX 不是本板默认操作，不要随意改 XDC。

如果数码管保持全零且 UART 完全无输出，优先怀疑旧程序映像或 CPU 未取指。

## M 扩展测试失败

数码管格式为 `E000000x`，低位编号含义：

| 编号 | 指令或边界 |
|---:|---|
| 1 | MUL |
| 2 | MULH |
| 3 | MULHU |
| 4 | DIV |
| 5 | DIVU |
| 6 | REM |
| 7 | REMU |
| 8–11 | 除零 |
| 12–13 | `INT_MIN / -1` 与余数 |

保存编号和串口输出。该类失败与普通 UART 通信失败分开处理。
