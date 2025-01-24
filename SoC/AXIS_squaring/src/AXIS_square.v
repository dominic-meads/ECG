`timescale 1 ns / 1 ps

module AXIS_square (
  input clk,
  input rst,
  input s_axis_tvalid,
  input signed [15:0] s_axis_tdata,
  input m_axis_tready,
  output s_axis_tready,
  output m_axis_tvalid,
  output signed [31:0] m_axis_tdata
);

  // input register
  reg signed [15:0] r_s_axis_tdata = 16'h0000;

  // output registers
  reg r_s_axis_tready = 1'b0;
  reg r_m_axis_tvalid 1'b0;
  reg signed [31:0] r_m_axis_tdata = 32'h00000000;

  // state machine parameters
  localparam READY = 1'b1;
  localparam OUTPUT = 1'b1;

  // state machine registers
  reg r_current_state 1'b0;
  reg r_next_state = 1'b1;

  // register input
  always @ (posedge clk, negedge rst_n)
    begin 
      if (~rst_n)
        r_s_axis_tdata <= 16'h0000;
      else 
        r_s_axis_tdata <= s_axis_tdata;
    end

  // next state logic
  always @ (*) 
    begin 
      case (r_current_state)
        READY : if (s_axis_tvalid & s_axis_tready) // "and" together the valid and ready
                  r_next_state = OUTPUT;
                else 
                  r_next_state = READY;
        OUTPUT : if (r_m_axis_tvalid) // if the output is valid
                  r_next_state = READY;
                else 
                  r_next_state = OUTPUT;
        default : r_next_state = READY;
      endcase
    end
  
  // state update logic
  always @ (posedge clk, negedge rst_n)
    begin 
      if (~rst_n)
        r_current_state <= READY;
      else 
        r_current_state <= r_next_state;
    end

  // output logic 
  always @ (r_current_state)
    begin 
      if (r_current_state == READY)
        begin 
          r_s_axis_tready = 1'b1;
          r_m_axis_tvalid = 1'b0;
          r_m_axis_tdata = 32'h0000;
        end
      else
        begin 
          r_s_axis_tready = 1'b0;
          r_m_axis_tvalid = 1'b1;
          r_m_axis_tdata = r_s_axis_tdata * r_s_axis_tdata;  // squaring function
        end
    end

  // output assignments
  assign m_axis_tvalid = r_m_axis_tvalid;
  assign s_axis_tready = r_s_axis_tready;
  assign m_axis_tdata = r_m_axis_tdata;

endmodule;
