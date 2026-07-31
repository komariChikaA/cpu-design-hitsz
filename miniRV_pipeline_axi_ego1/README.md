# miniRV 五级流水线 AXI EGO1 工程

这是面向 EGO1（`xc7a35tcsg324-1`）的五级流水线 AXI SoC 工程。当前
`src/coe/main.mem` 已预装正式 CoreMark 程序：

- CPU：miniRV 五级流水线 AXI，RV32IM
- CPU 主频：50 MHz
- CoreMark：1.0，单线程，700 次迭代
- 学号：`2024311081_2024311453`
- 程序镜像：38,400 × 32 bit

## 2026-07-29 无 Cache 基线实板结果

以下结果来自加入 Cache 之前的基线版本，不能作为 Cache 版本的新成绩：

- 流水线 M 扩展自检：`PASS`
- UART 输入 `A`：正确回显，数码管显示 `00000041`
- CoreMark：700 次迭代，32 秒
- CoreMark 校验：`Correct operation validated`
- CoreMark 得分：21.250 CoreMark，0.425 CoreMark/MHz
- CoreMark 最终数码管：`C0DE600D`
- 实现后时序：WNS 1.702 ns，TNS 0 ns，失败端点 0

详细记录见 [BOARD_ACCEPTANCE_RESULT.md](./BOARD_ACCEPTANCE_RESULT.md)。

## 2026-07-31 Cache 版实板结果

使用当前 ICache/DCache RTL 和同一份 700 次 CoreMark 镜像重新生成 bitstream，
Windows MobaXterm 串口实测：

- CoreMark：700 次迭代，14 秒；
- CoreMark 校验：`Correct operation validated`；
- CoreMark 得分：48.814 CoreMark，0.976 CoreMark/MHz；
- 四组 CRC 与无 Cache 基线及官方校验值一致；
- 最终输出：`FINISH`。

相对 50 MHz、700 次、32 秒的无 Cache 基线，得分和单位频率得分均提升约 2.30 倍。
完整抄录和证据边界见
[`cache-result.md`](../docs/course-report/board-evidence/coremark/cache-result.md)。

## 当前 Cache 实现

当前 RTL 已在 `cpu_core` 与 `axi_master` 之间接入 ICache/DCache：

- 64 line direct-mapped，16-byte（4-word）cache line；
- ICache 和 DCache read miss 通过 `ARLEN=3` 的 AXI burst refill；
- DCache 为 write-through、no-write-allocate；
- `0xFFFF_xxxx` MMIO 使用 Uncached 单拍访问；
- 板端 `axi_board_soc` 已支持 BRAM burst 和最后一拍 `RLAST`。

本地和 Linux 服务器的 `tests/run_iverilog.sh` 已覆盖 Cache refill/hit、
write-through、MMIO Uncached、分支期间旧 refill、AXI 四拍拼接和板端 burst。
当前 RTL 已在课程 `cdp-tests` 中通过 AXI Trace 45/45，原始日志和调试闭环见
[`miniRV_pipeline_cache_axi_report.md`](../trace_test/miniRV_pipeline_cache_axi_report.md)。
Cache 版 CoreMark 已在 EGO1 上得到 48.814 CoreMark、0.976 CoreMark/MHz，并通过
全部 CRC 校验。当前仍缺本次 Cache 构建的 Timing/Utilization/DRC 原始报告、
最终 bitstream 和板卡显示照片；这些材料补回前，不得沿用旧无 Cache 构建的 WNS、
资源占用或照片充当 Cache 版证据。

代码与现场讲解见
[CACHE_IMPLEMENTATION_AND_DEFENSE.md](../docs/acceptance/CACHE_IMPLEMENTATION_AND_DEFENSE.md)。

在 Linux `cdp-tests` 中安装当前 Cache RTL：

```bash
cd ~/miniRV_pipeline_axi_ego1
bash prepare_trace.sh ~/cdp-tests
cd ~/cdp-tests
make clean
make
python3 run_all_tests.py
```

`prepare_trace.sh` 会先把原 `mySoC` 重命名留档，不会直接删除旧实现。

到实验室后先阅读 [START_COREMARK_ACCEPTANCE.md](./START_COREMARK_ACCEPTANCE.md)。
使用 Windows 时直接阅读
[START_WINDOWS_CACHE_COREMARK.md](./START_WINDOWS_CACHE_COREMARK.md)，其中包含
Windows Vivado 构建、COM 串口记录和验收拍照流程。
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
.\verify_cache_coremark_windows.cmd
```

该入口会先执行通用工程/CoreMark 镜像校验，再明确检查 ICache、DCache 实例和 AXI
Cache-Line Burst。基础检查也可以分别执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verify_coremark_package.ps1
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
