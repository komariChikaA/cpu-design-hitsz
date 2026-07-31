# 报告提交与现场验收清单

## 仓库已经具备

- [x] 单周期完整数据通路总图和八张局部详图；
- [x] 单周期 `lh` 访存波形和 `mul` 波形；
- [x] 流水线五级数据通路图；
- [x] AXI 主机状态转换图；
- [x] 流水线 load-use/访存等待波形；
- [x] 无 Cache AXI 读、写事务波形和原始 VCD；
- [x] C_TEST0～2 原始照片和 Vivado 报告；
- [x] 流水线 M 扩展、UART、实现状态截图；
- [x] CoreMark 完整串口结果和板卡同框照片；
- [x] Cache 版 CoreMark 串口数值抄录：48.814 CoreMark、0.976 CoreMark/MHz；
- [x] 完整实验报告 DOCX 和经过逐页检查的 38 页 PDF；
- [x] Cache refill 与 AXI 四拍 burst 的原始 VCD、高清 PNG 和可编辑 SVG；
- [x] 最终 Cache 版实现截图数据：WNS 0.986 ns、TNS 0 ns、BRAM 98%、
  功耗 0.215 W。

## 报告提交前仍需人工完成

- [ ] 填写报告中仍标记“待填写”的两人姓名、班级、组号和评阅教师；
- [x] 正文已明确区分无 Cache 基线和最终 ICache/DCache 版本；
- [ ] 保存 Cache 版 MobaXterm 原始截图为 `coremark/cache-serial-result.png`；
- [ ] 补回 Cache 构建的 Timing/Utilization/DRC、bitstream 和板卡显示照片；
- [x] 已用 Word 导出 PDF，检查字体、分页和 23 张插图清晰度；
- [x] 已选择 C_TEST0～2、流水线 UART/RV32M、Cache/AXI 波形插入正文；
- [x] 已导出最终 PDF 并逐页检查，未发现裁切或重叠。

## 老师现场验收

2026-07-31 已完成现场验收；以下条目保留为复验/归档清单。

- [ ] 两名小组成员同时到场；
- [ ] 能展示并讲解完整单周期 CPU 数据通路图；
- [ ] 携带最终流水线 CoreMark `.bit`，使用 ILA 时同时携带匹配 `.ltx`；
- [ ] 携带流水线 CoreMark Timing、Utilization、Power、DRC 原始报告；
- [x] 能重新烧录并运行 Cache 版 CoreMark，串口出现
  `Correct operation validated`、48.814、0.976 和 `FINISH`；
- [x] 已验收 50 MHz、WNS/TNS、失败端点和板级显示；
- [ ] 保留完整 Vivado 工程和当前 `src/coe/main.mem`；
- [ ] 备份单周期 C_TEST0～2 三份 bitstream，以便老师抽查。

## 建议再补但不是已有课程硬证据

- [ ] 流水线 Basic Trace 45/45 汇总截图；
- [ ] 流水线 AXI Trace 45/45 汇总截图；
- [ ] CoreMark 原始串口文本日志；
- [ ] 长延迟指令重复发射修复前后的对比波形，用于“问题及解决方法”。
