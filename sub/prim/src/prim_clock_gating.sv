// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Common Library: Clock Gating cell

module prim_clock_gating (
  input  logic clk_i,
  input  logic en_i,
  input  logic test_en_i,
  output logic clk_o
);

`ifdef SIM
  // Assume en_i synchronized, if not put synchronizer prior to en_i
  logic en_latch;
  always_latch begin
    if (!clk_i) begin
      en_latch = en_i | test_en_i;
    end
  end
  assign clk_o = en_latch & clk_i;
`elsif SKY130
  sky130_fd_sc_hd__dlclkp_1 CG( .CLK(clk_i), .GCLK(clk_o), .GATE(en_i | test_en_i));
`else
  logic delay_clk;

  FRICG_X7P5B_A12TL clock_delay( .ECK(delay_clk), .CK(clk_i) );
  PREICG_X1P4B_A12TL clock_gate(.ECK(clk_o), .CK(delay_clk), .E(en_i), .SE(test_en_i));
`endif

endmodule
