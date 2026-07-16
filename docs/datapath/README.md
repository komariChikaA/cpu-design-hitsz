# miniRV 数据通路图

这里保存两张由结构化模型生成的 SVG：

- `system.svg`：`cpu_top` 层级的 `Inst_ROM ↔ cpu_core ↔ Data_RAM` 接口图。
- `core.svg`：`cpu_core` 内部的 IF、ID、EX、MEM、WB 数据通路和多周期状态。
- `compact.svg`：接近课程参考图的紧凑教学版，省略握手和多周期实现细节。
- `system.png`、`core.png`、`compact.png`：便于预览和直接插入不支持 SVG 的文档。

## 生成

```powershell
cd docs/datapath
npm.cmd install --cache .npm-cache
npm.cmd run build
```

生成器采用 ELK.js layered 布局、阶段分区约束和正交连线。图形源数据位于 `model/`，不要直接手工修改生成的 SVG/PNG；需要改模块、端口或连接时，修改 JSON 后重新生成。

也可以只生成一张图：

```powershell
node generate.mjs system
node generate.mjs core
node generate.mjs compact
```

## 表达约定

- 蓝色粗线：数据总线。
- 橙色线：控制信号或使能。
- 紫色虚线：跨周期请求、应答、busy、完成信号。
- 红色虚线：目标设计连接，当前 RTL 尚未实现。
- 灰色点线：当前 RTL 中为了占位或尚未完成而存在的特殊连接。
- 橙色虚线模块边框和 `TODO` 徽标：模块已有结构，但功能仍不完整。

当前必须保留的实现差异：

1. `cpu_core.v` 中 `MREQ.ram_wdata` 当前接 `32'h0`；目标设计应接 `RF.rD2`。
2. `Controller.v` 中 `is_mul`、`is_div` 当前固定为 0。
3. `ALU.v` 中 `busy` 当前固定为 0，乘除法单元虽然已实例化，但控制路径尚未接通。
4. `MREQ.v` 与 `MEXT.v` 仍有访存类型相关的 TODO。

因此 `core.svg` 同时显示当前实线连接与红色目标连接，避免把目标结构误认为已经实现。

## 视觉精修

SVG 可直接提交到仓库、嵌入 Markdown/网页，也可以导入 Figma 做展示版微调。Figma 只负责视觉精修；模块、端口、连接关系仍以 JSON 模型和 RTL 为准。
