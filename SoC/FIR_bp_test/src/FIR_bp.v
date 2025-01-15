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
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////


module FIR_bp #(
  parameter coeff_width  = 25,     // coefficient bit width
  parameter inout_width  = 16,     // input and output data wdth
  parameter scale_factor = 23,     // multiplying coefficients by 2^23
  parameter b0_coeff = 0,
  parameter b1_coeff = 3488,
  parameter b2_coeff = 4584,
  parameter b3_coeff = 1657,
  parameter b4_coeff = -7004,
  parameter b5_coeff = -21544,
  parameter b6_coeff = -38844,
  parameter b7_coeff = -52147,
  parameter b8_coeff = -52988,
  parameter b9_coeff = -35280,
  parameter b10_coeff = 0,
  parameter b11_coeff = 41968,
  parameter b12_coeff = 71124,
  parameter b13_coeff = 65590,
  parameter b14_coeff = 10873,
  parameter b15_coeff = -90396,
  parameter b16_coeff = -213161,
  parameter b17_coeff = -312565,
  parameter b18_coeff = -335311,
  parameter b19_coeff = -237025,
  parameter b20_coeff = 0,
  parameter b21_coeff = 355329,
  parameter b22_coeff = 770299,
  parameter b23_coeff = 1160719,
  parameter b24_coeff = 1439189,
  parameter b25_coeff = 1540115,
  parameter b26_coeff = 1439189,
  parameter b27_coeff = 1160719,
  parameter b28_coeff = 770299,
  parameter b29_coeff = 355329,
  parameter b30_coeff = 0,
  parameter b31_coeff = -237025,
  parameter b32_coeff = -335311,
  parameter b33_coeff = -312565,
  parameter b34_coeff = -213161,
  parameter b35_coeff = -90396,
  parameter b36_coeff = 10873,
  parameter b37_coeff = 65590,
  parameter b38_coeff = 71124,
  parameter b39_coeff = 41968,
  parameter b40_coeff = 0,
  parameter b41_coeff = -35280,
  parameter b42_coeff = -52988,
  parameter b43_coeff = -52147,
  parameter b44_coeff = -38844,
  parameter b45_coeff = -21544,
  parameter b46_coeff = -7004,
  parameter b47_coeff = 1657,
  parameter b48_coeff = 4584,
  parameter b49_coeff = 3488,
  parameter b50_coeff = 0
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

  // filter coefficients (multiplied floating point coefficients by 2^scale_factor)
  reg signed [coeff_width-1:0] r_b0_coeff = b0_coeff;
  reg signed [coeff_width-1:0] r_b1_coeff = b1_coeff;
  reg signed [coeff_width-1:0] r_b2_coeff = b2_coeff;
  reg signed [coeff_width-1:0] r_b3_coeff = b3_coeff;
  reg signed [coeff_width-1:0] r_b4_coeff = b4_coeff;
  reg signed [coeff_width-1:0] r_b5_coeff = b5_coeff;
  reg signed [coeff_width-1:0] r_b6_coeff = b6_coeff;
  reg signed [coeff_width-1:0] r_b7_coeff = b7_coeff;
  reg signed [coeff_width-1:0] r_b8_coeff = b8_coeff;
  reg signed [coeff_width-1:0] r_b9_coeff = b9_coeff;
  reg signed [coeff_width-1:0] r_b10_coeff = b10_coeff;
  reg signed [coeff_width-1:0] r_b11_coeff = b11_coeff;
  reg signed [coeff_width-1:0] r_b12_coeff = b12_coeff;
  reg signed [coeff_width-1:0] r_b13_coeff = b13_coeff;
  reg signed [coeff_width-1:0] r_b14_coeff = b14_coeff;
  reg signed [coeff_width-1:0] r_b15_coeff = b15_coeff;
  reg signed [coeff_width-1:0] r_b16_coeff = b16_coeff;
  reg signed [coeff_width-1:0] r_b17_coeff = b17_coeff;
  reg signed [coeff_width-1:0] r_b18_coeff = b18_coeff;
  reg signed [coeff_width-1:0] r_b19_coeff = b19_coeff;
  reg signed [coeff_width-1:0] r_b20_coeff = b20_coeff;
  reg signed [coeff_width-1:0] r_b21_coeff = b21_coeff;
  reg signed [coeff_width-1:0] r_b22_coeff = b22_coeff;
  reg signed [coeff_width-1:0] r_b23_coeff = b23_coeff;
  reg signed [coeff_width-1:0] r_b24_coeff = b24_coeff;
  reg signed [coeff_width-1:0] r_b25_coeff = b25_coeff;
  reg signed [coeff_width-1:0] r_b26_coeff = b26_coeff;
  reg signed [coeff_width-1:0] r_b27_coeff = b27_coeff;
  reg signed [coeff_width-1:0] r_b28_coeff = b28_coeff;
  reg signed [coeff_width-1:0] r_b29_coeff = b29_coeff;
  reg signed [coeff_width-1:0] r_b30_coeff = b30_coeff;
  reg signed [coeff_width-1:0] r_b31_coeff = b31_coeff;
  reg signed [coeff_width-1:0] r_b32_coeff = b32_coeff;
  reg signed [coeff_width-1:0] r_b33_coeff = b33_coeff;
  reg signed [coeff_width-1:0] r_b34_coeff = b34_coeff;
  reg signed [coeff_width-1:0] r_b35_coeff = b35_coeff;
  reg signed [coeff_width-1:0] r_b36_coeff = b36_coeff;
  reg signed [coeff_width-1:0] r_b37_coeff = b37_coeff;
  reg signed [coeff_width-1:0] r_b38_coeff = b38_coeff;
  reg signed [coeff_width-1:0] r_b39_coeff = b39_coeff;
  reg signed [coeff_width-1:0] r_b40_coeff = b40_coeff;
  reg signed [coeff_width-1:0] r_b41_coeff = b41_coeff;
  reg signed [coeff_width-1:0] r_b42_coeff = b42_coeff;
  reg signed [coeff_width-1:0] r_b43_coeff = b43_coeff;
  reg signed [coeff_width-1:0] r_b44_coeff = b44_coeff;
  reg signed [coeff_width-1:0] r_b45_coeff = b45_coeff;
  reg signed [coeff_width-1:0] r_b46_coeff = b46_coeff;
  reg signed [coeff_width-1:0] r_b47_coeff = b47_coeff;
  reg signed [coeff_width-1:0] r_b48_coeff = b48_coeff;
  reg signed [coeff_width-1:0] r_b49_coeff = b49_coeff;
  reg signed [coeff_width-1:0] r_b50_coeff = b50_coeff;

  // input register
  reg signed [inout_width-1:0] r_x = 0;

  // output registers
  reg r_m_axis_tvalid = 1'b0; 
  reg r_s_axis_tready = 1'b0;
  reg signed [inout_width-1:0] r_m_axis_tdata = 0;

  // delay registers
  reg signed [inout_width-1:0] r_x_z1 = 0;
  reg signed [inout_width-1:0] r_x_z2 = 0;
  reg signed [inout_width-1:0] r_x_z3 = 0;
  reg signed [inout_width-1:0] r_x_z4 = 0;
  reg signed [inout_width-1:0] r_x_z5 = 0;
  reg signed [inout_width-1:0] r_x_z6 = 0;
  reg signed [inout_width-1:0] r_x_z7 = 0;
  reg signed [inout_width-1:0] r_x_z8 = 0;
  reg signed [inout_width-1:0] r_x_z9 = 0;
  reg signed [inout_width-1:0] r_x_z10 = 0;
  reg signed [inout_width-1:0] r_x_z11 = 0;
  reg signed [inout_width-1:0] r_x_z12 = 0;
  reg signed [inout_width-1:0] r_x_z13 = 0;
  reg signed [inout_width-1:0] r_x_z14 = 0;
  reg signed [inout_width-1:0] r_x_z15 = 0;
  reg signed [inout_width-1:0] r_x_z16 = 0;
  reg signed [inout_width-1:0] r_x_z17 = 0;
  reg signed [inout_width-1:0] r_x_z18 = 0;
  reg signed [inout_width-1:0] r_x_z19 = 0;
  reg signed [inout_width-1:0] r_x_z20 = 0;
  reg signed [inout_width-1:0] r_x_z21 = 0;
  reg signed [inout_width-1:0] r_x_z22 = 0;
  reg signed [inout_width-1:0] r_x_z23 = 0;
  reg signed [inout_width-1:0] r_x_z24 = 0;
  reg signed [inout_width-1:0] r_x_z25 = 0;
  reg signed [inout_width-1:0] r_x_z26 = 0;
  reg signed [inout_width-1:0] r_x_z27 = 0;
  reg signed [inout_width-1:0] r_x_z28 = 0;
  reg signed [inout_width-1:0] r_x_z29 = 0;
  reg signed [inout_width-1:0] r_x_z30 = 0;
  reg signed [inout_width-1:0] r_x_z31 = 0;
  reg signed [inout_width-1:0] r_x_z32 = 0;
  reg signed [inout_width-1:0] r_x_z33 = 0;
  reg signed [inout_width-1:0] r_x_z34 = 0;
  reg signed [inout_width-1:0] r_x_z35 = 0;
  reg signed [inout_width-1:0] r_x_z36 = 0;
  reg signed [inout_width-1:0] r_x_z37 = 0;
  reg signed [inout_width-1:0] r_x_z38 = 0;
  reg signed [inout_width-1:0] r_x_z39 = 0;
  reg signed [inout_width-1:0] r_x_z40 = 0;
  reg signed [inout_width-1:0] r_x_z41 = 0;
  reg signed [inout_width-1:0] r_x_z42 = 0;
  reg signed [inout_width-1:0] r_x_z43 = 0;
  reg signed [inout_width-1:0] r_x_z44 = 0;
  reg signed [inout_width-1:0] r_x_z45 = 0;
  reg signed [inout_width-1:0] r_x_z46 = 0;
  reg signed [inout_width-1:0] r_x_z47 = 0;
  reg signed [inout_width-1:0] r_x_z48 = 0;
  reg signed [inout_width-1:0] r_x_z49 = 0;
  reg signed [inout_width-1:0] r_x_z50 = 0;

  // multiplication wires
  wire signed [inout_width + coeff_width-1:0] w_prod_b0;
  wire signed [inout_width + coeff_width-1:0] w_prod_b1;
  wire signed [inout_width + coeff_width-1:0] w_prod_b2;
  wire signed [inout_width + coeff_width-1:0] w_prod_b3;
  wire signed [inout_width + coeff_width-1:0] w_prod_b4;
  wire signed [inout_width + coeff_width-1:0] w_prod_b5;
  wire signed [inout_width + coeff_width-1:0] w_prod_b6;
  wire signed [inout_width + coeff_width-1:0] w_prod_b7;
  wire signed [inout_width + coeff_width-1:0] w_prod_b8;
  wire signed [inout_width + coeff_width-1:0] w_prod_b9;
  wire signed [inout_width + coeff_width-1:0] w_prod_b10;
  wire signed [inout_width + coeff_width-1:0] w_prod_b11;
  wire signed [inout_width + coeff_width-1:0] w_prod_b12;
  wire signed [inout_width + coeff_width-1:0] w_prod_b13;
  wire signed [inout_width + coeff_width-1:0] w_prod_b14;
  wire signed [inout_width + coeff_width-1:0] w_prod_b15;
  wire signed [inout_width + coeff_width-1:0] w_prod_b16;
  wire signed [inout_width + coeff_width-1:0] w_prod_b17;
  wire signed [inout_width + coeff_width-1:0] w_prod_b18;
  wire signed [inout_width + coeff_width-1:0] w_prod_b19;
  wire signed [inout_width + coeff_width-1:0] w_prod_b20;
  wire signed [inout_width + coeff_width-1:0] w_prod_b21;
  wire signed [inout_width + coeff_width-1:0] w_prod_b22;
  wire signed [inout_width + coeff_width-1:0] w_prod_b23;
  wire signed [inout_width + coeff_width-1:0] w_prod_b24;
  wire signed [inout_width + coeff_width-1:0] w_prod_b25;
  wire signed [inout_width + coeff_width-1:0] w_prod_b26;
  wire signed [inout_width + coeff_width-1:0] w_prod_b27;
  wire signed [inout_width + coeff_width-1:0] w_prod_b28;
  wire signed [inout_width + coeff_width-1:0] w_prod_b29;
  wire signed [inout_width + coeff_width-1:0] w_prod_b30;
  wire signed [inout_width + coeff_width-1:0] w_prod_b31;
  wire signed [inout_width + coeff_width-1:0] w_prod_b32;
  wire signed [inout_width + coeff_width-1:0] w_prod_b33;
  wire signed [inout_width + coeff_width-1:0] w_prod_b34;
  wire signed [inout_width + coeff_width-1:0] w_prod_b35;
  wire signed [inout_width + coeff_width-1:0] w_prod_b36;
  wire signed [inout_width + coeff_width-1:0] w_prod_b37;
  wire signed [inout_width + coeff_width-1:0] w_prod_b38;
  wire signed [inout_width + coeff_width-1:0] w_prod_b39;
  wire signed [inout_width + coeff_width-1:0] w_prod_b40;
  wire signed [inout_width + coeff_width-1:0] w_prod_b41;
  wire signed [inout_width + coeff_width-1:0] w_prod_b42;
  wire signed [inout_width + coeff_width-1:0] w_prod_b43;
  wire signed [inout_width + coeff_width-1:0] w_prod_b44;
  wire signed [inout_width + coeff_width-1:0] w_prod_b45;
  wire signed [inout_width + coeff_width-1:0] w_prod_b46;
  wire signed [inout_width + coeff_width-1:0] w_prod_b47;
  wire signed [inout_width + coeff_width-1:0] w_prod_b48;
  wire signed [inout_width + coeff_width-1:0] w_prod_b49;
  wire signed [inout_width + coeff_width-1:0] w_prod_b50;

  // acummulate wire
  wire signed [inout_width + coeff_width-1:0] w_sum; 

  // states
  localparam READY = 1'b0;
  localparam BUSY  = 1'b1;

  // state registers
  reg r_current_state = READY;
  reg r_next_state    = BUSY; 

  // control signals
  reg r_fir_en = 1'b0;  // enables iir filter

  // next state logic
  always @ (*)
    begin 
      case (r_current_state)
        READY : 
          begin 
            if (s_axis_tvalid & s_axis_tready) // axis handshake. Incoming data not valid unless BOTH valid and ready are high
              r_next_state <= BUSY;
            else 
              r_next_state <= r_current_state;
          end 

        BUSY : 
          begin 
            if (m_axis_tvalid == 1'b1)
              r_next_state <= READY;
            else 
              r_next_state <= r_current_state;
          end

        default : r_next_state <= READY;
      endcase
    end

  // output logic
  always @ (*)
    begin 
      if (r_current_state == READY)
        begin 
          r_m_axis_tvalid <= 1'b0;  // data not valid
          r_s_axis_tready <= 1'b1;  // set ready signal 
          r_fir_en        <= 1'b0;  // dont enable iir filter in this state (downstream data not valid yet)
        end 
      else if (r_current_state == BUSY)
        begin 
          r_m_axis_tvalid <= 1'b1;  // data valid
          r_s_axis_tready <= 1'b0;  // disable ready signal 
          r_fir_en        <= 1'b1;  // iir filter enabled (MAC happens in one clock cycle)
        end 
      else 
        begin 
          r_m_axis_tvalid <= 1'b0;  
          r_s_axis_tready <= 1'b0;  
          r_fir_en        <= 1'b0;      
        end   
    end 

  // state update
  always @ (posedge clk, negedge rst_n)
    begin
      if (~rst_n)
        r_current_state <= READY;
      else 
        r_current_state <= r_next_state;
    end
    
  // AXIS handshake to upstream module
  always @ (posedge clk, negedge rst_n)
    begin
      if (~rst_n)
        r_m_axis_tdata <= 0;
      else 
        begin
          if (m_axis_tready)  // only send data if upstream device is ready
            r_m_axis_tdata <= w_sum >>> scale_factor;
        end 
    end  
            
  // iir delay element control
  always @ (posedge clk, negedge rst_n)
    begin
        if (~rst_n)
          begin 
            r_x    <= 0; 
            r_x_z1 <= 0;
            r_x_z2 <= 0;
            r_x_z3 <= 0;
            r_x_z4 <= 0;
            r_x_z5 <= 0;
            r_x_z6 <= 0;
            r_x_z7 <= 0;
            r_x_z8 <= 0;
            r_x_z9 <= 0;
            r_x_z10 <= 0;
            r_x_z11 <= 0;
            r_x_z12 <= 0;
            r_x_z13 <= 0;
            r_x_z14 <= 0;
            r_x_z15 <= 0;
            r_x_z16 <= 0;
            r_x_z17 <= 0;
            r_x_z18 <= 0;
            r_x_z19 <= 0;
            r_x_z20 <= 0;
            r_x_z21 <= 0;
            r_x_z22 <= 0;
            r_x_z23 <= 0;
            r_x_z24 <= 0;
            r_x_z25 <= 0;
            r_x_z26 <= 0;
            r_x_z27 <= 0;
            r_x_z28 <= 0;
            r_x_z29 <= 0;
            r_x_z30 <= 0;
            r_x_z31 <= 0;
            r_x_z32 <= 0;
            r_x_z33 <= 0;
            r_x_z34 <= 0;
            r_x_z35 <= 0;
            r_x_z36 <= 0;
            r_x_z37 <= 0;
            r_x_z38 <= 0;
            r_x_z39 <= 0;
            r_x_z40 <= 0;
            r_x_z41 <= 0;
            r_x_z42 <= 0;
            r_x_z43 <= 0;
            r_x_z44 <= 0;
            r_x_z45 <= 0;
            r_x_z46 <= 0;
            r_x_z47 <= 0;
            r_x_z48 <= 0;
            r_x_z49 <= 0;
            r_x_z50 <= 0;
          end 
        else 
          begin
            if (r_fir_en) 
              begin 
                r_x    <= s_axis_tdata;
                r_x_z1 <= r_x;
                r_x_z2 <= r_x_z1;
                r_x_z3 <= r_x_z2;
                r_x_z4 <= r_x_z3;
                r_x_z5 <= r_x_z4;
                r_x_z6 <= r_x_z5;
                r_x_z7 <= r_x_z6;
                r_x_z8 <= r_x_z7;
                r_x_z9 <= r_x_z8;
                r_x_z10 <= r_x_z9;
                r_x_z11 <= r_x_z10;
                r_x_z12 <= r_x_z11;
                r_x_z13 <= r_x_z12;
                r_x_z14 <= r_x_z13;
                r_x_z15 <= r_x_z14;
                r_x_z16 <= r_x_z15;
                r_x_z17 <= r_x_z16;
                r_x_z18 <= r_x_z17;
                r_x_z19 <= r_x_z18;
                r_x_z20 <= r_x_z19;
                r_x_z21 <= r_x_z20;
                r_x_z22 <= r_x_z21;
                r_x_z23 <= r_x_z22;
                r_x_z24 <= r_x_z23;
                r_x_z25 <= r_x_z24;
                r_x_z26 <= r_x_z25;
                r_x_z27 <= r_x_z26;
                r_x_z28 <= r_x_z27;
                r_x_z29 <= r_x_z28;
                r_x_z30 <= r_x_z29;
                r_x_z31 <= r_x_z30;
                r_x_z32 <= r_x_z31;
                r_x_z33 <= r_x_z32;
                r_x_z34 <= r_x_z33;
                r_x_z35 <= r_x_z34;
                r_x_z36 <= r_x_z35;
                r_x_z37 <= r_x_z36;
                r_x_z38 <= r_x_z37;
                r_x_z39 <= r_x_z38;
                r_x_z40 <= r_x_z39;
                r_x_z41 <= r_x_z40;
                r_x_z42 <= r_x_z41;
                r_x_z43 <= r_x_z42;
                r_x_z44 <= r_x_z43;
                r_x_z45 <= r_x_z44;
                r_x_z46 <= r_x_z45;
                r_x_z47 <= r_x_z46;
                r_x_z48 <= r_x_z47;
                r_x_z49 <= r_x_z48;
                r_x_z50 <= r_x_z49;
              end 
          end 
    end

  // multiply
  assign w_prod_b0 = r_x * b0_coeff;
  assign w_prod_b1 = r_x_z1 * b1_coeff;
  assign w_prod_b2 = r_x_z2 * b2_coeff;
  assign w_prod_b3 = r_x_z3 * b3_coeff;
  assign w_prod_b4 = r_x_z4 * b4_coeff;
  assign w_prod_b5 = r_x_z5 * b5_coeff;
  assign w_prod_b6 = r_x_z6 * b6_coeff;
  assign w_prod_b7 = r_x_z7 * b7_coeff;
  assign w_prod_b8 = r_x_z8 * b8_coeff;
  assign w_prod_b9 = r_x_z9 * b9_coeff;
  assign w_prod_b10 = r_x_z10 * b10_coeff;
  assign w_prod_b11 = r_x_z11 * b11_coeff;
  assign w_prod_b12 = r_x_z12 * b12_coeff;
  assign w_prod_b13 = r_x_z13 * b13_coeff;
  assign w_prod_b14 = r_x_z14 * b14_coeff;
  assign w_prod_b15 = r_x_z15 * b15_coeff;
  assign w_prod_b16 = r_x_z16 * b16_coeff;
  assign w_prod_b17 = r_x_z17 * b17_coeff;
  assign w_prod_b18 = r_x_z18 * b18_coeff;
  assign w_prod_b19 = r_x_z19 * b19_coeff;
  assign w_prod_b20 = r_x_z20 * b20_coeff;
  assign w_prod_b21 = r_x_z21 * b21_coeff;
  assign w_prod_b22 = r_x_z22 * b22_coeff;
  assign w_prod_b23 = r_x_z23 * b23_coeff;
  assign w_prod_b24 = r_x_z24 * b24_coeff;
  assign w_prod_b25 = r_x_z25 * b25_coeff;
  assign w_prod_b26 = r_x_z26 * b26_coeff;
  assign w_prod_b27 = r_x_z27 * b27_coeff;
  assign w_prod_b28 = r_x_z28 * b28_coeff;
  assign w_prod_b29 = r_x_z29 * b29_coeff;
  assign w_prod_b30 = r_x_z30 * b30_coeff;
  assign w_prod_b31 = r_x_z31 * b31_coeff;
  assign w_prod_b32 = r_x_z32 * b32_coeff;
  assign w_prod_b33 = r_x_z33 * b33_coeff;
  assign w_prod_b34 = r_x_z34 * b34_coeff;
  assign w_prod_b35 = r_x_z35 * b35_coeff;
  assign w_prod_b36 = r_x_z36 * b36_coeff;
  assign w_prod_b37 = r_x_z37 * b37_coeff;
  assign w_prod_b38 = r_x_z38 * b38_coeff;
  assign w_prod_b39 = r_x_z39 * b39_coeff;
  assign w_prod_b40 = r_x_z40 * b40_coeff;
  assign w_prod_b41 = r_x_z41 * b41_coeff;
  assign w_prod_b42 = r_x_z42 * b42_coeff;
  assign w_prod_b43 = r_x_z43 * b43_coeff;
  assign w_prod_b44 = r_x_z44 * b44_coeff;
  assign w_prod_b45 = r_x_z45 * b45_coeff;
  assign w_prod_b46 = r_x_z46 * b46_coeff;
  assign w_prod_b47 = r_x_z47 * b47_coeff;
  assign w_prod_b48 = r_x_z48 * b48_coeff;
  assign w_prod_b49 = r_x_z49 * b49_coeff;
  assign w_prod_b50 = r_x_z50 * b50_coeff;

  // accumulate
  assign w_sum = w_prod_b0 + w_prod_b1 + w_prod_b2 + w_prod_b3 + w_prod_b4 + w_prod_b5 + w_prod_b6 + w_prod_b7 + w_prod_b8 + w_prod_b9 + w_prod_b10 + w_prod_b11 + w_prod_b12 + w_prod_b13 + w_prod_b14 + w_prod_b15 + w_prod_b16 + w_prod_b17 + w_prod_b18 + w_prod_b19 + w_prod_b20 + w_prod_b21 + w_prod_b22 + w_prod_b23 + w_prod_b24 + w_prod_b25 + w_prod_b26 + w_prod_b27 + w_prod_b28 + w_prod_b29 + w_prod_b30 + w_prod_b31 + w_prod_b32 + w_prod_b33 + w_prod_b34 + w_prod_b35 + w_prod_b36 + w_prod_b37 + w_prod_b38 + w_prod_b39 + w_prod_b40 + w_prod_b41 + w_prod_b42 + w_prod_b43 + w_prod_b44 + w_prod_b45 + w_prod_b46 + w_prod_b47 + w_prod_b48 + w_prod_b49 + w_prod_b50;

  // output assignments
  assign m_axis_tdata  = r_m_axis_tdata;
  assign m_axis_tvalid = r_m_axis_tvalid;
  assign s_axis_tready = r_s_axis_tready;

endmodule