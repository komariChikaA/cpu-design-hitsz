# RV32IM CoreMark for miniRV AXI EGO1

本目录以课程提供的 `c_test/4_coremark` 为基础，已适配当前流水线 AXI SoC：

- IROM：`0x00000000`，50 KiB
- DRAM 数据区：`0x0000C800`，50 KiB
- 堆栈区：`0x00019000`，50 KiB
- UART：`0xFFFF3000`
- LED：`0xFFFF1000`
- 数码管：`0xFFFF2000`
- 64 位计时器：`0xFFFF4000`
- CPU 主频：50 MHz
- 指令集/ABI：RV32IM / ILP32
- 正式迭代次数：700

正式预编译结果为当前目录下的 `main.coe`、`main.s` 以及 `prebuilt/coremark.elf`、
`prebuilt/coremark.bin`，对应工程根目录的 `src/coe/main.mem`。

## Linux 重新编译

下板包已经带程序镜像；没有修改源码时不需要重新编译。需要重新编译时：

```bash
CROSS_COMPILE=riscv32-unknown-elf- COREMARK_ITERATIONS=700 bash compile.sh
```

脚本也会自动查找 `riscv32-unknown-elf-`、`riscv64-unknown-elf-` 或
`riscv-none-elf-` 工具链。

回到工程根目录生成统一镜像：

```bash
python3 tools/bin2mem.py software/c_test/4_coremark/main.coe src/coe/main.mem
```

然后必须重新执行 Vivado 的 `source rebuild_ego1.tcl`。

## 实板成功条件

有效结果必须同时满足：

- `Iterations       : 700`
- 运行时间不少于 10 秒
- 没有 CRC 错误或 `Errors detected`
- 出现 `Correct operation validated`
- 出现 `CoreMark 1.0 :`、`CoreMark/MHz :` 和 `FINISH`
- 最终 LED 为 `C0A5`
- 最终数码管为 `C0DE600D`

如果最终 LED/数码管以 `E0` 开头，说明 CoreMark 自检或最短运行时间检查失败，不能作为通过
结果。

CoreMark 上游项目：https://github.com/eembc/coremark
