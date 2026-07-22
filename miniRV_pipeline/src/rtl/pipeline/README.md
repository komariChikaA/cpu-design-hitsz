# 流水线模块规划

此目录用于后续添加流水线专用 RTL。建议按职责拆分，而不是把全部控制逻辑堆入 `cpu_core.v`：

- `pipeline_regs.v`：IF/ID、ID/EX、EX/MEM、MEM/WB 流水寄存器；
- `hazard_unit.v`：RAW、Load-use 和多周期操作冒险检测；
- `forward_unit.v`：EX/MEM、MEM/WB 数据前递选择；
- `pipeline_ctrl.v`：各级 `stall`、`flush`、`valid` 和重定向控制。

文件名可以随实际设计调整。新增 RTL 后需要在 Vivado 工程中显式加入源文件，并同时更新本说明。
