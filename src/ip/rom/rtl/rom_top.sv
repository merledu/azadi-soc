// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Zeeshan Rafique <zeeshanrafique23@gmail.com>

module rom_top #(
  parameter ADDR = 8,
  parameter DW   = 32
)(
  input logic clk_i,
  input logic rst_ni,

  // tl-ul insterface
  input  tlul_pkg::tlul_h2d_t tl_d_i,
  output tlul_pkg::tlul_d2h_t tl_d_o
);

  logic tl_req;
  logic rvalid; // valid from device

  // ROM interface
  logic [ADDR-1:0] addr;
  logic [DW-1:0]   rdata;

  assign csb     = ~tl_req;

  tlul_sram_adapter #(
    .SramAw       (ADDR),
    .SramDw       (DW),
    .Outstanding  (2),
    .ByteAccess   (1),
    .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
    .ErrOnRead    (0)
  ) rom_tlul_adapter (
    .clk_i    (clk_i   ),
    .rst_ni   (rst_ni  ),
    .tl_i     (tl_d_i  ),
    .tl_o     (tl_d_o  ),
    .req_o    (tl_req  ),
    .gnt_i    (1'b1    ),
    .we_o     (),
    .addr_o   (addr    ),
    .wdata_o  (),
    .wmask_o  (),
    .rdata_i  (rdata   ),
    .rvalid_i (rvalid  ),
    .rerror_i (2'b0    )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid <= 1'b0;
    end else begin
      rvalid <= tl_req;
    end
  end

  // ARM ROM memory Model 1 KB
  rom #(
    .Width(DW),
    .Depth(ADDR)
    )u_rom(
    .clk_i	  ( clk_i ),
    .req_i    (tl_req),
    .rdata_o	( rdata ),
    .addr_i	  ( addr  )
  );
endmodule
