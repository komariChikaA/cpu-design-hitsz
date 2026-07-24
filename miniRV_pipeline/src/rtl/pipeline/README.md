# 流水线专用模块

## 流水与冒险

- `pipeline_regs.v`：IF/ID、ID/EX、EX/MEM、MEM/WB 流水寄存器，支持
  `stall`、`flush` 和 `valid`。
- `forward_unit.v`：生成 EX/MEM 与 MEM/WB 到 EX 级的前递选择。
- load-use、访存停顿、乘除法停顿、控制转移和请求去重逻辑位于
  `../cpu_core.v`，以避免把大量阶段信号跨模块传递。

## Trace/FPGA 双实现

- `ALU_trace.v`：Trace 使用的组合乘除法实现。
- `ALU_multicycle.v`：FPGA 使用的多周期乘除法实现。
- `Inst_ROM_trace.v`、`Data_RAM_trace.v`：从 `meminit.bin` 加载测试程序。
- `Inst_ROM_fpga.v`、`Data_RAM_fpga.v`：连接 Xilinx IROM/DRAM IP。

`../ALU.v`、`../Inst_ROM.v` 和 `../Data_RAM.v` 是稳定的公共包装层，根据
`RUN_TRACE` 自动选择实现。不要再通过复制文件或修改模块名来切换构建目标。
