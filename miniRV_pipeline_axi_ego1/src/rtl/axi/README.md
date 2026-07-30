# AXI 与 SoC 模块说明

AXI/板级模块已放在上一级 `src/rtl/`，以便直接复制全部 HDL 到 Trace 框架：

- `ICache.v`：64-line direct-mapped 取指 Cache，四拍 read refill。
- `DCache.v`：write-through/no-write-allocate 数据 Cache，MMIO Uncached。
- `axi_master.v`：I/D Cache 请求仲裁、四拍 read line 拼接和单拍写。
- `axi_board_soc.v`：EGO1 使用的 BRAM burst、地址译码、MMIO AXI 从设备。
- `simple_uart.v`：50 MHz、115200 baud 的单字节缓冲 UART。
- `sevenseg_display.v`：八位十六进制数码管扫描显示。
- `miniRV_SoC.v`：在 `RUN_TRACE` 下连接 `bram_axi U_bram`，否则连接 EGO1 板级从设备。

当前 ICache/DCache 已插入 CPU 访存接口和 `axi_master` 之间。普通取指/数据 read
miss 使用 4-beat INCR burst；外设读写保持 Uncached 单拍。完整状态机和验收信号见
[`docs/acceptance/CACHE_IMPLEMENTATION_AND_DEFENSE.md`](../../../../docs/acceptance/CACHE_IMPLEMENTATION_AND_DEFENSE.md)。
