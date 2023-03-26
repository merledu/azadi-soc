// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designer  : Zeeshan Rafique <zeeshanrafique23@gmail.com>
// Date,Time : 02/08/2022, 04:50 AM

module azadi_pin_top #(
  // We are using 64 pin IC package
  localparam int unsigned MAIN_IO_PORTS = 64 -10 // last 10 IOs are PWR/GND
)(
  input  logic [MAIN_IO_PORTS-1:0] io_in_i,
  output logic [MAIN_IO_PORTS-1:0] io_out_o,
  // both are active low signals
  output logic [MAIN_IO_PORTS-1:0] io_oeb_o,
  output logic [MAIN_IO_PORTS-1:0] io_ren_o
`ifdef SIM
  ,output logic clk_enb
`endif
);

  ////////////////////////////////
  // Local Parameters
  ////////////////////////////////
  localparam int unsigned GPIO = 24;
  localparam int unsigned UART = 4;
  localparam int unsigned SPI  = 4;
  localparam int unsigned PWM = 4;
  localparam int unsigned PWM_CH =2;
  localparam int unsigned IO_PORTS = 24;

  ////////////////////////////////
  // Local Signals
  ////////////////////////////////
  logic             [GPIO-1:0] gpio_in;
  logic             [GPIO-1:0] gpio_out;
  logic             [GPIO-1:0] gpio_oe;
  logic             [UART-1:0] uart_tx;
  logic             [UART-1:0] uart_rx;
  logic             [UART-1:0] uart_oe;
  logic             [SPI-1:0]  spi_sck;
  logic             [SPI-1:0]  spi_ssb;
  logic             [SPI-1:0]  spi_tdo;
  logic             [SPI-1:0]  spi_tdi;
  logic             [SPI-1:0]  spi_oeb;
  logic [PWM_CH-1:0][PWM-1:0]  pwm_o;
  logic [PWM_CH-1:0][PWM-1:0]  pwm_oe;

  // IOs to Pin Mux
  logic        [IO_PORTS-1:0] io_in;
  logic        [IO_PORTS-1:0] io_out;
  logic        [IO_PORTS-1:0] io_oeb;

  // House keeping SPI (Slave)
  logic       spi_sck_s;
  logic       spi_ssb_s;
  logic       spi_tdo_s;
  logic       spi_tdi_s;

  // QSPI Flash
  logic [3:0] qspi_i;
  logic [3:0] qspi_o;
  logic [3:0] qspi_oe;
  logic       qspi_csb;
  logic       qspi_clk;

  // Main Clock
  logic clk_i;
  // Main Reset
  logic rst_ni;
  // PLL lock
  logic pll_lock;
  // switch to toggle r/w program between QSPI or ICCM
  logic boot_sel0;
  logic boot_sel1;
  // led-alive from Boot ROM
  logic led_alive;

  ////////////////////////////////
  // Azadi System on Chip Top
  ////////////////////////////////
  azadi_soc_top azadi_soc_top_u (
  `ifdef USE_POWER_PINS
    .vccd1( vccd1 ),
    .vssd1( vssd1 ),
  `endif
    .clk_main_i ( clk_i     ),
    .rst_ni     ( rst_ni    ),
    .boot_sel0_i( boot_sel0 ),
    .boot_sel1_i( boot_sel1 ),
    .pll_lock_i ( pll_lock  ),
    .led_alive_o( led_alive ),
    // House keeping SPI
    .hk_sck_i   ( spi_sck_s ),
    .hk_sdi_i   ( spi_tdi_s ),
    .hk_csb_i   ( spi_ssb_s ),
    .hk_sdo_o   ( spi_tdo_s ),
    // GPIO interface
    .gpio_in_i  ( gpio_in   ),
    .gpio_out_o ( gpio_out  ),
    .gpio_oe_o  ( gpio_oe   ),
    // uart-periph interface
    .uart_tx_o  ( uart_tx   ),
    .uart_oe_o  ( uart_oe   ),
    .uart_rx_i  ( uart_rx   ),
    // SPI interface
    .ss_o       ( spi_ssb   ),
    .sclk_o     ( spi_sck   ),
    .sd_o       ( spi_tdo   ),
    .sd_oe_o    ( spi_oeb   ),
    .sd_i       ( spi_tdi   ),
    // PWM interface
    .pwm1_o     ( pwm_o[0]  ),
    .pwm2_o     ( pwm_o[1]  ),
    .pwm1_oe_o  ( pwm_oe[0] ),
    .pwm2_oe_o  ( pwm_oe[1] ),
    // QSPI interface
    .qspi_sdi_i ( qspi_i    ),
    .qspi_sdo_o ( qspi_o    ),
    .qspi_oe_o  ( qspi_oe   ),
    .qspi_csb_o ( qspi_csb  ),
    .qspi_clk_o ( qspi_clk  )
    `ifdef SIM
    ,.clk_enb_o ( clk_enb  )
    `endif
  );

  //////////////////////////////////////////////
  // IO [23:0] are handled in pin_mux module
  //////////////////////////////////////////////
  pin_mux #(
    // available GPIO pins to mux
    .GPIO   (24),
    // peripherals to mux with GPIO pins
    .UART   (1),
    .SPI    (2),
    .PWM    (4),
    .PWM_CH (2)
  ) pin_mux_u (
    .gpio_in_o  ( gpio_in      ),
    .gpio_out_i ( gpio_out     ),
    .gpio_oe_i  ( gpio_oe      ),
    .uart_tx_i  ( uart_tx[0]   ),
    .uart_rx_o  ( uart_rx[0]   ),
    .uart_oe_i  ( uart_oe[0]   ),
    .spi_sck_i  ( spi_sck[1:0] ),
    .spi_ssb_i  ( spi_ssb[1:0] ),
    .spi_tdo_i  ( spi_tdo[1:0] ),
    .spi_tdi_o  ( spi_tdi[1:0] ),
    .spi_oeb_i  ( spi_oeb[1:0] ),
    .pwm_o_i    ( pwm_o        ),
    .pwm_oe_i   ( pwm_oe       ),
    .io_in_i    ( io_in        ),
    .io_out_o   ( io_out       ),
    .io_oe_o    ( io_oe        )
  );

  // Dedicated IOs
  always_comb begin
    io_ren_o = '0; // Setting REN signal to have tie-low in synth

    ///////////////////////////////
    // Ouput enable is active low
    ///////////////////////////////

    // Dedicated IOs
    io_out_o[23:0] = io_out;
    io_oeb_o[23:0] = ~io_oe;
    io_in          = io_in_i[23:0];

    // IO[27:24] : House keeping SPI
    io_out_o[24] = spi_tdo_s;
    io_oeb_o[24] = 0;

    io_out_o[25] = 0;
    io_oeb_o[25] = 1;
    spi_tdi_s    = io_in_i[25];

    io_out_o[26] = 0;
    io_oeb_o[26] = 1;
    spi_sck_s    = io_in_i[26];

    io_out_o[27] = 0;
    io_oeb_o[27] = 1;
    spi_ssb_s    = io_in_i[27];

    // IO[29:28] : UART 3 - FTDI
    io_out_o[28]   = uart_tx[3];
    io_oeb_o[28]   = ~uart_oe[3];

    io_out_o[29] = 0;
    io_oeb_o[29] = 1;
    uart_rx[3]   = io_in_i[29];

    // IO[31:30] : UART 1
    io_out_o[30]   = uart_tx[1];
    io_oeb_o[30]   = ~uart_oe[1];

    io_out_o[31] = 0;
    io_oeb_o[31] = 1;
    uart_rx[1]   = io_in_i[31];

    // IO[33:32] : UART 2
    io_out_o[32] = uart_tx[2];
    io_oeb_o[32] = ~uart_oe[2];

    io_out_o[33] = 0;
    io_oeb_o[33] = 1;
    uart_rx[2]   = io_in_i[33];

    // IO[37:34] : SPI 2
    io_out_o[34] = spi_tdo[2];
    io_oeb_o[34] = spi_oeb[2];

    io_out_o[35] = 0;
    io_oeb_o[35] = 1;
    spi_tdi[2]   = io_in_i[35];

    io_out_o[36] = spi_sck[2];
    io_oeb_o[36] = 1;

    io_out_o[37] = ~spi_ssb[2];
    io_oeb_o[37] = 0;

    // IO[41:38] : SPI 3
    io_out_o[38] = spi_tdo[3];
    io_oeb_o[38] = spi_oeb[3];

    io_out_o[39] = 0;
    io_oeb_o[39] = 1;
    spi_tdi[3]   = io_in_i[39];

    io_out_o[40] = spi_sck[3];
    io_oeb_o[40] = 1;

    io_out_o[41] = ~spi_ssb[3];
    io_oeb_o[41] = 0;

    // IO[47:42] : QSPI
    io_out_o[42] = qspi_clk;
    io_oeb_o[42] = 0;

    io_out_o[43] = qspi_csb;
    io_oeb_o[43] = 0;

    qspi_i[0]    = io_in_i[44];
    io_out_o[44] = qspi_o[0];
    io_oeb_o[44] = qspi_oe[0];

    qspi_i[1]    = io_in_i[45];
    io_out_o[45] = qspi_o[1];
    io_oeb_o[45] = qspi_oe[1];

    qspi_i[2]    = io_in_i[46];
    io_out_o[46] = qspi_o[2];
    io_oeb_o[46] = qspi_oe[2];

    qspi_i[3]    = io_in_i[47];
    io_out_o[47] = qspi_o[3];
    io_oeb_o[47] = qspi_oe[3];

    // IO[48] : LED alive (tells program is written successfully)
    io_out_o[48] = led_alive;
    io_oeb_o[48] = 0;

    // IO[49] : Boot select
    boot_sel1    = io_in_i[49];
    io_out_o[49] = 0;
    io_oeb_o[49] = 1;

    // IO[50] : Reset
    rst_ni       = ~io_in_i[50];
    io_out_o[50] = 0;
    io_oeb_o[50] = 1;

    // IO[51] : Clock
    clk_i        = io_in_i[51];
    io_out_o[51] = 0;
    io_oeb_o[51] = 1;

    // IO[52] : PLL lock
    pll_lock     = io_in_i[52];
    io_out_o[52] = 0;
    io_oeb_o[52] = 1;

    // IO[53] : Power on Reset
    boot_sel0    = ~io_in_i[53];
    io_out_o[53] = 0;
    io_oeb_o[53] = 1;

  end

endmodule : azadi_pin_top
