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
C73E773081ED5C72154E8964262A0F46B4A0407413893824DC3F63C3C312BF06
```

解压后首先阅读 `START_WINDOWS_CACHE_COREMARK.md`，并运行：

```text
verify_cache_coremark_windows.cmd
```

本包提供正式 CoreMark 存储镜像和完整 Vivado 工程，不包含冒充新结果的历史
bitstream。必须在当前 Windows/Vivado 环境重新执行 `source rebuild_ego1.tcl`，
检查时序后烧录新生成的 bitstream。

包内 `CACHE_COREMARK_RESULT_20260731.md` 记录了 Cache 版实板结果：
48.814 CoreMark、0.976 CoreMark/MHz、14 秒、700 次迭代、CRC validated 和
`FINISH`。
