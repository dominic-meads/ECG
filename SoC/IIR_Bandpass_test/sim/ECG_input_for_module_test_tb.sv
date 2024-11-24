`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 11/23/2024 10:05:43 PM
// Design Name: 
// Module Name: ECG_input_for_module_test
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: Vivado 2024.1
// Description: 
//      Behvaioral model of MCP3202 ADC that gets samples from an ECG waveform and 
//      serializes them for SPI communication with the MCP3202 SPI driver written 
//      in verilog. Also includes some AXIS signal control from simulated "upstream"
//      device. 
//
//      This testbench hasnt been used much because is runs incredibly slow on my computer.
//
//      MCP3202 SPI driver: https://github.com/dominic-meads/ECG/blob/main/SoC/IIR_Bandpass_test/src/MCP3202_SPI_S_AXIS.v
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//    
//////////////////////////////////////////////////////////////////////////////////

module ECG_input_for_module_test;
  // module ports
  reg clk_in; 
  reg rst_n;
  reg sel;    // for output mux select in uut
  reg m_axis_tready;  // upstream device ready
  wire signed [15:0] m_axis_tdata;
  wire m_axis_tvalid;

  // behavioral ADC ports
  wire cs;
  wire sck;
  wire mosi;
  reg miso;  // tb is acting as slave ADC

  // 125 MHz system input clock gets divided to 50 MHz by clocking wizard ip
  always #4 clk_in = ~clk_in;

  // uut parameters
  localparam FCLK  = 50e6;  // clk frequency
  localparam FSMPL = 500;   // sampling freqeuncy 
  localparam SGL   = 1;     // sets ADC to single-ended
  localparam ODD   = 0;     // sets ADC sample input to channel 0

  localparam coeff_width  = 25;     // coefficient bit width
  localparam inout_width  = 16;     // input and output data wdth
  localparam scale_factor = 23;     // multiplying coefficients by 2^23
  
  // sos0 coeffs
  localparam sos0_b0_int_coeff = 514530;
  localparam sos0_b1_int_coeff = 0;
  localparam sos0_b2_int_coeff = -514530;
  localparam sos0_a1_int_coeff = -15932677;
  localparam sos0_a2_int_coeff = 7814858;

  // sos1 coeffs
  localparam sos1_b0_int_coeff = 514530;
  localparam sos1_b1_int_coeff = 0;
  localparam sos1_b2_int_coeff = -514530;
  localparam sos1_a1_int_coeff = -16534189;
  localparam sos1_a2_int_coeff = 8180250;

  // sos2 coeffs
  localparam sos2_b0_int_coeff = 498645;
  localparam sos2_b1_int_coeff = 0;
  localparam sos2_b2_int_coeff = -498645;
  localparam sos2_a1_int_coeff = -16019050;
  localparam sos2_a2_int_coeff = 7687568;

  // sos3 coeffs
  localparam sos3_b0_int_coeff = 498645;
  localparam sos3_b1_int_coeff = 0;
  localparam sos3_b2_int_coeff = -498645;
  localparam sos3_a1_int_coeff = -15487989;
  localparam sos3_a2_int_coeff = 7253728;

  // uut instantiation
  ADC_to_iir_test_top #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),  
    .ODD(ODD),
    .coeff_width(coeff_width),
    .inout_width(inout_width),
    .scale_factor(scale_factor),

    .sos0_b0_int_coeff(sos0_b0_int_coeff),
    .sos0_b1_int_coeff(sos0_b1_int_coeff),
    .sos0_b2_int_coeff(sos0_b2_int_coeff),
    .sos0_a1_int_coeff(sos0_a1_int_coeff),
    .sos0_a2_int_coeff(sos0_a2_int_coeff),

    .sos1_b0_int_coeff(sos1_b0_int_coeff),
    .sos1_b1_int_coeff(sos1_b1_int_coeff),
    .sos1_b2_int_coeff(sos1_b2_int_coeff),
    .sos1_a1_int_coeff(sos1_a1_int_coeff),
    .sos1_a2_int_coeff(sos1_a2_int_coeff),

    .sos2_b0_int_coeff(sos2_b0_int_coeff),
    .sos2_b1_int_coeff(sos2_b1_int_coeff),
    .sos2_b2_int_coeff(sos2_b2_int_coeff),
    .sos2_a1_int_coeff(sos2_a1_int_coeff),
    .sos2_a2_int_coeff(sos2_a2_int_coeff),

    .sos3_b0_int_coeff(sos3_b0_int_coeff),
    .sos3_b1_int_coeff(sos3_b1_int_coeff),
    .sos3_b2_int_coeff(sos3_b2_int_coeff),
    .sos3_a1_int_coeff(sos3_a1_int_coeff),
    .sos3_a2_int_coeff(sos3_a2_int_coeff)
  ) uut (
    .clk_in(clk_in),
    .rst_n(rst_n),
    .miso(miso),
    .m_axis_tready(m_axis_tready),
    .sel(sel),           
    .mosi(mosi),
    .sck(sck),
    .cs(cs),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid) 
  );

  // tb stimulus signals
  integer TCSH_start = 0;
  integer TCSH = 0;
  integer TSUCS_start = 0;
  integer TSUCS = 0;
  integer sck_period_start = 0;
  integer sck_period = 0;
  localparam num_samples = 4096;  // logic analyzer gives 4096 samples per export
  reg [11:0] r_ECG_smpl = 0;  // 12 bit sample from ADC

  // file io
  integer fid;
  integer status;
  integer sample; 
  integer i;
  integer j = 0;

  task tx_sample ();  // waits for cs to be active (low), and transmits sample
    begin
      wait (~cs) // cs low, start conversion. Check TCSH timing
        begin
          $display("Initiating new sample transmission");
          TCSH = $time - TCSH_start;
          TSUCS_start = $time;
          sck_period_start = $time;
          if (TCSH < 500) 
            $fatal(1,"TCSH timing failed. Must be >= 500 ns");

          wait(sck) // first sck rising edge after cs enable, ADC will check start bit. TSCUS min timing must be satisfied. 
            begin
              TSUCS = $time - TSUCS_start;
              if (TSUCS < 100)
                $fatal(1,"TSUCS timing failed. Must be >= 100 ns");
            end

          wait(~sck)  // wait for sck to go back to low (one full period), check freqeuncy. 10 kHz <= SCLK <= 900 kHz @ Vcc = 3.3 V. See "6.2 Maintaining Minimum Clock Speed"
            begin
              sck_period = $time - sck_period_start;
              if (sck_period > 100000)
                $fatal(1,"sck frequency too low. Must be >= 10 kHz");
              else if (sck_period < 1112)
                $fatal(1,"sck frequency too low. Must be <= 900 kHz");
            end 

          wait(sck)  // Check SGL/DIFF bit on rising edge of SCK
            // begin
            //   if (mosi == 1'b1)
            //     $display("set to single-ended mode");
            //   else
            //     $display("set to differential mode");
            // end

          wait(~sck) wait(sck)  // check ODD/SIGN bit on posedge SCK
            // begin
            //   if (mosi == 1'b1)
            //     $display("sampling on channel 1");
            //   else
            //    $display("sampling on channel 0");
            // end
          
          wait(~sck) wait(sck)  // check MSBF bit on posedge SCK
            // begin 
            //   if (mosi == 1'b1)
            //     $display("set to MSBF mode");
            //   else
            //     $display("set to LSBF mode");
            // end

          wait(~sck)  // TX null bit on negedge SCK after enable time = 200 ns (max)
            begin 
              #200 // TEN max (SCK falling edge to DOUT enable)
              miso = 0; 
            end

          wait(sck) wait(~sck)  // TX MSB of sample on negedge SCK
            miso = r_ECG_smpl[11];

          wait(sck) wait(~sck)  // TX bit 10 of sample on negedge SCK
            miso = r_ECG_smpl[10];

          wait(sck) wait(~sck)  // TX bit 9 of sample on negedge SCK
            miso = r_ECG_smpl[9];

          wait(sck) wait(~sck)  // TX bit 8 of sample on negedge SCK
            miso = r_ECG_smpl[8];

          wait(sck) wait(~sck)  // TX bit 7 of sample on negedge SCK
            miso = r_ECG_smpl[7];

          wait(sck) wait(~sck)  // TX bit 6 of sample on negedge SCK
            miso = r_ECG_smpl[6];

          wait(sck) wait(~sck)  // TX bit 5 of sample on negedge SCK
            miso = r_ECG_smpl[5];

          wait(sck) wait(~sck)  // TX bit 4 of sample on negedge SCK
            miso = r_ECG_smpl[4];

          wait(sck) wait(~sck)  // TX bit 3 of sample on negedge SCK
            miso = r_ECG_smpl[3];

          wait(sck) wait(~sck)  // TX bit 2 of sample on negedge SCK
            miso = r_ECG_smpl[2];

          wait(sck) wait(~sck)  // TX bit 1 of sample on negedge SCK
            miso = r_ECG_smpl[1];

          wait(sck) wait(~sck)  // TX bit 0 of sample on negedge SCK
            miso = r_ECG_smpl[0];

          wait(cs)
            begin 
              miso  = 1'bz;  // go high impedance
            end   
        end
    end 
  endtask

  initial 
    begin
      clk_in = 1'b0;
      rst_n = 1'b0;
      sel = 1'b0;    // set top module output to iir filtered signal 
      m_axis_tready = 1'b0;  // upstream device NOT ready
      miso = 1'b0;
      
      #1000
      rst_n = 1'b1;
      m_axis_tready = 1'b1;
      
      fid = $fopen("raw_ECG_samples.txt","r");

      for (i = 0; i < num_samples; i = i + 1)
        begin
          status = $fscanf(fid,"%d\n",sample);
          r_ECG_smpl = 12'(sample);
          TCSH_start = $time;
          tx_sample();
        end
      $fclose(fid);

      $finish;
    end

endmodule