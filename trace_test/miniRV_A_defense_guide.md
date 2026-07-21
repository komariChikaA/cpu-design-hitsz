# miniRV A 组指令答辩讲解稿

> 各模块的全部端口、内部参数和逻辑块含义见 [`miniRV_RTL_interface_guide.md`](./miniRV_RTL_interface_guide.md)。

这份讲解稿用于老师随机抽取 A 组的一条指令后，从“指令语义 → 数据通路表 → 控制信号 → RTL 代码 → 仿真波形”完整说明。A 组 18 条指令可归并成 6 类，因此不需要背 18 份互不相关的答案。

## 一、现场统一讲解顺序

无论抽到哪条指令，都按下面六步讲：

1. **说语义**：用一句公式说明指令做什么。
2. **拆字段**：指出 `opcode`、`funct3`、必要时的 `funct7`，以及 `rs1`、`rs2`、`rd`、立即数字段。
3. **读控制信号表**：依次解释 `npc_op`、`rf_we`、`rf_wsel`、`sext_op`、`alu_op`、`alua_sel`、`alub_sel`、`ram_rop`、`ram_wop`。
4. **沿数据通路走一遍**：从 PC/指令开始，经过 RF、SEXT、ALU，必要时经过 MREQ/MEXT，最后到 RF 写回或 NPC。
5. **对应 RTL**：先讲 `Controller.v` 的译码和控制，再讲 `cpu_core.v` 的多路选择，最后指出真正执行运算的模块。
6. **用波形闭环**：只有在 `ifetch_valid=1` 时解释 `inst`；核对输入、控制、运算结果、写回/访存和下一 PC。

数据通路总图见 [`docs/datapath/core.png`](../docs/datapath/core.png)，课程数据通路表和控制信号表见 [`miniRV_AB组_数据通路表+控制信号表.xlsx`](../course-materials/miniRV/miniRV_AB组_数据通路表+控制信号表.xlsx)。

## 二、控制信号编码

答辩时可以先说符号名，再补充代码中的二进制值。

| 信号 | 含义与编码 |
|---|---|
| `npc_op` | `PC4=00`，`JALR=01` |
| `rf_wsel` | `WB_ALU=00`，`WB_RAM=01`，`WB_PC4=10` |
| `sext_op` | `I_TYPE=000`，`S_TYPE=001`，`U_TYPE=011` |
| `alua_sel` | `SEL_RS1=0`，`SEL_PC=1` |
| `alub_sel` | `SEL_RS2=0`，`SEL_EXT=1` |
| `ram_rop` | 无读 `000`；字 `001`；有符号字节 `010`；无符号字节 `011`；有符号半字 `100`；无符号半字 `101` |
| `ram_wop` | 无写 `0000`；字节 `0001`；半字 `0011`；字 `1111` |

ALU 编码为：`ADD=00`、`SUB=01`、`XOR=04`、`SLL=05`、`SRL=06`、`SRA=07`。

## 三、A 组 18 条指令速查

下表中的 `-` 表示该信号对此指令不起作用。所有指令默认 `npc_op=PC4`，只有 `jalr` 例外。

| 指令 | 译码字段 `opcode/funct3/funct7` | `rf_we / rf_wsel` | `sext_op` | `ALU A / B / op` | 访存控制 |
|---|---|---|---|---|---|
| `add` | `0110011/000/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / ADD` | 无 |
| `sub` | `0110011/000/0100000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SUB` | 无 |
| `auipc` | `0010111/-/-` | `1 / WB_ALU` | `U_TYPE` | `PC / EXT / ADD` | 无 |
| `xor` | `0110011/100/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / XOR` | 无 |
| `xori` | `0010011/100/-` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / XOR` | 无 |
| `sll` | `0110011/001/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SLL` | 无 |
| `srl` | `0110011/101/0000000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SRL` | 无 |
| `srli` | `0010011/101/0000000` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / SRL` | 无 |
| `sra` | `0110011/101/0100000` | `1 / WB_ALU` | `-` | `RS1 / RS2 / SRA` | 无 |
| `srai` | `0010011/101/0100000` | `1 / WB_ALU` | `I_TYPE` | `RS1 / EXT / SRA` | 无 |
| `lb` | `0000011/000/-` | `1 / WB_RAM` | `I_TYPE` | `RS1 / EXT / ADD` | `ram_rop=BYTE_EXT` |
| `lbu` | `0000011/100/-` | `1 / WB_RAM` | `I_TYPE` | `RS1 / EXT / ADD` | `ram_rop=BYTE_UNSIGN` |
| `lh` | `0000011/001/-` | `1 / WB_RAM` | `I_TYPE` | `RS1 / EXT / ADD` | `ram_rop=HALF_EXT` |
| `lhu` | `0000011/101/-` | `1 / WB_RAM` | `I_TYPE` | `RS1 / EXT / ADD` | `ram_rop=HALF_UNSIGN` |
| `sw` | `0100011/010/-` | `0 / -` | `S_TYPE` | `RS1 / EXT / ADD` | `ram_wop=WORD_WRITE` |
| `sb` | `0100011/000/-` | `0 / -` | `S_TYPE` | `RS1 / EXT / ADD` | `ram_wop=BYTE_WRITE` |
| `sh` | `0100011/001/-` | `0 / -` | `S_TYPE` | `RS1 / EXT / ADD` | `ram_wop=HALF_WRITE` |
| `jalr` | `1100111/000/-` | `1 / WB_PC4` | `I_TYPE` | `RS1 / EXT / ADD` | `npc_op=JALR` |

注意：表格中的符号名来自课程表，RTL 中对应名称分别是 `EXT_I/EXT_S/EXT_U`、`ALU_A_RS1/ALU_A_PC`、`ALU_B_RS2/ALU_B_EXT`、`RAM_EXT_*` 和 `RAM_WE_*`。

## 四、18 条指令逐条讲解

下面每一条都可以直接作为现场回答。讲波形时，先把光标放到 `ifetch_valid=1` 且 `inst` 为目标指令的时刻，再读取同一时刻的组合逻辑信号；Load/Store 还要继续观察后续存储器应答周期。

### 1. `add rd, rs1, rs2`

- **语义**：`rd = rs1 + rs2`，按 32 位二进制补码相加，溢出时只保留低 32 位，不产生异常。
- **译码**：R 型，`opcode=0110011`、`funct3=000`、`funct7=0000000`；`rs1=inst[19:15]`、`rs2=inst[24:20]`、`rd=inst[11:7]`。
- **控制**：`npc_op=PC4`，`rf_we=1`，`rf_wsel=WB_ALU`，`alu_op=ADD`，`alua_sel=RS1`，`alub_sel=RS2`，不读写数据存储器。
- **数据通路**：RF 同时读出 `rf_rd1` 和 `rf_rd2`，分别进入 ALU A、B；`alu_c=rf_rd1+rf_rd2`，写回多路器选择 ALU 结果送入 `rd`，NPC 产生 `pc+4`。
- **代码**：`Controller.v` 的 `ADD_R` 完成译码，默认 ALU 操作为 ADD；`ALU.v` 中执行 `c=a+b`，`cpu_core.v` 选择两个寄存器操作数并写回。
- **波形**：打开 [`add.vcd`](../waveform/single/add.vcd)，验证 `alu_a=rf_rd1`、`alu_b=rf_rd2`、`alu_c=两者之和`，以及 `rf_we1=1`、`rf_wR=rd`、`rf_wD=alu_c`、`npc=pc+4`。

### 2. `sub rd, rs1, rs2`

- **语义**：`rd = rs1 - rs2`，结果保留低 32 位。
- **译码**：R 型，`opcode=0110011`、`funct3=000`、`funct7=0100000`。它与 `add` 的主要编码区别是 `funct7`。
- **控制**：除 `alu_op=SUB` 外，其余主要控制与 `add` 相同：下一 PC 选 `PC4`、两个 ALU 输入选 RS1/RS2、结果经 `WB_ALU` 写回。
- **数据通路**：`RF.rD1 → ALU.A`，`RF.rD2 → ALU.B`，ALU 做减法，结果直接回到 RF 的 `wD`。
- **代码**：`Controller.v` 的 `SUB` 判断 `funct7=0100000` 并产生 `ALU_SUB`；`ALU.v` 执行 `c=a-b`。
- **波形**：打开 [`sub.vcd`](../waveform/single/sub.vcd)，重点证明 `alu_op=01`、`alu_c=alu_a-alu_b`，并在 `rf_we1=1` 时检查写回寄存器和值。

### 3. `auipc rd, imm20`

- **语义**：`rd = PC + (imm20 << 12)`。这里使用的是当前指令的 PC，不是 `PC+4`。
- **译码**：U 型，`opcode=0010111`；`rd=inst[11:7]`，立即数来自 `inst[31:12]`。
- **控制**：`npc_op=PC4`，`rf_we=1`，`rf_wsel=WB_ALU`，`sext_op=U_TYPE`，`alu_op=ADD`，最关键的是 `alua_sel=PC`、`alub_sel=EXT`。
- **数据通路**：SEXT 生成 `{inst[31:12],12'b0}`；当前 PC 进入 ALU A，扩展立即数进入 ALU B，相加结果写回 `rd`。下一条指令仍从 `PC+4` 获取。
- **代码**：`Controller.v` 的 `AUIPC` 同时控制 U 型扩展和 ALU A 选择 PC；`SEXT.v` 的 `EXT_U` 左移 12 位；ALU 使用普通加法。
- **波形**：打开 [`auipc.vcd`](../waveform/single/auipc.vcd)，验证 `alua_sel=1`、`alu_a=pc`、`ext={imm20,12'b0}`、`alu_b=ext`、`rf_wD=pc+ext`。不要把 `alu_a` 误讲成 RS1，因为 U 型指令没有 RS1。

### 4. `xor rd, rs1, rs2`

- **语义**：`rd = rs1 XOR rs2`，每一位独立异或。
- **译码**：R 型，`opcode=0110011`、`funct3=100`、`funct7=0000000`。
- **控制**：`npc_op=PC4`，`rf_we=1`，`rf_wsel=WB_ALU`，`alu_op=XOR`，ALU 输入选择 RS1 和 RS2，无访存。
- **数据通路**：两个源寄存器进入 ALU，`alu_c=rf_rd1 ^ rf_rd2`，结果写回 `rd`。
- **代码**：`Controller.v` 的 `XOR_R` 产生 `ALU_XOR`；`ALU.v` 执行 `c=a^b`。
- **波形**：打开 [`xor.vcd`](../waveform/single/xor.vcd)，逐位或按十六进制验证 `alu_c=alu_a^alu_b`，并检查 `rf_wD=alu_c`。

### 5. `xori rd, rs1, imm12`

- **语义**：`rd = rs1 XOR sext(imm12)`。I 型立即数先符号扩展到 32 位，再参与异或。
- **译码**：I 型，`opcode=0010011`、`funct3=100`；立即数为 `inst[31:20]`。
- **控制**：`npc_op=PC4`，`rf_we=1`，`rf_wsel=WB_ALU`，`sext_op=I_TYPE`，`alu_op=XOR`，ALU A 选 RS1，B 选 EXT。
- **数据通路**：RF 读取 RS1；SEXT 对 `imm12` 符号扩展；两者进入 ALU 异或，结果写回 `rd`。
- **代码**：`Controller.v` 的 `XORI` 同时使 `imm_alu_inst` 成立，因此 `alub_sel=ALU_B_EXT`；`SEXT.v` 生成 I 型立即数，`ALU.v` 完成异或。
- **波形**：打开 [`xori.vcd`](../waveform/single/xori.vcd)，检查 `ext` 是否正确符号扩展、`alu_b=ext` 而不是 `rf_rd2`，以及 `rf_wD=rf_rd1^ext`。

### 6. `sll rd, rs1, rs2`

- **语义**：`rd = rs1 << rs2[4:0]`，逻辑左移，低位补 0，只使用 RS2 的低 5 位作为 0～31 的移位量。
- **译码**：R 型，`opcode=0110011`、`funct3=001`、`funct7=0000000`。
- **控制**：写回 ALU，ALU A/B 选择 RS1/RS2，`alu_op=SLL`，不访存，下一 PC 为 `PC+4`。
- **数据通路**：RF 的两个读口分别提供被移位数和移位量，ALU 左移结果经 `WB_ALU` 写回。
- **代码**：`Controller.v` 的 `SLL_R` 产生 `ALU_SLL`；`ALU.v` 使用 `a << b[4:0]`。
- **波形**：打开 [`sll.vcd`](../waveform/single/sll.vcd)，重点说明为什么只取 `alu_b[4:0]`，验证 `alu_c=alu_a<<alu_b[4:0]`。

### 7. `srl rd, rs1, rs2`

- **语义**：`rd = rs1 >> rs2[4:0]`，逻辑右移，高位补 0。
- **译码**：R 型，`opcode=0110011`、`funct3=101`、`funct7=0000000`。
- **控制与通路**：两个操作数均来自 RF，`alu_op=SRL`，结果通过 `WB_ALU` 写回，其他通路与普通 R 型运算相同。
- **代码**：`Controller.v` 用 `funct7=0000000` 区分 SRL；`ALU.v` 使用无符号逻辑右移 `a >> b[4:0]`。
- **波形**：打开 [`srl.vcd`](../waveform/single/srl.vcd)，验证高位补 0、移位量只取低 5 位、最终 `rf_wD=alu_c`。

### 8. `srli rd, rs1, shamt`

- **语义**：`rd = rs1 >> shamt`，逻辑右移，高位补 0，`shamt=inst[24:20]`。
- **译码**：I 型移位指令，`opcode=0010011`、`funct3=101`、`funct7=0000000`。
- **控制**：I 型扩展，ALU A 选 RS1、B 选 EXT，`alu_op=SRL`，结果经 `WB_ALU` 写回。
- **数据通路**：SEXT 虽然生成 32 位 `ext`，但 ALU 只使用 `ext[4:0]`，也就是编码中的 `shamt`。
- **代码**：`Controller.v` 的 `SRLI` 同时检查 `funct7`，避免与 `srai` 混淆；ALU 仍执行 `a >> b[4:0]`。
- **波形**：打开 [`srli.vcd`](../waveform/single/srli.vcd)，检查 `alub_sel=1`、`alu_b=ext`、`alu_c=alu_a>>ext[4:0]`，并观察高位补 0。

### 9. `sra rd, rs1, rs2`

- **语义**：`rd = signed(rs1) >>> rs2[4:0]`，算术右移，高位补原操作数符号位。
- **译码**：R 型，`opcode=0110011`、`funct3=101`、`funct7=0100000`。它与 `srl` 只在 `funct7` 上不同。
- **控制与通路**：ALU 输入来自 RS1/RS2，`alu_op=SRA`，结果写回 `rd`，无访存。
- **代码**：`Controller.v` 的 `SRA_R` 选择 `ALU_SRA`；`ALU.v` 使用 `$signed(a) >>> b[4:0]`，其中 `$signed` 保证按符号位填充。
- **波形**：打开 [`sra.vcd`](../waveform/single/sra.vcd)，最好选择 `alu_a[31]=1` 的测试点，证明右移后高位补 1，并与 SRL 的补 0 区分。

### 10. `srai rd, rs1, shamt`

- **语义**：`rd = signed(rs1) >>> shamt`，算术右移立即数。
- **译码**：I 型移位指令，`opcode=0010011`、`funct3=101`、`funct7=0100000`。
- **控制**：`sext_op=I_TYPE`、`alu_op=SRA`、A 选 RS1、B 选 EXT，ALU 结果写回。
- **数据通路**：`rs1` 是被移位数，`ext[4:0]=inst[24:20]` 是移位量；立即数字段高位中的 `0100000` 用于区分算术和逻辑右移，不影响 ALU 实际采用的低 5 位移位量。
- **代码**：`Controller.v` 的 `SRAI` 检查 `funct7=0100000`；`ALU.v` 使用带符号算术右移。
- **波形**：打开 [`srai.vcd`](../waveform/single/srai.vcd)，检查 `alu_b[4:0]=shamt`，并用负数输入证明结果高位进行符号扩展。

### 11. `lb rd, imm(rs1)`

- **语义**：从地址 `rs1+sext(imm12)` 读取 1 字节，并把该字节的 bit 7 符号扩展到 32 位后写入 `rd`。
- **译码**：I 型 Load，`opcode=0000011`、`funct3=000`。
- **控制**：`rf_we=1`、`rf_wsel=WB_RAM`、`sext_op=I_TYPE`、`alu_op=ADD`、A 选 RS1、B 选 EXT、`ram_rop=RAM_EXT_B`。
- **数据通路**：ALU 先算有效地址；MREQ 发出读请求；存储器返回包含目标字节的 32 位数据；MEXT 根据保存的地址低两位选择目标字节并符号扩展；`ram_ext` 最终写回 `rd`。
- **时序**：发请求时保存 `rd`、有效地址和 `ram_rop`，`ld_st_flag` 保持正在访存；直到 `daccess_rvalid=1` 才令 `rf_we1=1` 并推进 PC。
- **波形**：打开 [`lb.vcd`](../waveform/single/lb.vcd)，先验证 `daccess_addr=rf_rd1+ext`，再在响应周期验证所选字节、`ram_ext` 的高 24 位是否复制符号位，以及 `rf_wD=ram_ext`。

### 12. `lbu rd, imm(rs1)`

- **语义**：从有效地址读取 1 字节，并在高 24 位补 0 后写入 `rd`。
- **译码**：`opcode=0000011`、`funct3=100`；与 `lb` 的区别是 `funct3`。
- **控制与通路**：地址计算、请求和跨周期写回与 `lb` 相同，但 `ram_rop=RAM_EXT_BU`，MEXT 做零扩展而不是符号扩展。
- **代码**：`Controller.v` 的 `LBU` 选择 `RAM_EXT_BU`；MEXT 根据该控制把选中字节扩展为无符号 32 位数。
- **波形**：打开 [`lbu.vcd`](../waveform/single/lbu.vcd)，即使目标字节最高位为 1，`ram_ext[31:8]` 也必须全 0；这是与 `lb` 最重要的比较点。

### 13. `lh rd, imm(rs1)`

- **语义**：从有效地址读取 16 位半字，并把 bit 15 符号扩展到 32 位后写入 `rd`。
- **译码**：`opcode=0000011`、`funct3=001`。
- **控制**：与 Load 通用控制相同，`ram_rop=RAM_EXT_H` 指定有符号半字扩展。
- **数据通路**：ALU 计算地址，MREQ 仅在 `addr[0]=0` 时接受半字对齐访问；MEXT 根据 `addr[1]` 选择返回字的低半字或高半字，然后符号扩展。
- **波形**：打开 [`lh.vcd`](../waveform/single/lh.vcd)，检查地址最低位为 0、`daccess_ren` 有效；响应时确认所选半字及 `ram_ext[31:16]` 都等于该半字的符号位。

### 14. `lhu rd, imm(rs1)`

- **语义**：读取 16 位半字并零扩展到 32 位。
- **译码**：`opcode=0000011`、`funct3=101`。
- **控制与通路**：与 `lh` 相同，但 `ram_rop=RAM_EXT_HU`，MEXT 的高 16 位补 0。
- **代码**：`Controller.v` 用 `LHU` 选择无符号半字扩展；地址计算仍由 ALU ADD 完成。
- **波形**：打开 [`lhu.vcd`](../waveform/single/lhu.vcd)，验证对齐、响应握手以及 `ram_ext[31:16]=0`；即使读出的半字 bit 15 为 1，也不能补 1。

### 15. `sw rs2, imm(rs1)`

- **语义**：把 RS2 的 32 位数据写到地址 `rs1+sext(S-type imm)`。
- **译码**：S 型，`opcode=0100011`、`funct3=010`；立即数由 `inst[31:25]` 和 `inst[11:7]` 拼接，所以 Store 没有 `rd`。
- **控制**：`rf_we=0`，`sext_op=S_TYPE`，ALU A 选 RS1、B 选 EXT、`alu_op=ADD`，`ram_wop=RAM_WE_W`。
- **数据通路**：RS1 与立即数进入 ALU 计算地址；RS2 不进入地址加法，而是独立送到 `MREQ.ram_wdata`；对齐时 MREQ 产生 `daccess_wen=1111` 和完整 32 位写数据。
- **时序**：Store 不写 RF，必须等 `daccess_wresp=1` 才表示写事务完成并更新 PC。
- **波形**：打开 [`sw.vcd`](../waveform/single/sw.vcd)，验证 `daccess_addr=rf_rd1+ext`、地址低两位为 `00`、`daccess_wen=1111`、`daccess_wdata=rf_rd2`、`rf_we1=0`，最后出现 `daccess_wresp`。

### 16. `sb rs2, imm(rs1)`

- **语义**：把 RS2 的低 8 位写入有效地址指向的一个字节。
- **译码**：S 型，`opcode=0100011`、`funct3=000`。
- **控制**：不写 RF，S 型扩展，ALU ADD 计算地址，`ram_wop=RAM_WE_B`。
- **数据通路**：MREQ 根据 `addr[1:0]` 把基础字节使能 `0001` 左移，产生 `0001/0010/0100/1000`；同时把 `rf_rd2[7:0]` 移到相应的 8 位通道。
- **代码**：`MREQ.v` 使用 `4'b0001 << offset` 生成写使能，并使用 `ram_wdata << {offset,3'b000}` 对齐数据。
- **波形**：打开 [`sb.vcd`](../waveform/single/sb.vcd)，结合 `daccess_addr[1:0]` 检查 one-hot `daccess_wen`，并确认目标字节出现在 `daccess_wdata` 对应的 byte lane；`rf_we1` 应为 0。

### 17. `sh rs2, imm(rs1)`

- **语义**：把 RS2 的低 16 位写入有效地址指向的半字。
- **译码**：S 型，`opcode=0100011`、`funct3=001`。
- **控制**：不写 RF，S 型扩展，ALU ADD 计算地址，`ram_wop=RAM_WE_H`。
- **数据通路**：地址必须满足 `addr[0]=0`。若 `addr[1]=0`，MREQ 产生 `daccess_wen=0011`，数据放在低半字；若 `addr[1]=1`，产生 `1100`，数据移到高半字。
- **波形**：打开 [`sh.vcd`](../waveform/single/sh.vcd)，验证地址半字对齐、写使能为 `0011` 或 `1100`、RS2 低 16 位处于正确 lane，并等待 `daccess_wresp`。

### 18. `jalr rd, imm(rs1)`

- **语义**：先把 `PC+4` 写入 `rd`，再跳到 `(rs1+sext(imm12)) & 0xfffffffe`。最低位清零是 RISC-V 对 JALR 目标地址的规定。
- **译码**：I 型，`opcode=1100111`、`funct3=000`。
- **控制**：`npc_op=JALR`，`rf_we=1`，`rf_wsel=WB_PC4`，`sext_op=I_TYPE`，`alu_op=ADD`，A 选 RS1，B 选 EXT，无数据访存。
- **数据通路**：RS1 与扩展立即数进入 ALU 得到目标地址；`alu_c` 送入 NPC 并清零 bit 0 后更新 PC。同时另一条通路把 `pc4` 送到 RF 的 `wD`，写入 `rd`。
- **代码**：`Controller.v` 同时选择 `NPC_JALR` 和 `WB_PC4`；`NPC.v` 使用 `{jalr_addr[31:1],1'b0}`；`cpu_core.v` 的写回多路器选择 `pc4`。
- **波形**：打开 [`jalr.vcd`](../waveform/single/jalr.vcd)，同时检查两条结果：`npc={alu_c[31:1],1'b0}` 和 `rf_wD=pc4`。不能因为某个测试点中两者数值恰好相等，就认为它们来自同一通路。

## 五、六类数据通路怎么讲

### 1. R 型运算：`add/sub/xor/sll/srl/sra`

以 `sub rd, rs1, rs2` 为例：

`PC → 指令存储器 → inst → RF 同时读 rs1、rs2 → ALU 做 rf_rd1-rf_rd2 → WB_ALU → rd`。

数据通路表中，RF 的 `rR1=inst[19:15]`、`rR2=inst[24:20]`、`wR=inst[11:7]`、`wD=ALU.C`；ALU 的 A、B 分别来自 `RF.rD1`、`RF.rD2`。它不访问数据存储器，下一条地址是 `PC+4`。六条指令只在译码字段和 `alu_op` 上不同。

### 2. I 型运算：`xori/srli/srai`

以 `xori rd, rs1, imm` 为例：

`inst[31:20] → SEXT(I_TYPE) → ext`，RF 只读取 `rs1`；ALU A 选 `rf_rd1`，B 选 `ext`，执行异或，结果经 `WB_ALU` 写回 `rd`。移位立即数指令实际只使用 ALU B 的低 5 位作为移位量。

### 3. PC 相对运算：`auipc`

语义是 `rd = PC + (imm20 << 12)`。U 型立即数经 SEXT 形成 `{inst[31:12],12'b0}`；ALU A 选 PC 而不是 RS1，B 选扩展立即数，做加法并写回 `rd`。这里最容易漏讲的控制信号是 `alua_sel=SEL_PC`。

### 4. Load：`lb/lbu/lh/lhu`

语义都是先算有效地址 `addr = rs1 + sext(imm12)`，区别在读取宽度以及符号扩展方式：

`RF.rD1 + SEXT.ext → ALU.C → MREQ 地址 → 数据存储器 → daccess_rdata → MEXT → WB_RAM → rd`。

`lb/lh` 做符号扩展，`lbu/lhu` 做零扩展。Load 是跨周期指令：发出读请求时保存 `rd`、地址低位和读类型；等 `daccess_rvalid=1` 后，`rf_we1=1`，把 `ram_ext` 写回，然后才允许 PC 前进。

### 5. Store：`sw/sb/sh`

语义都是 `addr = rs1 + sext(S-type imm)`，然后把 `rs2` 的数据写到该地址：

`RF.rD1 + SEXT.ext → ALU.C → MREQ.ram_addr`，同时 `RF.rD2 → MREQ.ram_wdata`。MREQ 根据地址低两位生成字节使能和对齐后的写数据。Store 不写寄存器，所以 `rf_we=0`；等 `daccess_wresp=1` 后指令才完成。

其中 `sb` 的写使能会在 `0001/0010/0100/1000` 中按地址低两位移动；`sh` 为 `0011` 或 `1100`；对齐的 `sw` 为 `1111`。

### 6. 间接跳转：`jalr`

语义是：

```text
rd     = PC + 4
new_PC = (rs1 + sext(imm12)) & 0xfffffffe
```

RF 读取 `rs1`，I 型立即数经 SEXT 后进入 ALU B，ALU 做加法形成跳转地址；NPC 选择 `NPC_JALR` 并强制最低位清零。同时写回多路器选择 `WB_PC4`，把返回地址写入 `rd`。所以 `jalr` 有两条同时生效的结果通路：一条去 PC，另一条去 RF。

## 六、代码对应关系

答辩时不必逐行念代码，指出下面四层即可：

1. [`Controller.v`](../miniRV_basic/src/rtl/Controller.v) 第 33–50 行用 `opcode/funct3/funct7` 判断 A 组指令；第 81–133 行生成所有控制信号。
2. [`cpu_core.v`](../miniRV_basic/src/rtl/cpu_core.v) 第 110–148 行完成指令字段连接、译码、RF 读取和立即数扩展；第 170–181 行完成 ALU 输入选择和执行。
3. [`ALU.v`](../miniRV_basic/src/rtl/ALU.v) 第 50–58 行实现加减、异或和三种移位；[`SEXT.v`](../miniRV_basic/src/rtl/SEXT.v) 第 12–17 行实现 I/S/U 等立即数拼接。
4. 访存经过 [`MREQ.v`](../miniRV_basic/src/rtl/MREQ.v) 生成读写请求；`jalr` 在 [`NPC.v`](../miniRV_basic/src/rtl/NPC.v) 第 16–24 行产生 `PC+4` 和清零最低位后的新 PC。最终写回与完成时序在 `cpu_core.v` 第 224–243 行。

老师如果问“为什么代码里 `rf_we=1`，波形却不一定马上写回”，回答：`rf_we` 是译码得到的写回意图，真正送入寄存器堆的是时序门控后的 `rf_we1`。普通指令在 `ifetch_valid` 当拍写回，Load 在 `daccess_rvalid` 返回时写回。

## 七、波形应该展示哪些信号

所有 A 组波形都在 [`waveform/single`](../waveform/single/) 中，每条指令有独立 VCD。建议在 Surfer 中按以下顺序添加信号：

| 层次 | 信号 | 要证明什么 |
|---|---|---|
| 取指 | `pc`, `ifetch_valid`, `inst`, `npc`, `pc4` | 当前指令有效，下一 PC 正确 |
| 译码 | `npc_op`, `rf_wsel`, `sext_op`, `alu_op`, `alua_sel`, `alub_sel`, `ram_rop`, `ram_wop`, `rf_we` | 与控制信号表一致 |
| 执行 | `rf_rd1`, `rf_rd2`, `ext`, `alu_a`, `alu_b`, `alu_c` | 操作数选择和计算结果正确 |
| 写回 | `rf_we1`, `rf_wR`, `rf_wD` | 正确的值写进正确的 `rd` |
| Load | `daccess_ren`, `daccess_addr`, `daccess_rvalid`, `daccess_rdata`, `ram_ext`, `ld_st_flag` | 请求、响应和扩展正确 |
| Store | `daccess_wen`, `daccess_addr`, `daccess_wdata`, `daccess_wresp` | 字节使能、地址、写数据正确 |

波形判读有两个关键规则：

- `ifetch_valid=0` 时，`cpu_core` 会把内部 `inst` 强制成 `0x00000013`（NOP），此时不要拿 NOP 的控制信号解释目标指令。
- 只有 `rf_we1=1` 的时刻，`rf_wR/rf_wD` 才代表真实写回；Store 的 `rf_we1` 应始终为 0。

## 八、`jalr` 波形完整示例

打开 [`jalr.vcd`](../waveform/single/jalr.vcd)，在 VCD 时间 `290` 附近可以看到一条 `jalr x5, 0(x6)`：

| 信号 | 波形值 | 解释 |
|---|---:|---|
| `pc` | `0x00000014` | 当前指令地址 |
| `inst` | `0x000302e7` | `opcode=1100111`、`funct3=000`、`rs1=x6`、`rd=x5`、`imm=0` |
| `rf_rd1` | `0x00000018` | x6 中保存的基址 |
| `npc_op` | `01` | 选择 JALR 下一地址通路 |
| `rf_wsel` | `10` | 写回数据选择 `PC+4` |
| `alu_a / alu_b` | `0x18 / 0x0` | `rs1` 加扩展后的 I 型立即数 |
| `alu_c`、`npc` | `0x00000018` | 跳转目标 `(0x18+0)&~1=0x18` |
| `rf_we1 / rf_wR / rf_wD` | `1 / x5 / 0x00000018` | 把返回地址 `PC+4` 写入 x5 |

这一组波形同时证明了译码、ALU 跳转目标计算、NPC 选择和链接地址写回。这里目标地址与返回地址恰好同为 `0x18`，但来源不同：`npc` 来自 `alu_c`，`rf_wD` 来自 `pc4`，应结合 `npc_op=JALR` 和 `rf_wsel=WB_PC4` 判断，而不能只看数值相等。

## 九、可直接说的结尾

> 这条指令先由 opcode、funct3 和必要的 funct7 完成译码，控制器产生与表格一致的选择信号；数据按照 RF/SEXT—ALU—MEM—WB 或 NPC 的路径流动。波形中操作数、控制信号、ALU 结果以及最终写回或访存响应相互对应，因此不仅测试程序 PASS，而且这一条指令的内部执行过程也能被验证。
