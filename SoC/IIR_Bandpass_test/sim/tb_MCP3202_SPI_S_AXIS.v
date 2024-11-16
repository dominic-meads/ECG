`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 09/1/2024 10:44:56 PM
// Design Name: 
// Module Name: tb_MCP3202_SPI_S_AXIS
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: 
// Description: TB acts as MCP3202 ADC chip. Simulates timing, and sends out sample data. 
//              Verifies "MCP3202_SPI.v"
//
//              Datasheet: https://ww1.microchip.com/downloads/aemDocuments/documents/APID/ProductDocuments/DataSheets/21034F.pdf
// 
// Dependencies: Input clk frequency 10 MHz - 200 MHz
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_MCP3202_SPI_S_AXIS_with_intrpt;
  reg clk, rst_n, m_axis_tready;
  wire m_axis_tvalid; 
  wire [15:0] m_axis_tdata;
  wire m_axis_interrupt;
  
  localparam FCLK         = 100e6; // clk frequency
  localparam FSMPL        = 200;  // sampling freqeuncy 
  localparam SGL          = 1;    // sets ADC to single-ended
  localparam ODD          = 0;    // sets ADC sample input to channel 0 
	localparam SMPLS        = 30;   // samples per packet
	localparam DATA_WIDTH   = 16;   // axis_tdata width in bits
  localparam TDATA_CLKS   = 32;    // period in clock cycles that m_axis_tdata is held in the same state
  // intermediate signals
  wire w_cs, w_sck, w_mosi, w_miso;
  
  top #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),  
    .ODD(ODD),
    .SMPLS(SMPLS),
    .DATA_WIDTH(DATA_WIDTH),  
    .TDATA_CLKS(TDATA_CLKS)
  )
  uut (
    .clk(clk),
    .rst_n(rst_n),
    .miso(w_miso),
    .m_axis_tready(m_axis_tready),
    .mosi(w_mosi),
    .sck(w_sck),
    .cs(w_cs),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_interrupt(m_axis_interrupt)
  );

  ADC_behav #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),
    .ODD(ODD)
    ) 
    ADC_0 (
    .cs(w_cs),
    .sck(w_sck),
    .mosi(w_mosi),
    .miso(w_miso)
    );

  real half_clk_period = 1e9/(2*FCLK);
  always #half_clk_period clk = ~clk;
      
  initial 
    begin
      clk   = 1'b0;
      rst_n = 1'b0;
      m_axis_tready = 1'b0;
      #25
      rst_n = 1'b1;
      wait(m_axis_interrupt)
        begin
          #1700
          m_axis_tready = 1'b1;
          #240
          m_axis_tready = 1'b0;
          repeat(29)
            begin 
              #200
              m_axis_tready = 1'b1;
              #120
              m_axis_tready = 1'b0;
            end
        end
      #200000000
      $finish(2);
    end
endmodule