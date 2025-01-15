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

  AXIS_FIR_bp uut (
    .clk(clk),                      // input wire aclk
    .s_axis_tvalid(s_axis_tvalid),  // input wire s_axis_data_tvalid
    .s_axis_tready(s_axis_tready),  // output wire s_axis_data_tready
    .s_axis_tdata(s_axis_tdata),    // input wire [15 : 0] s_axis_data_tdata
    .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_data_tvalid
    .m_axis_tdata(m_axis_tdata)     // output wire [15 : 0] m_axis_data_tdata
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
      i_impulse_max = 2**(15)-1;            // 2^(inout_width-1) because input is signed, so to make max positive number need MSB-1 (sign bit stays 0)
      wait (rst_n == 1'b1)                  // wait for reset release
      wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge clk

      if (s_axis_tready == 1'b1)            // if uut is ready to accept data
        begin 
          s_axis_tdata  = i_impulse_max;    // send out impulse
          s_axis_tvalid = 1'b1;
          #20
          s_axis_tvalid = 1'b0;
        end

      #1980  
      wait (clk == 1'b0) wait (clk == 1'b1) // wait for rising edge clk 
      s_axis_tdata = 0;                     // data goes back to 0
      s_axis_tvalid = 1'b1;
      #20
      s_axis_tvalid = 1'b0;

      repeat(70)  
        begin
          #1980  
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
    #1000
    rst_n = 1'b0;  // reset to test an input signal
    checking_wave_output = 1'b1;

    // load samples into register
    fid = $fopen("10Hz_sine_wave_with_60_Hz_noise.txt","r");
    for (i = 0; i < num_samples; i = i + 1)
      begin
        status = $fscanf(fid,"%d\n",sample); 
        r_wave_sample[i] = 16'(sample);
      end
    $fclose(fid);
    
    #1000
    rst_n = 1'b1; // release reset
    
    repeat(num_samples)  // 500 Hz sampling
      begin 
        #1980
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