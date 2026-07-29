`timescale 1ns / 1ps

module multiplier #(
    parameter WIDTH = 32
)(
    input  wire               clk,
    input  wire               rst,
    input  wire [WIDTH-1:0]   x,
    input  wire [WIDTH-1:0]   y,
    input  wire               start,
    output reg  [2*WIDTH-1:0] z,
    output reg                busy
);

    // 三态迭代乘法器：IDLE 接收 start，CALC 每拍处理乘数一位，DONE 输出结果。
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    // multiplicand 每拍左移；multiplier 每拍右移；product 保存部分积。
    reg [2*WIDTH-1:0] multiplicand;
    reg [WIDTH-1:0]   multiplier;
    reg [2*WIDTH-1:0] product;
    reg [5:0] cnt;

    // 移位加法算法。busy 覆盖整个 CALC 区间，外层 ALU 用它冻结流水线。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            busy  <= 1'b0;
            multiplicand <= 0;
            multiplier <= 0;
            product <= 0;
            z <= 0;
            cnt <= WIDTH - 1;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // 锁存操作数并清空部分积，从最低乘数位开始。
                        multiplicand <= x;
                        multiplier   <= y;
                        product      <= 0;
                        cnt          <= WIDTH - 1;
                        busy         <= 1'b1;
                        state        <= CALC;
                    end else begin
                        busy <= 1'b0;
                    end
                end

                CALC: begin
                    // 当前乘数位为 1 时，把当前被乘数加入部分积。
                    if (multiplier[0])
                        product <= product + multiplicand;
                    multiplicand <= multiplicand << 1;
                    multiplier   <= multiplier >> 1;
                    // 共处理 WIDTH 位；最后一位完成后转到 DONE。
                    if (cnt == 0)
                        state <= DONE;
                    else
                        cnt <= cnt - 1;
                end

                DONE: begin
                    // 结果寄存到 z，并释放 busy；下一拍重新等待 start。
                    z    <= product;
                    busy <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
