# ICache / DCache 实现与验收讲解

> 适用工程：`miniRV_pipeline_axi_ego1`
>
> 本文只描述当前 `feature/pipeline-cache` 版本实际存在的 RTL。验收时按
> “CPU 请求 → Cache → AXI Master → BRAM/MMIO → 返回”顺序打开代码和波形。

## 1. 30 秒总述

当前流水线 SoC 在 `cpu_core` 与 `axi_master` 之间加入了独立 ICache 和 DCache：

- 两者都是 direct-mapped，64 line，每条 line 16 byte（4 个 32-bit word）；
- ICache 只读，miss 时对齐到 16 byte 边界，用一次 `ARLEN=3` 的 AXI INCR
  burst 取回 4 个 word；
- DCache 的 cached read miss 同样整行 refill；
- DCache 使用 write-through、no-write-allocate：store 始终写 AXI，写命中时
  同步按 `WSTRB` 更新缓存副本，写不命中不分配新 line；
- `0xFFFF_xxxx` 外设地址不缓存，DCache 产生 `dev_uncached=1`，AXI Master
  强制 `ARLEN=0`，所以 UART、LED、数码管、switch、timer 仍是单拍 MMIO；
- AXI Master 仲裁优先级为 DCache write > DCache read > ICache read；
- EGO1 板端 Slave 根据 `ARLEN` 返回 BRAM burst，并在最后一个 beat 给 `RLAST`。

一句话回答“为什么这样做”：取指和普通数据读利用空间局部性减少 AXI 事务，
但外设访问必须每次真正到达设备；write-through 则避免脏块回写状态机，便于保证
课程 SoC 的可解释性。

## 2. 总体连接

```text
                        +---------------------+
ifetch_req/addr ------> | ICache              |
ifetch_valid/inst <---- | tag / valid / data  |
                        +----------+----------+
                                   | line read
                                   v
+----------+             +---------+----------+             +---------------+
| cpu_core |             | axi_master         | AXI4        | bram_axi      |
| five     |             | D-W > D-R > I-R    +------------>| (Trace)       |
| stages   |             | 4-beat read pack   |             +---------------+
+----+-----+             +---------+----------+             +---------------+
     | daccess                      ^                        | axi_board_soc |
     v                              |                        | BRAM + MMIO   |
+----+-----------------+            |                        +---------------+
| DCache               +------------+
| read allocate        | line/single read, single write
| write-through        |
| MMIO uncached        |
+----------------------+
```

代码入口：

- `miniRV_pipeline_axi_ego1/src/rtl/cpu_top.v`
  - `U_core`：五级流水线核心；
  - `U_icache`：取指 Cache；
  - `U_dcache`：数据 Cache；
  - `U_aximaster`：三路请求仲裁和 AXI 五通道。
- `src/rtl/ICache.v`：ICache tag/data/valid 和 refill FSM。
- `src/rtl/DCache.v`：DCache read、write-through、Uncached 和 refill FSM。
- `src/rtl/axi_master.v`：`read_len`、`read_beat`、`read_buffer`，把 4 个
  `RDATA` beat 拼成 128-bit line。
- `src/rtl/axi_board_soc.v`：`read_active`、`read_len_reg`、
  `read_beat_reg`，产生板端 burst 和 `RLAST`。

## 3. 地址怎样拆成 tag / index / offset

一条 line 是 16 byte，因此低 4 位属于 line 内 offset。64 line 需要 6 位 index：

```text
31                    10 9             4 3       2 1       0
+-----------------------+---------------+---------+---------+
| tag (22 bit)          | index (6 bit) | word    | byte    |
+-----------------------+---------------+---------+---------+
```

- `cpu_addr[3:2]`：选择 line 内的 4 个 word；
- `cpu_addr[9:4]`：选择 64 个 line 中的一个；
- `cpu_addr[31:10]`：与该 line 保存的 tag 比较；
- hit 条件：`valid_array[index] && tag_array[index] == tag`；
- refill 地址：`{cpu_addr[31:4], 4'b0000}`。

Direct-mapped 的含义不是“没有替换”，而是一个内存块只有唯一候选 line。发生
同 index、不同 tag 的 miss 时，新块直接覆盖旧 line，因此不需要 LRU。

## 4. ICache 逐状态讲解

### `ST_IDLE`

组合逻辑先检查 `cpu_hit`：

- hit：`cpu_rvalid=1`，由 `cpu_raddr[3:2]` 选出 32-bit 指令；
- miss：在时钟沿锁存 `miss_line_addr/miss_index/miss_tag`，进入 `ST_REQ`。

### `ST_REQ`

`dev_ren=1`，向 AXI Master 提交 line-aligned 地址。只有
`dev_ren && dev_rrdy` 才代表请求被接受，随后进入 `ST_WAIT`。

### `ST_WAIT`

AXI Master 收齐四拍后给出一次 `dev_rvalid` 和 128-bit `dev_rdata`。ICache 将
整条 line、tag 和 valid 同时写入数组，然后回到 `ST_IDLE`，下一拍重新做 hit
判断并返回指令。

### 分支期间为什么不会交错旧指令

旧 PC 的 refill 已经在 AXI 中时不能取消。分支可以改变当前 `cpu_raddr`，ICache
仍把旧 line 安装进数组，但不会在 `ST_WAIT` 直接对 core 产生响应。回到
`ST_IDLE` 后，它用“当前地址”重新检查 tag；如果当前 PC 不属于旧 line，就发起
新 miss。测试 `cpu_top_fetch_tb` 专门覆盖了这一情况。

## 5. DCache 逐状态讲解

### Cached read

- `ST_IDLE + hit`：组合返回所选 word，不进入 AXI；
- `ST_IDLE + miss`：锁存对齐 line 地址，进入 `ST_RREQ`；
- `ST_RREQ`：等待 `dev_ren && dev_rrdy`；
- `ST_RWAIT`：等待完整 128-bit line，写入 data/tag/valid 后回 `ST_IDLE`；
- 下一拍变成 hit，数据才交给 core。

### Uncached read

当 `cpu_addr >= CACHEABLE_LIMIT` 时：

- 请求地址只按 word 对齐；
- `req_uncached=1`；
- AXI Master 把 `ARLEN` 设为 0；
- 返回时直接使用 `dev_rdata[31:0]`，不写 tag/data/valid。

因此连续两次读取 UART 状态或 timer 都会真实访问外设，不会读到旧缓存值。

### Write-through / no-write-allocate

store 到来时，DCache 总会进入 `ST_WREQ/ST_WWAIT`，等待完整 AW/W/B 事务：

- 写命中：用 `merge_bytes` 和 `cpu_wen` 更新 resident word 对应 byte lane；
- 写不命中：不发 read refill，不占用 line；
- 两种情况都把原始 `wen/address/data` 发给 AXI；
- 只有收到 `dev_wresp` 才给流水线 `cpu_wresp`，解除 memory freeze。

例如 `sb` 的 `cpu_wen=4'b0100` 时，只替换 word 的 byte lane 2，并把同样的
`WSTRB=0100` 送给内存。

## 6. AXI burst 怎样形成

Cache 设备侧一次返回 128 bit，但外部 AXI 数据宽度为 32 bit：

1. Master 接受 ICache miss：锁存 `read_len=3`、`read_beat=0`；
2. AR 通道发 `ARADDR=line_base, ARLEN=3, ARSIZE=2, ARBURST=INCR`；
3. 每次 `RVALID && RREADY` 把 `RDATA` 放入
   `read_buffer[read_beat*32 +: 32]`；
4. 非最后一拍令 `read_beat++`，保持 `RREADY=1`；
5. `RLAST=1` 时，把包含当前拍的 `read_buffer_next` 一次交给 ICache/DCache；
6. Uncached D read 的 `read_len=0`，第一拍同时也是最后一拍。

`ARLEN=3` 表示 4 拍，而不是 3 拍；AXI 中 length 字段编码的是
“beats minus one”。

板端 `axi_board_soc` 接受 AR 后保存 `read_len_reg/read_beat_reg/read_addr_reg`。
BRAM 每返回一拍且 Master 接收后，若尚未到末拍，就对 `read_addr_reg+4` 再发一次
同步读；`read_beat_reg==read_len_reg` 时给 `RLAST` 并结束事务。

## 7. `ready` 与 `valid` 在这里分别表示什么

- `valid`：发送方承诺“当前 payload 有效”，遇到 backpressure 必须保持；
- `ready`：接收方承诺“本拍愿意接收”；
- 只有时钟上升沿同时看到 `valid && ready`，这一拍才真正转移。

具体到本设计：

- `dev_ren && dev_rrdy`：Cache miss 请求被 AXI Master 接收；
- `ARVALID && ARREADY`：Slave 接收读地址和 burst 参数；
- `RVALID && RREADY`：一个 32-bit beat 被 Master 接收；
- `AWVALID && AWREADY`、`WVALID && WREADY`：写地址和写数据独立完成；
- `BVALID && BREADY`：整个 store 事务得到最终响应。

`ready=1` 不表示数据已经返回；例如 `dev_rrdy=1` 只是 Master 接收了 miss，Cache
仍要在 `ST_WAIT` 等 `dev_rvalid`。

## 8. 具体指令怎样走

### `lw x5, 4(x1)`

1. EX 级计算 `x1+4`；
2. MEM 级产生 `daccess_ren` 和地址；
3. DCache hit 时返回 word；miss 时流水线由 `memory_freeze` 保持；
4. miss 经过 AR 和四个 R beat 完成 refill；
5. DCache 下一拍 hit，`daccess_rvalid=1`；
6. core 对 `lb/lbu/lh/lhu/lw` 做相应扩展；
7. 数据进入 MEM/WB，在 WB 写 `x5`；
8. 紧随其后的依赖指令可能由 WB forwarding 获得该值。

### `sw x5, 8(x1)`

1. EX 级计算地址，store data 可由 forwarding 修正；
2. MEM 级产生 `daccess_wen/wdata`；
3. DCache 若命中先更新 resident line，同时发 write-through；
4. AXI 的 AW 与 W 可以不同拍握手；
5. Slave 返回 B；
6. DCache 给 `daccess_wresp`，流水线解除 freeze。

### `lw x5, 0(x1); add x6, x5, x7`

这仍是 load-use 冒险。Cache hit 只能缩短“数据从哪里回来”的等待，不能让 load
结果在 EX 级提前产生；冒险单元仍需插入 bubble。若 DCache miss，bubble 之外还会
出现整个流水线的 memory freeze，直到 refill 后 `daccess_rvalid` 到达。

## 9. 现场在 Vivado/波形软件里找哪些信号

### ICache miss → refill → hit

按层级展开：

```text
miniRV_SoC/U_cpu/U_icache
miniRV_SoC/U_cpu/U_aximaster
```

加入：

```text
cpu_ren cpu_raddr cpu_hit state
miss_line_addr dev_ren dev_rrdy dev_rvalid
m_axi_araddr m_axi_arlen m_axi_arvalid m_axi_arready
m_axi_rdata m_axi_rvalid m_axi_rready m_axi_rlast
read_beat read_buffer
```

讲解顺序：

1. `cpu_ren=1, cpu_hit=0`；
2. `miss_line_addr` 低四位为 0；
3. AR 握手时 `ARLEN=3`；
4. 四次 R 握手，`read_beat=0/1/2/3`；
5. 第四拍 `RLAST=1`；
6. `dev_rvalid` 提交整条 line；
7. ICache 回 IDLE 后 `cpu_hit=1, cpu_rvalid=1`。

### DCache write-through

加入：

```text
cpu_wen cpu_addr cpu_wdata cpu_hit
dev_wen dev_waddr dev_wdata dev_wresp
m_axi_awvalid m_axi_awready
m_axi_wvalid m_axi_wready m_axi_wstrb
m_axi_bvalid m_axi_bready
```

必须指出 AW/W 是独立通道，不能只看到其中一个 ready 就说 store 已完成；最终以
B 握手和 `dev_wresp` 为准。

### MMIO Uncached

加入：

```text
cpu_addr cpu_cacheable req_uncached dev_uncached
m_axi_araddr m_axi_arlen
```

地址为 `ffff_xxxx` 时，应看到 `cpu_cacheable=0`、`dev_uncached=1`、
`ARLEN=0`，且 valid/tag/data 数组不被写入。

仓库中的可直接打开波形：

- `docs/course-report/vcd/08_axi_cacheline_burst.vcd`：ARLEN=3、四个 R beat、
  RLAST、Uncached 单拍和 AW/W/B；
- `docs/course-report/vcd/10_cache_refill_hit_uncached.vcd`：ICache/DCache
  内部 miss/refill/hit、write-through、MMIO Uncached；
- `docs/course-report/vcd/11_board_bram_burst.vcd`：板端 Slave 的 ARLEN、
  递增地址、四个 R beat 和 RLAST；
- `docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd`：LED、数码管、
  switch、timer、UART 的 Uncached MMIO。

## 10. 老师可能追问

### 为什么不用 write-back？

write-back 还需要 dirty bit、替换时回写整行、读写 burst 仲裁和更多异常处理。
本实现选择 write-through/no-write-allocate，硬件状态少，store 的外部可见顺序
清晰；代价是每次 store 都有 AXI 写流量。

### 为什么 ICache 和 DCache 不共用一个数组？

独立数组允许流水线在同一周期命中取指和数据读取；它们只在 miss 时共享 AXI
Master，由仲裁器串行化外部事务。

### DCache 和 MMIO 怎样保持一致？

MMIO 根本不进入 Cache；每次 load/store 都经过 AXI 到板端寄存器，所以读 UART
状态、timer 或 switch 不会被旧 line 命中。

### miss 时为什么冻结流水线？

当前 core 是阻塞式访存接口，没有 miss status holding register 或乱序执行。
Cache 未给 `ifetch_valid/daccess_rvalid/wresp` 前，相关流水级必须保持，避免 PC、
指令和地址越过尚未完成的事务。

### 能同时处理多个 miss 吗？

不能。每个 Cache 只有一个 miss FSM，AXI Master 也只有一个未决事务。这是
blocking cache。优点是控制简单、返回不需要 transaction ID；缺点是 miss latency
期间不能服务第二个 miss。

### Cache 做完就证明 CoreMark 更快了吗？

不能只凭 RTL 推断。必须重新生成 bitstream，检查 WNS/TNS，实板运行相同迭代数，
记录 elapsed ticks 和 CoreMark/MHz，再与无 Cache 基线对比。Trace 证明功能正确，
不证明 FPGA 性能。

## 11. 验证命令与证据边界

本地 RTL 回归：

```bash
cd miniRV_pipeline_axi_ego1
bash tests/run_iverilog.sh
bash tests/generate_report_vcd.sh
```

关键 PASS：

```text
PASS: axi_master_tb
PASS: cache_tb
PASS: cpu_top_fetch_tb
PASS: board_peripheral_tb
PASS: cpu_top FPGA and RUN_TRACE elaboration
```

课程 AXI Trace 已在 `cdp-tests` 中用当前 RTL 重新构建并通过 45/45，详见
[`miniRV_pipeline_cache_axi_report.md`](../../trace_test/miniRV_pipeline_cache_axi_report.md)。
EGO1 CoreMark 仍必须用 Cache 版本重新实现、检查时序并下板。旧 bitstream 和旧
CoreMark 分数只能作为无 Cache 基线，不能冒充 Cache 版本结果。
