`timescale 1ns / 1ps

module AXIS_moving_average_tb;
  reg  clk;
  reg  rst_n;
  reg  s_axis_tvalid;
  reg  m_axis_tready; 
  reg  [31:0] s_axis_tdata;
  wire [31:0] m_axis_tdata;
  wire m_axis_tvalid;
  wire s_axis_tready;

  // 50 MHz clock
  always #10 clk = ~clk; 

  AXIS_moving_average uut (
    .clk(clk),                      // input wire aclk
    .s_axis_tvalid(s_axis_tvalid),  // input wire s_axis_data_tvalid
    .s_axis_tready(s_axis_tready),  // output wire s_axis_data_tready
    .s_axis_tdata(s_axis_tdata),    // input wire [31 : 0] s_axis_data_tdata
    .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_data_tvalid
    .m_axis_tdata(m_axis_tdata)     // output wire [31 : 0] m_axis_data_tdata
  );

   initial 
    begin
      clk = 1'b0;
      rst_n = 1'b0; 
      s_axis_tdata = 0;
      s_axis_tvalid = 1'b0;
      m_axis_tready = 1'b1; // upstream device ready
      #40
      rst_n = 1'b1; // release reset
      
      // output a signal that alternates between the value 3 and 5 (average should be 4 after initial delay of 74 samples)
      repeat(50)  // 500 Hz sampling
        begin 
          #1980
          s_axis_tdata = 5;
          wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge of clock
          s_axis_tvalid = 1'b1;
          #20
          s_axis_tvalid = 1'b0; // tvalid only high for 1 clock cycle

          #1980
          s_axis_tdata = 3;
          wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge of clock
          s_axis_tvalid = 1'b1;
          #20
          s_axis_tvalid = 1'b0; // tvalid only high for 1 clock cycle
        end
        #50000
        $finish;
      $finish;
    end

endmodule