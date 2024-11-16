`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 11/15/2024 10:05:43 PM
// Design Name: 
// Module Name: iir_4th_order_bandpass_axis
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: Vivado 2024.1
// Description: 
//      4th order Buttworth bandpass filter with coefficents generated in MATLAB from the following parameters:
//         - fs  = 500 Hz
//         - fc1 = 5 Hz
//         - fc2 = 15 Hz
//  
//      Filter consists of four DF1 sos filters cascaded together. The gain is embedded in the first section (sos0).
//      All the coefficients in MATLAB are multiplied by 2^23 for an integer coefficent width of 25 bits (max for 
//      7 series DSP48E1).
// 
//      Compatible with AXI4 Streaming interface, but does not have fifos, so unread data from upstream device is lost. 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//      See coefficient generation script and testing here: https://github.com/dominic-meads/ECG/blob/main/SoC/IIR_Bandpass_test/MATLAB%20scripts/Bandpass_coeff_gen.m
//      
//////////////////////////////////////////////////////////////////////////////////
module iir_4th_order_bandpass_axis #(
  parameter coeff_width  = 25,     // coefficient bit width
  parameter inout_width  = 16,     // input and output data wdth
  parameter scale_factor = 23,     // multiplying coefficients by 2^23
  
  // sos0 coefficients (gain embedded in this section)
  parameter sos0_b0_int_ceoff = 111,
  parameter sos0_b1_int_ceoff = -223,
  parameter sos0_b2_int_ceoff = 111,
  parameter sos0_a1_int_ceoff = -15487989,
  parameter sos0_a2_int_ceoff = 7253728,

  // sos1 coeffs
  parameter sos1_b0_int_ceoff = 8388608,
  parameter sos1_b1_int_ceoff = 16777992,
  parameter sos1_b2_int_ceoff = 8389384,
  parameter sos1_a1_int_ceoff = -16019049,
  parameter sos1_a2_int_ceoff = 7687567,

  // sos2 coeffs
  parameter sos2_b0_int_ceoff = 8388608,
  parameter sos2_b1_int_ceoff = 16776439,
  parameter sos2_b2_int_ceoff = 8387831,
  parameter sos2_a1_int_ceoff = -15932677,
  parameter sos2_a2_int_ceoff = 7814858,

  // sos3 coeffs
  parameter sos3_b0_int_ceoff = 8388608,
  parameter sos3_b1_int_ceoff = -16777215,
  parameter sos3_b2_int_ceoff = 8388608,
  parameter sos3_a1_int_ceoff = -16534190,
  parameter sos3_a2_int_ceoff = 8180250
)(
  input  clk,
  input  rst_n,
  input  s_axis_tvalid,
  input  m_axis_tready,
  input  signed [inout_width-1:0] s_axis_tdata,
  output signed [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid,
  output s_axis_tready
);