# miniRV 五级流水线 AXI EGO1 工程

这是面向 EGO1（`xc7a35tcsg324-1`）的五级流水线 AXI SoC 工程。当前
`src/coe/main.mem` 已预装正式 CoreMark 程序：

- CPU：miniRV 五级流水线 AXI，RV32IM
- CPU 主频：50 MHz
- CoreMark：1.0，单线程，700 次迭代
- 学号：`2024311081_2024311453`
- 程序镜像：38,400 × 32 bit

## 2026-07-29 实板结果

本工程已经在 EGO1 上完成实板验证：

- 流水线 M 扩展自检：`PASS`
- UART 输入 `A`：正确回显，数码管显示 `00000041`
- CoreMark：700 次迭代，32 秒
- CoreMark 校验：`Correct operation validated`
- CoreMark 得分：21.250 CoreMark，0.425 CoreMark/MHz
- CoreMark 最终数码管：`C0DE600D`
- 实现后时序：WNS 1.702 ns，TNS 0 ns，失败端点 0

详细记录见 [BOARD_ACCEPTANCE_RESULT.md](./BOARD_ACCEPTANCE_RESULT.md)。

到实验室后先阅读 [START_COREMARK_ACCEPTANCE.md](./START_COREMARK_ACCEPTANCE.md)。
当前镜像无需在 Linux 服务器重新编译，必须重新生成 bitstream，因为程序内容会被初始化进
FPGA 的 Block RAM。

## CoreMark 一键构建

使用 Vivado 2023.2 打开 `miniRV.xpr`，在 Tcl Console 执行：

```tcl
source rebuild_ego1.tcl
```

必须等到 Tcl Console 输出：

```text
EGO1 build finished.
```

随后烧录：

```text
outputs/vivado/miniRV_pipeline_axi_ego1.bit
```

不要烧录旧包中的同名 bit，也不要把 `main.mem` 单独复制到旧 bit 所在目录。正常评分建议使用
普通构建；只有调试问题时才使用 `source rebuild_ego1_ila.tcl`。

## 本机检查

Windows PowerShell：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verify_coremark_package.ps1
```

通用工程检查：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verify_package.ps1
```

## 重新编译 CoreMark（可选）

包内已带正式镜像，不需要为下板执行本节。只有修改 C 源码或迭代次数后才需要在装有
RISC-V GCC 的 Linux 环境执行：

```bash
cd software/c_test/4_coremark
CROSS_COMPILE=riscv32-unknown-elf- COREMARK_ITERATIONS=700 bash compile.sh
cd ../../..
python3 tools/bin2mem.py software/c_test/4_coremark/main.coe src/coe/main.mem
```

也可以把 `CROSS_COMPILE` 改成实际工具链前缀，例如
`riscv64-unknown-elf-`。重新编译后必须重新执行 Vivado 构建。

## 其他验证入口

- `START_PIPELINE_ACCEPTANCE.md`：流水线 M 扩展/UART 验收的历史流程。
- `AXI_LONG_LATENCY_REPLAY_FIX.md`：实板 UART 问题的根因及 RTL 修复。
- `ILA_DEBUG_GUIDE.md`：出现异常时的 ILA 调试方法。
- `verify_package.ps1`：工程、时钟、存储器、约束和关键 RTL 修复检查。

CoreMark 已由实板串口的 `Correct operation validated` 结果确认。后续修改 RTL、
时钟、存储器镜像或约束后，必须重新进行时序检查和实板回归，不能沿用本次结论。
