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

    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;
    reg [WIDTH-1:0] R, Q;
    reg [WIDTH-1:0] divisor;
    reg [WIDTH-1:0] dividend;
    reg [5:0] cnt;
    wire [WIDTH-1:0] R_shifted = {R[WIDTH-2:0], dividend[cnt]};

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
                        if (y == 0) begin
                            z   <= {WIDTH{1'b1}};
                            r   <= x;
                            busy <= 1'b0;
                            state <= IDLE;
                        end else begin
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
