// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified by MERL, for Azadi SoC

module tlul_xbar_periph (

  input logic clk_i,
  input logic rst_ni,

  // Host interfaces
  input  tlul_pkg::tlul_h2d_t tl_periph_i,
  output tlul_pkg::tlul_d2h_t tl_periph_o,

  // Device interfaces
  output tlul_pkg::tlul_h2d_t tl_gpio_o,
  input  tlul_pkg::tlul_d2h_t tl_gpio_i,

  output tlul_pkg::tlul_h2d_t tl_uart0_o,
  input  tlul_pkg::tlul_d2h_t tl_uart0_i,

  output tlul_pkg::tlul_h2d_t tl_uart1_o,
  input  tlul_pkg::tlul_d2h_t tl_uart1_i,

  output tlul_pkg::tlul_h2d_t tl_uart2_o,
  input  tlul_pkg::tlul_d2h_t tl_uart2_i,

  output tlul_pkg::tlul_h2d_t tl_uart3_o,
  input  tlul_pkg::tlul_d2h_t tl_uart3_i,

  output tlul_pkg::tlul_h2d_t tl_spi0_o,
  input  tlul_pkg::tlul_d2h_t tl_spi0_i,

  output tlul_pkg::tlul_h2d_t tl_spi1_o,
  input  tlul_pkg::tlul_d2h_t tl_spi1_i,

  output tlul_pkg::tlul_h2d_t tl_spi2_o,
  input  tlul_pkg::tlul_d2h_t tl_spi2_i,

  output tlul_pkg::tlul_h2d_t tl_spi3_o,
  input  tlul_pkg::tlul_d2h_t tl_spi3_i,

  output tlul_pkg::tlul_h2d_t tl_pwm0_o,
  input  tlul_pkg::tlul_d2h_t tl_pwm0_i,

  output tlul_pkg::tlul_h2d_t tl_pwm1_o,
  input  tlul_pkg::tlul_d2h_t tl_pwm1_i,

  output tlul_pkg::tlul_h2d_t tl_pwm2_o,
  input  tlul_pkg::tlul_d2h_t tl_pwm2_i,

  output tlul_pkg::tlul_h2d_t tl_pwm3_o,
  input  tlul_pkg::tlul_d2h_t tl_pwm3_i
);

  import tlul_pkg::*;
  import tlul_xbar_periph_pkg::*;

  // Host IFU
  tlul_pkg::tlul_h2d_t h0_dv_o[13];
  tlul_pkg::tlul_d2h_t h0_dv_i[13];
  tlul_pkg::tlul_h2d_t xbar_main_to_s1n;
  tlul_pkg::tlul_d2h_t s1n_to_xbar_main;
  logic [3:0]          device_sel_xbar_main;

  assign xbar_main_to_s1n = tl_periph_i;
  assign tl_periph_o      = s1n_to_xbar_main;
  
  // Devices connections
  assign tl_gpio_o  = h0_dv_o[0];
  assign h0_dv_i[0] = tl_gpio_i;

  assign tl_uart0_o  = h0_dv_o[1];
  assign h0_dv_i[1] = tl_uart0_i;

  assign tl_uart1_o  = h0_dv_o[2];
  assign h0_dv_i[2] = tl_uart1_i;

  assign tl_uart2_o  = h0_dv_o[3];
  assign h0_dv_i[3] = tl_uart2_i;

  assign tl_uart3_o  = h0_dv_o[4];
  assign h0_dv_i[4] = tl_uart3_i;

  assign tl_spi0_o  = h0_dv_o[5];
  assign h0_dv_i[5] = tl_spi0_i;

  assign tl_spi1_o  = h0_dv_o[6];
  assign h0_dv_i[6] = tl_spi1_i;

  assign tl_spi2_o  = h0_dv_o[7];
  assign h0_dv_i[7] = tl_spi2_i;

  assign tl_spi3_o  = h0_dv_o[8];
  assign h0_dv_i[8] = tl_spi3_i;

  assign tl_pwm0_o  = h0_dv_o[9];
  assign h0_dv_i[9] = tl_pwm0_i;

  assign tl_pwm1_o  = h0_dv_o[10];
  assign h0_dv_i[10] = tl_pwm1_i;

  assign tl_pwm2_o  = h0_dv_o[11];
  assign h0_dv_i[11] = tl_pwm2_i;

  assign tl_pwm3_o  = h0_dv_o[12];
  assign h0_dv_i[12] = tl_pwm3_i;

  // host xbar main (periph) socket
  always_comb begin 
    device_sel_xbar_main = 4'd13;

    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_GPIO)) == ADDR_SPACE_GPIO) begin
      device_sel_xbar_main = 4'd0; 
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_UART0)) == ADDR_SPACE_UART0) begin
      device_sel_xbar_main = 4'd1;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_UART1)) == ADDR_SPACE_UART1) begin
      device_sel_xbar_main = 4'd2;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_UART2)) == ADDR_SPACE_UART2) begin
      device_sel_xbar_main = 4'd3;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_UART3)) == ADDR_SPACE_UART3) begin
      device_sel_xbar_main = 4'd4;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_SPI0)) == ADDR_SPACE_SPI0) begin
      device_sel_xbar_main = 4'd5;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_SPI1)) == ADDR_SPACE_SPI1) begin
      device_sel_xbar_main = 4'd6;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_SPI2)) == ADDR_SPACE_SPI2) begin
      device_sel_xbar_main = 4'd7;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_SPI3)) == ADDR_SPACE_SPI3) begin
      device_sel_xbar_main = 4'd8;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_PWM0)) == ADDR_SPACE_PWM0) begin
      device_sel_xbar_main = 4'd9;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_PWM1)) == ADDR_SPACE_PWM1) begin
      device_sel_xbar_main = 4'd10;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_PWM2)) == ADDR_SPACE_PWM2) begin
      device_sel_xbar_main = 4'd11;
    end else 
    if ((xbar_main_to_s1n.a_address & ~(ADDR_MASK_PWM3)) == ADDR_SPACE_PWM3) begin
      device_sel_xbar_main = 4'd12;
    end
  end

  // host 2 socket
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (13)
  ) host_periph (
    .clk_i        ( clk_i                ),
    .rst_ni       ( rst_ni               ),
    .tl_h_i       ( xbar_main_to_s1n     ),
    .tl_h_o       ( s1n_to_xbar_main     ),
    .tl_d_o       ( h0_dv_o              ),
    .tl_d_i       ( h0_dv_i              ),
    .dev_select_i ( device_sel_xbar_main )
  );

endmodule
