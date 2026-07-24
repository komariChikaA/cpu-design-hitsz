# miniRV 单周期 AXI SoC

本工程由已经通过 Basic Trace 的 `miniRV_basic/` 独立复制而来。目前实现的是实验 2B 的第一阶段：**禁用 Cache 的单周期 CPU + 单事务 AXI4 + EGO1 板级 SoC**。流水线工程位于 `miniRV_pipeline/`，两条开发线互不覆盖。

## 已实现内容

- `axi_master.v`：取指、数据读、数据写三类请求仲裁；32 位、单拍 INCR 事务；支持字节写使能和总线等待。
- `RUN_TRACE` 分支：保持 `miniRV_SoC -> U_cpu(cpu_top) -> U_core(cpu_core)` 层级，实例化课程 Trace 要求的 `bram_axi U_bram`。
- EGO1 分支：50 MHz CPU 时钟、150 KiB 统一 BRAM、拨码开关、LED、八位数码管、UART 和 64 位计时器。
- 统一地址空间：

  | 地址 | 功能 |
  | --- | --- |
  | `0x0000_0000` 起 | 150 KiB 指令/数据存储器 |
  | `0xFFFF_0000` | 拨码开关（读） |
  | `0xFFFF_1000` | LED（写） |
  | `0xFFFF_2000` | 数码管（写） |
  | `0xFFFF_3000/+4/+8/+C` | UART RX/TX/状态/控制 |
  | `0xFFFF_4000/+8` | 计时器低/高 32 位（读） |

Cache 尚未接入。本阶段先通过 AXI Trace，再在相同 CPU 访存接口与 AXI 接口之间加入 ICache/DCache。

## 本地验证

- `src/sim/axi_master_tb.v` 覆盖取指/数据读优先级、地址对齐、总线等待、AW/W 独立握手、WSTRB 和写响应。
- 已使用周期级模型验证 AXI Master，以及板级内存整字/字节写、LED、拨码开关和非法地址响应。
- 已分别展开检查 `RUN_TRACE` 与 EGO1 条件编译层级，并用当前 Trace `bram_axi` 的完整端口表核对连接。

在上述本地检查基础上，当前实现已通过真实 AXI Trace 45/45。Vivado
综合、实现、bitstream 和 EGO1 实板验收使用独立的
`../miniRV_singlecycle_axi_ego1/` 工程完成。

## AXI Trace

1. 在 `src/rtl/defines.vh` 中启用 `` `define RUN_TRACE ``，保持两个 Cache 宏关闭。
2. 将 `src/rtl/` 下除 `ip/` 外的 HDL 文件复制到 `cdp-tests/mySoC/`。
3. 确认测试框架提供 `vsrc/bram_axi.v`，然后运行 AXI Trace。

Trace 环境中的 `fpga_rst` 为高电平复位；工程通过条件编译自动适配。不要改名 `miniRV_SoC`、`U_cpu`、`U_core` 或 `bram_axi U_bram`。

## EGO1 上板

1. 保持 `RUN_TRACE` 关闭，打开 `miniRV.xpr`。
2. 将程序转换为 `src/coe/main.mem`：

   ```powershell
   python .\tools\bin2mem.py path\to\program.bin .\src\coe\main.mem
   ```

   也可以把 `.coe` 作为输入。输出固定补齐为 38,400 个 32 位字，对应 150 KiB BRAM。
3. 综合、实现并检查时序，随后生成 bitstream。当前时钟向导配置为 50 MHz，UART 配置为 115200 baud。

板级约束沿用 `src/xdc/` 中的 EGO1 约束。已经验收的可移植板级工程、重建脚本和
完整操作记录位于 `../miniRV_singlecycle_axi_ego1/`；后续重新生成 bitstream 时仍应
复查时序和资源利用率。
