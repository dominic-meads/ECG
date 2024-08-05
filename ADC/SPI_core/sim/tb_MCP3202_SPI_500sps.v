`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 07/13/2024 10:44:56 PM
// Design Name: 
// Module Name: tb_MCP3202_SPI_500sps
// Project Name: 
// Target Devices: 7 Series
// Tool Versions: 
// Description: TB acts as MCP3202 ADC chip. Simulates timing, and sends out sample data. 
//              Verifies "MCP3202_SPI_500sps.v"
//
//              Datasheet: https://ww1.microchip.com/downloads/aemDocuments/documents/APID/ProductDocuments/DataSheets/21034F.pdf
// 
// Dependencies: Input clk frequency 10 MHz - 200 MHz
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_MCP3202_SPI_500sps;
  reg clk, rst_n, miso;
  wire mosi, sck, cs, dv;
  wire [11:0] data;
  
  localparam FCLK = 100e6; // clk frequency
  localparam SGL  = 1;     // single-ended mode
  localparam ODD  = 0;     // Data Aquisition on Channel 0
  
  MCP3202_SPI_500sps #(FCLK,SGL,ODD) uut (clk, rst_n, miso, mosi, sck, cs, data, dv);

  real half_clk_period = 1e9/(2*FCLK);
  always #half_clk_period clk = ~clk;
  
  integer wait_sck_cycle      = (1/FCLK)*900e9;
  integer wait_half_sck_cycle = (1/FCLK)*450e9;
  
  reg [11:0] r_tst_smpl = 12'hd73; // miso test sample word 

  reg [5:0] r_tb_sck_cntr = 0;
  
  integer TCSH_start = 0;
  integer TCSH = 0;
  integer TSUCS_start = 0;
  integer TSUCS = 0;
  integer sck_period_start = 0;
  integer sck_period = 0;
  

  // DO I NEED THIS? ADD IN FOREVER CONDITIONS TO CHECK FOR UNKNOWNS AND HIGH Z
  always @ (negedge sck)
    begin
      if (~rst_n)
        r_tb_sck_cntr <= 0;
      else 
        begin 
          if (r_tb_sck_cntr < 16)
            r_tb_sck_cntr <= r_tb_sck_cntr + 1;
          else 
            r_tb_sck_cntr <= 0;
        end 
    end 
      
  
  initial 
    begin 
      clk   = 1'b0;
      rst_n = 1'b0;
      miso  = 1'bz;
      #25
      rst_n = 1'b1;
      TCSH_start = $time;

      wait (~cs) // cs low, start conversion. Check TCSH timing
        begin
          TCSH = $time - TCSH_start;
          TSUCS_start = $time;
          sck_period_start = $time;
          if (TCSH >= 500)
            $display("TCSH timing statisifed");
          else 
            $fatal(1,"TCSH timing failed. Must be >= 500 ns");

          wait(sck) // first sck rising edge after cs enable, ADC will check start bit. TSCUS min timing must be satisfied. 
            begin
              TSUCS = $time - TSUCS_start;
              if (TSUCS >= 100)
                $display("TSUCS timing statisifed");
              else 
                $fatal(1,"TSUCS timing failed. Must be >= 100 ns");
              if (mosi == 1'b1)
                $display("START bit received");
              else 
                $display("START bit not received in time");
            end

          wait(~sck)  // wait for sck to go back to low (one full period), check freqeuncy. 10 kHz <= SCLK <= 900 kHz @ Vcc = 3.3 V. See "6.2 Maintaining Minimum Clock Speed"
            begin
              sck_period = $time - sck_period_start;
              if (sck_period <= 100000 && sck_period >= 1112)
                $display("sck frequency ok");
              else if (sck_period > 100000)
                $fatal(1,"sck frequency too low. Must be >= 10 kHz");
              else if (sck_period < 1112)
                $fatal(1,"sck frequency too low. Must be <= 900 kHz");
            end 

          wait(sck)  // Check SGL/DIFF bit on rising edge of SCK
            begin
              if (mosi == 1'b1)
                $display("set to single-ended mode");
              else
                $display("set to differential mode");
            end

          wait(~sck) wait(sck)  // check ODD/SIGN bit on posedge SCK
            begin
              if (mosi == 1'b1)
                $display("sampling on channel 1");
              else
                $display("sampling on channel 0");
            end
          
          wait(~sck) wait(sck)  // check MSBF bit on posedge SCK
            begin 
              if (mosi == 1'b1)
                $display("set to MSBF mode");
              else
                $display("set to LSBF mode");
            end

          wait(~sck)  // TX MSB of sample on negedge SCK
            begin 
              #200 // TEN max (SCK falling edge to DOUT enable)
              miso = r_tst_smpl[11];
            end

          wait(sck) wait(~sck)  // TX bit 10 of sample on negedge SCK
            miso = r_tst_smpl[10];

          wait(sck) wait(~sck)  // TX bit 9 of sample on negedge SCK
            miso = r_tst_smpl[9];

          wait(sck) wait(~sck)  // TX bit 8 of sample on negedge SCK
            miso = r_tst_smpl[8];

          wait(sck) wait(~sck)  // TX bit 7 of sample on negedge SCK
            miso = r_tst_smpl[7];

          wait(sck) wait(~sck)  // TX bit 6 of sample on negedge SCK
            miso = r_tst_smpl[6];

          wait(sck) wait(~sck)  // TX bit 5 of sample on negedge SCK
            miso = r_tst_smpl[5];

          wait(sck) wait(~sck)  // TX bit 4 of sample on negedge SCK
            miso = r_tst_smpl[4];

          wait(sck) wait(~sck)  // TX bit 3 of sample on negedge SCK
            miso = r_tst_smpl[3];

          wait(sck) wait(~sck)  // TX bit 2 of sample on negedge SCK
            miso = r_tst_smpl[2];

          wait(sck) wait(~sck)  // TX bit 1 of sample on negedge SCK
            miso = r_tst_smpl[1];

          wait(sck) wait(~sck)  // TX bit 0 of sample on negedge SCK
            miso = r_tst_smpl[0];

          // PUT IN DATA VALID FLAG
          wait(cs)
            begin 
              $display("All bits TX'ed. Data now valid. Sample time = %d", $time);
              if (data == r_tst_smpl)
                $display("SIMULATION PASSED: Module sample accurate");
              else
                $fatal(1,"SIMULATION FAILED: Module output data does not match test sample");        
            end 
          #30000
          $finish(2);
        end
    end
endmodule
