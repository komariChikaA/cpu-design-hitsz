# miniRV B 组 Basic Trace 测试报告

> 现场答辩请配合阅读 [`miniRV_B_defense_guide.md`](./miniRV_B_defense_guide.md)，其中包含 B 组 18 条指令的逐条讲解、控制信号、RTL 对应关系和波形验证方法。

- 开始时间：`2026-07-17 14:09:05 +0000`
- 结束时间：`2026-07-17 14:09:13 +0000`
- 测试目录：`/root/cdp-tests`
- 编译结果：**PASS**
- 指令结果：**18/18 通过，0 失败**

## 结果汇总

| 指令 | 结果 | make 退出码 | 日志 |
|---|---:|---:|---|
| `mul` | **PASS** | `0` | [`mul.log`](./miniRV_B_report_logs/mul.log) |
| `mulh` | **PASS** | `0` | [`mulh.log`](./miniRV_B_report_logs/mulh.log) |
| `mulhu` | **PASS** | `0` | [`mulhu.log`](./miniRV_B_report_logs/mulhu.log) |
| `div` | **PASS** | `0` | [`div.log`](./miniRV_B_report_logs/div.log) |
| `divu` | **PASS** | `0` | [`divu.log`](./miniRV_B_report_logs/divu.log) |
| `rem` | **PASS** | `0` | [`rem.log`](./miniRV_B_report_logs/rem.log) |
| `remu` | **PASS** | `0` | [`remu.log`](./miniRV_B_report_logs/remu.log) |
| `slt` | **PASS** | `0` | [`slt.log`](./miniRV_B_report_logs/slt.log) |
| `sltu` | **PASS** | `0` | [`sltu.log`](./miniRV_B_report_logs/sltu.log) |
| `slti` | **PASS** | `0` | [`slti.log`](./miniRV_B_report_logs/slti.log) |
| `sltiu` | **PASS** | `0` | [`sltiu.log`](./miniRV_B_report_logs/sltiu.log) |
| `or` | **PASS** | `0` | [`or.log`](./miniRV_B_report_logs/or.log) |
| `and` | **PASS** | `0` | [`and.log`](./miniRV_B_report_logs/and.log) |
| `andi` | **PASS** | `0` | [`andi.log`](./miniRV_B_report_logs/andi.log) |
| `blt` | **PASS** | `0` | [`blt.log`](./miniRV_B_report_logs/blt.log) |
| `bge` | **PASS** | `0` | [`bge.log`](./miniRV_B_report_logs/bge.log) |
| `bltu` | **PASS** | `0` | [`bltu.log`](./miniRV_B_report_logs/bltu.log) |
| `bgeu` | **PASS** | `0` | [`bgeu.log`](./miniRV_B_report_logs/bgeu.log) |

## 编译日志

```text
root@C20260312164614:/root/cdp-tests$ make
make[1]: Entering directory '/root/cdp-tests/obj_dir'
ccache g++  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -Os  -c -o test.o ../csrc/test.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated.o /usr/local/share/verilator/include/verilated.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_dpi.o /usr/local/share/verilator/include/verilated_dpi.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_vcd_c.o /usr/local/share/verilator/include/verilated_vcd_c.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_threads.o /usr/local/share/verilator/include/verilated_threads.cpp
python3 /usr/local/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include VminiRV_SoC.cpp VminiRV_SoC___024root__0.cpp VminiRV_SoC_cpu_top__0.cpp VminiRV_SoC_Inst_ROM__0.cpp VminiRV_SoC_cpu_core__0.cpp VminiRV_SoC_IROM__0.cpp VminiRV_SoC__Dpi.cpp VminiRV_SoC__Trace__0.cpp VminiRV_SoC___024root__Slow.cpp VminiRV_SoC___024root__0__Slow.cpp VminiRV_SoC_miniRV_SoC__Slow.cpp VminiRV_SoC_miniRV_SoC__0__Slow.cpp VminiRV_SoC_cpu_top__Slow.cpp VminiRV_SoC_cpu_top__0__Slow.cpp VminiRV_SoC_Inst_ROM__Slow.cpp VminiRV_SoC_Inst_ROM__0__Slow.cpp VminiRV_SoC_cpu_core__Slow.cpp VminiRV_SoC_cpu_core__0__Slow.cpp VminiRV_SoC_IROM__Slow.cpp VminiRV_SoC_IROM__0__Slow.cpp VminiRV_SoC__Syms__Slow.cpp VminiRV_SoC__Trace__0__Slow.cpp VminiRV_SoC__TraceDecls__0__Slow.cpp > VminiRV_SoC__ALL.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o VminiRV_SoC__ALL.o VminiRV_SoC__ALL.cpp
g++    test.o emu.o onboard.o result_monitor.o EX.o ID.o IF.o MEM.o WB.o verilated.o verilated_dpi.o verilated_vcd_c.o verilated_threads.o VminiRV_SoC__ALL.a    -pthread -lpthread -latomic   -o VminiRV_SoC
rm VminiRV_SoC__ALL.verilator_deplist.tmp
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.923 MB sources in 20 modules, into 0.338 MB in 23 C++ files needing 0.000 MB
- Verilator: Walltime 5.407 s (elab=0.010, cvt=0.340, bld=5.017); cpu 0.390 s on 1 threads; allocated 37.715 MB
```

## TEST = mul

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=mul
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = mulh

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=mulh
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = mulhu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=mulhu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = div

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=div
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.024 s (elab=0.000, cvt=0.000, bld=0.023); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = divu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=divu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = rem

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=rem
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = remu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=remu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.018 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000120, Stop now.
[0mTest Point Pass!
```

## TEST = slt

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=slt
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000004f0, Stop now.
[0mTest Point Pass!
```

## TEST = sltu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sltu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000004f0, Stop now.
[0mTest Point Pass!
```

## TEST = slti

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=slti
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x0000029c, Stop now.
[0mTest Point Pass!
```

## TEST = sltiu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sltiu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.022 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x0000029c, Stop now.
[0mTest Point Pass!
```

## TEST = or

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=or
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.024 s (elab=0.000, cvt=0.000, bld=0.023); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000004ec, Stop now.
[0mTest Point Pass!
```

## TEST = and

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=and
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000004e0, Stop now.
[0mTest Point Pass!
```

## TEST = andi

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=andi
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.025 s (elab=0.000, cvt=0.000, bld=0.023); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000001e8, Stop now.
[0mTest Point Pass!
```

## TEST = blt

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=blt
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.018 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000002e8, Stop now.
[0mTest Point Pass!
```

## TEST = bge

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=bge
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.022 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000348, Stop now.
[0mTest Point Pass!
```

## TEST = bltu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=bltu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x0000031c, Stop now.
[0mTest Point Pass!
```

## TEST = bgeu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=bgeu
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x0000037c, Stop now.
[0mTest Point Pass!
```
