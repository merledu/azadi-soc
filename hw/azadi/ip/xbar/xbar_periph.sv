

module xbar_periph (
  input clk_peri_i,
  input rst_peri_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_xbar_main_i,
  output tlul_pkg::tl_d2h_t tl_xbar_main_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_uart0_o,
  input  tlul_pkg::tl_d2h_t tl_uart0_i,
  output tlul_pkg::tl_h2d_t tl_uart1_o,
  input  tlul_pkg::tl_d2h_t tl_uart1_i,
  output tlul_pkg::tl_h2d_t tl_spi0_o,
  input  tlul_pkg::tl_d2h_t tl_spi0_i,
  output tlul_pkg::tl_h2d_t tl_spi1_o,
  input  tlul_pkg::tl_d2h_t tl_spi1_i,
  output tlul_pkg::tl_h2d_t tl_spi2_o,
  input  tlul_pkg::tl_d2h_t tl_spi2_i,
  output tlul_pkg::tl_h2d_t tl_pwm_o,
  input  tlul_pkg::tl_d2h_t tl_pwm_i,
  output tlul_pkg::tl_h2d_t tl_gpio_o,
  input  tlul_pkg::tl_d2h_t tl_gpio_i,
  output tlul_pkg::tl_h2d_t tl_i2c0_o,
  input  tlul_pkg::tl_d2h_t tl_i2c0_i,
  output tlul_pkg::tl_h2d_t tl_i2c1_o,
  input  tlul_pkg::tl_d2h_t tl_i2c1_i,
  output tlul_pkg::tl_h2d_t tl_can0_o,
  input  tlul_pkg::tl_d2h_t tl_can0_i,
  output tlul_pkg::tl_h2d_t tl_can1_o,
  input  tlul_pkg::tl_d2h_t tl_can1_i,
  output tlul_pkg::tl_h2d_t tl_adc_o,
  input  tlul_pkg::tl_d2h_t tl_adc_i,
  output tlul_pkg::tl_h2d_t tl_qspi_o,
  input  tlul_pkg::tl_d2h_t tl_qspi_i,

  input scanmode_i
);

  import tlul_pkg::*;
  import tl_periph_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = scanmode_i;

  tl_h2d_t tl_s1n_14_us_h2d ;
  tl_d2h_t tl_s1n_14_us_d2h ;


  tl_h2d_t tl_s1n_14_ds_h2d [13];
  tl_d2h_t tl_s1n_14_ds_d2h [13];

  // Create steering signal
  logic [3:0] dev_sel_s1n_14;



  assign tl_uart0_o = tl_s1n_14_ds_h2d[0];
  assign tl_s1n_14_ds_d2h[0] = tl_uart0_i;

  assign tl_uart1_o = tl_s1n_14_ds_h2d[1];
  assign tl_s1n_14_ds_d2h[1] = tl_uart1_i;

  assign tl_spi0_o = tl_s1n_14_ds_h2d[2];
  assign tl_s1n_14_ds_d2h[2] = tl_spi0_i;

  assign tl_spi1_o = tl_s1n_14_ds_h2d[3];
  assign tl_s1n_14_ds_d2h[3] = tl_spi1_i;

  assign tl_spi2_o = tl_s1n_14_ds_h2d[4];
  assign tl_s1n_14_ds_d2h[4] = tl_spi2_i;

  assign tl_pwm_o = tl_s1n_14_ds_h2d[5];
  assign tl_s1n_14_ds_d2h[5] = tl_pwm_i;

  assign tl_gpio_o = tl_s1n_14_ds_h2d[6];
  assign tl_s1n_14_ds_d2h[6] = tl_gpio_i;

  assign tl_i2c0_o = tl_s1n_14_ds_h2d[7];
  assign tl_s1n_14_ds_d2h[7] = tl_i2c0_i;

  assign tl_i2c1_o = tl_s1n_14_ds_h2d[8];
  assign tl_s1n_14_ds_d2h[8] = tl_i2c1_i;

  assign tl_can0_o = tl_s1n_14_ds_h2d[9];
  assign tl_s1n_14_ds_d2h[9] = tl_can0_i;

  assign tl_can1_o = tl_s1n_14_ds_h2d[10];
  assign tl_s1n_14_ds_d2h[10] = tl_can1_i;

  assign tl_adc_o = tl_s1n_14_ds_h2d[11];
  assign tl_s1n_14_ds_d2h[11] = tl_adc_i;

  assign tl_qspi_o = tl_s1n_14_ds_h2d[12];
  assign tl_s1n_14_ds_d2h[12] = tl_qspi_i;

  assign tl_s1n_14_us_h2d = tl_xbar_main_i;
  assign tl_xbar_main_o = tl_s1n_14_us_d2h;

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_14 = 4'd13;
    if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_UART0)) == ADDR_SPACE_UART0) begin
      dev_sel_s1n_14 = 4'd0;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_UART1)) == ADDR_SPACE_UART1) begin
      dev_sel_s1n_14 = 4'd1;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_SPI0)) == ADDR_SPACE_SPI0) begin
      dev_sel_s1n_14 = 4'd2;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_SPI1)) == ADDR_SPACE_SPI1) begin
      dev_sel_s1n_14 = 4'd3;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_SPI2)) == ADDR_SPACE_SPI2) begin
      dev_sel_s1n_14 = 4'd4;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_PWM)) == ADDR_SPACE_PWM) begin
      dev_sel_s1n_14 = 4'd5;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_GPIO)) == ADDR_SPACE_GPIO) begin
      dev_sel_s1n_14 = 4'd6;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_I2C0)) == ADDR_SPACE_I2C0) begin
      dev_sel_s1n_14 = 4'd7;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_I2C1)) == ADDR_SPACE_I2C1) begin
      dev_sel_s1n_14 = 4'd8;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_CAN0)) == ADDR_SPACE_CAN0) begin
      dev_sel_s1n_14 = 4'd9;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_CAN1)) == ADDR_SPACE_CAN1) begin
      dev_sel_s1n_14 = 4'd10;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_ADC)) == ADDR_SPACE_ADC) begin
      dev_sel_s1n_14 = 4'd11;

    end else if ((tl_s1n_14_us_h2d.a_address & ~(ADDR_MASK_QSPI)) == ADDR_SPACE_QSPI) begin
      dev_sel_s1n_14 = 4'd12;
end
  end


  // Instantiation phase
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (52'h0),
    .DRspDepth (52'h0),
    .N         (13)
  ) u_s1n_14 (
    .clk_i        (clk_peri_i),
    .rst_ni       (rst_peri_ni),
    .tl_h_i       (tl_s1n_14_us_h2d),
    .tl_h_o       (tl_s1n_14_us_d2h),
    .tl_d_o       (tl_s1n_14_ds_h2d),
    .tl_d_i       (tl_s1n_14_ds_d2h),
    .dev_select_i (dev_sel_s1n_14)
  );

endmodule
