/*
After premilinary testing, the 75-point moving averaged filter is 307 samples behind the FIR BP, and
the smoothed 2nd Derivative is 43 samples behind the moving averaged filter (or 350 samples behind 
the FIR BP). 

One sample represents the period of a tvalid pulse. 

Therefore, in order to phase align, the FIR bandpass signal must be delayed by 350 samples, and the 
moving averaged filter must be delayed by 43 samples. 
*/

`timescale 1ns/1ps

module Signal_Phase_Alignment_tb;

  // UUT ports
  reg  sys_clock = 1'b0;
  reg  reset_n = 1'b0;
  reg  M_AXIS_0_tready = 1'b0;
  reg  M_AXIS_1_tready = 1'b0;
  reg  s_axis_0_tvalid = 1'b0;
  reg signed [15:0] s_axis_0_tdata = 0;
  wire s_axis_0_tready;
  wire M_AXIS_0_tvalid;
  wire signed [31:0] M_AXIS_0_tdata;
  wire M_AXIS_1_tvalid;
  wire signed [31:0] M_AXIS_1_tdata;
  wire m_axis_2_tvalid;
  wire signed [31:0] m_axis_2_tdata;

  // sampling paramters
  real i_sample_freq   = 1e6;  // normal sampling frequency is 500 Hz, increased to 1 MHz to speed up sim
  time t_sample_period = 1e9 / i_sample_freq;
  localparam NUM_SAMPLES = 2000;

  // delay constants for phase alignment (in TVALID pulses)
  localparam FIR_BANDPASS_TVALID_DELAY_CYCLES = 350;
  localparam MOVING_AVERAGE_TVALID_DELAY_CYCLES = 43;
  int j = 0;
  int k = 0;

  // csv reader variables
  int fid;
  int sample;
  int status;
  int i;
  reg signed [15:0] r_sample [0:NUM_SAMPLES-1];

  // 12 MHz system clock (comes out of PLL at 60 MHz)
  always #41.667 sys_clock = ~sys_clock;

  // UUT instance
  ECG_bd_wrapper uut(
    .M_AXIS_0_tdata(M_AXIS_0_tdata),
    .M_AXIS_0_tready(M_AXIS_0_tready),
    .M_AXIS_0_tvalid(M_AXIS_0_tvalid),
    .M_AXIS_1_tdata(M_AXIS_1_tdata),
    .M_AXIS_1_tready(M_AXIS_1_tready),
    .M_AXIS_1_tvalid(M_AXIS_1_tvalid),
    .m_axis_2_tdata(m_axis_2_tdata),
    .m_axis_2_tvalid(m_axis_2_tvalid),
    .reset(reset_n),
    .s_axis_0_tdata(s_axis_0_tdata),
    .s_axis_0_tready(s_axis_0_tready),
    .s_axis_0_tvalid(s_axis_0_tvalid),
    .sys_clock(sys_clock)
  );

  // loads samples from file into the 2D register array and then closes the file. 
  // better to load first then close file because I ran into some window file permission
  // issues when the file was open the entire sim. 
  task load_samples();
    begin
      fid = $fopen("ECG_PCB_test.txt","r"); 
      for (i = 0; i < NUM_SAMPLES-1; i = i+1)
      begin 
        status = $fscanf(fid,"%d\n",sample);
        r_sample[i] = 16'(sample);
      end
      $fclose(fid);
      i = 0;
    end 
  endtask

  // outputs the samples over axi-stream
  task output_ECG_over_stream();
  begin 
    for (i = 0; i < NUM_SAMPLES-1; i = i+1)
    begin 
      wait (sys_clock == 0) wait (sys_clock == 1) // wait for rising clock edge
      s_axis_0_tdata = r_sample[i];               // send sample over stream
      s_axis_0_tvalid = 1'b1;                     // tvalid high
      wait (sys_clock == 0) wait (sys_clock == 1) // wait for rising edge
      s_axis_0_tvalid = 1'b0;                     // tvalid low (only high for one clock cycle)
      #t_sample_period;                           // wait for sample period before repeating
    end
  end 
  endtask;

  // task for delay/alignment of FIR bandpass
  // assert tready only after correct delay
  task phase_align_fir_bp();
  begin
    wait (reset_n == 1'b1); 
    for(j = 0; j < FIR_BANDPASS_TVALID_DELAY_CYCLES; j = j+1)
    begin
      #t_sample_period
      if (j == FIR_BANDPASS_TVALID_DELAY_CYCLES-1) 
      begin 
        M_AXIS_0_tready = 1'b1;
      end 
    end 
  end 
  endtask;

  // initial block for delay/alignment of FIR bandpass
  initial 
    begin
      phase_align_fir_bp();   
    end 

    // task for delay/alignment of moving averaged signal
  task phase_align_moving_average();
  begin 
  end 
  endtask;

  // initial block for delay/alignment of moving averaged signal
  initial 
    begin
       

    end

  // main initial block
  initial 
    begin
      load_samples(); 
      #t_sample_period; 
      reset_n = 1'b1;
      output_ECG_over_stream();
      $finish;
    end 


endmodule