# 实验室快速开始

## 需要携带

带上完整的 `miniRV_pipeline_axi_ego1/` 文件夹，不能只复制 `miniRV.xpr`。
若使用仓库根目录生成的压缩包，先完整解压到不含中文和空格的短路径，例如：

```text
C:\Workspace\miniRV_pipeline_axi_ego1
```

当前压缩包已经内置 `1_pipeline_mext_test` 镜像，可以同时检查 AXI 访存、流水线
多周期 M 扩展、UART、LED、拨码和数码管。只有修改测试程序后才需要在 Linux
服务器重新执行：

```bash
cd ~/miniRV_pipeline_axi_ego1
bash prepare_program.sh 1_pipeline_mext_test
wc -l src/coe/main.mem
```

最后一行必须是 `38400`；随后应带走这份更新后的完整目录。

## Vivado

1. 用 Vivado 2023.2 打开 `miniRV.xpr`。
2. 确认器件是 `xc7a35tcsg324-1`，顶层是 `miniRV_SoC`。
3. 在 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

4. 只有脚本打印 `EGO1 build finished.` 才使用本次 bitstream：

```text
outputs/vivado/miniRV_pipeline_axi_ego1.bit
```

脚本失败时不要点击旧的 `Generate Bitstream` 结果继续烧录，应保存完整错误并查看
`VIVADO_BRINGUP_ISSUES.md`。

## 烧录与串口

1. Hardware Manager → Open Target → Auto Connect。
2. Program Device，选择上述 `.bit`。
3. 串口使用 `115200 8N1`，关闭流控。
4. `S6 RST` 是 CPU 复位；不要按 `S5 PROG#`，后者会清除 FPGA 配置。
5. 流水线专项程序通过时应显示：

```text
串口：<Phase 0> M-extension self-test: PASS
LED：00A5
数码管：600D600D
```

随后输入 `A`，应回显且数码管显示 `00000041`。

若之后主动执行 `bash prepare_program.sh 0_uart_test` 恢复 UART 基础程序，则
串口首先输出 `miniRV AXI EGO1 Test #0 - UART simple test`，输入 `A` 后同样
应回显并显示 `00000041`，但它不包含 M 扩展自检。

## 离开实验室前

填写 `BOARD_VALIDATION_TEMPLATE.md`，并复制回：

- `outputs/vivado/*.rpt` 和本次 `.bit`；
- `vivado.log` 或完整 Messages；
- UART 输出截图；
- LED、数码管和开发板照片；
- 本次使用的 `main.c`、`main.coe`、`main.mem`。

详细步骤见 `BOARD_BRINGUP.md`。
