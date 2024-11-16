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
//      Filter consists of four sos filters cascaded together. The gain is embedded in the first section (sos0). All
//      the coefficients in MATLAB are multiplied by 2^23 for an integer coefficent width of 25 bits (max for 
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
//      See coefficient generation script and testing here: 
//      
//////////////////////////////////////////////////////////////////////////////////
module iir_4th_order_bandpass_axis #(
  parameter 
)