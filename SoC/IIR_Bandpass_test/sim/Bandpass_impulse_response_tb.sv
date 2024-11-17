`timescale 1ns / 1ps

module Bandpass_impulse_response_tb;
  reg  clk;
  reg  rst_n;
  reg  s_axis_tvalid;
  reg  m_axis_tready; 
  reg  signed [15:0] s_axis_tdata;
  wire signed [15:0] m_axis_tdata;
  wire m_axis_tvalid;
  wire s_axis_tready;

  always #10 clk = ~clk; 

  iir_4th_order_bandpass_axis #(
    .coeff_width(25),
    .inout_width(16),
    .scale_factor(23),

    .sos0_b0_int_coeff(111),
    .sos0_b1_int_coeff(-223),
    .sos0_b2_int_coeff(111),
    .sos0_a1_int_coeff(-15487989),
    .sos0_a2_int_coeff(7253728),

    .sos1_b0_int_coeff(8388608),
    .sos1_b1_int_coeff(16777992),
    .sos1_b2_int_coeff(8389384),
    .sos1_a1_int_coeff(-16019049),
    .sos1_a2_int_coeff(7687567),

    .sos2_b0_int_coeff(8388608),
    .sos2_b1_int_coeff(16776439),
    .sos2_b2_int_coeff(8387831),
    .sos2_a1_int_coeff(-15932677),
    .sos2_a2_int_coeff(7814858),

    .sos3_b0_int_coeff(8388608),
    .sos3_b1_int_coeff(-16777215),
    .sos3_b2_int_coeff(8388608),
    .sos3_a1_int_coeff(-16534190),
    .sos3_a2_int_coeff(8180250)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(s_axis_tready)
  );

  initial 
    begin
    clk = 1'b0;
    rst_n = 1'b0; 
    s_axis_tdata = 0;
    s_axis_tvalid = 1'b0; 
    m_axis_tready = 1'b0;
    #40
    rst_n = 1'b1;  // release reset
    #20
    m_axis_tready = 1'b1;  // upstream device becomes ready
    #20
    s_axis_tdata = 16'h7FFF;  // positive impulse
    #20
    s_axis_tvalid = 1'b1;
    #20
    s_axis_tvalid = 1'b0;
    #20
    s_axis_tdata = 16'h0000;
    repeat(500)
      begin  
        #20
        s_axis_tvalid = 1'b1;
        #20
        s_axis_tvalid = 1'b0;
      end 
    #20000
    $finish;
    end

endmodule

/*
module Bandpass_impulse_response_tb;
  reg  clk;
  reg  rst_n;
  reg  s_axis_tvalid;
  reg  m_axis_tready; 
  reg  signed [15:0] s_axis_tdata;
  wire signed [15:0] m_axis_tdata;
  wire m_axis_tvalid;
  wire s_axis_tready;

  always #10 clk = ~clk; 

  integer fid;
  integer status;
  integer sample; 
  integer i;
  integer j = 0;
  
  localparam num_samples = 1000;
  
  reg signed [15:0] r_wave_sample [num_samples - 1:0];

  iir_DF1_Biquad_AXIS #(
    .coeff_width(25),
    .inout_width(16),
    .scale_factor(23),

    .sos0_b0_int_coeff(111),
    .sos0_b1_int_coeff(-223),
    .sos0_b2_int_coeff(111),
    .sos0_a1_int_coeff(-15487989),
    .sos0_a2_int_coeff(7253728),

    .sos1_b0_int_coeff(8388608),
    .sos1_b1_int_coeff(16777992),
    .sos1_b2_int_coeff(8389384),
    .sos1_a1_int_coeff(-16019049),
    .sos1_a2_int_coeff(7687567),

    .sos2_b0_int_coeff(8388608),
    .sos2_b1_int_coeff(16776439),
    .sos2_b2_int_coeff(8387831),
    .sos2_a1_int_coeff(-15932677),
    .sos2_a2_int_coeff(7814858),

    .sos3_b0_int_coeff(8388608),
    .sos3_b1_int_coeff(-16777215),
    .sos3_b2_int_coeff(8388608),
    .sos3_a1_int_coeff(-16534190),
    .sos3_a2_int_coeff(8180250)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(s_axis_tready)
  );

  initial 
    begin
    clk = 1'b0;
    rst_n = 1'b0; 
    s_axis_tdata = 0;
    s_axis_tvalid = 1'b0; 
    m_axis_tready = 1'b1;  // upstream device is ready

    // load samples into register
    fid = $fopen("50kHz_sine_wave_with_noise.txt","r");
    for (i = 0; i < num_samples; i = i + 1)
      begin
        status = $fscanf(fid,"%d\n",sample); 
        //$display("%d\n",sample);
        r_wave_sample[i] = 16'(sample);
        //$display("%d index is %d\n",i,r_wave_sample[i]);
      end
    $fclose(fid);
    
    #1000
    rst_n = 1'b1; // release reset

    repeat(num_samples)  // 10 MHz sampling
      begin 
        #80
        r_s_axis_tdata = r_wave_sample[j];
        j = j + 1;
        wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge of clock
        r_s_axis_tvalid = 1'b1;
        #20
        r_s_axis_tvalid = 1'b0; // tvalid only high for 1 clock cycle
      end
      #50000
      $finish;
    end

endmodule
*/