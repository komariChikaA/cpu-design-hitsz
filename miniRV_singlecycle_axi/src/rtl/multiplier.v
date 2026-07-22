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

    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg [2*WIDTH-1:0] multiplicand;
    reg [WIDTH-1:0]   multiplier;
    reg [2*WIDTH-1:0] product;
    reg [5:0] cnt;

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
                    if (multiplier[0])
                        product <= product + multiplicand;
                    multiplicand <= multiplicand << 1;
                    multiplier   <= multiplier >> 1;
                    if (cnt == 0)
                        state <= DONE;
                    else
                        cnt <= cnt - 1;
                end

                DONE: begin
                    z    <= product;
                    busy <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
