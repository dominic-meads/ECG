// Tests the axis_differentiator.v file by applying a triangle waveform. 
// The output (derivative) should be a square wave
//
// Difference equation of FIR filter to implement derivative: 
// y[n] = x[n] - x[n-1]
// the xilinx FIR compiler was used with a coefficient vector of [1; -1]

module axis_differentiator_tb;
  reg  clk;
  reg  rst_n;
  reg  s_axis_tvalid;
  reg signed [15:0] s_axis_tdata;
  wire s_axis_tready;
  wire m_axis_tvalid;
  wire signed [15:0] m_axis_tdata;

  always #10 clk = ~clk;  // 50 MHz clock

  axis_differentiator uut (
  .rst_n(rst_n),                        // input wire aresetn
  .clk(clk),                              // input wire aclk
  .s_axis_tvalid(s_axis_tvalid),  // input wire s_axis_data_tvalid
  .s_axis_tready(s_axis_tready),  // output wire s_axis_data_tready
  .s_axis_tdata(s_axis_tdata),    // input wire [15 : 0] s_axis_data_tdata
  .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_data_tvalid
  .m_axis_tdata(m_axis_tdata)    // output wire [15 : 0] m_axis_data_tdata
  );

  integer i = 0;
  
  initial
    begin 
      clk = 1'b0;
      rst_n = 1'b0;
      s_axis_tvalid = 1'b0;
      s_axis_tdata = 0;
      #100
      rst_n = 1'b1;

      // ------------ Triangle wave generation (rise from 0-50 and fall back down to 0)
      repeat (10)
        begin
          repeat (51)
            begin
              wait(clk == 1'b0) wait (clk == 1'b1)
              s_axis_tdata = i;
              s_axis_tvalid = 1'b1;
              #20
              s_axis_tvalid = 1'b0;
              #40
              i = i + 1;
            end
            
          i = 49;
          
          repeat (49)
            begin
              wait(clk == 1'b0) wait (clk == 1'b1)
              s_axis_tdata = i;
              s_axis_tvalid = 1'b1;
              #20
              s_axis_tvalid = 1'b0;
              #40 
              i = i - 1;
            end
        end
      // ------------ END Triangle wave generation

      $finish;
    end

endmodule