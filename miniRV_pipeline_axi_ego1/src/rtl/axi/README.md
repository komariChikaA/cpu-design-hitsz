# AXI 与 SoC 模块说明

AXI/板级模块已放在上一级 `src/rtl/`，以便直接复制全部 HDL 到 Trace 框架：

- `axi_master.v`：CPU 请求仲裁与单拍 AXI4 主设备。
- `axi_board_soc.v`：EGO1 使用的统一 BRAM、地址译码和 AXI 从设备。
- `simple_uart.v`：50 MHz、115200 baud 的单字节缓冲 UART。
- `sevenseg_display.v`：八位十六进制数码管扫描显示。
- `miniRV_SoC.v`：在 `RUN_TRACE` 下连接 `bram_axi U_bram`，否则连接 EGO1 板级从设备。

当前为无 Cache 的 AXI Trace 首通配置。后续 ICache/DCache 应插入 CPU 访存接口和 `axi_master` 之间，不需要改动 SoC 对外的 AXI 通道。
