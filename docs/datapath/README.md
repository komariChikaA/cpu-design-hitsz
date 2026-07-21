# miniRV 数据通路图

这里保存三张由结构化模型生成的 SVG：

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

## 与最终 RTL 的对应关系

1. Store 数据由寄存器堆第二读口 `RF.rD2` 送入 `MREQ.ram_wdata`。
2. `Controller` 产生 `is_mul`、`is_div`，`ALU` 内的迭代乘除法单元通过 `busy` 参与跨周期完成控制。
3. `MREQ` 完成字节/半字/字的写使能和写数据对齐，`MEXT` 完成读取结果的移位及符号/零扩展。
4. `core.svg` 展示握手、多周期状态和完成控制；`compact.svg` 为验收讲解而省略这些实现细节。

三张图均以当前实验一最终 RTL 为准，不再包含旧 starter 版本的占位连接或 `TODO` 标记。

## 视觉精修

SVG 可直接提交到仓库、嵌入 Markdown/网页，也可以导入 Figma 做展示版微调。Figma 只负责视觉精修；模块、端口、连接关系仍以 JSON 模型和 RTL 为准。
