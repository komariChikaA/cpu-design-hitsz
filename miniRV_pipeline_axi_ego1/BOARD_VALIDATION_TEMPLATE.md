# 流水线 AXI EGO1 验收记录

- 日期：
- 实验室电脑：
- Vivado 版本：
- Git commit：
- 程序：`0_uart_test` / `1_pipeline_mext_test`
- Bitstream 时间：

## Vivado

- [ ] 器件为 `xc7a35tcsg324-1`
- [ ] Synthesis 成功
- [ ] Implementation 成功
- [ ] Generate Bitstream 成功
- [ ] IROM/DRAM/clk_wiz_0 未使用旧 cache
- [ ] `RAMD64E` 未大规模出现
- [ ] BRAM、LUT、MUX 未超量
- [ ] WNS：
- [ ] TNS：
- [ ] DRC Error 为 0

最差时序路径：

```text
起点：
终点：
逻辑级数：
Slack：
```

## 实板

- [ ] Hardware Manager 识别 `xc7a35t_0`
- [ ] Program Device 成功
- [ ] S6 复位后重新启动
- [ ] M-extension self-test 显示 PASS
- [ ] PASS 后 LED 为 `00A5`
- [ ] PASS 后数码管为 `600D600D`
- [ ] UART 输出完整启动文本
- [ ] 输入 `A` 后正确回显
- [ ] 数码管显示 `00000041`
- [ ] LED 显示字符低位
- [ ] 拨码不全零时可连续测试
- [ ] 拨码全零时处理一次后结束

## 异常与附件

Vivado warning/error：

```text

```

串口完整输出：

```text

```

已保存：

- [ ] `outputs/vivado/*.rpt`
- [ ] `.bit`
- [ ] Vivado 日志
- [ ] UART 截图
- [ ] 开发板照片
- [ ] 本次 `main.c/main.coe/main.mem`
