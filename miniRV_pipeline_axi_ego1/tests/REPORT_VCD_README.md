# 报告 2.3 流水线波形生成

报告模板要求两类实测波形：

1. 流水线 CPU 处理数据冒险的过程；
2. Cache miss 后经总线访问主存并返回的过程。

当前流水线工程已实现 ICache/DCache，第二类由 Cache 内部定向测试与 AXI
cache-line burst 两份波形共同证明；单周期 AXI 的旧波形仍属于无 Cache 证据，
两者不能混称。

## 在 Ubuntu/Linux 服务器上生成 VCD

进入仓库根目录后执行：

```bash
cd miniRV_pipeline_axi_ego1
bash tests/generate_report_vcd.sh
```

如果提示缺少 `iverilog`：

```bash
sudo apt update
sudo apt install -y iverilog
bash tests/generate_report_vcd.sh
```

脚本会先进行自检，只有仿真断言通过才会保留以下文件：

- `docs/course-report/vcd/06_pipeline_load_use_hazard.vcd`
- `docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd`
- `docs/course-report/vcd/08_axi_cacheline_burst.vcd`
- `docs/course-report/vcd/10_cache_refill_hit_uncached.vcd`
- `docs/course-report/vcd/11_board_bram_burst.vcd`
- `docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd`

旧四份波形曾在 2026-07-29 Ubuntu GitHub Actions/Icarus 回归
[`30446791756`](https://github.com/komariChikaA/cpu-design-hitsz/actions/runs/30446791756)
中执行。Cache 新增波形必须以当前分支的本地/CI 运行记录为准，不能沿用旧 run
证明新 RTL。

终端应看到：

```text
PASS: pipeline_hazard_tb
PASS: pipeline_flow_tb
PASS: axi_master_tb
PASS: cache_tb
PASS: board_peripheral_tb
```

波形与验收问题的对应关系：

| 原始 VCD | 现场回答 |
|---|---|
| `06_pipeline_load_use_hazard.vcd` | load-use 为什么需要 bubble，AXI 等待时哪些级保持，返回后如何从 WB 前递 |
| `07_pipeline_five_stage_forward_branch.vcd` | 一条指令怎样经过 IF/ID/EX/MEM/WB，MEM/WB 前递，taken branch 如何冲刷错误路径 |
| `08_axi_cacheline_burst.vcd` | `ARLEN=3`、四个 R beat、`RLAST`，Uncached 单拍以及 AW/W/B |
| `10_cache_refill_hit_uncached.vcd` | I/D miss、refill、hit、write-through 和 MMIO Uncached |
| `11_board_bram_burst.vcd` | 板端 ARLEN、递增地址、四个 R beat 和 RLAST |
| `09_board_peripheral_mmio_uart.vcd` | LED/数码管/switch/timer、UART TX/RX 的 MMIO |

## 在 Windows 上转成报告用 PNG

将两份 VCD 放回仓库的 `docs/course-report/vcd/`，然后在仓库根目录运行：

```powershell
node docs/datapath/generate_report_evidence.mjs
```

会额外生成：

- `06a_pipeline_load_use_hazard.png`
- Cache burst/refill 标注图（由新增 VCD 生成）；
- 原有 `06b_no_cache_axi_read.png`、`06c_no_cache_axi_write.png` 仅保留给单周期
  无 Cache AXI 项使用。

PNG 已筛选报告需要的关键信号、标出关键时刻，并保留原始 VCD 作为可复核证据。
