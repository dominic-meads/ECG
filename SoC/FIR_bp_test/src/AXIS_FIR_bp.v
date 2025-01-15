  `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 1/14/2025 10:05:43 PM
// Design Name: 
// Module Name: FIR_bp
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: Vivado 2024.1
// Description: 
//      Basic FIR filter implemented in FPGA. 
//      50th order Bandpass filter with a passband between 2 Hz and 48 Hz. Sampling frequency is 500 Hz. 
//      Used to remove power line noise and some DC offset from the ECG signal before doing more processing.
//
//      Integer coefficients generated in MATLAB. 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////  
module AXIS_FIR_bp (
  input  clk,
  input  s_axis_tvalid,
  input  signed [15:0] s_axis_tdata,
  output signed [15:0] m_axis_tdata,
  output m_axis_tvalid,
  output s_axis_tready
  ); 
  
  wire signed [39:0] w_m_axis_tdata;
  
  fir_compiler_0 fir0 (
    .aclk(clk),                          // input wire aclk
    .s_axis_data_tvalid(s_axis_tvalid),  // input wire s_axis_data_tvalid
    .s_axis_data_tready(s_axis_tready),  // output wire s_axis_data_tready
    .s_axis_data_tdata(s_axis_tdata),    // input wire [15 : 0] s_axis_data_tdata
    .m_axis_data_tvalid(m_axis_tvalid),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata(w_m_axis_tdata)     // output wire [39 : 0] m_axis_data_tdata
  );
  
  assign m_axis_tdata = w_m_axis_tdata >>> 23;

endmodule