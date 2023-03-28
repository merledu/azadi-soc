// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Sajjad Ahmed <sajjad.ahmed3052@gmail.com>

module qspi_top(
  input logic                 clk_i,
  input logic                 rst_ni,
  input logic                 por_ni,

  input  tlul_pkg::tlul_h2d_t tl_i,
  output tlul_pkg::tlul_d2h_t tl_o,

  input  logic [31:0]         wdata_i,
  input  logic                we_i,

  input  logic [3:0]          qspi_i,
  output logic [3:0]          qspi_o,
  output logic [3:0]          qspi_oe,
  output logic                qspi_csb,
  output logic                qspi_clk
);

  logic [23:0] addr;
  logic        req;
  logic [31:0] data;
  logic        valid;
  logic        we;
  logic        gnt;
  logic        trig;  
  logic        gnt_sync;

  qspi_xip u_qspi(
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .por_ni   (por_ni),
    .addr_i   ((addr <<2)),
    .req_i    (req),
    .rdata_o  (data),
    .rvalid_o (valid),
    .wdata_i  (wdata_i),
    .we_i     (we_i),
    .qspi_i   (qspi_i),
    .qspi_o   (qspi_o),
    .qspi_oe  (qspi_oe),
    .qspi_csb (qspi_csb),
    .qspi_clk (qspi_clk)
  );

  tlul_sram_adapter #(
    .SramAw       (24),
    .SramDw       (32), 
    .Outstanding  (2),  
    .ByteAccess   (1),
    .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
    .ErrOnRead    (0)   // 1: Reads not allowed, automatically error  

  ) qspi_tl_intf (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .tl_i      (tl_i),
    .tl_o      (tl_o), 
    .req_o     (req),
    .gnt_i     (gnt),
    .we_o      (),
    .addr_o    (addr),
    .wdata_o   (),
    .wmask_o   (),
    .rdata_i   (data),
    .rvalid_i  (valid),
    .rerror_i  (2'b0)
  );

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      gnt <= 1'b0;
      gnt_sync <= 1'b0;
      trig <= 1'b0;
    end else begin
      if (req && !gnt && !trig) begin
        gnt_sync <= 1'b1;
        gnt <= gnt_sync;
        trig <= 1'b1;
      end else if (valid) begin
        trig <= 1'b0;
      end else begin
        gnt_sync <= 1'b0;
        gnt <= gnt_sync;
      end
    end
  end
endmodule
