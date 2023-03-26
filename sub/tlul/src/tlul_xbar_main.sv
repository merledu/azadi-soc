// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified by MERL, for Azadi SoC

module tlul_xbar_main (

  input logic clk_i,
  input logic rst_ni,

  // Host interfaces
  input  tlul_pkg::tlul_h2d_t tl_ibex_ifu_i,
  output tlul_pkg::tlul_d2h_t tl_ibex_ifu_o,

  input  tlul_pkg::tlul_h2d_t tl_ibex_lsu_i,
  output tlul_pkg::tlul_d2h_t tl_ibex_lsu_o,

  // Device interfaces
  output tlul_pkg::tlul_h2d_t tl_qspi_o,
  input  tlul_pkg::tlul_d2h_t tl_qspi_i,

  output tlul_pkg::tlul_h2d_t tl_iccm_o,
  input  tlul_pkg::tlul_d2h_t tl_iccm_i,

  output tlul_pkg::tlul_h2d_t tl_dccm_o,
  input  tlul_pkg::tlul_d2h_t tl_dccm_i,

  output tlul_pkg::tlul_h2d_t tl_timer0_o,
  input  tlul_pkg::tlul_d2h_t tl_timer0_i,

  output tlul_pkg::tlul_h2d_t tl_timer1_o,
  input  tlul_pkg::tlul_d2h_t tl_timer1_i,

  output tlul_pkg::tlul_h2d_t tl_timer2_o,
  input  tlul_pkg::tlul_d2h_t tl_timer2_i,

  output tlul_pkg::tlul_h2d_t tl_tic_o,
  input  tlul_pkg::tlul_d2h_t tl_tic_i,

  output tlul_pkg::tlul_h2d_t tl_periph_o,
  input  tlul_pkg::tlul_d2h_t tl_periph_i,

  output tlul_pkg::tlul_h2d_t tl_plic_o,
  input  tlul_pkg::tlul_d2h_t tl_plic_i,

  output tlul_pkg::tlul_h2d_t tl_rom_o,
  input  tlul_pkg::tlul_d2h_t tl_rom_i
);

  import tlul_pkg::*;
  import tlul_xbar_main_pkg::*;

  // Host IFU
  tlul_pkg::tlul_h2d_t h0_dv_o[3];
  tlul_pkg::tlul_d2h_t h0_dv_i[3];
  tlul_pkg::tlul_h2d_t ibexifu_to_s1n;
  tlul_pkg::tlul_d2h_t s1n_to_ibexifu;
  logic [1:0]          device_sel_ifu;

  // Host LSU
  tlul_pkg::tlul_h2d_t h1_dv_o[7];
  tlul_pkg::tlul_d2h_t h1_dv_i[7];
  tlul_pkg::tlul_h2d_t ibexlsu_to_s1n;
  tlul_pkg::tlul_d2h_t s1n_to_ibexlsu;
  logic [2:0]          device_sel_lsu;

  assign ibexifu_to_s1n = tl_ibex_ifu_i;
  assign tl_ibex_ifu_o  = s1n_to_ibexifu;

  assign ibexlsu_to_s1n = tl_ibex_lsu_i;
  assign tl_ibex_lsu_o  = s1n_to_ibexlsu;
  
  // IFU devices connections
  assign tl_rom_o  = h0_dv_o[0];
  assign h0_dv_i[0] = tl_rom_i;

  assign tl_qspi_o  = h0_dv_o[1];
  assign h0_dv_i[1] = tl_qspi_i;

  assign tl_iccm_o  = h0_dv_o[2];
  assign h0_dv_i[2] = tl_iccm_i;

  // LSU devices connections
  assign tl_dccm_o   = h1_dv_o[0];
  assign h1_dv_i[0]  = tl_dccm_i;

  assign tl_timer0_o = h1_dv_o[1];
  assign h1_dv_i[1]  = tl_timer0_i;

  assign tl_timer1_o = h1_dv_o[2];
  assign h1_dv_i[2]  = tl_timer1_i;

  assign tl_timer2_o = h1_dv_o[3];
  assign h1_dv_i[3]  = tl_timer2_i;

  assign tl_tic_o    = h1_dv_o[4];
  assign h1_dv_i[4]  = tl_tic_i;

  assign tl_plic_o  = h1_dv_o[5];
  assign h1_dv_i[5] = tl_plic_i;

  assign tl_periph_o  = h1_dv_o[6];
  assign h1_dv_i[6]   = tl_periph_i;

  // host ifu socket
  always_comb begin 
    device_sel_ifu = 2'd3;

    if ((ibexifu_to_s1n.a_address & ~(ADDR_MASK_ROM)) == ADDR_SPACE_ROM) begin
      device_sel_ifu = 2'd0;
    end else
    if ((ibexifu_to_s1n.a_address & ~(ADDR_MASK_QSPI)) == ADDR_SPACE_QSPI) begin
      device_sel_ifu = 2'd1; 
    end else 
    if ((ibexifu_to_s1n.a_address & ~(ADDR_MASK_ICCM)) == ADDR_SPACE_ICCM) begin
      device_sel_ifu = 2'd2;
    end
  end

  // host lsu socket
  always_comb begin 
    device_sel_lsu = 3'd7;

    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
      device_sel_lsu = 3'd0;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER0)) == ADDR_SPACE_TIMER0) begin
      device_sel_lsu = 3'd1;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER1)) == ADDR_SPACE_TIMER1) begin
      device_sel_lsu = 3'd2;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER2)) == ADDR_SPACE_TIMER2) begin
      device_sel_lsu = 3'd3;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_TIC)) == ADDR_SPACE_TIC) begin
      device_sel_lsu = 3'd4;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_PLIC)) == ADDR_SPACE_PLIC) begin
      device_sel_lsu = 3'd5;
    end else
    if ((ibexlsu_to_s1n.a_address & ~(ADDR_MASK_PERIPH)) == ADDR_SPACE_PERIPH) begin
      device_sel_lsu = 3'd6;
    end
  end

  // host 2 socket
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (3)
  ) host_ifu (
    .clk_i        ( clk_i          ),
    .rst_ni       ( rst_ni         ),
    .tl_h_i       ( ibexifu_to_s1n ),
    .tl_h_o       ( s1n_to_ibexifu ),
    .tl_d_o       ( h0_dv_o        ),
    .tl_d_i       ( h0_dv_i        ),
    .dev_select_i ( device_sel_ifu )
  );

  // host 2 socket
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (7)
  ) host_lsu (
    .clk_i        ( clk_i          ),
    .rst_ni       ( rst_ni         ),
    .tl_h_i       ( ibexlsu_to_s1n ),
    .tl_h_o       ( s1n_to_ibexlsu ),
    .tl_d_o       ( h1_dv_o        ),
    .tl_d_i       ( h1_dv_i        ),
    .dev_select_i ( device_sel_lsu )
  );

endmodule
