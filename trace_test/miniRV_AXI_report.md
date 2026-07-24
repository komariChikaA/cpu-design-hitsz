# miniRV 单周期 AXI Trace 测试报告

- 记录日期：`2026-07-23`
- 测试环境：Linux，工作目录 `/root/cdp-tests`
- 执行命令：`python3 run_all_tests.py`
- 测试对象：单周期 miniRV AXI SoC
- 测试结果：**45/45 通过，0 项失败**
- 完整输出：[miniRV_AXI_run_all_tests.log](./miniRV_AXI_run_all_tests.log)

## 结论

本次服务器测试的 45 个测试点均输出 `Test Point Pass!`，最终汇总为
`Passed Tests (45)`、`Failed Tests (0)`。

测试程序最后输出的是 `SUMMARY`，而不是 `SUMMARY (Basic Tests)`。结合工程顶层中
`cpu_top` 使用 `axi_master`、`miniRV_SoC` 使用 `bram_axi` 的层级检查结果，本次结果
记录为单周期 CPU 的 **AXI Trace** 测试结果。

本报告证明当前提交到服务器的设计能够通过该 `cdp-tests` 测试框架中的 AXI Trace
指令测试。随后完成的 Vivado 综合、实现、bitstream 和 EGO1 实板验收记录见
[`../miniRV_singlecycle_axi_ego1/VIVADO_BRINGUP_ISSUES.md`](../miniRV_singlecycle_axi_ego1/VIVADO_BRINGUP_ISSUES.md)。

## 测试点

| 测试点 | 结果 |
|---|---|
| `lb` | PASS |
| `bltu` | PASS |
| `jal` | PASS |
| `slt` | PASS |
| `sra` | PASS |
| `ori` | PASS |
| `lhu` | PASS |
| `rem` | PASS |
| `div` | PASS |
| `add` | PASS |
| `bgeu` | PASS |
| `auipc` | PASS |
| `beq` | PASS |
| `srl` | PASS |
| `jalr` | PASS |
| `and` | PASS |
| `sh` | PASS |
| `xori` | PASS |
| `or` | PASS |
| `srai` | PASS |
| `lw` | PASS |
| `slti` | PASS |
| `start` | PASS |
| `blt` | PASS |
| `sw` | PASS |
| `lui` | PASS |
| `bne` | PASS |
| `slli` | PASS |
| `sll` | PASS |
| `sub` | PASS |
| `sb` | PASS |
| `remu` | PASS |
| `mul` | PASS |
| `sltu` | PASS |
| `mulhu` | PASS |
| `andi` | PASS |
| `xor` | PASS |
| `mulh` | PASS |
| `divu` | PASS |
| `bge` | PASS |
| `addi` | PASS |
| `lbu` | PASS |
| `sltiu` | PASS |
| `srli` | PASS |
| `lh` | PASS |

## 服务器输出摘要

```text
root@C20260312164614:~/cdp-tests# python3 run_all_tests.py

==================== SUMMARY ====================
Passed Tests (45):
lb, bltu, jal, slt, sra, ori, lhu, rem, div, add, bgeu, auipc, beq, srl, jalr, and, sh, xori, or, srai, lw, slti, start, blt, sw, lui, bne, slli, sll, sub, sb, remu, mul, sltu, mulhu, andi, xor, mulh, divu, bge, addi, lbu, sltiu, srli, lh
-------------------------------------------------
Failed Tests (0):
```

完整的逐项编译、运行和差分测试输出保存在
[miniRV_AXI_run_all_tests.log](./miniRV_AXI_run_all_tests.log)。
