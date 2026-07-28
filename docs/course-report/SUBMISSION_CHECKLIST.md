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
- [x] 插入高清图片的实验报告 DOCX 工作稿。

## 报告提交前仍需人工完成

- [ ] 填写报告封面、小组成员、日期和所有正文分析；
- [ ] 明确写出本设计为“无 Cache 直接 AXI 访问”，不要冒充 Cache miss；
- [ ] 用 Word/LibreOffice 打开 DOCX，检查本机字体、分页和图片清晰度；
- [ ] 选择最清楚的 C_TEST、流水线和 CoreMark 照片插入正文，不必把所有原图都放入；
- [ ] 导出最终 PDF，并逐页检查没有裁切、重叠和空白页。

## 老师现场验收

- [ ] 两名小组成员同时到场；
- [ ] 能展示并讲解完整单周期 CPU 数据通路图；
- [ ] 携带最终流水线 CoreMark `.bit`，使用 ILA 时同时携带匹配 `.ltx`；
- [ ] 携带流水线 CoreMark Timing、Utilization、Power、DRC 原始报告；
- [ ] 能重新烧录并运行 CoreMark，串口出现 `Correct operation validated`；
- [ ] 能展示 50 MHz、WNS/TNS、失败端点和 `C0DE600D`；
- [ ] 保留完整 Vivado 工程和当前 `src/coe/main.mem`；
- [ ] 备份单周期 C_TEST0～2 三份 bitstream，以便老师抽查。

## 建议再补但不是已有课程硬证据

- [ ] 流水线 Basic Trace 45/45 汇总截图；
- [ ] 流水线 AXI Trace 45/45 汇总截图；
- [ ] CoreMark 原始串口文本日志；
- [ ] 长延迟指令重复发射修复前后的对比波形，用于“问题及解决方法”。
