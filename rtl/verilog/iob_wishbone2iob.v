`include "timescale.v"

module iob_wishbone2iob #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
) (
    input wire clk_i,
    input wire arst_i,
    input wire wb_rst_i, // WB Documentation - SUGGESTION 3.00, Some circuits require an asynchronous reset capability. If an IP core or other SoC component requires an asynchronous reset, then define it as a non-WISHBONE signal. This prevents confusion with the WISHBONE reset [RST_I] signal that uses a purely synchronous protocol, and needs to be applied to the WISHBONE interface only.

    // Wishbone interface
    input  wire [ADDR_W-1:0]   wb_addr_i,
    input  wire [DATA_W/8-1:0] wb_select_i,
    input  wire                wb_we_i,
    input  wire                wb_cyc_i,
    input  wire                wb_stb_i,
    input  wire [DATA_W-1:0]   wb_data_i,
    output wire                wb_ack_o,
    output wire                wb_error_o,
    output wire [DATA_W-1:0]   wb_data_o,

    // IOb interface
    output wire                valid_o,
    output wire [ADDR_W-1:0]   address_o,
    output wire [DATA_W-1:0]   wdata_o,
    output wire [DATA_W/8-1:0] wstrb_o,
    input  wire [DATA_W-1:0]   rdata_i,
    input  wire                ready_i
);
    
    // IOb auxiliar wires
    wire                valid;
    wire                valid_r;
    wire                valid_e;
    wire                ready;
    wire                ready_r;
    wire [DATA_W-1:0]   rdata_r;
    // Wishbone auxiliar wire
    wire [DATA_W/8-1:0] wb_select;
    wire [DATA_W/8-1:0] wb_select_r;
    wire [ADDR_W-1:0]   wb_addr_r;
    wire [DATA_W-1:0]   wb_data_r;

    // Logic
    assign valid_o = (valid)&(~valid_r);
    assign address_o  = valid? wb_addr_i:wb_addr_r;
    assign wdata_o = valid? wb_data_i:wb_data_r;
    assign wstrb_o = valid? wb_select:wb_select_r;

    assign valid_e = valid_o|ready_i;
    assign valid = wb_cyc_i&wb_stb_i;
    assign wb_select = wb_we_i? wb_select_i:4'h0;
    iob_reg #(1,0) iob_reg_valid (clk_i, arst_i, wb_rst_r, 1'b1, valid, valid_r);
    iob_reg #(ADDR_W,0) iob_reg_addr (clk_i, arst_i, wb_rst_r, valid, wb_addr_i, wb_addr_r);
    iob_reg #(DATA_W,0) iob_reg_data (clk_i, arst_i, wb_rst_r, valid, wb_data_i, wb_data_r);
    iob_reg #(DATA_W/8,0) iob_reg_sel (clk_i, arst_i, wb_rst_r, valid, wb_select, wb_select_r);

    assign wb_data_o = ready_i? rdata_i:rdata_r;
    assign wb_ack_o = ready;
    assign ready = ready_i|ready_r&wb_stb_i;
    assign wb_error_o = 1'b0;
    iob_reg #(DATA_W,0) iob_reg_rdata (clk_i, arst_i, wb_rst_r, valid, rdata_i, rdata_r);
    iob_reg #(1,0) iob_reg_ready (clk_i, arst_i, wb_rst_r, 1'b1, ready, ready_r);

    iob_reg #(1,0) iob_reg_reset (clk_i, arst_i|valid_o, wb_rst_r, 1'b1, arst_i, wb_rst_r);

endmodule