# miniRV B 组指令答辩讲解稿

> 各模块的全部端口、内部参数和逻辑块含义见 [`miniRV_RTL_interface_guide.md`](./miniRV_RTL_interface_guide.md)。

本稿用于老师随机抽取 B 组任意一条指令后，从“指令语义 → 数据通路表 → 控制信号 → RTL 代码 → 仿真波形”完整说明。B 组共 18 条指令，包含逻辑运算、大小比较、条件分支和 M 扩展乘除法。

## 一、统一讲解顺序

1. 先写出指令语义，明确有符号还是无符号。
2. 拆出 `opcode`、`funct3`、`funct7`、`rs1`、`rs2`、`rd` 或立即数。
3. 对照控制信号表解释 `npc_op`、`rf_we`、`rf_wsel`、`sext_op`、`alu_op`、`alua_sel`、`alub_sel` 和访存控制。
4. 沿 RF、SEXT、ALU、NPC 或 WB 讲数据流向。
5. 指出 `Controller.v` 的译码、`cpu_core.v` 的通路选择和 `ALU.v` 的实际运算。
6. 用 VCD 验证操作数、控制信号、运算结果和最终状态；乘除法必须继续观察 `busy` 拉高到撤销的整个过程。

数据通路总图见 [`docs/datapath/core.png`](../docs/datapath/core.png)，课程表见 [`miniRV_AB组_数据通路表+控制信号表.xlsx`](../course-materials/miniRV/miniRV_AB组_数据通路表+控制信号表.xlsx)。

## 二、B 组控制信号速查

所有非分支指令的 `npc_op=PC4`；四条分支指令的 `npc_op=BRANCH`。B 组指令均不访问数据存储器，因此 `ram_rop=0`、`ram_wop=0`。

| 指令 | `opcode/funct3/funct7` | `rf_we / rf_wsel` | `sext_op` | `ALU A / B / op` | 特殊控制 |
|---|---|---|---|---|---|
| `and` | `0110011/111/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / AND` | - |
| `or` | `0110011/110/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / OR` | - |
| `slt` | `0110011/010/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SLT` | 有符号比较 |
| `sltu` | `0110011/011/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SLTU` | 无符号比较 |
| `slti` | `0010011/010/-` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / SLT` | 有符号比较 |
| `sltiu` | `0010011/011/-` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / SLTU` | 立即数先符号扩展，再无符号比较 |
| `andi` | `0010011/111/-` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / AND` | - |
| `blt` | `1100011/100/-` | `0 / -` | `B_TYPE` | `RS1 / RS2 / LT` | `npc_op=BRANCH` |
| `bge` | `1100011/101/-` | `0 / -` | `B_TYPE` | `RS1 / RS2 / GE` | `npc_op=BRANCH` |
| `bltu` | `1100011/110/-` | `0 / -` | `B_TYPE` | `RS1 / RS2 / LTU` | `npc_op=BRANCH` |
| `bgeu` | `1100011/111/-` | `0 / -` | `B_TYPE` | `RS1 / RS2 / GEU` | `npc_op=BRANCH` |
| `mul` | `0110011/000/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / MUL` | `is_mul=1` |
| `mulh` | `0110011/001/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / MULH` | `is_mul=1`，有符号高 32 位 |
| `mulhu` | `0110011/011/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / MULHU` | `is_mul=1`，无符号高 32 位 |
| `div` | `0110011/100/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / DIV` | `is_div=1` |
| `divu` | `0110011/101/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / DIVU` | `is_div=1`，无符号 |
| `rem` | `0110011/110/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / REM` | `is_div=1`，取余数 |
| `remu` | `0110011/111/0000001` | `1 / WB_ALU` | `-` | `RS1 / RS2 / REMU` | `is_div=1`，无符号余数 |

## 三、18 条指令逐条讲解

### 1. `and rd, rs1, rs2`

- **语义**：`rd = rs1 & rs2`，对两个 32 位操作数逐位与。
- **译码**：R 型，`opcode=0110011`、`funct3=111`、`funct7=0000000`。
- **控制**：`npc_op=PC4`、`rf_we=1`、`rf_wsel=WB_ALU`、`alu_op=AND`，ALU A/B 分别选 RS1/RS2，无访存。
- **数据通路**：RF 两个读口输出进入 ALU，`alu_c=rf_rd1&rf_rd2`，结果经写回多路器进入 `rd`，PC 更新为 `PC+4`。
- **代码**：`Controller.v` 的 `AND_R` 产生 `ALU_AND`；`ALU.v` 执行 `c=a&b`。
- **波形**：打开 [`and.vcd`](../waveform/single/and.vcd)，检查 `alu_a=rf_rd1`、`alu_b=rf_rd2`、`alu_c=alu_a&alu_b`，并在 `rf_we1=1` 时核对 `rf_wR` 和 `rf_wD`。

### 2. `or rd, rs1, rs2`

- **语义**：`rd = rs1 | rs2`，逐位或。
- **译码**：R 型，`opcode=0110011`、`funct3=110`、`funct7=0000000`。
- **控制与通路**：与 `and` 相同，只是 `alu_op=OR`；两个寄存器操作数进入 ALU，结果通过 `WB_ALU` 写回。
- **代码**：`Controller.v` 的 `OR_R` 产生 `ALU_OR`；`ALU.v` 执行 `c=a|b`。
- **波形**：打开 [`or.vcd`](../waveform/single/or.vcd)，验证 `alu_c=alu_a|alu_b`、`rf_wD=alu_c` 和 `npc=pc+4`。

### 3. `slt rd, rs1, rs2`

- **语义**：把两个操作数按有符号补码比较；若 `signed(rs1)<signed(rs2)`，则 `rd=1`，否则 `rd=0`。
- **译码**：R 型，`opcode=0110011`、`funct3=010`、`funct7=0000000`。
- **控制**：写回 ALU，输入选 RS1/RS2，`alu_op=SLT`，无访存。
- **数据通路**：RF 读出两个源数，ALU 进行有符号比较并生成 32 位的 0 或 1，写回 `rd`。
- **代码**：`ALU.v` 使用 `$signed(a)<$signed(b)`；`$signed` 是它与 `sltu` 的关键区别。
- **波形**：打开 [`slt.vcd`](../waveform/single/slt.vcd)，选择正负号不同的测试点最有说服力。例如 `0xffffffff` 按有符号是 -1，应小于 1，结果为 1。

### 4. `sltu rd, rs1, rs2`

- **语义**：按无符号数比较；若 `unsigned(rs1)<unsigned(rs2)`，则 `rd=1`，否则为 0。
- **译码**：R 型，`opcode=0110011`、`funct3=011`、`funct7=0000000`。
- **控制与通路**：与 `slt` 相同，但 `alu_op=SLTU`，比较不解释符号位。
- **代码**：`ALU.v` 直接使用 `a<b`，两个信号本身是无符号 wire。
- **波形**：打开 [`sltu.vcd`](../waveform/single/sltu.vcd)，可用 `0xffffffff` 与 1 对比：按无符号前者更大，所以结果为 0，这与 `slt` 相反。

### 5. `slti rd, rs1, imm12`

- **语义**：若 `signed(rs1)<signed(sext(imm12))`，则 `rd=1`，否则为 0。
- **译码**：I 型，`opcode=0010011`、`funct3=010`。
- **控制**：`sext_op=I_TYPE`、`alu_op=SLT`、ALU A 选 RS1、B 选 EXT，结果经 `WB_ALU` 写回。
- **数据通路**：RF 读取 RS1，SEXT 对 12 位立即数做符号扩展，两者进入 ALU 做有符号比较。
- **代码**：`Controller.v` 将 `SLTI` 归入立即数 ALU 指令，使 `alub_sel=ALU_B_EXT`；ALU 使用有符号比较。
- **波形**：打开 [`slti.vcd`](../waveform/single/slti.vcd)，先确认负立即数的 `ext[31:12]` 全 1，再核对比较结果和写回值。

### 6. `sltiu rd, rs1, imm12`

- **语义**：立即数仍先按 I 型规则符号扩展到 32 位，然后把扩展结果和 RS1 都当成无符号数比较；条件成立写 1，否则写 0。
- **译码**：I 型，`opcode=0010011`、`funct3=011`。
- **控制**：I 型扩展、A 选 RS1、B 选 EXT、`alu_op=SLTU`、结果写回 ALU 通路。
- **易错点**：`sltiu` 的“U”表示比较方式无符号，不表示立即数零扩展。比如立即数 -1 会先扩展成 `0xffffffff`，再作为很大的无符号数参与比较。
- **代码**：SEXT 仍执行 `EXT_I`，ALU 则执行无符号 `a<b`。
- **波形**：打开 [`sltiu.vcd`](../waveform/single/sltiu.vcd)，同时展示 `ext` 和 `alu_c`，用来证明“符号扩展、无符号比较”这两个步骤并不矛盾。

### 7. `andi rd, rs1, imm12`

- **语义**：`rd = rs1 & sext(imm12)`。
- **译码**：I 型，`opcode=0010011`、`funct3=111`。
- **控制**：`sext_op=I_TYPE`、`alu_op=AND`、ALU A 选 RS1、B 选 EXT、结果经 `WB_ALU` 写回。
- **数据通路**：RS1 由 RF 提供，立即数由 SEXT 符号扩展，ALU 逐位与后写入 `rd`。
- **代码**：`Controller.v` 的 `ANDI` 同时决定立即数输入选择和 `ALU_AND`。
- **波形**：打开 [`andi.vcd`](../waveform/single/andi.vcd)，验证 `alu_b=ext` 而不是 RS2，并检查 `rf_wD=rf_rd1&ext`。

### 8. `blt rs1, rs2, offset`

- **语义**：按有符号数比较；若 `signed(rs1)<signed(rs2)`，跳到 `PC+sext(B-imm)`，否则执行 `PC+4`。
- **译码**：B 型，`opcode=1100011`、`funct3=100`；立即数由 `inst[31]、inst[7]、inst[30:25]、inst[11:8]` 重排，最低位补 0。
- **控制**：`npc_op=BRANCH`、`rf_we=0`、`sext_op=B_TYPE`、`alu_op=LT`，ALU 输入选 RS1/RS2。
- **数据通路**：ALU 不生成写回数据，而是输出比较结果 `br`；SEXT 生成分支偏移；NPC 根据 `br` 在 `pc+ext` 与 `pc+4` 之间选择。
- **代码**：`ALU.v` 使用 `$signed(a)<$signed(b)` 产生 `br`；`NPC.v` 的分支分支项完成下一 PC 选择。
- **波形**：打开 [`blt.vcd`](../waveform/single/blt.vcd)，分别找 `br=1` 和 `br=0` 的测试点：taken 时 `npc=pc+ext`，not-taken 时 `npc=pc4`；两种情况下 `rf_we1=0`。

### 9. `bge rs1, rs2, offset`

- **语义**：按有符号数比较；若 `signed(rs1)>=signed(rs2)` 则跳转，否则顺序执行。
- **译码**：B 型，`opcode=1100011`、`funct3=101`。
- **控制与通路**：与 `blt` 相同，但 `alu_op=GE`，ALU 的 `br` 条件改为有符号大于等于。
- **代码**：`ALU.v` 使用 `$signed(a)>=$signed(b)`。
- **波形**：打开 [`bge.vcd`](../waveform/single/bge.vcd)，验证相等时也必须 `br=1`；然后根据 `br` 检查 `npc` 选择偏移目标或 `pc+4`。

### 10. `bltu rs1, rs2, offset`

- **语义**：按无符号数比较；若 `rs1<rs2` 则分支跳转。
- **译码**：B 型，`opcode=1100011`、`funct3=110`。
- **控制**：`npc_op=BRANCH`、B 型扩展、`alu_op=LTU`、不写 RF。
- **数据通路**：RF 两个值送入 ALU 无符号比较，`br` 控制 NPC；偏移计算仍是 `pc+ext`。
- **代码**：`ALU.v` 使用无符号 `a<b`，与 `blt` 的 `$signed` 比较不同。
- **波形**：打开 [`bltu.vcd`](../waveform/single/bltu.vcd)，用最高位为 1 的操作数说明它被当成大正数；检查 `br`、`ext` 和 `npc` 三者关系。

### 11. `bgeu rs1, rs2, offset`

- **语义**：按无符号数比较；若 `rs1>=rs2` 则跳转。
- **译码**：B 型，`opcode=1100011`、`funct3=111`。
- **控制与通路**：`alu_op=GEU`，其余与其他 B 型分支一致；ALU 产生 `br`，NPC 决定下一地址，无寄存器写回。
- **代码**：`ALU.v` 使用无符号 `a>=b`。
- **波形**：打开 [`bgeu.vcd`](../waveform/single/bgeu.vcd)，确认相等时 taken；若 `br=1`，必须看到 `npc=pc+ext`，否则为 `pc+4`。

### 12. `mul rd, rs1, rs2`

- **语义**：计算 32×32 位乘积，`rd` 取完整 64 位乘积的低 32 位。低 32 位对有符号和无符号乘法相同。
- **译码**：M 扩展 R 型，`opcode=0110011`、`funct3=000`、`funct7=0000001`。
- **控制**：`rf_we=1`、`rf_wsel=WB_ALU`、`alu_op=MUL`、A/B 选 RS1/RS2、`is_mul=1`。
- **数据通路与时序**：ALU 锁存操作数和操作码，`multiplier` 采用移位加法迭代；`mul_div_busy=1` 期间 PC 保持不变，`rf_wR_r` 保存 rd。完成时 ALU 取乘积低 32 位，`rf_we1` 脉冲写回，然后 PC 前进。
- **代码**：`ALU.v` 根据符号先求绝对值、迭代相乘并按符号修正 64 位结果；`multiplier.v` 的 `IDLE/CALC/DONE` 状态机完成 32 轮运算。
- **波形**：打开 [`mul.vcd`](../waveform/single/mul.vcd)，观察 `mul_flag` 启动、`mul_busy/mul_div_busy` 拉高、PC 保持、计数器递减、busy 撤销后 `rf_we1=1`，并验证 `rf_wD=(rs1*rs2)[31:0]`。

### 13. `mulh rd, rs1, rs2`

- **语义**：把 RS1、RS2 都视为有符号数相乘，`rd` 取有符号 64 位乘积的高 32 位。
- **译码**：`opcode=0110011`、`funct3=001`、`funct7=0000001`。
- **控制与时序**：与 `mul` 相同，但 `alu_op=MULH`；仍走有符号乘法器，完成后选择 `mul_res_signed[63:32]`。
- **易错点**：不能只用 32 位乘法结果再右移，必须先保留完整 64 位积；负数结果需要在 64 位范围内补码修正。
- **代码**：ALU 通过 `sign_ab_r=a[31]^b[31]` 保存结果符号，完成后对 64 位绝对值乘积取补码，再取高半部分。
- **波形**：打开 [`mulh.vcd`](../waveform/single/mulh.vcd)，检查输入符号、`sign_ab_r`、64 位 `mul_res_signed` 和最终高 32 位写回值。

### 14. `mulhu rd, rs1, rs2`

- **语义**：把两个操作数都当成无符号数相乘，`rd` 取 64 位乘积的高 32 位。
- **译码**：`opcode=0110011`、`funct3=011`、`funct7=0000001`。
- **控制与时序**：`alu_op=MULHU`、`is_mul=1`，使用无符号乘法通路 `U_mulu`；完成后选择 `mulu_res[63:32]`。
- **区别**：当任一操作数最高位为 1 时，`mulhu` 与 `mulh` 的高 32 位通常不同，因为 `mulhu` 不把该位解释为负号。
- **波形**：打开 [`mulhu.vcd`](../waveform/single/mulhu.vcd)，观察 `mulu_flag/mulu_busy` 而不是 `mul_flag/mul_busy`，并核对无符号 64 位乘积的高半部分。

### 15. `div rd, rs1, rs2`

- **语义**：有符号整数除法，商向 0 截断，`rd=quotient`。除数为 0 时结果为 `0xffffffff`；`0x80000000 / 0xffffffff` 的溢出结果为 `0x80000000`。
- **译码**：`opcode=0110011`、`funct3=100`、`funct7=0000001`。
- **控制**：`alu_op=DIV`、`is_div=1`、写回 ALU，两个输入来自 RS1/RS2。
- **数据通路与时序**：ALU 保存操作数符号并把绝对值送入迭代除法器；`div_busy=1` 时 PC 停住；完成后按商的符号做补码修正并写回。
- **代码**：`divider.v` 用恢复除法逐位生成商和余数；`ALU.v` 处理正负号、除零结果和最终商选择。
- **波形**：打开 [`div.vcd`](../waveform/single/div.vcd)，观察 `div_flag`、`div_busy`、`cnt`、`div_quo`、符号修正后的 `alu_c`，最后在 busy 下降后检查 `rf_we1/rf_wD`。

### 16. `divu rd, rs1, rs2`

- **语义**：无符号整数除法，`rd=unsigned(rs1)/unsigned(rs2)`；除数为 0 时商为 `0xffffffff`。
- **译码**：`opcode=0110011`、`funct3=101`、`funct7=0000001`。
- **控制与时序**：`alu_op=DIVU`、`is_div=1`，使用 `U_divu` 对原始位模式直接做无符号迭代除法，不进行符号绝对值和结果符号修正。
- **区别**：最高位为 1 的数在 `divu` 中是大正数，因此可能与 `div` 得到完全不同的商。
- **波形**：打开 [`divu.vcd`](../waveform/single/divu.vcd)，观察 `divu_flag/divu_busy/divu_quo`，确认 `rf_wD=divu_quo`，并检查 PC 在 busy 期间不变。

### 17. `rem rd, rs1, rs2`

- **语义**：有符号余数，满足 `rs1 = quotient*rs2 + remainder`；余数非零时与被除数 RS1 同号。除数为 0 时余数等于 RS1；溢出特例余数为 0。
- **译码**：`opcode=0110011`、`funct3=110`、`funct7=0000001`。
- **控制与时序**：`alu_op=REM`、`is_div=1`，与 `div` 共用有符号除法器，但完成后选择余数而不是商。
- **代码**：ALU 根据保存的 `a_sign_r` 修正 `div_rem` 的符号；注意余数符号取决于被除数，而不是两个操作数符号异或。
- **波形**：打开 [`rem.vcd`](../waveform/single/rem.vcd)，观察 `div_rem`、`a_sign_r`、修正后的 `alu_c`，并用 `a=q*b+r` 复核最终值。

### 18. `remu rd, rs1, rs2`

- **语义**：无符号余数，`rd=unsigned(rs1)%unsigned(rs2)`；除数为 0 时结果等于 RS1。
- **译码**：`opcode=0110011`、`funct3=111`、`funct7=0000001`。
- **控制与时序**：`alu_op=REMU`、`is_div=1`，使用无符号除法器并选择 `divu_rem` 写回，不进行符号修正。
- **区别**：它与 `divu` 使用同一次类型的迭代过程，但 `divu` 取商，`remu` 取余数；与 `rem` 相比，输入输出都按无符号解释。
- **波形**：打开 [`remu.vcd`](../waveform/single/remu.vcd)，检查 `divu_flag/divu_busy/divu_rem`，busy 结束时 `rf_wD=divu_rem`，并验证 `rs1=divu_quo*rs2+divu_rem`。

## 四、三类数据通路总结

### 1. 普通 ALU 写回

`and/or/slt/sltu` 使用 `RF.rD1、RF.rD2 → ALU → WB_ALU → RF`；`slti/sltiu/andi` 把第二个输入换成 `SEXT.ext`。这些都是单周期指令，在 `ifetch_valid` 有效的同一拍产生 `rf_we1` 和 `inst_finished`。

### 2. 条件分支

`blt/bge/bltu/bgeu` 的两个寄存器操作数进入 ALU，只生成一位 `br`；B 型立即数进入 NPC 作为 offset。`br=1` 时 `npc=pc+ext`，否则 `npc=pc+4`。分支不写回 RF，也不访问数据存储器。

### 3. 乘除法多周期通路

`mul/mulh/mulhu/div/divu/rem/remu` 启动 ALU 内部迭代单元。开始时保存 `rd`、操作数符号和 `alu_op`；busy 期间 PC 不前进；完成后由 `op_r` 决定选择积的高/低位、商或余数，`rf_we1` 仅在结果有效时产生一个写回脉冲。

## 五、代码对应关系

1. [`Controller.v`](../miniRV_basic/src/rtl/Controller.v) 第 53–70 行识别 18 条 B 组指令，第 75–135 行生成分类、ALU、分支和乘除法控制。
2. [`cpu_core.v`](../miniRV_basic/src/rtl/cpu_core.v) 第 110–181 行完成译码、RF/SEXT 和 ALU 输入选择；第 153–168 行保存乘除法状态；第 224–243 行在 busy 结束后写回并推进 PC。
3. [`ALU.v`](../miniRV_basic/src/rtl/ALU.v) 第 34–77 行选择乘除结果、普通 ALU 结果和分支条件；第 79 行以后完成乘除启动、操作数/操作码保存及四个迭代单元连接。
4. [`multiplier.v`](../miniRV_basic/src/rtl/multiplier.v) 实现移位加法乘法器；[`divider.v`](../miniRV_basic/src/rtl/divider.v) 实现逐位恢复除法器；[`NPC.v`](../miniRV_basic/src/rtl/NPC.v) 根据 `br` 选择分支目标。

## 六、波形信号清单

| 指令类型 | 建议展示的信号 |
|---|---|
| 所有指令 | `pc`, `ifetch_valid`, `inst`, `npc`, `rf_rd1`, `rf_rd2`, `ext`, `alu_op`, `alu_a`, `alu_b`, `alu_c`, `rf_we1`, `rf_wR`, `rf_wD` |
| 分支 | 再加 `npc_op`, `sext_op`, `br`, `pc4` |
| 乘法 | 再加 `is_mul`, `mul_div_flag`, `mul_flag` 或 `mulu_flag`, `mul_busy` 或 `mulu_busy`, `mul_div_busy`, `op_r`, `rf_wR_r` |
| 除法/余数 | 再加 `is_div`, `div_flag` 或 `divu_flag`, `div_busy` 或 `divu_busy`, `cnt`, `div_quo/div_rem` 或 `divu_quo/divu_rem` |

判读时注意：

- `ifetch_valid=0` 后内部 `inst` 会变成 NOP，乘除法真正使用的是已经锁存的 `op_r`、操作数和 `rf_wR_r`。
- `rf_we` 表示译码后的写回意图，真正写寄存器堆的是 `rf_we1`。
- 比较/分支题先说明 signed 或 unsigned，再解释十六进制数；否则最高位为 1 的输入很容易讲反。
- 分支必须分别会讲 taken 和 not-taken；乘除法必须从 start 讲到 busy 撤销，不能只截最终写回一拍。

## 七、可直接说的结尾

> 这条指令由 opcode、funct3 和 funct7 完成译码，控制信号与课程表一致。两个源操作数经 RF 进入 ALU，立即数指令还经过 SEXT；普通运算从 ALU 写回，分支由 br 控制 NPC，乘除法则在 busy 期间保持 PC 并在迭代完成后写回。波形中的输入、控制、结果和最终状态彼此对应，因此可以证明该指令的内部实现正确。
