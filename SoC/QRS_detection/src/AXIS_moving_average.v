  `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 1/27/2025 10:05:43 PM
// Design Name: 
// Module Name: FIR_bp
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: Vivado 2024.1
// Description: 
//      74-point moving average filter generated with a FIR compiler (all taps have same coefficient) 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////  
module AXIS_moving_average (
  input  clk,
  input  s_axis_tvalid,
  input  signed [31:0] s_axis_tdata,
  output signed [31:0] m_axis_tdata,
  output m_axis_tvalid,
  output s_axis_tready
  ); 
  
  wire signed [51:0] w_m_axis_tdata;
  
  fir_compiler_1 fir1 (
    .aclk(clk),                          // input wire aclk
    .s_axis_data_tvalid(s_axis_tvalid),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(s_axis_tready),  // output wire s_axis_data_tready
    .s_axis_data_tdata(s_axis_tdata),    // input wire [31 : 0] s_axis_data_tdata
    .m_axis_data_tvalid(m_axis_tvalid),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata(w_m_axis_tdata)     // output wire [55 : 0] m_axis_data_tdata
  );
  
  assign m_axis_tdata = w_m_axis_tdata >>> 20;

endmodule