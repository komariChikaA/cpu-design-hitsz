# 报告 2.3 流水线波形生成

报告模板要求两类实测波形：

1. 流水线 CPU 处理数据冒险的过程；
2. Cache miss 后经总线访问主存并返回的过程。

当前工程没有 Cache，第二类不能写成“Cache miss”。本工程可提供的真实证据是
“无 Cache 的 CPU 请求经 AXI 五通道完成读写事务并返回”的完整波形，并应在报告中
明确说明实现边界。

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
- `docs/course-report/vcd/06_no_cache_axi_transaction.vcd`
- `docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd`

2026-07-29 已在 Ubuntu GitHub Actions/Icarus 回归
[`30446791756`](https://github.com/komariChikaA/cpu-design-hitsz/actions/runs/30446791756)
中实际执行，四个 testbench 均输出 `PASS`。仓库中的 VCD 即该次构建产物，
不是手工绘制或仅保留截图。

终端应看到：

```text
PASS: pipeline_hazard_tb
PASS: pipeline_flow_tb
PASS: axi_master_tb
PASS: board_peripheral_tb
```

四份波形与验收问题的对应关系：

| 原始 VCD | 现场回答 |
|---|---|
| `06_pipeline_load_use_hazard.vcd` | load-use 为什么需要 bubble，AXI 等待时哪些级保持，返回后如何从 WB 前递 |
| `07_pipeline_five_stage_forward_branch.vcd` | 一条指令怎样经过 IF/ID/EX/MEM/WB，MEM/WB 前递，taken branch 如何冲刷错误路径 |
| `06_no_cache_axi_transaction.vcd` | AR/R 和 AW/W/B 何时握手，AW/W 为什么可以不同拍，backpressure 时 VALID/数据为何保持 |
| `09_board_peripheral_mmio_uart.vcd` | LED/数码管/switch/timer 的 MMIO，UART TX/RX 状态机和 AXI 访问 |

## 在 Windows 上转成报告用 PNG

将两份 VCD 放回仓库的 `docs/course-report/vcd/`，然后在仓库根目录运行：

```powershell
node docs/datapath/generate_report_evidence.mjs
```

会额外生成：

- `06a_pipeline_load_use_hazard.png`
- `06b_no_cache_axi_read.png`
- `06c_no_cache_axi_write.png`

PNG 已筛选报告需要的关键信号、标出关键时刻，并保留原始 VCD 作为可复核证据。
