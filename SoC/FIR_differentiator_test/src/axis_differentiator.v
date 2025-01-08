// implements a differentiator filter with the difference equation
// y[n] = x[n] - x[n-1]

module axis_differentiator (
  input  clk,
  input  rst_n,
  input  s_axis_tvalid,
  input signed [15:0] s_axis_tdata,
  output s_axis_tready,
  output m_axis_tvalid,
  output signed [15:0] m_axis_tdata
);

  // input register x[n]
  reg signed [15:0] r_xn = 0;

  // input delayed register x[n-1]
  reg signed [15:0] r_xn_1 = 0;

  // output registers 
  reg signed [15:0] r_yn = 0; // y[n]
  reg r_s_axis_tready = 1'b0; // tells downstream device that module is ready for data
  reg r_m_axis_tvalid = 1'b0; 

  always @ (posedge clk, negedge rst_n)
    begin 
      if (~rst_n)
        begin  // reset registers and deassert ready and output valid signal
          r_xn   <= 0;
          r_xn_1 <= 0;
          r_yn   <= 0;
          r_s_axis_tready <= 1'b0; 
          r_m_axis_tvalid <= 1'b0;
        end 
      else 
        begin 
          r_s_axis_tready <= 1'b1;
          if (s_axis_tvalid && r_s_axis_tready)  // axi stream handshake
            begin 
              r_xn   <= s_axis_tdata;
              r_xn_1 <= r_xn;
              r_yn   <= r_xn - r_xn_1;
              r_m_axis_tvalid <= 1'b1;
            end 
          else 
            r_m_axis_tvalid <= 1'b0;
        end 
    end

  assign m_axis_tdata = r_yn;
  assign m_axis_tvalid = r_m_axis_tvalid;
  assign s_axis_tready = r_s_axis_tready;

endmodule;