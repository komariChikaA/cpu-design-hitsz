# 最终 CoreMark 流水线 AXI 自学材料

优先使用：

- [可搜索 HTML 手册](./miniRV_CoreMark流水线AXI_代码与波形自学手册.html)
- [固定版 PDF 手册](./miniRV_CoreMark流水线AXI_代码与波形自学手册.pdf)
- [Markdown 源讲义](../COREMARK_PIPELINE_AXI_STUDY_GUIDE.md)

内容只针对 `miniRV_pipeline_axi_ego1/` 最终 CoreMark 工程，覆盖：

1. 完整模块层级和 21 个手写 RTL 文件职责；
2. IF、ID、EX、MEM、WB 在代码中的实现；
3. 前递、load-use、store 数据旁路、分支冲刷、AXI 等待和 RV32M；
4. AXI AR/R、AW/W/B 五通道；
5. BRAM、LED、数码管、switch、timer 和 UART；
6. 四份原始 VCD 的生成、Surfer/GTKWave 打开方式和信号组；
7. Vivado Behavioral Simulation 与实板 ILA 的适用边界；
8. 下一次验收前的自测题。

重新生成 HTML/PDF：

```powershell
python -B docs/acceptance/training/build_study_manual.py --repo-root .
```

PDF 由本机 Chrome/Edge 无头打印生成。生成后应使用 `pdfinfo`、
`pdftoppm` 和逐页图片检查页数、图像、代码块与表格是否完整。
