// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designer  : Zeeshan Rafique <zeeshanrafique23@gmail.com>
// Date,Time : 02/08/2022, 02:00 AM

module azadi_pin_mux #(
  // available GPIO pins to mux
  parameter int unsigned GPIO   = 24,
  // peripherals to mux with GPIO pins
  parameter int unsigned UART   = 1,
  parameter int unsigned SPI    = 1,
  parameter int unsigned PWM    = 4,
  parameter int unsigned PWM_CH = 2,

  // do not change this
  localparam int unsigned IO_PORTS = GPIO
) (
  // Peripheral/SoC interface IOs
  output logic            [GPIO-1:0] gpio_in_o,
  input  logic            [GPIO-1:0] gpio_out_i,
  input  logic            [GPIO-1:0] gpio_oe_i,

  input  logic            [UART-1:0] uart_tx_i,
  output logic            [UART-1:0] uart_rx_o,
  input  logic            [UART-1:0] uart_oe_i,

  input  logic             [SPI-1:0] spi_sck_i,
  input  logic             [SPI-1:0] spi_ssb_i,
  input  logic             [SPI-1:0] spi_tdo_i,
  output logic             [SPI-1:0] spi_tdi_o,
  input  logic             [SPI-1:0] spi_oeb_i,

  input  logic [PWM-1:0][PWM_CH-1:0] pwm_o_i,
  input  logic [PWM-1:0][PWM_CH-1:0] pwm_oe_i,

  // Chip side IOs
  input  logic        [IO_PORTS-1:0] io_in_i,
  output logic        [IO_PORTS-1:0] io_out_o,
  output logic        [IO_PORTS-1:0] io_oe_o
);

  ////////////////////////////
  //        Pin Mux
  ////////////////////////////

  always_comb begin : pin_mux_logic
    // IO[1:0] : UART 0
    // RX
    gpio_in_o[0] = io_in_i[0];
    uart_rx_o[0] = io_in_i[0];
    io_oe_o[0]   = gpio_oe_i[0]; // output enable
    io_out_o[0]  = gpio_oe_i[0] ? gpio_out_i[0] : 0; // output mux

    // TX
    gpio_in_o[1] = io_in_i[1];
    io_oe_o[1]   = gpio_oe_i[1] | uart_oe_i[0]; // output enable
    io_out_o[1]  = uart_oe_i[0] ? uart_tx_i[0] : gpio_oe_i[1] ? gpio_out_i[1] : 0; // output mux

    // IO[5:2] : SPI 0
    // TDO
    gpio_in_o[2] = io_in_i[2];
    io_oe_o[2]   = gpio_oe_i[2] | spi_oeb_i[0]; // output enable
    io_out_o[2]  = spi_oeb_i[0] ? spi_tdo_i[0] : gpio_oe_i[2] ? gpio_out_i[2] : 0; // output mux

    // TDI
    gpio_in_o[3] = io_in_i[3];
    spi_tdi_o[0] = io_in_i[3];
    io_oe_o[3]   = gpio_oe_i[3]; // output enable
    io_out_o[3]  = gpio_oe_i[3] ? gpio_out_i[3] : 0; // output mux

    // SCK
    gpio_in_o[4] = io_in_i[4];
    io_oe_o[4]   = gpio_oe_i[4] | spi_oeb_i[0]; // output enable
    io_out_o[4]  = spi_oeb_i[0] ? spi_sck_i[0] : gpio_oe_i[4] ? gpio_out_i[4] : 0; // output mux

    // SS
    gpio_in_o[5] = io_in_i[5];
    io_oe_o[5]   = gpio_oe_i[5] | spi_oeb_i[0]; // output enable
    io_out_o[5]  = spi_oeb_i[0] ? spi_ssb_i[0] : gpio_oe_i[5] ? gpio_out_i[5] : 0; // output mux

    // IO[9:6] : SPI 1
    // TDO
    gpio_in_o[6] = io_in_i[6];
    io_oe_o[6]   = gpio_oe_i[6] | spi_oeb_i[1]; // output enable
    io_out_o[6]  = spi_oeb_i[1] ? spi_tdo_i[1] : gpio_oe_i[6] ? gpio_out_i[6] : 0; // output mux

    // TDI
    gpio_in_o[7] = io_in_i[7];
    spi_tdi_o[1] = io_in_i[7];
    io_oe_o[7]   = gpio_oe_i[7]; // output enable
    io_out_o[7]  = gpio_oe_i[7] ? gpio_out_i[7] : 0; // output mux

    // SCK
    gpio_in_o[8] = io_in_i[8];
    io_oe_o[8]   = gpio_oe_i[8] | spi_oeb_i[1]; // output enable
    io_out_o[8]  = spi_oeb_i[1] ? spi_sck_i[1] : gpio_oe_i[8] ? gpio_out_i[8] : 0; // output mux

    // SS
    gpio_in_o[9] = io_in_i[9];
    io_oe_o[9]   = gpio_oe_i[9] | spi_oeb_i[1]; // output enable
    io_out_o[9]  = spi_oeb_i[1] ? spi_ssb_i[1] : gpio_oe_i[9] ? gpio_out_i[9] : 0; // output mux

    // IO[10] : PWM 0 - CH 0
    gpio_in_o[10] = io_in_i[10];
    io_oe_o[10]   = gpio_oe_i[10] | pwm_oe_i[0][0]; // output enable
    io_out_o[10]  = pwm_oe_i[0][0] ? pwm_o_i[0][0] : gpio_oe_i[10] ? gpio_out_i[10] : 0; // output mux

    // IO[11] : PWM 0 - CH 1
    gpio_in_o[11] = io_in_i[11];
    io_oe_o[11]   = gpio_oe_i[11] | pwm_oe_i[0][1]; // output enable
    io_out_o[11]  = pwm_oe_i[0][1] ? pwm_o_i[0][1] : gpio_oe_i[11] ? gpio_out_i[11] : 0; // output mux

    // IO[12] : PWM 1 - CH 0
    gpio_in_o[12] = io_in_i[12];
    io_oe_o[12]   = gpio_oe_i[12] | pwm_oe_i[1][0]; // output enable
    io_out_o[12]  = pwm_oe_i[1][0] ? pwm_o_i[1][0] : gpio_oe_i[12] ? gpio_out_i[12] : 0; // output mux

    // IO[13] : PWM 1 - CH 1
    gpio_in_o[13] = io_in_i[13];
    io_oe_o[13]   = gpio_oe_i[13] | pwm_oe_i[1][1]; // output enable
    io_out_o[13]  = pwm_oe_i[1][1] ? pwm_o_i[1][1] : gpio_oe_i[13] ? gpio_out_i[13] : 0; // output mux

    // IO[14] : PWM 2 - CH 0
    gpio_in_o[14] = io_in_i[14];
    io_oe_o[14]   = gpio_oe_i[14] | pwm_oe_i[2][0]; // output enable
    io_out_o[14]  = pwm_oe_i[2][0] ? pwm_o_i[2][0] : gpio_oe_i[14] ? gpio_out_i[14] : 0; // output mux

    // IO[15] : PWM 2 - CH 1
    gpio_in_o[15] = io_in_i[15];
    io_oe_o[15]   = gpio_oe_i[15] | pwm_oe_i[2][1]; // output enable
    io_out_o[15]  = pwm_oe_i[2][1] ? pwm_o_i[2][1] : gpio_oe_i[15] ? gpio_out_i[15] : 0; // output mux

    // IO[16] : PWM 3 - CH 0
    gpio_in_o[16] = io_in_i[16];
    io_oe_o[16]   = gpio_oe_i[16] | pwm_oe_i[3][0]; // output enable
    io_out_o[16]  = pwm_oe_i[3][0] ? pwm_o_i[3][0] : gpio_oe_i[16] ? gpio_out_i[16] : 0; // output mux

    // IO[17] : PWM 3 - CH 1
    gpio_in_o[17] = io_in_i[17];
    io_oe_o[17]   = gpio_oe_i[17] | pwm_oe_i[3][1]; // output enable
    io_out_o[17]  = pwm_oe_i[3][1] ? pwm_o_i[3][1] : gpio_oe_i[17] ? gpio_out_i[17] : 0; // output mux

    // IO[IO_PORTS-1:18] : Dedicated
    gpio_in_o[IO_PORTS-1:18] = io_in_i[IO_PORTS-1:18];
    io_oe_o[IO_PORTS-1:18]   = gpio_oe_i[IO_PORTS-1:18]; // output enable
    io_out_o[IO_PORTS-1:18]  = gpio_oe_i[IO_PORTS-1:18] ? gpio_out_i[IO_PORTS-1:18] : 0; // output mux

  end : pin_mux_logic

endmodule : azadi_pin_mux 
