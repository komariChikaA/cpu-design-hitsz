# 单周期 SoC C_TEST0～2 验收记录

## 基本信息

- 日期：
- 地点：
- 组员：2024311081、2024311453
- 开发板：EGO1
- Vivado：2023.2
- 器件：xc7a35tcsg324-1
- CPU 时钟：50 MHz

## 包与工程检查

- [ ] `verify_lab_package.ps1` 输出 `LAB PACKAGE CHECK: PASS`
- [ ] 顶层为 `miniRV_SoC`
- [ ] 三项均完成 Synthesis、Implementation、Generate Bitstream
- [ ] 三项均为 `WNS >= 0`、`TNS = 0`
- [ ] 无阻断性 DRC 错误
- [ ] IROM/DRAM 未使用旧 cache

## C_TEST0

- [ ] 已选择 `0_uart_test` 并重新生成/烧录 bitstream
- [ ] 串口标题包含 `2024311081_2024311453` 和 `Test #0`
- [ ] 输出 `Hello World!`
- [ ] 输入 `A` 后串口回显正确
- [ ] 数码管显示 `00000041`
- [ ] LED 显示字符低位
- [ ] 拨码全 0 后再次输入，打印 `Test ended.`
- [ ] 已保存 bitstream、报告、串口截图和开发板照片

## C_TEST1

- [ ] 已选择 `1_formatIO_test` 并重新生成/烧录 bitstream
- [ ] 串口标题包含双学号和 `Test #1`
- [ ] Phase 0 格式化输出正确
- [ ] `123 x hello` 回显正确，数码管为 `0000007B`
- [ ] `-42 y again` 回显正确，最低位 LED 点亮
- [ ] 数码管为 `0000002A`
- [ ] `0 q end` 后打印 `Test ended.`
- [ ] 已保存 bitstream、报告、串口截图和开发板照片

## C_TEST2

- [ ] 已选择 `2_sort_test` 并重新生成/烧录 bitstream
- [ ] 串口标题包含双学号和 `Test #2`
- [ ] 固定数组结果为 `-1 0 2 3 4 5 7 8`
- [ ] 排序时间正常输出
- [ ] 动态数组大小输入 `16`
- [ ] 动态数组成功生成并排序
- [ ] 最后打印 `malloc released.`
- [ ] 已保存 bitstream、报告、串口截图和开发板照片

## 三项结果

- C_TEST0：
- C_TEST1：
- C_TEST2：
- C_TEST0 WNS/TNS：
- C_TEST1 WNS/TNS：
- C_TEST2 WNS/TNS：
- LUT/FF/BRAM：
- 遇到的问题：
- 解决方法：
