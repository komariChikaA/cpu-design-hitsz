`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// EGO1 八位十六进制数码管动态扫描驱动
// -----------------------------------------------------------------------------
// value 的 8 个十六进制半字节分别显示在 8 位数码管上。位选和段选均为高有效。
module sevenseg_display(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] value,
    output reg  [ 7:0] dig_en,
    output reg  [ 7:0] dig_seg
);

    // 计数器高 3 位选择当前扫描位，降低每位刷新频率并利用视觉暂留。
    reg [15:0] scan_counter;
    wire [2:0] digit_index = scan_counter[15:13];
    reg  [3:0] digit_value;

    // 自由运行扫描计数器。
    always @(posedge clk or posedge rst) begin
        if (rst)
            scan_counter <= 16'h0;
        else
            scan_counter <= scan_counter + 16'h1;
    end

    // 组合逻辑分两步：先选 value 中的 4-bit 数字，再译成 8-bit 段码。
    always @(*) begin
        case (digit_index)
            3'd0: digit_value = value[ 3: 0];
            3'd1: digit_value = value[ 7: 4];
            3'd2: digit_value = value[11: 8];
            3'd3: digit_value = value[15:12];
            3'd4: digit_value = value[19:16];
            3'd5: digit_value = value[23:20];
            3'd6: digit_value = value[27:24];
            default: digit_value = value[31:28];
        endcase

        // 同一时刻只点亮一位。
        dig_en = 8'b0000_0001 << digit_index;
        // 段码顺序与 EGO1 约束文件中的引脚定义一致。
        case (digit_value)
            4'h0: dig_seg = 8'b1111_1100;
            4'h1: dig_seg = 8'b0110_0000;
            4'h2: dig_seg = 8'b1101_1010;
            4'h3: dig_seg = 8'b1111_0010;
            4'h4: dig_seg = 8'b0110_0110;
            4'h5: dig_seg = 8'b1011_0110;
            4'h6: dig_seg = 8'b1011_1110;
            4'h7: dig_seg = 8'b1110_0000;
            4'h8: dig_seg = 8'b1111_1110;
            4'h9: dig_seg = 8'b1111_0110;
            4'ha: dig_seg = 8'b1110_1110;
            4'hb: dig_seg = 8'b0011_1110;
            4'hc: dig_seg = 8'b1001_1100;
            4'hd: dig_seg = 8'b0111_1010;
            4'he: dig_seg = 8'b1001_1110;
            default: dig_seg = 8'b1000_1110;
        endcase
    end

endmodule
