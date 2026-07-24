# miniRV 流水线 Basic Trace 验收报告

- 记录日期：`2026-07-25`
- 来源分支：`origin/feature/pipelined`
- 来源提交：`389b1f1da1df5f3402b790d2cf8dba2ae5a10781`
- 测试环境：Linux，工作目录 `/root/cdp-tests`
- 测试对象：五级流水线 miniRV CPU
- 测试结果：**45/45 通过，0 项失败**
- 完整输出：[miniRV_pipeline_run_all_tests.log](./miniRV_pipeline_run_all_tests.log)

## 结论

日志包含 45 次 `Test Point Pass!`，最终汇总为 `Passed Tests (45)`、
`Failed Tests (0)`；未发现 mismatch、timeout、assert、异常退出或失败测试标记。

本次测试覆盖算术、逻辑、移位、分支、跳转、访存以及 M 扩展指令。测试脚本使用
旧版 `SUMMARY` 标题而不是 `SUMMARY (Basic Tests)`，但测试工程没有
`axi_master`/`bram_axi` 层级，结果属于 Basic Trace。

## 整理修复

验收后将孤立分支中的实现整理进 `miniRV_pipeline/`，并完成以下工程修复：

- 显式声明 `stall_mem`，不再依赖隐式 wire；
- 为 `RUN_TRACE` 下未使用的板级输出提供确定值；
- 将 Trace 与 FPGA 的 ALU、IROM、DRAM 实现改为 `RUN_TRACE` 自动选择；
- 在 Vivado XPR 中显式加入流水寄存器、前递单元和双实现模块；
- 增加 `prepare_trace.sh`，保证子目录模块会平铺进入课程测试框架。

公共包装层没有改变已通过测试的 Trace 实现行为。

## 验收边界

本报告证明流水线 CPU 通过 Basic Trace。非 Trace 分支使用多周期乘除法和 Xilinx
Block Memory Generator，仍需在 Vivado 与 EGO1 上进行独立综合、时序和实板验证。
