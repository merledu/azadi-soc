// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Zeeshan Rafique <zeeshanrafique23@gmail.com>

module rom #(
  parameter int unsigned WIDTH = 32,
  parameter int unsigned DEPTH = 8 // 1kB default
) (
  input  logic             clk_i,
  input  logic             req_i,
  input  logic [DEPTH-1:0] addr_i,
  output logic [WIDTH-1:0] rdata_o
);
  localparam Actual_Depth = 2**DEPTH;

  logic [WIDTH-1:0] mem [0:Actual_Depth-1];

  always_ff @(posedge clk_i) begin
    if (req_i) begin
      rdata_o <= mem[addr_i];
    end
  end
endmodule
