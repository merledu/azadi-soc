// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified by MERL, for Azadi SoC

package tluh_xbar_main_pkg;

  // Main cross bar memory map
  localparam logic [31:0] ADDR_SPACE_QSPI   = 32'h80000000;
  localparam logic [31:0] ADDR_SPACE_ICCM   = 32'h10000000;
  localparam logic [31:0] ADDR_SPACE_DCCM   = 32'h20000000;
  localparam logic [31:0] ADDR_SPACE_TIMER0 = 32'h30000000;
  localparam logic [31:0] ADDR_SPACE_TIMER1 = 32'h30001000;
  localparam logic [31:0] ADDR_SPACE_TIMER2 = 32'h30002000;
  localparam logic [31:0] ADDR_SPACE_TIC    = 32'h30003000;
  localparam logic [31:0] ADDR_SPACE_PERIPH = 32'h40000000;
  localparam logic [31:0] ADDR_SPACE_PLIC   = 32'h50000000;
  localparam logic [31:0] ADDR_SPACE_ROM    = 32'h60000000;

  // Main cross bar memory map offset masks
  localparam logic [31:0] ADDR_MASK_QSPI    = 32'h00FFFFFF;
  localparam logic [31:0] ADDR_MASK_ICCM    = 32'h00007FFF;
  localparam logic [31:0] ADDR_MASK_DCCM    = 32'h0000FFFF;
  localparam logic [31:0] ADDR_MASK_TIMER0  = 32'h00000FFF;
  localparam logic [31:0] ADDR_MASK_TIMER1  = 32'h00000FFF;
  localparam logic [31:0] ADDR_MASK_TIMER2  = 32'h00000FFF;
  localparam logic [31:0] ADDR_MASK_TIC     = 32'h000000FF;
  localparam logic [31:0] ADDR_MASK_PERIPH  = 32'h0000FFFF;
  localparam logic [31:0] ADDR_MASK_PLIC    = 32'h00000FFF;
  localparam logic [31:0] ADDR_MASK_ROM     = 32'h000003FF;

endpackage
