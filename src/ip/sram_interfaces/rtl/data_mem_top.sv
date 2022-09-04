// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module data_mem_top (
  input logic clk_i,
  input logic rst_ni,

  // tl-ul insterface
  input tlul_pkg::tlul_h2d_t tl_d_i,
  output tlul_pkg::tlul_d2h_t tl_d_o,

  // sram interface
  output  logic        csb,
  output  logic [12:0] addr_o,
  output  logic [31:0] wdata_o,
  output  logic [3:0]  wmask_o,
  output  logic        we_o,
  input   logic [31:0] rdata_i,

  // boot selection
  input   logic [31:0] boot_reg_i
);

  logic        tl_req;
  logic [31:0] tl_wmask;
  logic        we_i;
  logic        rvalid_o;

  // Boot Register Logic: Start //
  logic [31:0] boot_reg;
  logic [31:0] rdata;
  logic        read_boot_reg;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      boot_reg      <= '0;
      read_boot_reg <= '0;
    end else begin
      if (tl_d_i.a_address == 32'h20002000) begin
        read_boot_reg <= 1'b1;
      end else begin
        boot_reg      <= boot_reg_i;
        read_boot_reg <= 1'b0;
      end
    end
  end

  assign rdata = read_boot_reg ? boot_reg : rdata_i;
  // Boot Register Logic: End //

  assign wmask_o[0] = (tl_wmask[7:0]   != 8'b0) ? 1'b1: 1'b0;
  assign wmask_o[1] = (tl_wmask[15:8]  != 8'b0) ? 1'b1: 1'b0;
  assign wmask_o[2] = (tl_wmask[23:16] != 8'b0) ? 1'b1: 1'b0;
  assign wmask_o[3] = (tl_wmask[31:24] != 8'b0) ? 1'b1: 1'b0;

  assign we_o    = ~we_i;
  assign csb     = ~tl_req;

  tlul_sram_adapter #(
    .SramAw       (13),
    .SramDw       (32),
    .Outstanding  (2),
    .ByteAccess   (1),
    .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
    .ErrOnRead    (0)
  ) data_mem (
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .tl_i     (tl_d_i),
    .tl_o     (tl_d_o),
    .req_o    (tl_req),
    .gnt_i    (1'b1),
    .we_o     (we_i),
    .addr_o   (addr_o),
    .wdata_o  (wdata_o),
    .wmask_o  (tl_wmask),
    .rdata_i  (rdata),
    .rvalid_i (rvalid_o),
    .rerror_i (2'b0)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
    end else if (we_i) begin
      rvalid_o <= 1'b0;
    end else begin
      rvalid_o <= tl_req;
    end
  end

endmodule
