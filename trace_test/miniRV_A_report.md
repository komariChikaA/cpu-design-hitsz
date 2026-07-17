# miniRV A 组 Basic Trace 测试报告

- 开始时间：`2026-07-17 03:03:06 +0000`
- 结束时间：`2026-07-17 03:03:09 +0000`
- 测试目录：`/root/cdp-tests`
- 编译结果：**PASS**
- 指令结果：**18/18 通过，0 失败**

## 结果汇总

| 指令 | 结果 | make 退出码 | 日志 |
|---|---:|---:|---|
| `add` | **PASS** | `0` | [`add.log`](./miniRV_A_report_logs/add.log) |
| `sub` | **PASS** | `0` | [`sub.log`](./miniRV_A_report_logs/sub.log) |
| `auipc` | **PASS** | `0` | [`auipc.log`](./miniRV_A_report_logs/auipc.log) |
| `xor` | **PASS** | `0` | [`xor.log`](./miniRV_A_report_logs/xor.log) |
| `xori` | **PASS** | `0` | [`xori.log`](./miniRV_A_report_logs/xori.log) |
| `sll` | **PASS** | `0` | [`sll.log`](./miniRV_A_report_logs/sll.log) |
| `srl` | **PASS** | `0` | [`srl.log`](./miniRV_A_report_logs/srl.log) |
| `srli` | **PASS** | `0` | [`srli.log`](./miniRV_A_report_logs/srli.log) |
| `sra` | **PASS** | `0` | [`sra.log`](./miniRV_A_report_logs/sra.log) |
| `srai` | **PASS** | `0` | [`srai.log`](./miniRV_A_report_logs/srai.log) |
| `lb` | **PASS** | `0` | [`lb.log`](./miniRV_A_report_logs/lb.log) |
| `lbu` | **PASS** | `0` | [`lbu.log`](./miniRV_A_report_logs/lbu.log) |
| `lh` | **PASS** | `0` | [`lh.log`](./miniRV_A_report_logs/lh.log) |
| `lhu` | **PASS** | `0` | [`lhu.log`](./miniRV_A_report_logs/lhu.log) |
| `sw` | **PASS** | `0` | [`sw.log`](./miniRV_A_report_logs/sw.log) |
| `sb` | **PASS** | `0` | [`sb.log`](./miniRV_A_report_logs/sb.log) |
| `sh` | **PASS** | `0` | [`sh.log`](./miniRV_A_report_logs/sh.log) |
| `jalr` | **PASS** | `0` | [`jalr.log`](./miniRV_A_report_logs/jalr.log) |

## 编译日志

```text
root@C20260312164614:/root/cdp-tests$ make
make[1]: Entering directory '/root/cdp-tests/obj_dir'
make[1]: Nothing to be done for 'default'.
make[1]: Leaving directory '/root/cdp-tests/obj_dir'
- V e r i l a t i o n   R e p o r t: Verilator 5.051 devel rev v5.050-74-g796d5174f
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.022 s (elab=0.000, cvt=0.000, bld=0.020); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.021 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.020 s (elab=0.000, cvt=0.000, bld=0.019); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.017 s (elab=0.000, cvt=0.000, bld=0.016); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.018); cpu 0.002 s on 1 threads; allocated 30.832 MB
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
- Verilator: Walltime 0.019 s (elab=0.000, cvt=0.000, bld=0.017); cpu 0.001 s on 1 threads; allocated 30.832 MB
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
