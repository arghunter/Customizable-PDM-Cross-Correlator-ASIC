/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_pdm_correlator_arghunter (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
wire rst;
  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out[7:3] = 0;
  assign uio_oe[2:0]  = 1;
  assign uio_oe[7:3]  = 0;
  
  assign rst = !rst_n;
  generate
    top_module u_top_module (
        .clk(ui_in[0]),
        .rst(rst),
        .spi_mosi(ui_in[1]),
        .spi_cs_n(ui_in[2]),
        .mic_data_1(ui_in[3]),
        .mic_data_2(ui_in[4]),
        .out(uo_out),
        .mic_clk(uio_out[0]),
        .pos(uio_out[1]),
        .neg(uio_out[2])
    );    
  endgenerate
  // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk,ui_in[7:5],uio_in[7:0], 1'b0};

endmodule
