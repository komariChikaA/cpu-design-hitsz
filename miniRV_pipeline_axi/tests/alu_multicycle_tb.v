`timescale 1ns / 1ps

`include "defines.vh"

module alu_multicycle_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst = 1'b1;
    reg [4:0] op = `ALU_ADD;
    reg [31:0] a = 32'h0;
    reg [31:0] b = 32'h0;
    wire [31:0] c;
    wire br;
    wire busy;

    ALU_multicycle dut (
        .rst(rst),
        .clk(clk),
        .op(op),
        .a(a),
        .b(b),
        .c(c),
        .br(br),
        .busy(busy)
    );

    task fail;
        input [8*96-1:0] message;
        begin
            $fatal(1, "FAIL: %0s", message);
        end
    endtask

    task run_mext;
        input [4:0] test_op;
        input [31:0] test_a;
        input [31:0] test_b;
        input [31:0] expected;
        integer cycles;
        begin
            @(negedge clk);
            op = test_op;
            a = test_a;
            b = test_b;
            #1;
            if (!busy)
                fail("busy must assert in the launch cycle");

            cycles = 0;
            while (busy) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
                if (cycles > 40)
                    fail("multi-cycle operation timed out");
            end

            if (c !== expected) begin
                $fatal(1,
                       "FAIL: op=%h a=%h b=%h expected=%h actual=%h",
                       test_op, test_a, test_b, expected, c);
            end

            // Model the edge on which EX/MEM consumes the completed result.
            @(negedge clk);
            op = `ALU_ADD;
            a = 32'd1;
            b = 32'd2;
            @(posedge clk);
            #1;
            if (busy || c !== 32'd3)
                fail("ALU did not return to the single-cycle path");
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst <= 1'b0;

        run_mext(`ALU_MUL,   32'd6,         32'd7,         32'd42);
        run_mext(`ALU_MULH,  32'hffff_fffe, 32'd3,         32'hffff_ffff);
        run_mext(`ALU_MULHU, 32'h8000_0000, 32'd2,         32'd1);
        run_mext(`ALU_DIV,   32'hffff_ffd6, 32'd6,         32'hffff_fff9);
        run_mext(`ALU_DIVU,  32'd42,        32'd6,         32'd7);
        run_mext(`ALU_REM,   32'hffff_ffd5, 32'd6,         32'hffff_ffff);
        run_mext(`ALU_REMU,  32'd43,        32'd6,         32'd1);
        run_mext(`ALU_DIV,   32'd6,         32'd0,         32'hffff_ffff);
        run_mext(`ALU_REM,   32'h8000_0000, 32'd0,         32'h8000_0000);
        run_mext(`ALU_DIV,   32'h8000_0000, 32'hffff_ffff, 32'h8000_0000);
        run_mext(`ALU_REM,   32'h8000_0000, 32'hffff_ffff, 32'h0000_0000);

        $display("PASS: alu_multicycle_tb");
        $finish;
    end
endmodule
