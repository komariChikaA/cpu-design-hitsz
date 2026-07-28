# 课程报告与验收证据

本目录集中保存可以进入 Git、可以复核且适合长期维护的课程交付物。Vivado
bitstream、仿真可执行文件、工具缓存和重复打包文件不在此处保存。

## 目录结构

```text
docs/course-report/
├── 计算机设计与实践-实验报告.docx
├── figures/                 # 报告高清 PNG 与可编辑 SVG
├── vcd/                     # 生成流水线/AXI 波形图的原始 VCD
└── board-evidence/
    ├── singlecycle/         # C_TEST0～2 照片和 Vivado 原始报告
    ├── pipeline/            # M 扩展、UART 和实现状态
    └── coremark/            # CoreMark 串口结果和板卡同框照片
```

## 已覆盖的课程要求

- 单周期 SoC：C_TEST0、C_TEST1、C_TEST2 均有实板照片和 Timing、Utilization、
  Power 原始报告；
- 流水线 SoC：有 M 扩展自测、UART 输入 `A` 和板级显示证据；
- CoreMark：有两位学号、50 MHz、700 次迭代、CRC、得分和
  `Correct operation validated` 的完整串口截图；
- Vivado：流水线实现截图显示 WNS 1.702 ns、TNS 0 ns、失败端点 0；
- 报告插图：单周期完整数据通路、半字访存、乘法、流水线数据通路、AXI
  状态机、流水线冒险、AXI 读写事务；
- 原始波形：保留流水线 load-use 和无 Cache AXI 事务 VCD。

本设计没有实现 Cache。报告中的总线波形应准确描述为“无 Cache 的直接 AXI
读写事务”，不能写成 Cache miss。

## 重新生成图和报告

在仓库根目录运行：

```powershell
node docs/datapath/generate_report_evidence.mjs
python docs/datapath/build_report_figures.py
python docs/datapath/make_a4_figure_preview.py
```

前两条命令更新本目录中的报告图和 DOCX；第三条仅把 A4 可读性预览写入被忽略的
`outputs/report/qa/`。

流水线 VCD 可在带 Icarus Verilog 的 Linux 环境重新生成：

```bash
bash miniRV_pipeline_axi_ego1/tests/generate_report_vcd.sh
```

## 提交边界

单周期三个 ZIP 中的 `.bit` 已从 Git 交付物中排除，但对应照片和四类 Vivado 报告
均已解包保存。流水线/CoreMark 的原始 `.bit`、`.ltx` 和 `.rpt` 尚未从实验室电脑
取回；当前仓库只保存其实现状态截图。现场验收前请同时保留本地可烧录文件，具体见
[SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)。
