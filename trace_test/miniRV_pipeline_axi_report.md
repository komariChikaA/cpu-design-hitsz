# miniRV 流水线 AXI Trace 验收报告

- 记录日期：`2026-07-25`
- 测试分支：`agent/integrate-pipeline-axi`
- 测试环境：Linux，工作目录 `/root/cdp-tests`
- 测试对象：无 Cache 五级流水线 miniRV CPU + 单事务 AXI4 Master
- 测试框架：AXI Trace，使用 `vsrc/bram_axi.v`
- 最终结果：**45/45 通过，0 项失败**
- 完整输出：[miniRV_pipeline_axi_run_all_tests.log](./miniRV_pipeline_axi_run_all_tests.log)

## 结论

最终日志包含 45 次 `Test Point Pass!`，汇总为 `Passed Tests (45)`、
`Failed Tests (0)`，未出现 mismatch、timeout、assert、异常退出或失败测试标记。
测试覆盖完整的算术、逻辑、移位、分支、跳转、访存和 M 扩展测试集合，包括
`start`、`sb`、`sh` 和 `sw`。

测试工程保持课程 AXI Trace 所需层级：

```text
miniRV_SoC
├── U_cpu : cpu_top
│   ├── U_core : cpu_core
│   └── U_aximaster : axi_master
└── U_bram : bram_axi
```

## 初测问题与修复

第一次流水线 AXI Trace 回归通过 41 项，失败项为 `sh`、`start`、`sw` 和 `sb`。
失败日志显示同一条 store 的 `debug_mem_we` 在 AXI 等待期间持续有效；AXI Master
产生响应并回到空闲态后，流水线还要到下一个时钟沿才撤销原请求，因此旧请求还可能
被再次接受。

修复分为两部分：

- 在 `cpu_top.v` 中屏蔽 AXI 响应脉冲期间尚未撤销的取指、数据读和数据写请求，
  避免已完成事务被重复发起，同时保留真正背靠背请求的能力；
- 在流水线 AXI 专用 `cpu_core.v` 中，仅在写响应完成时产生一次
  `debug_mem_we`，使 Trace 事件与架构 store 一一对应。

流水线分支跳转期间还会校验在途取指地址；若 AXI 返回的是跳转前的过期响应，则丢弃
该响应并重新请求跳转目标。

## 本地结构检查

使用与课程 `bram_axi` 相同端口表的结构模型展开 `RUN_TRACE` 完整层级，并执行
Yosys `hierarchy -check`、`proc` 和 `check`，结果为 `0 problems`。流水线核心仍来自
已通过 45/45 Basic Trace 的 `miniRV_pipeline/`；单事务 AXI Master 仍来自已通过
45/45 单周期 AXI Trace 的 `miniRV_singlecycle_axi/`。

## 验收边界

本报告证明无 Cache 流水线 CPU 已通过 AXI Trace。它不代表 Vivado 综合、实现、
时序或 EGO1 实板已经通过。下一阶段应复用已验证的
`miniRV_singlecycle_axi_ego1/` 板级内存、UART、时钟、复位和约束，建立独立的
`miniRV_pipeline_axi_ego1/` 并重新完成板级验收。
