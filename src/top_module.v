// `include "spi_port.v"
// `include "memory.v"
// `include "demux.v"
// `include "decimator.v"
// `include "buffer.v"
// `include "i2s_bus.v"

module top_module(
    input wire clk,
    input wire rst,
    input wire spi_mosi,
    input wire spi_cs_n,
    input wire mic_data_1,
    input wire mic_data_2,
    output wire [7:0] out,
    output wire mic_clk,
    output wire pos,
    output wire neg
);
wire [7:0] addr;
wire [7:0] value;
wire wr_en = 1;
wire rd_en = 1;
wire [7:0] mem_out;
wire [7:0] decimation_ratio;
wire dec_data_1;
wire dec_data_2;
wire dec_clk;
wire [7:0] filter_length;
wire [7:0] filter_out;
wire [15:0] capture_reg;
wire dummy;
wire dummy2;
wire corr_dec_clk;
assign addr = capture_reg[15:8];
assign value = capture_reg[7:0];
assign mic_clk = clk;

    spi_port u_spi_port(
        .clk(clk),
        .rst_n(!rst),
        .spi_clk(clk),
        .spi_mosi(spi_mosi),
        .spi_miso(dummy),
        .spi_cs_n(spi_cs_n),
        .capture_reg(capture_reg)
    );
    memory u_memory(
        .clk(clk),            
        .rst_n(!rst),          
        .addr(addr),     
        .data_in(value),  
        .wr_en(wr_en),          
        .rd_en(rd_en),          
        .data_out(mem_out) 
    );
    demux1to2 u_demux1to2(
        .sel(addr),
        .d(mem_out),
        .a(decimation_ratio), //Check that these don't reset 
        .b(filter_length)
    );
    decimator u_decimator_1(
        .clk(clk),              
        .rst(rst),              
        .decimation_ratio(decimation_ratio),
        .data(mic_data_1),             
        .out(dec_data_1),              
        .dec_clk(dec_clk)           
    );
    decimator u_decimator_2(
        .clk(clk),              
        .rst(rst),              
        .decimation_ratio(decimation_ratio),
        .data(mic_data_2),             
        .out(dec_data_2),              
        .dec_clk(dummy2)           
    );
    buffer u_buffer(
        .clk(corr_dec_clk),         
        .rst(rst),         
        .data_1(dec_data_1),        
        .data_2(dec_data_2),        
        .length(filter_length),
        .corr(out),
        .pos(pos),
        .neg(neg)   
    );
assign corr_dec_clk = (decimation_ratio == 8'b1) ? clk : dec_clk;





endmodule
