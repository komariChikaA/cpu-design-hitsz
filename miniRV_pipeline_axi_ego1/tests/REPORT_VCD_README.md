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
- `docs/course-report/vcd/06_no_cache_axi_transaction.vcd`

终端应看到：

```text
PASS: pipeline_hazard_tb
PASS: axi_master_tb
```

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
