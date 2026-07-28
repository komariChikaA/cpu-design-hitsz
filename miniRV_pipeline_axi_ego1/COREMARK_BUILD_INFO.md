# CoreMark 正式镜像构建信息

生成日期：2026-07-29

## 配置

```text
来源：课程 c_test_rv_stu.tar.gz 中的 c_test/4_coremark
目标：miniRV 五级流水线 AXI EGO1
FPGA：xc7a35tcsg324-1
CPU 频率：50 MHz
ISA / ABI：RV32IM / ILP32
优化：-O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las
CoreMark 模式：PERFORMANCE_RUN，单线程
迭代次数：700
学号：2024311081_2024311453
编译器：xPack GNU RISC-V Embedded GCC 12.2.0
```

课程说明要求 `core_portme.c` 中的 `MHZ` 与实际 CPU 频率一致；本工程时钟向导输出和
CoreMark 参数均为 50 MHz。

## 正式产物

```text
程序字数：13422
统一存储器深度：38400 × 32 bit
main.mem SHA-256：
6ACE2393153B87ACAFA9B740979E265ABDA63CF6D223BBCF8DAEB32FF8729D2D

coremark.elf SHA-256：
F3D280467C4889EDFD45E3F289D1C24F7E001F60C7FE321BA26716965E2D6070

coremark.bin SHA-256：
F7FD6A05E9A3E66E88590837E9709A86F3C69D4FD38BD5C798FCED6760255B59
```

ELF 和原始二进制随工程保存在
`software/c_test/4_coremark/prebuilt/`，反汇编保存在 `main.s`。

ELF 主要段：

```text
.text               35020 bytes @ 0x00000000
.rodata              2336 bytes @ 0x0000C800
.srodata.cst4           8 bytes
.srodata.cst8           8 bytes
.eh_frame              80 bytes
.data                  12 bytes
.sdata                 44 bytes
.bss                 2000 bytes
.sbss                  28 bytes
```

`.text` 小于 50 KiB IROM；RAM 文件数据和 BSS 均位于课程提供的 DRAM 地址范围内。

## 板级状态码

```text
刚启动：LED C001，数码管 C0010000
全部通过：LED C0A5，数码管 C0DE600D
检测到错误：LED E0xx，数码管 E000xxxx
无法验证：LED E0FF，数码管 E0FF0000
```

这些状态码用于辅助判断，最终验收仍以完整串口输出和实板照片为准。
