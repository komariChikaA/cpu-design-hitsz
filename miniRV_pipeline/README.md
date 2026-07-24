# miniRV 五级流水线 CPU

本工程是在 `miniRV_basic/` 完整指令集实现上改造的实验 2A 流水线 CPU。
队友提交的 `feature/pipelined` 实现已经整理到仓库正常工程结构，并完成
Basic Trace 验收。

## 当前状态

- IF、ID、EX、MEM、WB 五级流水；
- IF/ID、ID/EX、EX/MEM、MEM/WB 四组带 `valid` 的流水寄存器；
- EX/MEM 与 MEM/WB 数据前递；
- load-use 冒险检测与气泡插入；
- 访存和多周期乘除法停顿；
- 分支、JAL、JALR 重定向与错误路径冲刷；
- Trace 调试信号来自真正的 MEM/WB 提交阶段；
- Basic Trace：**45/45 通过，0 项失败**。

测试报告见
[`../trace_test/miniRV_pipeline_report.md`](../trace_test/miniRV_pipeline_report.md)。

## 工程入口

- Vivado 工程：`miniRV.xpr`
- CPU 核心：`src/rtl/cpu_core.v`
- 流水寄存器：`src/rtl/pipeline/pipeline_regs.v`
- 前递单元：`src/rtl/pipeline/forward_unit.v`
- 顶层与 SoC：`src/rtl/cpu_top.v`、`src/rtl/miniRV_SoC.v`
- Trace 安装脚本：`prepare_trace.sh`

## Trace 与 FPGA 实现

工程不再要求手工替换同名模块：

- `RUN_TRACE` 开启时，`ALU.v`、`Inst_ROM.v`、`Data_RAM.v` 自动选择
  `*_trace` 实现，直接适配课程 Verilator 测试；
- `RUN_TRACE` 关闭时，自动选择多周期乘除法和 Xilinx IROM/DRAM IP 实现；
- `miniRV.xpr` 已显式包含全部流水线专用 RTL。

在 Linux 服务器准备并运行 Basic Trace：

```bash
bash miniRV_pipeline/prepare_trace.sh ~/cdp-tests
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

脚本会备份服务器上原有的 `mySoC`，并把子目录中的流水线模块平铺到
`cdp-tests/mySoC/`。

## 改造边界

流水线核心继续使用简单的取指和数据请求/响应接口，没有把 AXI 五通道直接耦合进
`cpu_core`。已验证的单周期 AXI Master、板级 BRAM 和外设仍保存在
`miniRV_singlecycle_axi/` 与 `miniRV_singlecycle_axi_ego1/`。

下一阶段是在保持本工程 Basic Trace 回归的前提下，将流水线 CPU 接入现有 AXI
路径，再依次验证 AXI Trace、Vivado 综合/时序和 EGO1 上板。

## 验收边界

现有 45/45 结果证明 `RUN_TRACE` 下的流水线功能正确。FPGA 分支已经补齐并通过
结构检查，但多周期乘除法、Vivado 时序和实板行为仍需单独回归，不能由 Basic
Trace 结果替代。
