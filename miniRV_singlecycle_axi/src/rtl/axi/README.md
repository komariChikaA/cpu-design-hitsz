# AXI 与 SoC 模块规划

此目录用于后续添加单周期 AXI SoC 专用 RTL，建议至少区分：

- `axi_master.v`：CPU 请求到 AXI 读写通道的状态机；
- `request_arbiter.v`：取指请求和数据访问请求仲裁；
- `axi_bridge.v`：主存与外设地址译码及总线桥；
- `io_*`：UART、LED、数码管、开关和计时器等外设接口。

首次 AXI Trace 应关闭 Cache；总线基本功能稳定后，再加入 ICache 和 DCache。新增 RTL 或 IP 后需要在 Vivado 工程中显式加入，并更新本说明记录实际模块和地址映射。
