# miniRV 五级流水线 AXI Trace

本目录把已经通过 Basic Trace 的五级流水线 CPU 接到已经验证的单事务 AXI4 Master，
用于实验 2B 的下一阶段验收。它是独立工程，不修改
`miniRV_pipeline/` 和 `miniRV_singlecycle_axi/` 两条已通过的基线。

## 当前范围

- IF、ID、EX、MEM、WB 五级流水线、前递、暂停、冲刷和多周期乘除法来自
  `miniRV_pipeline/`。
- AXI Master 和 `bram_axi U_bram` 顶层连接来自
  `miniRV_singlecycle_axi/`。
- `cpu_top.v` 增加流水线专用的取指响应校验：分支跳转发生时，若跳转前的 AXI
  取指仍在途，其返回值会被丢弃，随后重新请求跳转目标地址。
- CPU 请求在 AXI 响应脉冲期间会被屏蔽，避免 Master 已回到空闲态而流水线尚未撤销
  请求时重复发起同一笔取指、读或写事务；store 的 Trace 写事件只在写响应完成时产生。
- FPGA 多周期乘除法在启动拍即暂停 EX，先锁存前递后的源操作数，再等待结果完成；
  空泡不会重新启动旧指令，连续相同的 M 扩展指令也会分别执行。
- AXI Trace 已完成 **45/45 通过，0 项失败**；Vivado、时序和 EGO1 上板尚未在
  本目录验收。

完整验收报告见
[`../trace_test/miniRV_pipeline_axi_report.md`](../trace_test/miniRV_pipeline_axi_report.md)。

## 层级约定

AXI Trace 所需名称保持不变：

```text
miniRV_SoC
├── U_cpu : cpu_top
│   ├── U_core : cpu_core
│   └── U_aximaster : axi_master
└── U_bram : bram_axi
```

`bram_axi` 由 AXI 版 `cdp-tests/vsrc/bram_axi.v` 提供，不应复制进本目录。

## Linux 验收

将整个 `miniRV_pipeline_axi/` 目录放到服务器后执行：

```bash
bash miniRV_pipeline_axi/prepare_trace.sh ~/cdp-tests
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

脚本会先把原 `mySoC` 备份为带时间戳的目录，再把本工程 RTL 平铺到
`cdp-tests/mySoC/`。验收日志应明确显示使用 AXI Trace，并以测试目录中运行时发现的
全部 `.bin` 为准；本工程的已验证结果为 45/45。

## 本地 RTL 回归

Ubuntu/Debian 安装 `iverilog` 后执行：

```bash
bash miniRV_pipeline_axi/tests/run_iverilog.sh
```

该脚本验证：

- 多周期 `MUL/MULH/MULHU/DIV/DIVU/REM/REMU`、除零和有符号溢出；
- 完整流水线中的相关操作数前递、连续 M 扩展指令和写回；
- `RUN_TRACE` 与 FPGA 两种 ALU 选择；
- AXI 读写地址对齐、读优先级、AW/W 独立握手和背压期间信号稳定；
- 分支重定向后丢弃旧取指响应并重新请求目标地址；
- `cpu_top` 在两种构建模式下均可完整展开。

同一检查由 `.github/workflows/pipeline-axi-rtl.yml` 在 PR 中自动执行。

## 后续边界

真实 AXI Trace 已通过，后续按下列顺序推进：

1. 以已经上板成功的 `miniRV_singlecycle_axi_ego1/` 为板级基线建立
   `miniRV_pipeline_axi_ego1/`；
2. 复用时钟、复位、BRAM、UART 和 EGO1 约束；
3. 在 Vivado 中重新完成综合、实现、时序检查和 bitstream；
4. 使用已验证的 UART 程序做实板回归。

Basic Trace 通过不能替代 AXI Trace；AXI Trace 通过也不能替代 Vivado 和实板验收。
本目录是可合并的 Trace/RTL 基线，不包含 Xilinx IP、XDC 或 bitstream；板级内容应放在
独立的 `miniRV_pipeline_axi_ego1/`，避免把未经 Vivado 验证的生成文件混入本工程。
