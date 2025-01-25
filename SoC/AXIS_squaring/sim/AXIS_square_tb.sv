`timescale 1 ns / 1 ps

module AXIS_square_tb;
  reg clk;
  reg rst_n;
  reg s_axis_tvalid;
  reg signed [15:0] s_axis_tdata;
  reg m_axis_tready;
  wire s_axis_tready;
  wire m_axis_tvalid;
  wire signed [31:0] m_axis_tdata;

  AXIS_square uut (
  .clk(clk),
  .rst_n(rst_n),
  .s_axis_tvalid(s_axis_tvalid),
  .s_axis_tdata(s_axis_tdata),
  .m_axis_tready(m_axis_tready),
  .s_axis_tready(s_axis_tready),
  .m_axis_tvalid(m_axis_tvalid),
  .m_axis_tdata(m_axis_tdata)
  );

  // 50 MHz clk
  always #10 clk = ~clk;

  initial 
    begin 
      clk = 1'b0;
      rst_n = 1'b0;
      s_axis_tvalid = 1'b0;
      s_axis_tdata = 16'h0000;
      m_axis_tready = 1'b1;  
      #50
      rst_n = 1'b1;
      #50
      repeat(10)
        begin
          #100
          wait(s_axis_tready);  // wait for upstream ready signal
          s_axis_tvalid = 1'b1;  // output data valid
          s_axis_tdata = s_axis_tdata + 1;
          #20
          s_axis_tvalid = 1'b0;
        end 
      #40
      m_axis_tready = 1'b0;
      #40
      rst_n = 1'b0;
      #40 
      rst_n = 1'b1;
      s_axis_tdata = 16'h0000;
      #50
      repeat(10)
        begin
          #100
          wait(s_axis_tready);  // wait for upstream ready signal
          s_axis_tvalid = 1'b1;  // output data valid
          s_axis_tdata = s_axis_tdata - 1;
          #20
          s_axis_tvalid = 1'b0;
        end 
      $finish;
    end
endmodule
          