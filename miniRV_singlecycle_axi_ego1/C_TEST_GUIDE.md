# 单周期 EGO1 C_TEST0～2 操作手册

三项测试统一使用双人学号 `2024311081_2024311453`，按
**C_TEST0 → C_TEST1 → C_TEST2** 顺序验收。每次切换程序后都必须重新生成并
烧录 bitstream，旧 bitstream 不会自动包含新的 `main.mem`。

## 1. Linux 服务器编译

把 `outputs/miniRV_singlecycle_c_test0_1_2_linux_20260727.zip` 上传到服务器：

```bash
unzip miniRV_singlecycle_c_test0_1_2_linux_20260727.zip \
  -d miniRV_singlecycle_c_test_linux
cd ~/miniRV_singlecycle_c_test_linux
command -v riscv32-unknown-elf-gcc || command -v riscv64-unknown-elf-gcc
command -v python3
```

依次编译三项：

```bash
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 0_uart_test
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 1_formatIO_test
STUDENT_ID=2024311081_2024311453 bash prepare_program.sh 2_sort_test
```

每项都必须显示 `Compile succeeded`、正确的双学号和
`Updated .../src/coe/main.mem (38400 words)`。完成后下载整个
`outputs/programs/`，不要只下载最后一次生成的 `src/coe/main.mem`。

## 2. Windows 选择程序

在工程目录运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\prepare_program.ps1 0_uart_test
```

测试名也可以换成 `1_formatIO_test` 或 `2_sort_test`。脚本必须报告
`38400 words`。随后在 Vivado 2023.2 Tcl Console 运行：

```tcl
source rebuild_ego1.tcl
```

必须看到 `EGO1 build finished.`，确认 `WNS >= 0`、`TNS = 0`，再烧录
`miniRV.runs/impl_1/miniRV_SoC.bit`。串口使用 `115200 8N1`、无流控，
按 `S6 RST` 启动；不要按 `S5 PROG#`。

## 3. C_TEST0 验收与拍照

先把任意一个拨码开关置 1，再复位。串口应显示双学号、`Test #0` 和
`Hello World!`。

输入：

```text
A
```

应回显 `A`，LED 显示其低位，数码管显示 ASCII 码 `00000041`。保持这一画面，
拍一张同时包含开发板、数码管和串口标题的照片。然后把所有拨码开关置 0，
再输入一个字符，应打印 `Test ended.`，补拍结束画面。

## 4. C_TEST1 验收与拍照

依次输入：

```text
123 x hello
-42 y again
0 q end
```

- 标题应包含双学号和 `Test #1`，Phase 0 格式化输出正常；
- 输入 `123 x hello` 后数码管显示 `0000007B`；
- 输入 `-42 y again` 后最低位 LED 点亮，数码管显示 `0000002A`；
- 输入 `0 q end` 后打印 `Test ended.`。

至少保存标题/Phase 0、`0000007B`、`0000002A` 和结束画面。

## 5. C_TEST2 验收与拍照

固定数组阶段输入：

```text
8 3 -1 7 0 2 5 4
```

应输出升序结果 `-1 0 2 3 4 5 7 8` 和排序用时。动态数组阶段输入：

```text
16
```

应成功生成、排序并打印动态数组，最后显示 `malloc released.`。至少保存标题、
固定数组排序结果及计时、动态数组结果和释放成功画面。

本工程 UART 接收缓冲很小。如果粘贴整行出现丢字符，请在串口工具中设置约
10 ms 的字符发送延迟，或手动输入。

## 6. 离开实验室前保存

每项分别保存：

- `C_TEST0.bit`、`C_TEST1.bit`、`C_TEST2.bit`；
- 对应的 `timing_summary.rpt`、`utilization.rpt`；
- 完整串口日志或截图；
- 能看清开发板、LED/数码管和串口标题的照片；
- 填好的 `BOARD_VALIDATION_TEMPLATE.md`。

建议照片命名为 `00_package_check.jpg`、`10_ctest0_A.jpg`、
`11_ctest0_end.jpg`、`20_ctest1_phase0.jpg`、`21_ctest1_123.jpg`、
`22_ctest1_minus42.jpg`、`23_ctest1_end.jpg`、
`30_ctest2_fixed.jpg`、`31_ctest2_dynamic.jpg`。
