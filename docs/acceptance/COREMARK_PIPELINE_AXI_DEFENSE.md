# CoreMark 最终版流水线 AXI 答辩手册

> 最终检查对象：`miniRV_pipeline_axi_ego1/`
> 目标：辅助主讲同学在老师追问时，快速完成“原理回答 → 代码定位 → 信号解释 →
> 指令举例 → 调试证据”。
> 快速用法：老师说出关键词后，先在本文件搜索，再按给出的文件名和行号打开 RTL。

## 1. 先记住最终版框架

```text
miniRV_SoC
├── Clock Wizard + reset_sync
├── U_cpu : cpu_top
│   ├── U_core : cpu_core
│   │   ├── U_PIPE_REGS : pipeline_regs
│   │   ├── U_CU        : Controller
│   │   ├── U_RF        : RF
│   │   ├── U_SEXT      : SEXT
│   │   ├── U_FWD       : forward_unit
│   │   ├── U_ALU       : ALU
│   │   │   └── U_impl  : ALU_multicycle（实板）/ ALU_trace（Trace）
│   │   ├── U_MEM_REQ   : MREQ
│   │   └── U_MEM_EXT   : MEXT
│   └── U_aximaster : axi_master
└── U_board_soc : axi_board_soc
    ├── U_memory  : board_bram
    │   ├── IROM  : 50 KiB
    │   └── DRAM  : 100 KiB
    ├── U_uart    : simple_uart
    └── U_display : sevenseg_display
```

数据流主线：

```text
PC/IF → IF/ID → ID/译码与读寄存器 → ID/EX
      → EX/ALU/分支 → EX/MEM → MEM/AXI请求 → MEM/WB → WB/写寄存器
```

总线主线：

```text
cpu_core 的 ifetch/daccess
→ cpu_top 的请求防重与过期取指过滤
→ axi_master 的单事务五通道握手
→ axi_board_soc 的 BRAM/MMIO 地址译码
```

## 2. 基础问题

### 2.1 什么是流水线？

把一条指令的工作拆成多个阶段，不同指令在同一时刻占用不同阶段，从而提高吞吐率。
本设计是经典五级：

| 级 | 名称 | 本设计做什么 |
|---|---|---|
| IF | Instruction Fetch | PC 产生取指地址，通过 AXI 得到指令 |
| ID | Instruction Decode | 译码、读寄存器、立即数扩展、产生控制信号 |
| EX | Execute | ALU、分支判断、地址计算、乘除法 |
| MEM | Memory | 发起 load/store，等待 AXI 完成，完成子字节对齐 |
| WB | Write Back | 从 ALU、内存、PC+4、立即数中选择结果写寄存器 |

### 2.2 为什么是五级？

它把取指、译码、运算、访存、写回这些性质不同的工作隔开，控制清楚，适合本课程
RV32IM 数据通路。级数更多不一定更好：会增加级间寄存器、分支罚时和旁路复杂度。

### 2.3 流水线提高的是延迟还是吞吐率？

主要提高吞吐率。理想情况下填满后每拍退休一条，理想 CPI 接近 1；单条指令仍需经过
五级，延迟不一定减少。本设计还有 AXI 等待、load-use 和多周期乘除法，所以实际
CPI 大于 1。当前 CoreMark 没有硬件退休指令计数器，因此不能从现有输出声称实测 CPI。

### 2.4 `valid`、bubble、stall、flush 有什么区别？

- `valid=1`：该级内容对应一条真实指令；
- bubble：`valid=0` 的空项，即使旧控制位还保留也不能产生架构效果；
- stall：级间寄存器保持原值，指令不向前移动；
- flush：主动把错误路径指令的 `valid` 清零。

最终版在 `pipeline_regs.v` 中：

- `!stall_if` 才更新 IF/ID；
- `!stall_id` 才更新 ID/EX；
- `!stall_ex` 才更新 EX/MEM；
- `!stall_mem` 才更新 MEM/WB；
- taken branch 的 `flush` 清除 IF/ID 和 ID/EX，分支自己仍可进入 MEM。

### 2.5 什么是数据冒险？

当前指令需要的数据由更早指令产生，但还没正常写回寄存器。三种名称：

- RAW：Read After Write，后指令读前指令尚未写的数据；
- WAR：Write After Read；
- WAW：Write After Write。

本设计按序发射、按序执行、单一 WB 写口，年轻指令不能越过老指令提交，因此实际要
解决的是 RAW。WAR/WAW 不会形成乱序机器中的覆盖问题。

### 2.6 什么是控制冒险？

分支或跳转改变 PC 时，前面已经取得的顺序路径指令可能是错的。最终版在 EX 级解析，
taken 时将 PC 改为目标地址，并 flush IF/ID、ID/EX；如果 AXI 中还有旧 PC 的取指，
`cpu_top.v` 会丢弃过期响应。

### 2.7 什么是结构冒险？

多个请求争用同一硬件资源。最终版只有一个 AXI Master，同时只能有一笔事务，
优先级为 data write > data read > instruction read。争用时通过 ready 和流水线冻结
序列化，不会让请求互相覆盖。

### 2.8 AXI 的 VALID/READY 怎么理解？

VALID 表示发送方提供了有效信息，READY 表示接收方可以接收；只有同一拍两者都为 1
才握手。VALID 在握手前必须保持，地址/数据也必须稳定。五个通道是：

- AW：写地址；
- W：写数据；
- B：写响应；
- AR：读地址；
- R：读数据。

AW 与 W 相互独立，不能假定它们同一拍完成。

### 2.9 MMIO 是什么？

把外设寄存器映射到普通地址空间，CPU 继续执行 lw/sw，无需专用 I/O 指令：

| 地址 | 外设 |
|---|---|
| `0xFFFF0000` | 拨码开关，只读 |
| `0xFFFF1000` | LED，写 |
| `0xFFFF2000` | 八位数码管，写 |
| `0xFFFF3000/+4/+8/+C` | UART RX/TX/状态/控制 |
| `0xFFFF4000/+8` | 64 位计时器低/高 32 位 |

### 2.10 CoreMark 证明什么？

CoreMark 是长时间综合负载，覆盖列表、矩阵、状态机、CRC、控制流、访存和算术。
无 Cache 基线在 50 MHz、700 次迭代下运行 32 秒；当前 Cache 版运行 14 秒，
两者都输出相同的四组正确 CRC 和 `Correct operation validated`。Cache 版得到
48.814 CoreMark、0.976 CoreMark/MHz，约为基线的 2.30 倍。长时间综合负载比短
指令自测更能暴露偶发的流水线、总线和长延迟问题，但它不替代逐条 Trace。

## 3. 全部 RTL 文件怎么解释

### 3.1 顶层与板级

| 文件 | 作用 | 老师可能问 |
|---|---|---|
| `miniRV_SoC.v` | Trace/实板二选一顶层、PLL、复位、ILA 探针、连接 CPU 与板级 AXI Slave | 复位极性、为什么 Trace 和实板不同、ILA 看什么 |
| `cpu_top.v` | 连接 core 与 AXI Master，屏蔽刚完成的旧请求，过滤分支后的过期取指 | 为什么会重复事务、旧取指怎么丢弃 |
| `axi_master.v` | 单事务 AXI Master，读写仲裁和五通道状态机 | READY/VALID、AW/W 独立握手、请求优先级 |
| `axi_board_soc.v` | 150 KiB BRAM 与 UART/LED/数码管/计时器的 AXI Slave | 地址译码、BRAM 一拍延迟、UART 状态 |
| `board_bram.v` | IROM 50 KiB + DRAM 100 KiB 的 BMG 适配 | 为什么指令区不写、地址如何分 bank |
| `simple_uart.v` | 115200 8N1 单字节 UART TX/RX 状态机 | A 怎么被接收、波特率怎么得到 |
| `sevenseg_display.v` | 八位十六进制动态扫描 | 为什么看到的是 32 位十六进制 |

### 3.2 流水线核心

| 文件 | 作用 | 老师可能问 |
|---|---|---|
| `cpu_core.v` | 五级主数据通路、PC、冒险、前递、分支、访存冻结、写回 | 最核心文件，任何冒险都从这里定位 |
| `pipeline/pipeline_regs.v` | IF/ID、ID/EX、EX/MEM、MEM/WB 四组寄存器与 valid/stall/flush | bubble 和 stall 如何实现 |
| `pipeline/forward_unit.v` | 选择 EX/MEM 或 MEM/WB 结果前递到 EX | 为什么 load 不能从 MEM 级直接前递 |
| `Controller.v` | opcode/funct3/funct7 译码为 ALU、立即数、访存、写回控制 | 指令如何识别 |
| `RF.v` | 2 读 1 写寄存器堆，x0 固定为 0 | x0 为什么不会被写 |
| `SEXT.v` | I/S/B/U/J 五种立即数重排和符号扩展 | 分支立即数为什么末位补 0 |
| `ALU.v` | Trace 组合 ALU 与实板多周期 ALU 的包装选择 | 为什么两套实现 |
| `pipeline/ALU_trace.v` | Trace 下组合 RV32IM 运算 | 为什么 `busy=0` |
| `pipeline/ALU_multicycle.v` | 实板普通 ALU + 多周期 M 扩展控制 | 启动拍为什么也要 busy |
| `multiplier.v` | 32 拍移位加法乘法器 | 乘法怎么做 |
| `divider.v` | 恢复除法式逐位商/余数 | 除零和符号如何处理 |
| `MREQ.v` | load/store 地址、字节使能和写数据移位 | sb/sh/sw 的 WSTRB 怎么来 |
| `MEXT.v` | 从 32 位读数据中按地址低位选字节/半字并扩展 | lb/lbu、lh/lhu 区别 |
| `defines.vh` | ALU/NPC/扩展/写回宏、MMIO 地址、Cache 开关 | 当前有没有 Cache |

### 3.3 软件与验证

| 文件 | 作用 |
|---|---|
| `software/c_test/4_coremark/src/coremark/src/core_main.c` | CoreMark workload、迭代、CRC 和有效性判断 |
| `software/c_test/4_coremark/src/coremark/core_portme.c` | 50 MHz 计时器适配、得分、LED/数码管结束码 |
| `software/c_test/4_coremark/src/common/sc_print.c` | UART MMIO 字符输出 |
| `tests/pipeline_hazard_tb.v` | 两拍存储等待下验证 load-use 和后续前递 |
| `tests/alu_multicycle_tb.v` | 全部 M 扩展、除零和溢出边界 |
| `tests/cpu_core_mext_tb.v` | M 扩展在完整流水线中的相关和连续执行 |
| `tests/axi_master_tb.v` | 地址对齐、WSTRB、AW/W 独立、背压稳定 |
| `tests/cpu_top_fetch_tb.v` | taken branch 后过期 AXI 取指不能进入 core |
| `tests/uart_system_tb.v` | CPU→AXI→MMIO→UART 全系统接收 `0x41` |

## 4. 五级流水在代码中怎么实现

### 4.1 IF：PC 和取指

位置：`cpu_core.v:43-56`、`521-534`（也可搜索 `ifetch_req` / `ifetch_addr`）。

```verilog
always @(posedge cpu_clk or posedge cpu_rst) begin
    if (cpu_rst)
        pc <= 32'h0;
    else if (ex_bj_f)
        pc <= ex_bj_target;
    else if (ifetch_valid && !stall_if)
        pc <= pc + 32'h4;
end

assign ifetch_req  = resume_ifetch | !pause_ifetch;
assign ifetch_addr = ex_bj_f ? ex_bj_target : pc;
```

回答要点：

- 正常只有收到有效指令且前端未停顿才 `PC+4`；
- taken branch 优先于顺序更新；
- AXI 未返回时不能把 PC 当作已取到；
- 访存/M 扩展结束的 `resume_ifetch` 用于重新拉起取指。

### 4.2 IF/ID

位置：`pipeline_regs.v:114-141`（搜索 `IF/ID`）。

```verilog
if (flush) begin
    id_inst_r  <= 32'h0;
    id_valid_r <= 1'b0;
end else if (!stall_if) begin
    id_pc_r    <= if_pc;
    id_inst_r  <= if_inst;
    id_valid_r <= if_valid_in;
end
```

老师问“stall 时发生什么”：没有进入赋值分支，所以寄存器保持，ID 仍看到原指令。

### 4.3 ID：译码、寄存器和立即数

位置：`cpu_core.v:109-117`、`216-285`（搜索 `U_CU` / `U_RF` / `U_SEXT`）。

ID 先从 opcode 判断该指令是否真的使用 rs1/rs2，避免把立即数字段误判成数据相关；
Controller 生成控制，RF 读两个源操作数，SEXT 产生立即数。

WB 同拍旁路在 `cpu_core.v:269-274`（搜索 `wb_fwd_rs1`）：

```verilog
wire wb_fwd_rs1 = wb_rf_we && wb_valid && (wb_rd != 0)
                  && (wb_rd == id_rs1) && id_rf1 && id_valid;
wire [31:0] rf_rd1_fwd = wb_fwd_rs1 ? rf_wD : rf_rd1;
```

这是为了解决“WB 正在写、ID 同拍读相同寄存器”的读写时序歧义。

### 4.4 ID/EX

位置：`pipeline_regs.v:145-239`（搜索 `ID/EX`）。

它不只保存数据，还保存 rs1/rs2/rd、ALU 操作、访存控制、写回选择和 valid。冒险时
`id_valid_for_ex=0` 注入 bubble；真正全局冻结时 `stall_id=1` 保持原 EX 指令。

### 4.5 EX：前递、ALU、分支

位置：`cpu_core.v:398-466`（搜索 `U_FWD` / `U_ALU`）。

```verilog
assign fwd_a = (forward_a_sel == 2'b01) ? mem_wb_data :
               (forward_a_sel == 2'b10) ? rf_wD       : ex_rf_rd1;
assign fwd_b = (forward_b_sel == 2'b01) ? mem_wb_data :
               (forward_b_sel == 2'b10) ? rf_wD       : ex_rf_rd2;

assign alu_a = ex_alua_sel ? ex_pc  : fwd_a;
assign alu_b = ex_alub_sel ? ex_ext : fwd_b;
```

`01` 表示从较近的 MEM 级前递，优先级高；`10` 表示从 WB 前递。

分支位置：`cpu_core.v:339-393`（搜索 `ex_bj_target` / `flush`）。

```verilog
assign ex_bj_target = ex_is_jalr ? {alu_c[31:1], 1'b0}
                                 : (ex_pc + ex_ext);
assign ex_bj_taken = (ex_is_branch && br) || ex_is_jal || ex_is_jalr;
```

实板 AXI 构建 taken 必定重定向；Trace 零延迟模型保留目标已在 ID 时的去重逻辑。

### 4.6 EX/MEM

位置：`pipeline_regs.v:241-293`（搜索 `EX/MEM`）。

保存 ALU 结果、store 数据、访存类型、rd 和写回选择。特别注意 store 数据传入的是
`fwd_store_data`，不是 ID 时读到的旧 `ex_rf_rd2`。

### 4.7 MEM：请求、等待和子字节

位置：`cpu_core.v:475-500`（搜索 `U_MEM_REQ` / `mem_op_active`）。

- MREQ 把地址低两位变成 byte strobe 和移位后的写数据；
- `mem_op_active` 保证 bubble 不发请求；
- MEXT 对返回的整字按 byte offset 选字节/半字并做有/无符号扩展；
- `ld_st_suspend` 从访存进入 EX 后保持，直到 `daccess_rvalid/daccess_wresp`。

### 4.8 MEM/WB 与 WB

位置：`pipeline_regs.v:295-329`、`cpu_core.v:505-518`（搜索 `MEM/WB` / `wb_rf_wsel`）。

```verilog
case (wb_rf_wsel)
    WB_ALU : rf_wD = wb_alu_c;
    WB_RAM : rf_wD = wb_ram_ext;
    WB_PC4 : rf_wD = wb_pc + 4;
    WB_EXT : rf_wD = wb_ext;
endcase
```

- 算术/AUIPC/M 扩展写 ALU；
- load 写 RAM；
- JAL/JALR 写 PC+4；
- LUI 写立即数。

RF 的写使能是 `wb_rf_we && wb_valid`，bubble 不会写回。

## 5. 各种冒险逐项回答

### 5.1 普通 ALU RAW

例子：

```asm
add x3, x1, x2
sub x4, x3, x5
```

周期关系：

| 周期 | add | sub | 处理 |
|---|---|---|---|
| C1 | IF |  |  |
| C2 | ID | IF |  |
| C3 | EX | ID | sub 在 ID 读到的 x3 可能还是旧值 |
| C4 | MEM | EX | `mem_rd==ex_rs1`，从 EX/MEM 前递 add 结果 |
| C5 | WB | MEM | 不需要 stall |

代码：`forward_unit.v:25-39`、`cpu_core.v:398-434`（搜索 `forward_a_sel` / `fwd_a`）。

为什么 MEM load 被排除：

```verilog
wire fwd_a_ex = mem_rf_we && !mem_is_load && ...
```

load 在 MEM 等到的数据不能像 ALU 结果一样从 EX/MEM 立即得到。

### 5.2 load-use

例子：

```asm
lw   x2, 0(x1)
addi x3, x2, 1
```

检测：`cpu_core.v:288-296`（搜索 `load_use_hazard`）。

```verilog
wire load_use_hazard = ex_is_load && ex_rf_we && (ex_rd != 0) &&
    ((id_uses_rs1 && ex_rd == id_rs1) ||
     (id_uses_rs2 && ex_rd == id_rs2));
```

处理：

1. `stall_if=1`，PC 和 IF/ID 保持；
2. `id_valid_for_ex=0`，向 EX 注入 bubble；
3. load 进入 MEM 并等待 AXI；
4. `memory_freeze=1` 时保持活动流水级；
5. 数据到达后 load 进入 WB；
6. dependent 指令重新进入 EX，从 WB 的 `rf_wD` 前递。

不能只靠前递的原因：load 数据在 dependent 指令原本进入 EX 的那一拍还不存在。

现成测试：`tests/pipeline_hazard_tb.v:62-67`，指令序列为：

```asm
addi x1, x0, 16
lw   x2, 0(x1)   # 返回 42，且人为等待两拍
addi x3, x2, 1   # load-use，结果 43
addi x4, x3, 2   # 普通前递，结果 45
```

波形：[load-use VCD 图](../course-report/figures/06a_pipeline_load_use_hazard.png)。

### 5.3 store 数据相关

例子：

```asm
add x5, x1, x2
sw  x5, 0(x3)
```

sw 同时需要：

- rs1 作为地址基址，走 `fwd_a`；
- rs2 作为写数据，走 `fwd_store_data`。

代码：`cpu_core.v:433-434`，在实例化 `pipeline_regs` 的 `cpu_core.v:167-168` 通过
`ex_rf_rd2_in(fwd_store_data)` 写入 EX/MEM。

如果是：

```asm
lw x5, 0(x1)
sw x5, 0(x3)
```

store 的 rs2 也被 `id_uses_rs2` 识别，所以触发 load-use，再从 WB 前递，不会把旧
x5 写入内存。

### 5.4 分支依赖与控制冒险

例子：

```asm
add x1, x2, x3
beq x1, x0, target
```

beq 在 EX 比较，x1 可从前一条 add 的 MEM 级前递，不需要额外 stall。若 taken：

1. `br=1`；
2. `ex_bj_taken=1`；
3. PC 选 `ex_pc+ex_ext`；
4. `flush=1`，清除 IF/ID、ID/EX；
5. cpu_top 丢弃旧 PC 的在途 AXI 返回。

未 taken 不 flush，继续顺序 PC。

### 5.5 JAL 与 JALR

JAL：

- 目标：`ex_pc + J immediate`；
- rd 写 `PC+4`；
- 不读 rs1/rs2。

JALR：

- ALU 算 `rs1 + I immediate`；
- 目标最低位强制 0：`{alu_c[31:1],1'b0}`；
- rd 写 `PC+4`；
- rs1 可以从前级前递。

### 5.6 M 扩展长延迟

例子：

```asm
mul x3, x1, x2
add x4, x3, x5
```

实板 ALU 在启动边沿锁存已经前递后的 a/b，`busy` 从启动拍就拉高，冻结 EX 及前面
流水级，直到乘法器完成。结果进入 EX/MEM 后，add 可从 MEM 前递。

关键代码：`ALU_multicycle.v:100-144`（搜索 `operation_start` / `operation_issued`）。

为什么 `busy` 包含 `operation_start`：

> 如果只在内部乘法器下一拍的 busy 拉高，启动边沿 EX/MEM 会先采走旧 ALU 结果。

为什么有 `operation_issued`：

> 它标识当前 EX 的确拥有一个多周期操作，不能用 `ALU_ADD=0` 当“空闲”哨兵；
> 完成边沿清除后，下一条相同 M 指令仍可重新启动。

为什么 bubble 要把 ALU op 屏蔽为 ADD：

```verilog
wire [4:0] active_alu_op = ex_valid ? ex_alu_op : `ALU_ADD;
```

流水寄存器在 bubble 时可能保留旧控制位；如果不看 valid，旧 MUL/DIV 会被再次启动。

### 5.7 连续 load/M 指令的重复发射

最终实板调试发现的关键 bug：

> 以前 load/M 进入 EX 时把 IF 停住，同一条指令仍留在 ID；长延迟操作完成后它又进入
> EX，造成重复执行。UART 状态 load 被重复后，前递甚至把返回值当下一次地址基址。

最终代码 `cpu_core.v:366-389`（搜索 `load_duplicate` / `id_valid_for_ex`）：

```verilog
wire load_duplicate = id_is_ld_st   && ex_is_ld_st;
wire mul_duplicate  = id_is_mul_div && ex_is_mul_div;

assign stall_if = load_use_hazard || load_duplicate || mul_duplicate ||
                  effective_freeze;
assign id_valid_for_ex = id_valid && !load_use_hazard
                       && !load_duplicate && !mul_duplicate;
```

这里的思想不是“看见 load 就永远停 IF”，而是区分：

- 真正的数据相关；
- ID 与 EX 中同类长延迟指令的重复/相邻情况；
- 当前活动操作确实处于 freeze。

### 5.8 AXI 访存等待

`memory_freeze = ld_st_suspend && !ld_st_done`。等待时：

- 当前 MEM 请求和地址保持；
- EX、ID 和 IF 不推进；
- MEM/WB 也在 `stall_mem` 下保持；
- `daccess_rvalid` 或 `daccess_wresp` 到达后解除。

这和 load-use bubble 不同：load-use 是某一依赖指令晚一拍进入 EX；AXI wait 是外部
事务尚未完成，必须保持在途状态。

### 5.9 AXI 响应后的重复事务

位置：`cpu_top.v:89-91`（搜索 `ic_axi_req` / `dc_axi_rreq`）。

```verilog
wire       ic_axi_req  = cpu2ic_rreq && !ic_axi_valid;
wire       dc_axi_rreq = (|cpu2dc_ren) && !dc2cpu_valid;
wire [3:0] dc_axi_wen  = cpu2dc_wen & {4{!dc2cpu_wresp}};
```

Master 在产生 response 的同一拍回 IDLE，但 core 到下一时钟沿才撤销旧请求。如果
不在 response 拍屏蔽，该请求可能被第二次接受。这曾导致 AXI Trace 的
`sh/start/sw/sb` 失败，修复后 45/45。

### 5.10 分支后的过期取指

位置：`cpu_top.v:98-110`（搜索 `ic_pending_word_addr`）。

AXI 接受取指时记录 `ic_pending_word_addr`。返回时只有它仍等于 core 当前请求地址，
才产生 `ic2cpu_valid`。分支改变 PC 后，旧地址响应即使正常返回也被丢弃。

## 6. 具体指令怎么沿数据通路执行

### 6.1 `addi x3, x0, 42`

1. IF 取指；
2. ID：opcode `0010011`、funct3 `000`，Controller 选 ADD、EXT_I、rs1 和立即数；
3. SEXT 得到 42，RF 的 x0 恒为 0；
4. EX：`0+42`；
5. MEM：无访存；
6. WB：`WB_ALU`，写 x3=42。

### 6.2 `add x4, x3, x5`

R 型 opcode `0110011`、funct3 `000`、funct7 `0000000`。两个源都从 RF/前递路径，
EX 相加，WB_ALU 写 rd。如果上一条刚产生 x3，forward_unit 优先从 MEM 前递。

### 6.3 `lh x5, 1(x1)`

1. ID：load、EXT_I、ALU_ADD、WB_RAM、`RAM_EXT_H`；
2. EX：计算字节地址 `x1+1`；
3. MEM/MREQ：AXI 实际读对齐的 32 位整字；
4. axi_master 把 ARADDR 低两位清零；
5. 返回后 MEXT 根据原地址 `byte_offs=01` 右移 8 位；
6. 取低 16 位，按 `RAM_EXT_H` 符号扩展；
7. WB 写 x5。

`lhu` 的唯一区别是零扩展。`lb/lbu` 同理，只取 8 位。

### 6.4 `sb/sh/sw`

以 `sb x5, 2(x1)` 为例：

1. EX 算地址；
2. store 数据可能从前级前递；
3. MREQ 看到 offset=2，产生 `WSTRB=0100`；
4. 把 x5 低 8 位左移 16 位到对应 byte lane；
5. AXI 的 AW/W 独立握手；
6. B 响应到达才完成。

`sh` 产生两位 strobe；`sw` 对齐时为 `1111`。当前 MREQ 对跨 32 位边界的非对齐
half/word 不拆分事务，课程测试使用可支持的对齐范围。

### 6.5 `beq x1, x2, target`

ID 生成 B 型立即数和 `ALU_EQ`；EX 对前递后的 rs1/rs2 比较。相等则目标为
`ex_pc+ex_ext`，flush 两条年轻指令，PC 重定向。B 型立即数最低位补 0，因为指令
地址至少按 2 字节对齐。

### 6.6 `jal x1, target`

EX 直接认为 taken，目标为 PC+J immediate；WB 把原 PC+4 写 x1，便于返回。

### 6.7 `jalr x1, 0(x5)`

EX 用前递后的 x5 加 I immediate，最低位清零作为目标；WB 写 PC+4。函数返回常见
形式是 `jalr x0,0(ra)`，x0 丢弃链接地址。

### 6.8 `lui` 和 `auipc`

- `lui rd,imm20`：SEXT 形成 `imm20<<12`，WB_EXT 直接写；
- `auipc rd,imm20`：ALU A 选 PC，B 选 U immediate，WB_ALU 写 PC+立即数。

### 6.9 `mul/div/rem`

Controller 用 funct7=`0000001` 和 funct3 区分七种 M 指令。实板进入
ALU_multicycle：

- MUL/MULH：先取绝对值，用无符号移位加法，再按符号恢复；
- MULHU：直接无符号高 32 位；
- DIV/DIVU：约 32 拍逐位生成商；
- REM/REMU：同时保留余数；
- 除数为 0：商全 1，余数为被除数；
- `INT_MIN / -1` 由 32 位补码自然得到 `0x80000000`，余数 0。

### 6.10 UART 软件中的 load/store

`sc_print.c`：

```c
while (*uart_stat_reg & 0x8u)
    ;
*uart_tx_fifo = (unsigned int)c;
```

第一行不断从 `0xFFFF3008` load 状态，等 TX 不忙；第二行向 `0xFFFF3004` store
字符。axi_board_soc 把该写变成 `uart_tx_start` 单拍脉冲，simple_uart 发送
start bit、8 data bits、stop bit。

接收 A 时，simple_uart 以 50 MHz/115200≈434 拍/bit，在起始位中点确认后逐位采样，
最终 `rx_data=0x41`、`rx_valid=1`。CPU 读 RX 地址 `0xFFFF3000` 后产生
`uart_rx_pop`，清除 valid。

## 7. AXI 与板级代码

### 7.1 AXI Master 状态机

位置：`axi_master.v:77-81`（搜索 `ST_IDLE`）。

```text
ST_IDLE
├─ 读 → ST_RADDR --AR握手--> ST_RDATA --R握手--> ST_IDLE
└─ 写 → ST_WSEND --AW和W均握手--> ST_WRESP --B握手--> ST_IDLE
```

请求优先级在 `axi_master.v:139-160`：data write > data read > instruction read。
所有访问单拍、32 位，AR/AW 地址按 4 字节对齐，子字节由 WSTRB/MEXT 处理。

### 7.2 为什么 AW/W 要分别记录？

从机可能先 ready 地址，也可能先 ready 数据。代码分别清
`m_axi_awvalid/m_axi_wvalid`，只有两者都完成才进入 WRESP。测试
`axi_master_tb.v` 还检查背压时 W 通道不能变化。

### 7.3 板级 AXI Slave

`axi_board_soc.v`：

- 地址小于 150 KiB 走 board_bram；
- IROM 50 KiB、DRAM 100 KiB；
- BMG 读有一拍延迟，用 `memory_read_pending` 记录；
- 其他高地址走 MMIO case；
- 不认识的地址返回 DECERR。

### 7.4 64 位计时器为什么高-低-高读？

CoreMark 在 `core_portme.c:59-71`：

```c
do {
    high_before = *timer_high;
    low         = *timer_low;
    high_after  = *timer_high;
} while (high_before != high_after);
```

如果读 low 时发生 32 位回卷，前后 high 不同，就重读，避免拼出不一致的 64 位值。

## 8. Trace 和实板为什么有两套 ALU？

`ALU.v` 根据 `RUN_TRACE` 自动选择：

- Trace：`ALU_trace` 用组合乘除，匹配课程参考环境，`busy=0`；
- 实板：`ALU_multicycle` 用迭代乘法器/除法器，降低组合路径，`busy` 冻结流水线。

回答时不能说“两套 CPU”。数据通路和指令语义相同，仅 M 扩展执行单元时序不同。
两套都被定向测试覆盖，最终实板 CoreMark 又验证了多周期版本。

## 9. 调试：老师最看重的部分

### 9.1 推荐的调试思路

始终沿数据流分层：

1. 时钟/复位是否正常；
2. PC 是否变化；
3. 是否发出取指 AR；
4. AR/R 是否握手；
5. 指令是否进入 ID/EX；
6. stall/flush 是否合理；
7. load/store 是否发出正确地址与 strobe；
8. WB 是否只提交一次；
9. MMIO 地址是否到达外设；
10. 软件是否看到预期状态。

### 9.2 ILA 探针速查

| 位 | 信号 | 用途 |
|---|---|---|
| `[199:192]` | ARLEN | Cache refill 应为 `03`，MMIO 为 `00` |
| `[191]` | RLAST | 四拍 refill 的最后一拍 |
| `[190:187]` | WSTRB | store 的有效 byte lane |
| `[186]` | 原始 RX | PC 是否真的把 UART 数据送到 FPGA |
| `[185]` | 同步后 RX | 输入同步是否工作 |
| `[184:183]` | RX state | IDLE/START/DATA/STOP |
| `[182]` | RX valid | 一个字符是否收完 |
| `[181:174]` | RX data | A 应为 `41` |
| `[173]` | PLL lock | 时钟向导是否锁定 |
| `[172]` | sys_rst | CPU 是否已脱离复位 |
| `[171:140]` | PC | CPU 是否前进/卡在哪 |
| `[139]`/`[138]` | ifetch req/valid | core 请求与响应 |
| `[137:106]` | ARADDR | 取指/数据读地址 |
| `[105:74]` | RDATA | 返回指令或数据 |
| `[73:70]` | AR/R valid-ready | 读握手 |
| `[69:38]` | AWADDR | 写地址，UART TX 应出现 `FFFF3004` |
| `[37:6]` | WDATA | 写字符 A 应含 `00000041` |
| `[5:0]` | AW/W/B valid-ready | 写握手与响应 |

### 9.3 从现象反推问题

| 现象 | 先看 |
|---|---|
| LED/数码管全 0，串口无输出 | PLL lock、sys_rst、PC、第一笔 AR |
| PC 不变，ARVALID=0 | core 取指请求/复位 |
| AR 握手但 RVALID 不来 | board_bram/AXI Slave 读响应 |
| 四个 R beat 后 ifetch_valid=0 | ICache 是否安装 line；当前 PC 是否因分支改变 |
| 能收到板发的 U，但 PC 发 A 无效 | RX 原始引脚→同步→状态机→rx_valid→CPU status load |
| ILA 中 rx_data 一直 41，CPU仍无反应 | 看 CPU 是否读 `FFFF3008/FFFF3000`，以及 load 是否重复发射 |
| store 重复出现 | response 拍屏蔽、`debug_mem_we` 是否只在 wresp 脉冲 |
| 分支后执行旧指令 | flush valid、ICache refill 后是否用当前 PC 重新查 tag |
| MUL 后结果错/重复 | 启动拍 busy、操作数是否前递后锁存、operation_issued |

### 9.4 本项目真正修过的三类问题

1. AXI 响应拍旧请求重复接受：41/45 → 屏蔽 response 拍 → 45/45；
2. taken branch 后旧取指返回：记录 pending address，只转发当前 PC 的响应；
3. load/M 长延迟重复进入 EX：重新区分依赖、duplicate 和 active freeze，UART 与
   CoreMark 最终实板通过。

老师问“你怎么证明修好了”时，不只说看代码：

- 45/45 AXI Trace；
- `cpu_top_fetch_tb`；
- `pipeline_hazard_tb`；
- `cpu_core_mext_tb`；
- 全系统 UART `0x41`；
- 实板 M 扩展 PASS；
- CoreMark CRC validated。

## 10. CoreMark 结果怎么解释

Cache 版实板记录：

```text
CoreMark Size    : 666
Total ticks      : 717005179
Total time (secs): 14
Iterations/Sec   : 50
Iterations       : 700
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x65c5
Correct operation validated.
CoreMark 1.0 : 48.814
CoreMark/MHz : 0.976
FINISH
```

有效性口径：

- 运行时间超过 10 秒；
- CRC 与已知 seed 配置匹配；
- 输出 `Correct operation validated`；
- 没有 `Errors detected`；
- 程序最终到达 `FINISH`。

得分计算来自 `core_portme.c:188-189`：

```c
CoreMark_Per_MHZ = ITERATIONS * 1000000 / total_ticks;
CoreMark = CoreMark_Per_MHZ * 50;
```

不要把 CoreMark/MHz 说成 IPC 或 CPI，它是基准得分按 MHz 归一化。

无 Cache 基线为 21.250 CoreMark、0.425 CoreMark/MHz、32 秒；两次测试的频率、
迭代次数、seed 和四组 CRC 相同，因此可以直接比较。Cache 版约为基线的 2.30 倍。
当前串口原图、Cache Timing/Utilization/DRC 和板卡显示照片仍需归档；不能拿无 Cache
图片或 WNS 冒充 Cache 版证据。

## 11. 快速问答

### 为什么 x0 永远为 0？

RF 读 x0 直接返回 0，写回时 `wR!=0` 才写数组。

### 为什么前递选择 MEM 优先于 WB？

MEM 中是更年轻、离当前 EX 更近的生产者；两个都命中同一 rs 时必须取最新值。

### 为什么 load 结果不能从 MEM 级普通前递？

EX/MEM 中只有 load 地址，数据要等 AXI R 通道完成，再经过 MEXT，最早从 WB 路径可用。

### 分支罚几拍？

分支在 EX 解析，taken 时 IF/ID 与 ID/EX 两个年轻位置被冲刷，基本控制罚时对应两个
前端位置；实际 AXI 取指延迟还会增加等待，不能固定声称所有情况恰好两拍。

### 有没有分支预测？

没有，默认顺序取指，EX 解析后再重定向。

### 有没有 Cache？

有。`ENABLE_ICACHE/ENABLE_DCACHE` 均开启；I/D Cache 为 64-line direct-mapped、
16-byte line。read miss 用 `ARLEN=3` 四拍 refill；DCache write-through、
no-write-allocate，MMIO Uncached。逐状态说明见
[`CACHE_IMPLEMENTATION_AND_DEFENSE.md`](./CACHE_IMPLEMENTATION_AND_DEFENSE.md)。

### AXI 是 AXI4 还是 AXI4-Lite？

接口使用 AXI4 的 len/size/burst/last。Cache read refill 为 `ARLEN=3` 的四拍
32-bit INCR burst，Uncached read 和 write 仍为单拍；不支持多笔 outstanding。

### 为什么数据写优先于取指？

保证老的 MEM 级 store 尽快完成并解除流水线冻结，避免让年轻取指占用唯一 Master。

### signed 和 unsigned 比较在哪里区分？

ALU 中 `SLT/BLT/BGE` 使用 `$signed`，`SLTU/BLTU/BGEU` 使用无符号比较。

### sb/sh 如何避免改坏同一字其他字节？

MREQ 产生精确 WSTRB；BRAM/AXI Slave 只使能对应 byte lane。

### 为什么 CoreMark BRAM 利用率 96%？

已有截图来自带 ILA 的构建，ILA 本身占用 BRAM；同时工程使用 150 KiB IROM+DRAM。
不能把 96% 直接解释为 CPU 核心面积。

### WNS 1.702 ns 表示什么？

最差建立时间仍有 1.702 ns 正余量；TNS=0、0 failing endpoints，说明该实现满足
当前时钟约束。它不等于还能无条件把主频提高相同比例，改频后必须重新实现。

## 12. 主讲与辅助配合

主讲回答顺序：

1. 先用一句基础原理；
2. 再说本项目怎么做；
3. 给具体文件和信号；
4. 用一条指令或一个 bug 举例；
5. 最后给测试证据。

辅助同学听到关键词后这样定位：

| 老师关键词 | 立刻打开 |
|---|---|
| 五级/valid/stall/flush | `cpu_core.v:43-211, 366-393` + `pipeline_regs.v` |
| 前递/RAW | `forward_unit.v:25-39` + `cpu_core.v:398-434` |
| load-use | `cpu_core.v:288-296, 366-389` + hazard 波形 |
| store 数据 | `cpu_core.v:167-168, 433-434, 475-485` + `MREQ.v` |
| 分支/JAL/JALR | `cpu_core.v:339-393, 534` |
| 乘除法 | `ALU_multicycle.v:39-179` |
| AXI 握手 | `axi_master.v:77-207` + AXI 波形 |
| Cache hit/miss | `ICache.v`、`DCache.v` + Cache 波形 |
| 四拍 refill | `axi_master.v` 的 `read_len/read_beat/read_buffer` |
| 过期取指 | `ICache.v` 回 IDLE 后重新检查当前地址 |
| MMIO/UART | `axi_board_soc.v:190-261` + `simple_uart.v:65-188` |
| CoreMark 计时 | `core_portme.c:36-71, 100-130, 164-194` |
| 调试/ILA | `miniRV_SoC.v:192-238` + `ILA_DEBUG_GUIDE.md` |

## 13. 最后一分钟总结

> 最终版本是带 ICache/DCache、单发射、五级 RV32IM 流水线 AXI SoC。核心通过 valid、
> 前递、load-use bubble、taken flush、AXI memory freeze 和 M 扩展 busy 保持按序
> 一次提交；I/D Cache 以四拍 burst refill，DCache 对 MMIO 保持 Uncached；板级 AXI Slave
> 连接 150 KiB BRAM、UART、LED、数码管和 64 位计时器。功能证据包括流水线 Basic
> 45/45、Cache/AXI 定向回归、Cache 版课程 AXI Trace 45/45，以及 Cache 版 EGO1
> CoreMark 的 48.814/0.976、CRC validated 和 FINISH。Cache 构建的原始时序报告、
> bitstream 和板卡照片还需从实验室电脑补回。
