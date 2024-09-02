`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 09/1/2024 10:37:57 PM
// Design Name: 
// Module Name: MCP3202_SPI_S_AXIS
// Project Name: 
// Target Devices: 7 series
// Tool Versions: 
// Description: AXI4 Stream compatible SPI core for the MCP3202 ADC. Input samples come from the ADC
//              and go into a FIFO buffer (depth 16). Downstream modules can read from FIFO using 
//              AXI stream. This Module is the slave in the transaction. 
// 
// Dependencies: Input clk frequency 10 MHz - 200 MHz
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MCP3202_SPI_S_AXIS #(
  parameter FCLK  = 100e6, // clk frequency
  parameter FSMPL = 500,   // sampling freqeuncy 
  parameter SGL   = 1,     // sets ADC to single-ended
  parameter ODD   = 0      // sets ADC sample input to channel 0 
)(
  input clk,
  input rst_n,
  input miso,
  input m_axis_spi_tready,
  output mosi,
  output sck,
  output cs,
  output signed [15:0] m_axis_spi_tdata,
  output m_axis_spi_tvalid 
);

  wire w_s_axis_spi_tvalid;
  wire w_s_axis_spi_tready;
  wire signed [15:0] w_s_axis_spi_tdata;

  fifo_generator_0 fifo0 (
  .wr_rst_busy(wr_rst_busy),      // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy),      // output wire rd_rst_busy
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(rst_n),          // input wire s_aresetn
  // slave SPI module (to FIFO)
  .s_axis_tvalid(w_s_axis_spi_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(w_s_axis_spi_tready),  // output wire s_axis_tready
  .s_axis_tdata(w_s_axis_spi_tdata),    // input wire [15 : 0] s_axis_tdata
  // master downstream module
  .m_axis_tvalid(m_axis_spi_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(m_axis_spi_tready),  // input wire m_axis_tready
  .m_axis_tdata(m_axis_spi_tdata)    // output wire [15 : 0] m_axis_tdata
  );

  MCP3202_SPI #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),
    .ODD(ODD)
  )
  spi0 (
    .clk(clk),
    .rst_n(rst_n),
    .miso(miso),
    .ready(w_s_axis_spi_tready),
    .mosi(mosi),
    .sck(sck),
    .cs(cs),
    .data(w_s_axis_spi_tdata),
    .dv(w_s_axis_spi_tvalid)
  );

endmodule

