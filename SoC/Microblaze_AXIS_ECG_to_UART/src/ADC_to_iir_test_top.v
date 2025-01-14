module ADC_to_iir_test_top #(
  parameter FCLK  = 60e6,  // clk frequency
  parameter FSMPL = 500,   // sampling freqeuncy 
  parameter SGL   = 1,     // sets ADC to single-ended
  parameter ODD   = 0,     // sets ADC sample input to channel 0

  parameter coeff_width  = 25,     // coefficient bit width
  parameter inout_width  = 16,     // input and output data wdth
  parameter scale_factor = 23,     // multiplying coefficients by 2^23
  
 // sos0 coeffs
  parameter sos0_b0_int_coeff = 2174371,
  parameter sos0_b1_int_coeff = 0,
  parameter sos0_b2_int_coeff = -2174371,
  parameter sos0_a1_int_coeff = -11556035,
  parameter sos0_a2_int_coeff = 5587438,

  // sos1 coeffs
  parameter sos1_b0_int_coeff = 2174371,
  parameter sos1_b1_int_coeff = 0,
  parameter sos1_b2_int_coeff = -2174371,
  parameter sos1_a1_int_coeff = -16621402,
  parameter sos1_a2_int_coeff = 8238155,

  // sos2 coeffs
  parameter sos2_b0_int_coeff = 1949056,
  parameter sos2_b1_int_coeff = 0,
  parameter sos2_b2_int_coeff = -1949056,
  parameter sos2_a1_int_coeff = -16368696,
  parameter sos2_a2_int_coeff = 7986060,

  // sos3 coeffs
  parameter sos3_b0_int_coeff = 1949056,
  parameter sos3_b1_int_coeff = 0,
  parameter sos3_b2_int_coeff = -1949056,
  parameter sos3_a1_int_coeff = -9542824,
  parameter sos3_a2_int_coeff = 2899653
  )(
  input clk_in,  // 60 MHz
  input rst_n,
  input miso,
  input m_axis_tready,  // ready signal from upstream device
  input sel,            // output mux select (see end of file)
  output mosi,
  output sck,
  output cs,
  output signed [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid
  );

  // intermediate signals
  wire [inout_width-1:0] w_spi_to_iir_axis_tdata;
  wire [inout_width-1:0] w_iir_output_axis_tdata;
  wire w_spi_to_iir_axis_tvalid;
  wire w_iir_to_spi_axis_tready;

  // module instantiations

  MCP3202_SPI_S_AXIS #(
    .FCLK(FCLK),
    .FSMPL(FSMPL),
    .SGL(SGL),  
    .ODD(ODD)
  ) spi0 (
    .clk(clk_in),
    .rst_n(rst_n),
    .miso(miso),
    .s_axis_spi_tready(w_iir_to_spi_axis_tready),
    .mosi(mosi),
    .sck(sck),
    .cs(cs),
    .s_axis_spi_tdata(w_spi_to_iir_axis_tdata),
    .s_axis_spi_tvalid(w_spi_to_iir_axis_tvalid)
  );

  iir_bandpass_noise_offset_removal_axis #(
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
  ) iir0 (
    .clk(clk_in),
    .rst_n(rst_n),
    .s_axis_tvalid(w_spi_to_iir_axis_tvalid),
    .s_axis_tdata(w_spi_to_iir_axis_tdata),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(w_iir_output_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(w_iir_to_spi_axis_tready)
  );

  // this mux controls whether the raw data coming out of the ADC is seen on the output, or if it is the filtered signal
  // I only have 16 inputs on my logic analyzer, so I cant view both at the same time. 
  assign m_axis_tdata = sel ? w_spi_to_iir_axis_tdata : w_iir_output_axis_tdata;

endmodule 
