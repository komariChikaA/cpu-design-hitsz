# miniRV 下板包

## Windows：流水线 AXI + ICache/DCache + CoreMark

下载：

```text
miniRV_pipeline_axi_ego1_CACHE_COREMARK_700_WINDOWS_20260731.zip
```

配置：

- EGO1 `xc7a35tcsg324-1`；
- Vivado 2023.2；
- 五级流水线 RV32IM，50 MHz；
- 64-line ICache 和 64-line DCache；
- 16-byte Cache Line，AXI 四拍 burst refill；
- DCache write-through、no-write-allocate；
- MMIO Uncached；
- CoreMark 700 次迭代；
- 学号 `2024311081_2024311453`。

SHA-256：

```text
EBD59206BD0A5F4E49D836EAEEC9038C5BD435D75F53CCD972E4F535889A9A7C
```

解压后首先阅读 `START_WINDOWS_CACHE_COREMARK.md`，并运行：

```text
verify_cache_coremark_windows.cmd
```

本包提供正式 CoreMark 存储镜像和完整 Vivado 工程，不包含冒充新结果的历史
bitstream。必须在当前 Windows/Vivado 环境重新执行 `source rebuild_ego1.tcl`，
检查时序后烧录新生成的 bitstream。
