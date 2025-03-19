// takes one slave input and outputs it over two master axi stream ports

module axis_input_to_dual_output #(
  parameter WIDTH = 16
)(
  input  s_axis_tvalid,
  input  signed [WIDTH-1:0] s_axis_tdata,
  input  m_axis_tready_0,
  input  m_axis_tready_1,
  output s_axis_tready,
  output m_axis_tvalid_0,
  output signed [WIDTH-1:0] m_axis_tdata_0,
  output m_axis_tvalid_1,
  output signed [WIDTH-1:0] m_axis_tdata_1
);

assign s_axis_tready = m_axis_tready_0 | m_axis_tready_1;
assign m_axis_tdata_0 = s_axis_tdata;
assign m_axis_tdata_1 = s_axis_tdata;
assign m_axis_tvalid_0 = s_axis_tvalid;
assign m_axis_tvalid_1 = s_axis_tvalid;

endmodule