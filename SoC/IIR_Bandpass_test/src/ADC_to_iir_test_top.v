module ADC_to_iir_test_top #(
  parameter FCLK  = 50e6,  // clk frequency
  parameter FSMPL = 500,   // sampling freqeuncy 
  parameter SGL   = 1,     // sets ADC to single-ended
  parameter ODD   = 0,     // sets ADC sample input to channel 0

  parameter coeff_width  = 25,     // coefficient bit width
  parameter inout_width  = 16,     // input and output data wdth
  parameter scale_factor = 23,     // multiplying coefficients by 2^23
  
  // sos0 coeffs
  parameter sos0_b0_int_coeff = 514530,
  parameter sos0_b1_int_coeff = 0,
  parameter sos0_b2_int_coeff = -514530,
  parameter sos0_a1_int_coeff = -15932677,
  parameter sos0_a2_int_coeff = 7814858,

  // sos1 coeffs
  parameter sos1_b0_int_coeff = 514530,
  parameter sos1_b1_int_coeff = 0,
  parameter sos1_b2_int_coeff = -514530,
  parameter sos1_a1_int_coeff = -16534189,
  parameter sos1_a2_int_coeff = 8180250,

  // sos2 coeffs
  parameter sos2_b0_int_coeff = 498645,
  parameter sos2_b1_int_coeff = 0,
  parameter sos2_b2_int_coeff = -498645,
  parameter sos2_a1_int_coeff = -16019050,
  parameter sos2_a2_int_coeff = 7687568,

  // sos3 coeffs
  parameter sos3_b0_int_coeff = 498645,
  parameter sos3_b1_int_coeff = 0,
  parameter sos3_b2_int_coeff = -498645,
  parameter sos3_a1_int_coeff = -15487989,
  parameter sos3_a2_int_coeff = 7253728
  )(
  input clk_in,  // 125 MHz
  input rst_n,
  input miso,
  input m_axis_tready,  // ready signal from upstream device
  output mosi,
  output sck,
  output cs,
  output signed [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid
  );

  // intermediate signals
  wire [inout_width-1:0] w_spi_to_iir_axis_tdata;
  wire w_spi_to_iir_axis_tvalid;
  wire w_iir_to_spi_axis_tready;
  wire w_clk_50MHz;

  // module instantiations

  clk_wiz_0 clk0
   (
    // Clock out ports
    .clk_out1(w_clk_50MHz),     // output clk_out1
    // Status and control signals
    .resetn(rst_n), // input resetn
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_in)      // input clk_in1
  );

  MCP3202_SPI_S_AXIS #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),  
    .ODD(ODD)
  ) spi0 (
    .clk(w_clk_50MHz),
    .rst_n(rst_n),
    .miso(miso),
    .s_axis_spi_tready(w_iir_to_spi_axis_tready),
    .mosi(mosi),
    .sck(sck),
    .cs(cs),
    .s_axis_spi_tdata(w_spi_to_iir_axis_tdata),
    .s_axis_spi_tvalid(w_spi_to_iir_axis_tvalid)
  );

  iir_4th_order_bandpass_axis #(
    .coeff_width(25),
    .inout_width(16),
    .scale_factor(23),

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
  ) iir0 (
    .clk(w_clk_50MHz),
    .rst_n(rst_n),
    .s_axis_tvalid(w_spi_to_iir_axis_tvalid),
    .s_axis_tdata(w_spi_to_iir_axis_tdata),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(w_iir_to_spi_axis_tready)
  );

endmodule 
