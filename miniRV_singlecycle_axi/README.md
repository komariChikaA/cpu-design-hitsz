# miniRV 单周期 AXI SoC 实验基线

本工程由仓库中已经通过完整 miniRV Basic Trace 的 `miniRV_basic/` 复制而来。当前工程仍使用原有取指和数据访问实现，尚未包含 AXI Master、Cache 或新 I/O；建立此目录是为了在不影响单周期基线和流水线实验的前提下完成实验 2B。

## 工程入口

- Vivado 工程：`miniRV.xpr`
- CPU 核心：`src/rtl/cpu_core.v`
- 顶层与 SoC：`src/rtl/cpu_top.v`、`src/rtl/miniRV_SoC.v`
- AXI/SoC 新增模块规划：`src/rtl/axi/README.md`
- Trace 说明：仓库根目录 `docs/TRACE_TESTING.md`

## 改造边界

保持 `cpu_core` 的 `ifetch_*` 和 `daccess_*` 请求/响应接口，把 AXI 协议转换放在核心外部。这样通过 AXI Trace 的 SoC 外壳以后可以继续接入 `miniRV_pipeline/` 中完成的流水线核心。

单周期 CPU 接入 AXI 后，访存操作允许等待多个周期：CPU 在请求发出后暂停，直到读数据有效或写响应返回。一次访问只能发出一次请求，不能在等待期间重复启动 AXI 事务。

## 推荐实现顺序

1. 使用状态机实现一次只处理一个事务的 AXI Master。
2. 添加取指/数据请求仲裁、总线桥和 AXI 主存，先禁用 Cache。
3. 使用单周期 CPU 通过 AXI Trace，确认读写通道和 Trace 提交时机正确。
4. 接入拨码开关、LED、数码管、UART 和计时器等 I/O。
5. 启用并验证 ICache、DCache，再次通过 AXI Trace。
6. 最后保持接口不变，将单周期核心替换为已经通过 Basic Trace 的流水线核心。

## 阶段验收

至少分别验证普通读写、窄访问、连续访存、总线等待和错误路径无副作用。最终应保留禁用 Cache 与启用 Cache 两种配置的 AXI Trace 结果，方便集成流水线后回归。
