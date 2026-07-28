# C_TEST0～2 实验室操作与拍照 README

到实验室只看这一份。目标是在 EGO1 上按 **C_TEST0 → C_TEST1 → C_TEST2**
顺序重新构建、烧录、运行并留证。服务器编译过程已经记录在
`SERVER_BUILD_LOG.md`，不需要再拍服务器截图。

## 一、开始前

1. 将整个 ZIP 解压到无中文、无空格的短路径：

   ```text
   C:\Workspace\miniRV_singlecycle_axi_ego1_lab
   ```

2. 在工程目录打开 PowerShell，运行：

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass `
     -File .\verify_lab_package.ps1
   ```

3. 必须看到：

   ```text
   PASS 0_uart_test: program=12854 words image=38400
   PASS 1_formatIO_test: program=12994 words image=38400
   PASS 2_sort_test: program=13012 words image=38400
   Selected program: C_TEST0 (0_uart_test)
   LAB PACKAGE CHECK: PASS
   ```

4. 截图保存为 `00_package_check_pass.png`。

串口统一设置为 `115200 8N1`、无流控。UART 缓冲较小，粘贴整行时设置约
10 ms 字符发送延迟。`S6 RST` 是 CPU 复位，不要按 `S5 PROG#`。

## 二、每次测试都要执行的构建流程

将 `<测试目录>` 换成对应名称：

```powershell
.\prepare_program.ps1 <测试目录>
```

打开 `miniRV.xpr`，在 Vivado 2023.2 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

必须看到 `EGO1 build finished.`。打开 Timing Summary，确认：

- `WNS >= 0`；
- `TNS = 0`；
- Failing Endpoints 为 0；
- 没有阻断性 DRC 错误。

Hardware Manager 中烧录：

```text
miniRV.runs\impl_1\miniRV_SoC.bit
```

每次构建会在工程根目录产生：

```text
timing_summary.rpt
utilization.rpt
power.rpt
```

切换下一个程序前，先把 bitstream 和三份报告复制到独立目录。下面以 C_TEST0
为例：

```powershell
New-Item -ItemType Directory .\board_results\C_TEST0 -Force
Copy-Item .\miniRV.runs\impl_1\miniRV_SoC.bit `
  .\board_results\C_TEST0\C_TEST0.bit
Copy-Item .\timing_summary.rpt,.\utilization.rpt,.\power.rpt `
  .\board_results\C_TEST0\
```

C_TEST1、C_TEST2 时把目录名和 bitstream 文件名对应替换。每项拍一张
Timing Summary 截图，分别命名：

```text
10_ctest0_timing.png
20_ctest1_timing.png
30_ctest2_timing.png
```

## 三、C_TEST0

### 1. 选择、构建和烧录

```powershell
.\prepare_program.ps1 0_uart_test
```

重新执行 `source rebuild_ego1.tcl`，保存 C_TEST0 的 bitstream 和报告，再烧录。

### 2. 标题与输出

先将任意一个拨码开关拨到 1，再按 `S6 RST`。串口应显示：

```text
2024311081_2024311453 miniRV AXI EGO1 Test #0 - UART simple test:
<Phase 0> - Output test:
Hello World!
<Phase 1> - Input test:
```

截屏保存为 `11_ctest0_title.png`。

### 3. 字符和板级外设

输入：

```text
A
```

串口应回显 `Input received: A`，数码管应显示 ASCII 码：

```text
00000041
```

保存：

- `12_ctest0_uart_A.png`：串口截图；
- `13_ctest0_board_00000041.jpg`：手机拍开发板，必须看清数码管和 LED。

### 4. 正常结束

将所有拨码开关拨为 0，再输入一次 `A`，应打印 `Test ended.`。保存：

```text
14_ctest0_end.png
```

## 四、C_TEST1

### 1. 选择、重新构建和烧录

```powershell
.\prepare_program.ps1 1_formatIO_test
```

必须重新执行 `source rebuild_ego1.tcl` 并重新烧录，不能复用 C_TEST0 bitstream。

### 2. Phase 0

复位后截屏，画面必须包含双学号、`Test #1` 和：

```text
<Phase 0> - Formatted output test:
123
0x456
c
Hello World!
98.765400
```

保存为：

```text
21_ctest1_phase0.png
```

### 3. 正整数

输入：

```text
123 x hello
```

数码管应显示 `0000007B`。保存：

- `22_ctest1_123_uart.png`：串口回显；
- `23_ctest1_board_0000007B.jpg`：开发板数码管。

### 4. 负整数

输入：

```text
-42 y again
```

最低位 LED 应点亮，数码管应显示 `0000002A`。保存：

- `24_ctest1_minus42_uart.png`：串口回显；
- `25_ctest1_board_0000002A_led.jpg`：必须同时拍清数码管和点亮的 LED。

### 5. 正常结束

输入：

```text
0 q end
```

应打印 `Test ended.`，保存为 `26_ctest1_end.png`。

## 五、C_TEST2

### 1. 选择、重新构建和烧录

```powershell
.\prepare_program.ps1 2_sort_test
```

必须重新执行 `source rebuild_ego1.tcl` 并重新烧录。

### 2. 固定数组排序

复位后标题应包含双学号、`Test #2` 和
`<Phase 0> - Fixed size sorting test:`。输入：

```text
8 3 -1 7 0 2 5 4
```

截图必须包含：

```text
Sorted array:
-1 0 2 3 4 5 7 8
Time consumed: ... ms
```

保存为 `31_ctest2_fixed_sort.png`。

### 3. 动态内存和计时器

看到 `<Phase 1> - Malloc test:` 后输入：

```text
16
```

程序应生成16个数、输出排序后的数组和用时，最后打印：

```text
malloc released.
```

若一屏放不下，分别保存：

- `32_ctest2_generated_array.png`；
- `33_ctest2_sorted_malloc_released.png`。

再拍一张板卡与正在显示结果的电脑同框照片：

```text
34_ctest2_board_running.jpg
```

## 六、报告模板要求的额外证据

这些不是三项 C_TEST 的重复照片，但课程报告仍需要：

1. 流水线 SoC 的 Post-Implementation 总览截图，包含 DRC、Timing、
   Utilization 和 Power，且没有时序违例。当前单周期截图不能冒充流水线截图。
2. 单周期仿真：半字/字节访存任选一条、乘除法任选一条，分别保存清晰波形，
   必须包含信号名、关键值和具体时刻。
3. 流水线仿真：数据冒险处理波形。
4. Cache/AXI：Cache Miss、总线请求、主存返回全过程波形。
5. 至少两个组内讨论解决的问题，保留报错和修复后证据。

建议在报告模板中增加：

```text
1.4 单周期SoC的AXI与C_TEST下板验证
1.4.1 下板环境与程序镜像
1.4.2 C_TEST0 UART及外设测试
1.4.3 C_TEST1 格式化输入输出测试
1.4.4 C_TEST2 排序、动态内存及计时器测试
```

ILA 只在出现卡死、串口无输出或访存异常时使用；三项正常跑通时，不需要为了
拍照额外植入 ILA。

## 七、离开实验室前检查

- [ ] 三个测试都重新生成并烧录了各自的 bitstream
- [ ] 三项标题都包含 `2024311081_2024311453`
- [ ] C_TEST0 显示 `00000041` 并正常结束
- [ ] C_TEST1 显示 `0000007B`、`0000002A` 和点亮的最低位 LED
- [ ] C_TEST2 固定数组排序正确，动态数组正常并打印 `malloc released.`
- [ ] 三份 bitstream 均已另存
- [ ] 三组 timing、utilization、power 报告均已另存
- [ ] 串口截图和开发板照片已按编号命名
- [ ] 已填 `BOARD_VALIDATION_TEMPLATE.md`

单周期 SoC 跑通 C_TEST0～2 是“良好”档的一部分。本仓库的流水线 CPU AXI Trace
和流水线 SoC CoreMark 实板测试也已通过，系统实现已经完成“优秀”档闭环。后续重点
是按本清单复现、完成报告文字并准备现场验收。
