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

  // 50 MHz clock
  always #10 clk = ~clk; 

  // constants for module instantiation
  localparam coeff_width  = 25;
  localparam inout_width  = 16;
  localparam scale_factor = 23;

  localparam b0_coeff = 0;
  localparam b1_coeff = 3488;
  localparam b2_coeff = 4584;
  localparam b3_coeff = 1657;
  localparam b4_coeff = -7004;
  localparam b5_coeff = -21544;
  localparam b6_coeff = -38844;
  localparam b7_coeff = -52147;
  localparam b8_coeff = -52988;
  localparam b9_coeff = -35280;
  localparam b10_coeff = 0;
  localparam b11_coeff = 41968;
  localparam b12_coeff = 71124;
  localparam b13_coeff = 65590;
  localparam b14_coeff = 10873;
  localparam b15_coeff = -90396;
  localparam b16_coeff = -213161;
  localparam b17_coeff = -312565;
  localparam b18_coeff = -335311;
  localparam b19_coeff = -237025;
  localparam b20_coeff = 0;
  localparam b21_coeff = 355329;
  localparam b22_coeff = 770299;
  localparam b23_coeff = 1160719;
  localparam b24_coeff = 1439189;
  localparam b25_coeff = 1540115;
  localparam b26_coeff = 1439189;
  localparam b27_coeff = 1160719;
  localparam b28_coeff = 770299;
  localparam b29_coeff = 355329;
  localparam b30_coeff = 0;
  localparam b31_coeff = -237025;
  localparam b32_coeff = -335311;
  localparam b33_coeff = -312565;
  localparam b34_coeff = -213161;
  localparam b35_coeff = -90396;
  localparam b36_coeff = 10873;
  localparam b37_coeff = 65590;
  localparam b38_coeff = 71124;
  localparam b39_coeff = 41968;
  localparam b40_coeff = 0;
  localparam b41_coeff = -35280;
  localparam b42_coeff = -52988;
  localparam b43_coeff = -52147;
  localparam b44_coeff = -38844;
  localparam b45_coeff = -21544;
  localparam b46_coeff = -7004;
  localparam b47_coeff = 1657;
  localparam b48_coeff = 4584;
  localparam b49_coeff = 3488;
  localparam b50_coeff = 0;

  FIR_bp #(
    .coeff_width(25),
    .inout_width(16),
    .scale_factor(23),
    .b0_coeff(b0_coeff),
    .b1_coeff(b1_coeff),
    .b2_coeff(b2_coeff),
    .b3_coeff(b3_coeff),
    .b4_coeff(b4_coeff),
    .b5_coeff(b5_coeff),
    .b6_coeff(b6_coeff),
    .b7_coeff(b7_coeff),
    .b8_coeff(b8_coeff),
    .b9_coeff(b9_coeff),
    .b10_coeff(b10_coeff),
    .b11_coeff(b11_coeff),
    .b12_coeff(b12_coeff),
    .b13_coeff(b13_coeff),
    .b14_coeff(b14_coeff),
    .b15_coeff(b15_coeff),
    .b16_coeff(b16_coeff),
    .b17_coeff(b17_coeff),
    .b18_coeff(b18_coeff),
    .b19_coeff(b19_coeff),
    .b20_coeff(b20_coeff),
    .b21_coeff(b21_coeff),
    .b22_coeff(b22_coeff),
    .b23_coeff(b23_coeff),
    .b24_coeff(b24_coeff),
    .b25_coeff(b25_coeff),
    .b26_coeff(b26_coeff),
    .b27_coeff(b27_coeff),
    .b28_coeff(b28_coeff),
    .b29_coeff(b29_coeff),
    .b30_coeff(b30_coeff),
    .b31_coeff(b31_coeff),
    .b32_coeff(b32_coeff),
    .b33_coeff(b33_coeff),
    .b34_coeff(b34_coeff),
    .b35_coeff(b35_coeff),
    .b36_coeff(b36_coeff),
    .b37_coeff(b37_coeff),
    .b38_coeff(b38_coeff),
    .b39_coeff(b39_coeff),
    .b40_coeff(b40_coeff),
    .b41_coeff(b41_coeff),
    .b42_coeff(b42_coeff),
    .b43_coeff(b43_coeff),
    .b44_coeff(b44_coeff),
    .b45_coeff(b45_coeff),
    .b46_coeff(b46_coeff),
    .b47_coeff(b47_coeff),
    .b48_coeff(b48_coeff),
    .b49_coeff(b49_coeff),
    .b50_coeff(b50_coeff)
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

  // variables for tb stimulus
  integer i_impulse_max = 0;
  integer fid;
  integer status;
  integer sample; 
  integer i;
  integer j = 0;

  // global status flags to know which mode I am checking in the testbench
  bit checking_impulse_resp = 1'b0;  
  bit checking_wave_output = 1'b0;
  
  localparam num_samples = 350;
  
  reg signed [15:0] r_wave_sample [num_samples - 1:0];

  // generates an impulse
  task axis_impulse();
    begin
      checking_impulse_resp = 1'b1;
      i_impulse_max = 2**(inout_width-1)-1; // 2^(inout_width-1) because input is signed, so to make max positive number need MSB-1 (sign bit stays 0)
      wait (rst_n == 1'b1)                  // wait for reset release
      wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge clk

      if (s_axis_tready == 1'b1)            // if uut is ready to accept data
        begin 
          s_axis_tdata  = i_impulse_max;    // send out impulse
          s_axis_tvalid = 1'b1;
          #20
          s_axis_tvalid = 1'b0;
        end

      #1999980  // fs = 500 Hz
      wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge clk 
      s_axis_tdata = 0;                     // data goes back to 0
      s_axis_tvalid = 1'b1;
      #20
      s_axis_tvalid = 1'b0;

      repeat(500)  // repeat for 500 samples @ fs =  500 Hz
        begin
          #1999980  // fs = 500 Hz
          wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge clk
          s_axis_tvalid = 1'b1;                 // valid flag every clock cycle
          #20
          s_axis_tvalid = 1'b0;
        end
      
      checking_impulse_resp = 1'b0;
    end
  endtask

  // file output for impulse response
  initial 
    begin
        wait (checking_impulse_resp == 1'b1) // indicates in the impulse response section of tb
        fid = $fopen("Bandpass_impulse_response_output.txt","w");     // create or open file
        $display("file opened");
        while (checking_impulse_resp == 1'b1)
          begin 
            wait (m_axis_tvalid == 0) wait (m_axis_tvalid == 1); // wait for rising edge of master tvalid output
            $fdisplay(fid,"%d",m_axis_tdata);                    // write output data to file
          end 
        $fclose(fid);
    end

   initial 
    begin
    clk = 1'b0;
    rst_n = 1'b0; 
    s_axis_tdata = 0;
    s_axis_tvalid = 1'b0;
    m_axis_tready = 1'b1; // upstream device ready
    #40
    rst_n = 1'b1;
    #40
    axis_impulse();
    #10000
    rst_n = 1'b0;  // reset to test an input signal
    checking_wave_output = 1'b1;

    // load samples into register
    fid = $fopen("10Hz_sine_wave_with_60_Hz_noise.txt","r");
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
    
    repeat(num_samples)  // 500 Hz sampling
      begin 
        #1999980
        s_axis_tdata = r_wave_sample[j];
        j = j + 1;
        wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge of clock
        s_axis_tvalid = 1'b1;
        #20
        s_axis_tvalid = 1'b0; // tvalid only high for 1 clock cycle
      end
      #50000
      $finish;
    $finish;
    end

endmodule