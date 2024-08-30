`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dominic Meads
// 
// Create Date: 07/13/2024 10:37:57 PM
// Design Name: 
// Module Name: MCP3202_SPI_500sps
// Project Name: 
// Target Devices: 7 zeries
// Tool Versions: 
// Description: An SPI master for an MCP3202 ADC. It has a sample rate of 500 samples/sec and 
//              will be used for an ECG demo. The ADC is set to operate in single-ended sampling
//              "MSB first" mode on input channel 0. The ADC can be set to differential mode and 
//              channel can be changed (see "parameters"), but "MSB first" mode is always selected
//
// 
// Dependencies: Input clk frequency 10 MHz - 200 MHz
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MCP3202_SPI_500sps #(
    parameter FCLK = 100e6, // clk frequency
    parameter SGL = 1,      // sets ADC to single-ended
    parameter ODD = 0       // sets ADC sample input to channel 0
    )(
    input clk,
    input rst_n,
    input reg miso,
    output mosi,
    output sck,
    output cs,
    output [11:0] data,
    output dv
    );

    localparam INIT = 2'b00;  // initialize the state machine
    localparam TX   = 2'b01;  // set the sample channel, sampling mode, etc...
    localparam RX   = 2'b10;  // convert the bitstream into parellel word
    localparam IDLE = 2'b11;  // CS is high

    reg [1:0] r_state = INIT;

    // Calculates number of input clk cycle counts equal to TCSH time (depends on clk)
    localparam param_tcsh_clk_cnts_max = 2e-3 * FCLK - 15300; 
    integer TCSH_CLK_CNTS_MAX = $rtoi(param_tcsh_clk_cnts_max);

    // additional MOSI data
    localparam START = 1'b1;           // start bit
    localparam	MSBF = 1'b1;           // sets ADC to transmit MSB first

    // DATA TO BE TX'ed VIA MOSI LINE
    reg [3:0] r_tx_data = {MSBF, ODD[0], SGL[0], START};

    // output registers
    reg r_mosi = 0; 
    reg [12:0] r_rx_data = 13'h0000; // 1 null bit and 12 data bits
    reg r_cs = 1;       	     // disable CS to start
    reg r_dv = 0;                    // DATA_VALID register
    
    reg[$clog2(TCSH_CLK_CNTS_MAX)-1:0] r_tcsh_clk_cnts = 0;
    reg r_tcsh_clk_cntr_en = 0;
    
    // input clk cycles per single spi clk cycle
    reg[9:0] r_clk_cnts_per_sck = 0;
    
    // spi clk cycle counter
    reg[4:0] r_sck_cntr = 0;
    reg r_sck_en = 0;
    
    // TCSH counter
    always @ (posedge clk or negedge rst_n)
        begin
            if (~rst_n || ~r_tcsh_clk_cntr_en)
                r_tcsh_clk_cnts <= 0;
            else 
                begin
                  if (r_tcsh_clk_cnts < TCSH_CLK_CNTS_MAX - 1) 

                        r_tcsh_clk_cnts <= r_tcsh_clk_cnts + 1;
                    else 
                        r_tcsh_clk_cnts <= 0;
                end 
        end

    // input clk divider for SCLK (divided by 900)
     always @ (posedge clk or negedge rst_n)
        begin
            if (~rst_n || ~r_sck_en)
                r_clk_cnts_per_sck <= 0;
            else 
                begin
                    if (r_clk_cnts_per_sck < 899)  // divide system clk by 900, input between 10 MHz to 200 MHz
                        r_clk_cnts_per_sck <= r_clk_cnts_per_sck + 1;
                    else
                        r_clk_cnts_per_sck <= 0;
                end
        end
        
    // SCLK cycle counter
     always @ (posedge clk or negedge rst_n)
        begin 
            if (~rst_n || ~r_sck_en)
                r_sck_cntr <= 0;
            else
                begin 
                    if (r_sck_cntr < 16 && r_clk_cnts_per_sck == 899)
                        r_sck_cntr <= r_sck_cntr + 1;
                    else if (r_sck_cntr == 16 && r_clk_cnts_per_sck == 899)
                        r_sck_cntr <= 0;
                end
        end 
    
    always @ (posedge clk, negedge rst_n)
        begin
            if (~rst_n)
                begin
                    r_state <= INIT;
                
                    r_cs      <= 1'b1;
                    r_mosi    <= 1'b0;
                    r_rx_data <= 13'h0000;
                    r_dv      <= 1'b0;
                                
                    r_tcsh_clk_cntr_en <= 1'b0;
                    r_sck_en           <= 1'b0;
                end
            else 
                begin 
                    case (r_state) 
                        
                        INIT :
                            begin 
                                r_cs      <= 1'b1;
                                r_mosi    <= 1'b0;
                                r_rx_data <= 13'h0000;
                                r_dv      <= 1'b0;
                                
                                r_tcsh_clk_cntr_en <= 1'b1;
                                r_sck_en           <= 1'b0;
                                
                              if (r_tcsh_clk_cnts == TCSH_CLK_CNTS_MAX - 1)  // only move to next state if the total disable time is met
                                    r_state <= TX;
                                else
                                    r_state <= INIT;
                            end
                    
                        TX : 
                            begin 
                                r_cs      <= 1'b0;
                                r_mosi    <= r_tx_data[r_sck_cntr];
                                r_rx_data <= 13'h0000;
                                r_dv      <= 1'b0;
                                
                                r_tcsh_clk_cntr_en <= 1'b0;
                                r_sck_en       <= 1'b1;

                                if (r_sck_cntr == 3 && r_clk_cnts_per_sck == 899)
                                    r_state <= RX;
                                else
                                    r_state <= TX;
                            end 

                        RX : 
                            begin 
                                r_cs   <= 1'b0;
                                r_mosi <= 1'b0;
                                if (r_clk_cnts_per_sck == 449)
                                    r_rx_data[12-(r_sck_cntr-4)] <= miso; 
                            
                                r_dv   <= 1'b0;
                                
                                r_tcsh_clk_cntr_en <= 1'b0;
                                r_sck_en       <= 1'b1;
                                
                                if (r_sck_cntr == 16 && r_clk_cnts_per_sck == 898)
                                    r_state <= IDLE;
                                else
                                    r_state <= RX;  
                            end

                        IDLE : 
                            begin
                                r_cs      <= 1'b1;
                                r_mosi    <= 1'b0;
                                r_dv      <= 1'b1;
                                
                                r_tcsh_clk_cntr_en <= 1'b1;
                                r_sck_en           <= 1'b0;
                                
                              if (r_tcsh_clk_cnts == TCSH_CLK_CNTS_MAX - 1)  // only move to next state if the total disable time is met
                                    r_state <= TX;
                            end

                        default : r_state <= INIT;

                    endcase
                end 
        end

    assign cs = r_cs;
    assign mosi = r_mosi;
    assign data = r_rx_data[11:0];
    assign dv = r_dv;
    assign sck = (r_clk_cnts_per_sck <= 449 && r_sck_en) ? 0:1;

endmodule

