`timescale 1ns / 1ps

module divider #(
    parameter WIDTH = 32
)(
    input  wire               clk,
    input  wire               rst,
    input  wire [WIDTH-1:0]   x,
    input  wire [WIDTH-1:0]   y,
    input  wire               start,
    output reg  [WIDTH-1:0]   z,
    output reg  [WIDTH-1:0]   r,
    output reg                busy
);

    // 三态无符号恢复除法器；有符号处理在上层 ALU_multicycle 完成。
    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    // R 为当前余数，Q 为商，dividend 保存被除数各位，divisor 保存除数。
    reg [WIDTH-1:0] R, Q;
    reg [WIDTH-1:0] divisor;
    reg [WIDTH-1:0] dividend;
    reg [5:0] cnt;
    // 每拍把下一位被除数移入余数，随后判断能否减去除数。
    wire [WIDTH-1:0] R_shifted = {R[WIDTH-2:0], dividend[cnt]};

    // 恢复除法主状态机。busy=1 时外层流水线必须保持当前 EX 指令。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            busy    <= 1'b0;
            R       <= 0;
            Q       <= 0;
            r       <= 0;
            z       <= 0;
            cnt     <= 0;
            divisor <= 0;
            dividend <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // RISC-V 除零规则：商全 1，余数等于被除数。
                        if (y == 0) begin
                            z   <= {WIDTH{1'b1}};
                            r   <= x;
                            busy <= 1'b0;
                            state <= IDLE;
                        end else begin
                            // 正常除法从被除数最高位开始，共迭代 WIDTH 次。
                            divisor  <= y;
                            dividend <= x;
                            R        <= 0;
                            Q        <= 0;
                            cnt      <= WIDTH - 1;
                            busy     <= 1'b1;
                            state    <= CALC;
                        end
                    end else begin
                        busy <= 1'b0;
                    end
                end

                CALC: begin
                    // 试商：若移入新位后的余数不小于除数，当前商位写 1。
                    R <= R_shifted;
                    if (R_shifted >= divisor) begin
                        R <= R_shifted - divisor;
                        Q <= (Q << 1) | 1'b1;
                    end else begin
                        Q <= Q << 1;
                    end

                    if (cnt == 0) begin
                        state <= DONE;
                    end else begin
                        cnt <= cnt - 1;
                    end
                end

                DONE: begin
                    // 同时输出商 z 和余数 r，然后回到 IDLE。
                    z   <= Q;
                    r   <= R;
                    busy <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
