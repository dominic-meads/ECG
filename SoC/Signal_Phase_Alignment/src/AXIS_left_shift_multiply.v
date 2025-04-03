// multiplies input signal by 16 using a left shift of 4

module AXIS_left_shift_multiply #(
  parameter WIDTH = 32
)(
  input  s_axis_tvalid,
  input  signed [WIDTH-1:0] s_axis_tdata,
  input  m_axis_tready,
  output s_axis_tready,
  output m_axis_tvalid,
  output signed [WIDTH-1:0] m_axis_tdata
);

assign s_axis_tready = m_axis_tready;
assign m_axis_tdata = s_axis_tdata <<< 4;
assign m_axis_tvalid = s_axis_tvalid;

endmodule