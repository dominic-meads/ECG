`timescale 1ns / 1ps
// glue logic that increases the width of my 16-bit wide DSP blocks and SPI slave to 32-bits wide 
// for microblaze axi-streaming ports. I cant seem to be able to change the width of the microblaze ports


module axis_width_16_to_32 (
  input signed [15:0] s_axis_tdata,
  input s_axis_tvalid,
  input m_axis_tready,
  output signed [31:0] m_axis_tdata,
  output m_axis_tvalid,
  output s_axis_tready
  );
    
  assign m_axis_tdata = { {16{s_axis_tdata[15]}}, s_axis_tdata };  // sign extend the input to 32 bits
  
  // other signals passthrough
  assign m_axis_tvalid = s_axis_tvalid;
  assign s_axis_tready = m_axis_tready; 
   
endmodule
