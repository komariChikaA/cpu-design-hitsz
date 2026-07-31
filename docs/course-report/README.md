# 课程报告与验收证据

本目录集中保存可以进入 Git、可以复核且适合长期维护的课程交付物。Vivado
bitstream、仿真可执行文件、工具缓存和重复打包文件不在此处保存。

## 目录结构

```text
docs/course-report/
├── 计算机设计与实践-实验报告.docx          # 原始工作稿
├── 计算机设计与实践-实验报告-最终版.docx    # 可编辑交付版
├── 计算机设计与实践-实验报告-最终版.pdf     # 打印/提交版
├── build_full_report.py                    # 最终报告生成脚本
├── generate_cache_waveforms.py             # 从 VCD 生成 Cache/AXI 波形
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
- CoreMark：最终 Cache 版在 50 MHz 下完成 700 次迭代，用时 14 s，
  CoreMark=48.814、CoreMark/MHz=0.976，CRC 全部正确并输出 `FINISH`；
- Vivado：最终 Cache 版实现后 WNS 0.986 ns、TNS 0 ns、失败端点
  0/20810；LUT 30%、FF 15%、BRAM 98%，片上功耗 0.215 W；
- 报告插图：单周期完整数据通路、半字访存、乘法、流水线数据通路、AXI
  状态机、流水线冒险、AXI 读写事务；
- 原始波形：保留 load-use、无 Cache AXI 基线、Cache refill、AXI 四拍
  burst 和外设 MMIO/UART VCD。

最终版已实现分离式 ICache/DCache：两者均为 1 KiB、64 行、每行
16 Byte（128 bit）、直接映射。无 Cache 图和分数仅作基线对比，最终
结论以 Cache 版为准。

## 重新生成图和报告

在仓库根目录运行：

```powershell
node docs/datapath/generate_report_evidence.mjs
python docs/datapath/build_report_figures.py
python docs/datapath/make_a4_figure_preview.py
python docs/course-report/generate_cache_waveforms.py
python docs/course-report/build_full_report.py
powershell -ExecutionPolicy Bypass -File docs/course-report/export_report_pdf.ps1
```

前三条更新基础报告图及 A4 预览；后三条从现有 VCD 生成
Cache/AXI 波形，填充课程模板并导出最终 PDF。QA 预览仍写入被忽略的
`outputs/report/`。

流水线 VCD 可在带 Icarus Verilog 的 Linux 环境重新生成：

```bash
bash miniRV_pipeline_axi_ego1/tests/generate_report_vcd.sh
```

## 提交边界

单周期三个 ZIP 中的 `.bit` 已从 Git 交付物中排除，但对应照片和四类 Vivado 报告
均已解包保存。流水线/CoreMark 的原始 `.bit`、`.ltx` 和 `.rpt` 尚未从实验室电脑
取回；当前仓库只保存其实现状态截图。现场验收前请同时保留本地可烧录文件，具体见
[SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)。
