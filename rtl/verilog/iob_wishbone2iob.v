`include "timescale.v"

module iob_wishbone2iob #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
) (
    input wire clk_i,
    input wire arst_i,

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
    wire                valid_r;
    wire                valid_e;
    wire                ready;
    wire                ready_r;
    wire [DATA_W-1:0]   rdata_r;
    // Wishbone auxiliar wire

    // Logic
    assign valid_o = (wb_cyc_i&wb_stb_i)&(~valid_r);
    assign address_o  = wb_addr_i;
    assign wdata_o = wb_data_i;
    assign wstrb_o = wb_we_i? wb_select_i:4'h0;

    assign valid_e = valid_o|ready_i;
    iob_reg #(1,0) iob_reg_valid (clk_i, arst_i, 1'b0, valid_e, valid_o, valid_r);

    assign wb_data_o = ready_i? rdata_i:rdata_r;
    assign wb_ack_o = (ready_i|ready_r)&wb_stb_i;
    assign wb_error_o = 1'b0;
    iob_reg #(DATA_W,0) iob_reg_rdata (clk_i, arst_i, 1'b0, ready_i, rdata_i, rdata_r);
    iob_reg #(1,0) iob_reg_ready (clk_i, arst_i, ~wb_stb_i, ready_i, ready, ready_r);


endmodule