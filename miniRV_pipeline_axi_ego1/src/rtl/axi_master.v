`timescale 1ns / 1ps

`include "defines.vh"

// Single-transaction AXI4 master used by the no-cache Lab 2B baseline.
// Requests are accepted in the following order: data write, data read,
// instruction read.  All transfers are aligned, single-beat, 32-bit accesses;
// byte and halfword stores are selected through WSTRB.
module axi_master(
    input  wire         aclk,
    input  wire         areset,     // high active

    // Instruction-side read interface
    output reg          ic_dev_rrdy,
    input  wire         ic_cpu_ren,
    input  wire [31:0]  ic_cpu_raddr,
    output reg          ic_dev_rvalid,
    output reg  [`IC_BLK_SIZE-1:0] ic_dev_rdata,

    // Data-side write interface
    output reg          dc_dev_wrdy,
    input  wire [ 3:0]  dc_cpu_wen,
    input  wire [31:0]  dc_cpu_waddr,
    input  wire [31:0]  dc_cpu_wdata,
    output reg          dc_dev_wresp,

    // Data-side read interface
    output reg          dc_dev_rrdy,
    input  wire         dc_cpu_ren,
    input  wire [31:0]  dc_cpu_raddr,
    output reg          dc_dev_rvalid,
    output reg  [`DC_BLK_SIZE-1:0] dc_dev_rdata,

    // AXI4 master write address channel
    output reg  [31:0]  m_axi_awaddr,
    output wire [ 7:0]  m_axi_awlen,
    output wire [ 2:0]  m_axi_awsize,
    output wire [ 1:0]  m_axi_awburst,
    output reg          m_axi_awvalid,
    input  wire         m_axi_awready,

    // AXI4 master write data channel
    output reg  [31:0]  m_axi_wdata,
    output reg  [ 3:0]  m_axi_wstrb,
    output wire         m_axi_wlast,
    output reg          m_axi_wvalid,
    input  wire         m_axi_wready,

    // AXI4 master write response channel
    output reg          m_axi_bready,
    input  wire [ 1:0]  m_axi_bresp,
    input  wire         m_axi_bvalid,

    // AXI4 master read address channel
    output reg  [31:0]  m_axi_araddr,
    output wire [ 7:0]  m_axi_arlen,
    output wire [ 2:0]  m_axi_arsize,
    output wire [ 1:0]  m_axi_arburst,
    output reg          m_axi_arvalid,
    input  wire         m_axi_arready,

    // AXI4 master read data channel
    output reg          m_axi_rready,
    input  wire [31:0]  m_axi_rdata,
    input  wire [ 1:0]  m_axi_rresp,
    input  wire         m_axi_rlast,
    input  wire         m_axi_rvalid
);

    localparam [2:0] ST_IDLE   = 3'd0;
    localparam [2:0] ST_RADDR  = 3'd1;
    localparam [2:0] ST_RDATA  = 3'd2;
    localparam [2:0] ST_WSEND  = 3'd3;
    localparam [2:0] ST_WRESP  = 3'd4;

    reg [2:0] state;
    reg       read_is_data;

    assign m_axi_awlen   = 8'd0;
    assign m_axi_awsize  = 3'b010; // four bytes per beat
    assign m_axi_awburst = 2'b01;  // INCR
    assign m_axi_wlast   = 1'b1;
    assign m_axi_arlen   = 8'd0;
    assign m_axi_arsize  = 3'b010;
    assign m_axi_arburst = 2'b01;

    // Only the highest-priority request sees ready when requests overlap.
    always @(*) begin
        ic_dev_rrdy = 1'b0;
        dc_dev_rrdy = 1'b0;
        dc_dev_wrdy = 1'b0;

        if (state == ST_IDLE) begin
            dc_dev_wrdy = 1'b1;
            dc_dev_rrdy = !(|dc_cpu_wen);
            ic_dev_rrdy = !(|dc_cpu_wen) && !dc_cpu_ren;
        end
    end

    // sys_rst is asserted for multiple clock cycles after the clock wizard
    // locks. Use a synchronous reset here so the AXI address/control
    // registers that feed Block RAM do not trigger Vivado REQP-1839.
    always @(posedge aclk) begin
        if (areset) begin
            state           <= ST_IDLE;
            read_is_data    <= 1'b0;
            ic_dev_rvalid   <= 1'b0;
            ic_dev_rdata    <= {`IC_BLK_SIZE{1'b0}};
            dc_dev_rvalid   <= 1'b0;
            dc_dev_rdata    <= {`DC_BLK_SIZE{1'b0}};
            dc_dev_wresp    <= 1'b0;
            m_axi_awaddr    <= 32'h0;
            m_axi_awvalid   <= 1'b0;
            m_axi_wdata     <= 32'h0;
            m_axi_wstrb     <= 4'h0;
            m_axi_wvalid    <= 1'b0;
            m_axi_bready    <= 1'b0;
            m_axi_araddr    <= 32'h0;
            m_axi_arvalid   <= 1'b0;
            m_axi_rready    <= 1'b0;
        end else begin
            // CPU-side responses are pulses.
            ic_dev_rvalid <= 1'b0;
            dc_dev_rvalid <= 1'b0;
            dc_dev_wresp  <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if ((|dc_cpu_wen) && dc_dev_wrdy) begin
                        m_axi_awaddr  <= {dc_cpu_waddr[31:2], 2'b00};
                        m_axi_awvalid <= 1'b1;
                        m_axi_wdata   <= dc_cpu_wdata;
                        m_axi_wstrb   <= dc_cpu_wen;
                        m_axi_wvalid  <= 1'b1;
                        state         <= ST_WSEND;
                    end else if (dc_cpu_ren && dc_dev_rrdy) begin
                        read_is_data  <= 1'b1;
                        m_axi_araddr  <= {dc_cpu_raddr[31:2], 2'b00};
                        m_axi_arvalid <= 1'b1;
                        state         <= ST_RADDR;
                    end else if (ic_cpu_ren && ic_dev_rrdy) begin
                        read_is_data  <= 1'b0;
                        m_axi_araddr  <= {ic_cpu_raddr[31:2], 2'b00};
                        m_axi_arvalid <= 1'b1;
                        state         <= ST_RADDR;
                    end
                end

                ST_RADDR: begin
                    if (m_axi_arvalid && m_axi_arready) begin
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;
                        state         <= ST_RDATA;
                    end
                end

                ST_RDATA: begin
                    if (m_axi_rvalid && m_axi_rready) begin
                        m_axi_rready <= 1'b0;
                        if (read_is_data) begin
                            dc_dev_rdata  <= m_axi_rdata;
                            dc_dev_rvalid <= 1'b1;
                        end else begin
                            ic_dev_rdata  <= m_axi_rdata;
                            ic_dev_rvalid <= 1'b1;
                        end
                        state <= ST_IDLE;
                    end
                end

                ST_WSEND: begin
                    if (m_axi_awvalid && m_axi_awready)
                        m_axi_awvalid <= 1'b0;
                    if (m_axi_wvalid && m_axi_wready)
                        m_axi_wvalid <= 1'b0;

                    if ((!m_axi_awvalid || m_axi_awready) &&
                        (!m_axi_wvalid  || m_axi_wready)) begin
                        m_axi_bready <= 1'b1;
                        state        <= ST_WRESP;
                    end
                end

                ST_WRESP: begin
                    if (m_axi_bvalid && m_axi_bready) begin
                        m_axi_bready <= 1'b0;
                        dc_dev_wresp <= 1'b1;
                        state        <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    // The current CPU interface has no exception/error return path.  BRESP,
    // RRESP and RLAST are intentionally observed only by the AXI testbench.
    wire _unused_ok = &{1'b0, m_axi_bresp, m_axi_rresp, m_axi_rlast};

endmodule
