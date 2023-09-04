// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified by MERL, for Azadi SoC

package tluh_xbar_periph_pkg;

  // Peripheral cross bar memory map
  localparam logic [31:0] ADDR_SPACE_GPIO     = 32'h40001000;
  localparam logic [31:0] ADDR_SPACE_UART0    = 32'h40002000;
  localparam logic [31:0] ADDR_SPACE_UART1    = 32'h40002100;
  localparam logic [31:0] ADDR_SPACE_UART2    = 32'h40002200;
  localparam logic [31:0] ADDR_SPACE_UART3    = 32'h40002300;
  localparam logic [31:0] ADDR_SPACE_SPI0     = 32'h40003000;
  localparam logic [31:0] ADDR_SPACE_SPI1     = 32'h40003100;
  localparam logic [31:0] ADDR_SPACE_SPI2     = 32'h40003200;
  localparam logic [31:0] ADDR_SPACE_SPI3     = 32'h40003300;
  localparam logic [31:0] ADDR_SPACE_PWM0     = 32'h40004000;
  localparam logic [31:0] ADDR_SPACE_PWM1     = 32'h40004100;
  localparam logic [31:0] ADDR_SPACE_PWM2     = 32'h40004200;
  localparam logic [31:0] ADDR_SPACE_PWM3     = 32'h40004300;

  // Peripheral cross bar memory map offset masks
  localparam logic [31:0] ADDR_MASK_GPIO     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_UART0    = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_UART1    = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_UART2    = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_UART3    = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_SPI0     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_SPI1     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_SPI2     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_SPI3     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_PWM0     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_PWM1     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_PWM2     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_PWM3     = 32'h000000FF;

endpackage
