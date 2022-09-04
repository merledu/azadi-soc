// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Sajjad Ahmed <sajjad.ahmed3052@gmail.com>

module clk_rst_mngr (
  input logic clk_i,
  input logic sys_rst_ni,
  input logic por_ni,
  input logic ndm_rst_ni,
  input logic pll_lock_i,

  output logic clk_enb_o
);

  typedef enum logic [1:0] {IDLE, A_RESET, D_RESET} state_t;
  logic [15:0] clk_counter;
  logic        clk_enb;
  logic        count_enb;
  state_t      clk_cnt_state_c, clk_cnt_state_n;

  always_ff @(posedge clk_i or negedge por_ni) begin
    if(!por_ni) begin
      clk_counter     <= '0;
      clk_enb_o       <= '0;
      clk_cnt_state_n <= IDLE;
    end else if (pll_lock_i) begin
      clk_enb_o       <= clk_enb;
      clk_cnt_state_n <= clk_cnt_state_c;
      if(count_enb) begin
        clk_counter <= clk_counter + 16'd1;
      end else begin
        clk_counter <= '0;
      end
    end else begin
      clk_counter     <= '0;
      clk_enb_o       <= '0;
      clk_cnt_state_n <= IDLE;
    end
  end

  always_comb begin
    unique case (clk_cnt_state_n)
      IDLE: begin
        clk_enb   = 1'b1;
        count_enb = 1'b0;
        if(!sys_rst_ni) begin
          clk_cnt_state_c = A_RESET;
        end else begin
          clk_cnt_state_c = IDLE;
        end
      end

      A_RESET: begin
        clk_enb         = 1'b0;
        count_enb       = 1'b0;
        if(!sys_rst_ni) begin
          clk_cnt_state_c = A_RESET;
        end else begin
          clk_cnt_state_c = D_RESET;
        end
      end

      D_RESET: begin
        if(!sys_rst_ni) begin
          clk_cnt_state_c = A_RESET;
          clk_enb         = 1'b0;
          count_enb       = 1'b0;
        end else if(clk_counter != 16'd1000) begin
          clk_cnt_state_c = D_RESET;
          clk_enb         = 1'b0;
          count_enb       = 1'b1;
        end else begin
          clk_cnt_state_c = IDLE;
          clk_enb         = 1'b1;
          count_enb       = 1'b0;
        end
      end

      default: begin
        clk_cnt_state_c = IDLE;
        clk_enb         = 1'b1;
        count_enb       = 1'b0;
      end
    endcase
  end
endmodule : clk_rst_mngr
