# miniRV 全项目 Trace 测试报告

- 开始时间：`2026-07-17 14:50:19 +0000`
- 结束时间：`2026-07-17 14:50:31 +0000`
- 测试目录：`/root/cdp-tests`
- 编译结果：**PASS**
- 项目结果：**45/45 通过，0 失败**

## 结果汇总

| 项目 | 结果 | make 退出码 | 日志 |
|---|---:|---:|---|
| `add` | **PASS** | `0` | [`add.log`](./miniRV_all_report_logs/add.log) |
| `addi` | **PASS** | `0` | [`addi.log`](./miniRV_all_report_logs/addi.log) |
| `and` | **PASS** | `0` | [`and.log`](./miniRV_all_report_logs/and.log) |
| `andi` | **PASS** | `0` | [`andi.log`](./miniRV_all_report_logs/andi.log) |
| `auipc` | **PASS** | `0` | [`auipc.log`](./miniRV_all_report_logs/auipc.log) |
| `beq` | **PASS** | `0` | [`beq.log`](./miniRV_all_report_logs/beq.log) |
| `bge` | **PASS** | `0` | [`bge.log`](./miniRV_all_report_logs/bge.log) |
| `bgeu` | **PASS** | `0` | [`bgeu.log`](./miniRV_all_report_logs/bgeu.log) |
| `blt` | **PASS** | `0` | [`blt.log`](./miniRV_all_report_logs/blt.log) |
| `bltu` | **PASS** | `0` | [`bltu.log`](./miniRV_all_report_logs/bltu.log) |
| `bne` | **PASS** | `0` | [`bne.log`](./miniRV_all_report_logs/bne.log) |
| `div` | **PASS** | `0` | [`div.log`](./miniRV_all_report_logs/div.log) |
| `divu` | **PASS** | `0` | [`divu.log`](./miniRV_all_report_logs/divu.log) |
| `jal` | **PASS** | `0` | [`jal.log`](./miniRV_all_report_logs/jal.log) |
| `jalr` | **PASS** | `0` | [`jalr.log`](./miniRV_all_report_logs/jalr.log) |
| `lb` | **PASS** | `0` | [`lb.log`](./miniRV_all_report_logs/lb.log) |
| `lbu` | **PASS** | `0` | [`lbu.log`](./miniRV_all_report_logs/lbu.log) |
| `lh` | **PASS** | `0` | [`lh.log`](./miniRV_all_report_logs/lh.log) |
| `lhu` | **PASS** | `0` | [`lhu.log`](./miniRV_all_report_logs/lhu.log) |
| `lui` | **PASS** | `0` | [`lui.log`](./miniRV_all_report_logs/lui.log) |
| `lw` | **PASS** | `0` | [`lw.log`](./miniRV_all_report_logs/lw.log) |
| `mul` | **PASS** | `0` | [`mul.log`](./miniRV_all_report_logs/mul.log) |
| `mulh` | **PASS** | `0` | [`mulh.log`](./miniRV_all_report_logs/mulh.log) |
| `mulhu` | **PASS** | `0` | [`mulhu.log`](./miniRV_all_report_logs/mulhu.log) |
| `or` | **PASS** | `0` | [`or.log`](./miniRV_all_report_logs/or.log) |
| `ori` | **PASS** | `0` | [`ori.log`](./miniRV_all_report_logs/ori.log) |
| `rem` | **PASS** | `0` | [`rem.log`](./miniRV_all_report_logs/rem.log) |
| `remu` | **PASS** | `0` | [`remu.log`](./miniRV_all_report_logs/remu.log) |
| `sb` | **PASS** | `0` | [`sb.log`](./miniRV_all_report_logs/sb.log) |
| `sh` | **PASS** | `0` | [`sh.log`](./miniRV_all_report_logs/sh.log) |
| `sll` | **PASS** | `0` | [`sll.log`](./miniRV_all_report_logs/sll.log) |
| `slli` | **PASS** | `0` | [`slli.log`](./miniRV_all_report_logs/slli.log) |
| `slt` | **PASS** | `0` | [`slt.log`](./miniRV_all_report_logs/slt.log) |
| `slti` | **PASS** | `0` | [`slti.log`](./miniRV_all_report_logs/slti.log) |
| `sltiu` | **PASS** | `0` | [`sltiu.log`](./miniRV_all_report_logs/sltiu.log) |
| `sltu` | **PASS** | `0` | [`sltu.log`](./miniRV_all_report_logs/sltu.log) |
| `sra` | **PASS** | `0` | [`sra.log`](./miniRV_all_report_logs/sra.log) |
| `srai` | **PASS** | `0` | [`srai.log`](./miniRV_all_report_logs/srai.log) |
| `srl` | **PASS** | `0` | [`srl.log`](./miniRV_all_report_logs/srl.log) |
| `srli` | **PASS** | `0` | [`srli.log`](./miniRV_all_report_logs/srli.log) |
| `start` | **PASS** | `0` | [`start.log`](./miniRV_all_report_logs/start.log) |
| `sub` | **PASS** | `0` | [`sub.log`](./miniRV_all_report_logs/sub.log) |
| `sw` | **PASS** | `0` | [`sw.log`](./miniRV_all_report_logs/sw.log) |
| `xor` | **PASS** | `0` | [`xor.log`](./miniRV_all_report_logs/xor.log) |
| `xori` | **PASS** | `0` | [`xori.log`](./miniRV_all_report_logs/xori.log) |

## 编译日志

```text
root@C20260312164614:/root/cdp-tests$ make
make[1]: Entering directory '/root/cdp-tests/obj_dir'
ccache g++  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -Os  -c -o test.o ../csrc/test.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated.o /usr/local/share/verilator/include/verilated.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_dpi.o /usr/local/share/verilator/include/verilated_dpi.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_vcd_c.o /usr/local/share/verilator/include/verilated_vcd_c.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o verilated_threads.o /usr/local/share/verilator/include/verilated_threads.cpp
python3 /usr/local/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include VminiRV_SoC.cpp VminiRV_SoC___024root__0.cpp VminiRV_SoC_cpu_top__0.cpp VminiRV_SoC_Inst_ROM__0.cpp VminiRV_SoC_cpu_core__0.cpp VminiRV_SoC_IROM__0.cpp VminiRV_SoC__Dpi.cpp VminiRV_SoC__Trace__0.cpp VminiRV_SoC__ConstPool__0__Slow.cpp VminiRV_SoC___024root__Slow.cpp VminiRV_SoC___024root__0__Slow.cpp VminiRV_SoC_miniRV_SoC__Slow.cpp VminiRV_SoC_miniRV_SoC__0__Slow.cpp VminiRV_SoC_cpu_top__Slow.cpp VminiRV_SoC_cpu_top__0__Slow.cpp VminiRV_SoC_Inst_ROM__Slow.cpp VminiRV_SoC_Inst_ROM__0__Slow.cpp VminiRV_SoC_cpu_core__Slow.cpp VminiRV_SoC_cpu_core__0__Slow.cpp VminiRV_SoC_IROM__Slow.cpp VminiRV_SoC_IROM__0__Slow.cpp VminiRV_SoC__Syms__Slow.cpp VminiRV_SoC__Trace__0__Slow.cpp VminiRV_SoC__TraceDecls__0__Slow.cpp > VminiRV_SoC__ALL.cpp
ccache g++ -Os  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=0 -DVM_TRACE=1 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=1 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-int-in-bool-context -Wno-shadow -Wno-sign-compare -Wno-subobject-linkage -Wno-tautological-compare -Wno-uninitialized -Wno-unused-but-set-parameter -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable    -DPATH=meminit.bin -DARCH_ON=0 -I/root/cdp-tests/golden_model/include   -c -o VminiRV_SoC__ALL.o VminiRV_SoC__ALL.cpp
g++    test.o emu.o onboard.o result_monitor.o EX.o ID.o IF.o MEM.o WB.o verilated.o verilated_dpi.o verilated_vcd_c.o verilated_threads.o VminiRV_SoC__ALL.a    -pthread -lpthread -latomic   -o VminiRV_SoC
rm VminiRV_SoC__ALL.verilator_deplist.tmp
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.946 MB sources in 20 modules, into 0.379 MB in 24 C++ files needing 0.001 MB
- Verilator: Walltime 5.405 s (elab=0.011, cvt=0.346, bld=5.003); cpu 0.399 s on 1 threads; allocated 37.723 MB
```

## TEST = add

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=add
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
[1;34mECALL at PC = 0x00000508, Stop now.
[0mTest Point Pass!
```

## TEST = addi

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=addi
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
[1;34mECALL at PC = 0x000002b0, Stop now.
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.002 s on 1 threads; allocated 30.832 MB
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

## TEST = auipc

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=auipc
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
[1;34mECALL at PC = 0x00000070, Stop now.
[0mTest Point Pass!
```

## TEST = beq

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=beq
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.017 s (elab=0.000, cvt=0.000, bld=0.016); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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

## TEST = bne

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=bne
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
[1;34mECALL at PC = 0x000002ec, Stop now.
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.002 s on 1 threads; allocated 30.832 MB
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

## TEST = jal

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=jal
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
[1;34mECALL at PC = 0x00000078, Stop now.
[0mTest Point Pass!
```

## TEST = jalr

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=jalr
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
[1;34mECALL at PC = 0x000000fc, Stop now.
[0mTest Point Pass!
```

## TEST = lb

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lb
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.027 s (elab=0.000, cvt=0.000, bld=0.025); cpu 0.002 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008	
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004	
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x00000274, Stop now.
[0mTest Point Pass!
```

## TEST = lbu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lbu
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
[1;34mECALL at PC = 0x00000274, Stop now.
[0mTest Point Pass!
```

## TEST = lh

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lh
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
[1;34mECALL at PC = 0x00000294, Stop now.
[0mTest Point Pass!
```

## TEST = lhu

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lhu
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
[1;34mECALL at PC = 0x000002a8, Stop now.
[0mTest Point Pass!
```

## TEST = lui

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lui
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
[1;34mECALL at PC = 0x00000088, Stop now.
[0mTest Point Pass!
```

## TEST = lw

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=lw
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
[1;34mECALL at PC = 0x000002b4, Stop now.
[0mTest Point Pass!
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.031 s (elab=0.000, cvt=0.000, bld=0.028); cpu 0.002 s on 1 threads; allocated 30.832 MB
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

## TEST = ori

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=ori
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
[1;34mECALL at PC = 0x00000204, Stop now.
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
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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

## TEST = sb

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sb
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
[1;34mECALL at PC = 0x0000041c, Stop now.
[0mTest Point Pass!
```

## TEST = sh

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sh
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
[1;34mECALL at PC = 0x000004a0, Stop now.
[0mTest Point Pass!
```

## TEST = sll

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sll
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
[1;34mECALL at PC = 0x00000578, Stop now.
[0mTest Point Pass!
```

## TEST = slli

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=slli
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008	
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004	
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000002ac, Stop now.
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
- Verilator: Walltime 0.018 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.018 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
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

## TEST = sra

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sra
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
[1;34mECALL at PC = 0x000005c4, Stop now.
[0mTest Point Pass!
```

## TEST = srai

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=srai
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
[1;34mECALL at PC = 0x000002e0, Stop now.
[0mTest Point Pass!
```

## TEST = srl

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=srl
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
[1;34mPeripheral name: MONITOR	base: 0x80000000	addr len: 0x00000008	
[0m[1;34mPeripheral name: Digit	base: 0xffff2000	addr len: 0x00000004	
[0m[mycpu] Resetting ...
[INFO] Data RAM initialized with meminit.bin
[INFO] Instruction ROM initialized with meminit.bin
[mycpu] Reset done.
[difftest] Test Start!
[1;34mECALL at PC = 0x000005ac, Stop now.
[0mTest Point Pass!
```

## TEST = srli

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=srli
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
[1;34mECALL at PC = 0x000002c8, Stop now.
[0mTest Point Pass!
```

## TEST = start

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=start
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
Digit: 0x25000000
Digit: 0x25000001
Digit: 0x25000002
Digit: 0x25000003
Digit: 0x25000004
Digit: 0x25000005
Digit: 0x25000006
Digit: 0x25000007
Digit: 0x25000008
Digit: 0x25000009
Digit: 0x2500000a
Digit: 0x2500000b
Digit: 0x2500000c
Digit: 0x2500000d
Digit: 0x2500000e
Digit: 0x2500000f
Digit: 0x25000010
Digit: 0x25000011
Digit: 0x25000012
Digit: 0x25000013
Digit: 0x25000014
Digit: 0x25000015
Digit: 0x25000016
Digit: 0x25000017
Digit: 0x25000018
Digit: 0x25000019
Digit: 0x2500001a
Digit: 0x2500001b
Digit: 0x2500001c
Digit: 0x2500001d
Digit: 0x2500001e
Digit: 0x2500001f
Digit: 0x25000020
Digit: 0x25000021
Digit: 0x25000022
Digit: 0x25000023
Digit: 0x25000024
Digit: 0x25000025
[1;34mECALL at PC = 0x00000268, Stop now.
[0mTest Point Pass!
```

## TEST = sub

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sub
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
[1;34mECALL at PC = 0x000004e8, Stop now.
[0mTest Point Pass!
```

## TEST = sw

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=sw
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
[1;34mECALL at PC = 0x000004ac, Stop now.
[0mTest Point Pass!
```

## TEST = xor

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=xor
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
[1;34mECALL at PC = 0x000004e8, Stop now.
[0mTest Point Pass!
```

## TEST = xori

- 结果：**PASS**
- 退出码：`0`

```text
root@C20260312164614:/root/cdp-tests$ make run TEST=xori
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
[1;34mECALL at PC = 0x0000020c, Stop now.
[0mTest Point Pass!
```
