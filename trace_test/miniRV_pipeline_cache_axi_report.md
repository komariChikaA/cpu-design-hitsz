# 流水线 I/D Cache AXI Trace 验证报告

## 1. 结论

2026-07-30 在课程 Linux `cdp-tests` 环境中，用当前
`miniRV_pipeline_axi_ego1` Cache RTL 替换 `mySoC` 后重新构建并执行：

```text
Passed Tests (45):
lb, bltu, jal, slt, sra, ori, lhu, rem, div, add, bgeu, auipc, beq, srl,
jalr, and, sh, xori, or, srai, lw, slti, start, blt, sw, lui, bne, slli,
sll, sub, sb, remu, mul, sltu, mulhu, andi, xor, mulh, divu, bge, addi,
lbu, sltiu, srli, lh

Failed Tests (0):
```

因此，当前流水线 ICache/DCache + AXI 版本通过课程 AXI Trace **45/45**。

## 2. 被验证的实现

- ICache：64-line direct-mapped，16-byte/4-word cache line；
- DCache：64-line direct-mapped，read-allocate、write-through、
  no-write-allocate；
- Cacheable read miss：`ARLEN=3`，接收四拍 `RDATA`，最后一拍检查
  `RLAST`；
- MMIO/越界地址：Uncached 单拍访问；
- DCache 优先于 ICache 使用 AXI Master；
- store 的 AW/W 可独立握手，等待 B 响应后只上报一次完成；
- Cache miss 或 M 扩展 busy 时保持流水线，并抑制冻结 WB 寄存器的重复
  Trace 提交事件。

对应代码入口：

- [`ICache.v`](../miniRV_pipeline_axi_ego1/src/rtl/ICache.v)
- [`DCache.v`](../miniRV_pipeline_axi_ego1/src/rtl/DCache.v)
- [`cpu_top.v`](../miniRV_pipeline_axi_ego1/src/rtl/cpu_top.v)
- [`axi_master.v`](../miniRV_pipeline_axi_ego1/src/rtl/axi_master.v)
- [`cpu_core.v`](../miniRV_pipeline_axi_ego1/src/rtl/cpu_core.v)

## 3. 执行过程

上传当前工程后，服务器执行了：

```bash
cd /root/miniRV_pipeline_cache_20260730-235143/miniRV_pipeline_axi_ego1
bash tests/run_iverilog.sh
bash prepare_trace.sh /root/cdp-tests
cd /root/cdp-tests
make clean
make
python3 run_all_tests.py
```

安装脚本先把原实现保存为：

```text
/root/cdp-tests/mySoC.before-pipeline-cache.20260730-155146
```

随后将 23 个 Cache/流水线 AXI RTL 文件安装到
`/root/cdp-tests/mySoC`。服务器上的本次完整上传副本保存在：

```text
/root/miniRV_pipeline_cache_20260730-235143
```

## 4. 调试闭环

第一次课程构建暴露出一条普通注释以 `verilator public` 开头，被
Verilator 5.051 当成非法 pragma；把说明文字和真正的
`/* verilator public */` 属性分开后构建通过。

构建通过后的第一次 Trace 为 29/45。失败集中在 load/store 和 M 扩展，首个
差异表现为参考模型已提交 PC `0x0000000c`，CPU 却再次上报 PC
`0x00000008`。原因不是 Cache 数据错误，而是 Cache miss 延长
`effective_freeze` 后，冻结在 WB 的上一条指令仍保持
`debug_wb_rf_we=1`，被 Trace 误认为第二次架构提交。

最终修正为：

```verilog
assign debug_wb_rf_we = wb_rf_we && wb_valid && !effective_freeze;
```

该门控只约束 Trace 的“新提交事件”；WB 数据仍可用于前递，流水线与 Cache
功能数据通路没有被绕过。修正后课程 Trace 为 45/45。

## 5. 原始证据

- [课程 AXI Trace 完整日志](./miniRV_pipeline_cache_axi_run_all_tests.log)
  - 字节数：31,072
  - SHA-256：
    `08ba2bd6db27e7e851b83b6d7593f135a3ecd41227c84897df3d4362ce1d73d8`
- [服务器项目 Icarus 回归日志](./miniRV_pipeline_cache_iverilog.log)
  - 字节数：1,535
  - SHA-256：
    `892eb892e2e35bef6673a4a4b7aecce6162810a315f09b23be4c28f2feeadbce`

## 6. 证据边界

这次结果证明当前 Cache RTL 在课程 Verilator/AXI Trace 环境下通过完整
RV32IM 45 项测试，也证明同一上传工程的 Icarus 定向回归通过。它不等同于
Vivado 综合、实现时序或 EGO1 实板 CoreMark；Cache 版 bitstream、WNS 和实板
性能仍需用当前源码重新生成和测量。
