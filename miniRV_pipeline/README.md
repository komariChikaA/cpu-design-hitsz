# miniRV 流水线 CPU 实验基线

本工程由仓库中已经通过完整 miniRV Basic Trace 的 `miniRV_basic/` 复制而来。当前 RTL 仍然是单周期 CPU；建立此目录的目的是冻结一份可运行基线，后续只在本目录内完成实验 2A 的流水线改造。

## 工程入口

- Vivado 工程：`miniRV.xpr`
- CPU 核心：`src/rtl/cpu_core.v`
- 顶层与 SoC：`src/rtl/cpu_top.v`、`src/rtl/miniRV_SoC.v`
- 流水线新增模块规划：`src/rtl/pipeline/README.md`
- 基线回归脚本：仓库根目录 `trace_test/run_miniRV_all_tests.sh`

## 改造边界

流水线改造应保留 `cpu_core` 现有的取指和数据访问请求/响应接口。不要把 AXI 五通道直接耦合进流水线核心；AXI、Cache、总线桥和外设属于 SoC 层，由另一个基础工程先行验证。

建议保留现有 `Controller`、`RF`、`SEXT`、`ALU`、`MREQ` 和 `MEXT` 等功能模块，优先改造 `cpu_core` 内部的指令推进方式。

## 推荐实现顺序

1. 加入 IF/ID、ID/EX、EX/MEM、MEM/WB 四组带 `valid` 的流水寄存器。
2. 使用无相关、无访存、无乘除法、无跳转程序验证理想五级流水线。
3. 增加 RAW 冒险检测，先用暂停保证正确性。
4. 实现默认预测不跳转，跳转成立时重定向 PC 并清空错误指令。
5. 处理访存和乘除法的多周期暂停，请求或启动信号只能发出一次。
6. 增加数据前递；Load-use 等数据尚未产生的情况继续暂停。
7. 让 Trace 调试信号来自真正的 MEM/WB 提交级，并通过完整 Basic Trace。

## 阶段验收

每个阶段都应保存最小定向程序和关键波形。最终验收条件是：完整指令集 Basic Trace 全部通过，流水线暂停期间无重复访存请求，错误路径指令不会写寄存器或存储器。
