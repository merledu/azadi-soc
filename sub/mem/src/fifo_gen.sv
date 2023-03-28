// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Sajjad Ahmed <sajjad.ahmed3052@gmail.com>

module fifo_gen #(
  parameter FIFO32 = 1,
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = FIFO32 ? 7: 6
)(
  input  logic                  clk_i,
  input  logic                  rst_ni,

  input  logic                  rd_i,
  input  logic                  wr_i,
  input  logic                  clr_i,
  input  logic [DATA_WIDTH-1:0] wdata_i,

  output logic                  empty_o,
  output logic                  empty_delay_o,
  output logic                  full_o,
  output logic [DATA_WIDTH-1:0] rdata_o,
  output logic [ADDR_WIDTH-1:0] size_o
);

  // local pointer signals
  logic [ADDR_WIDTH-1:0] w_ptr, w_ptr_next, w_ptr_succ;
  logic [ADDR_WIDTH-1:0] r_ptr, r_ptr_next, r_ptr_succ;
  logic [ADDR_WIDTH-2:0] addr;

  // local Signals
  logic cen;
  logic wr_en;
  logic full_reg;
  logic empty_reg;
  logic full_next;
  logic empty_next;
  logic empty_delay;

  /////////////////////////
  // Continues assigments
  /////////////////////////
  assign size_o  = w_ptr;
  assign wr_en   = wr_i & (~full_reg);
  assign full_o  = full_reg;
  assign empty_o = empty_reg;
  assign cen     = (wr_i ? 1'b0 : rd_i ? 1'b0 : 1'b1);
  assign addr    = ({ADDR_WIDTH-2{rd_i}} & r_ptr[ADDR_WIDTH-2:0]) | ({ADDR_WIDTH-2{wr_i}} & w_ptr[ADDR_WIDTH-2:0]);

  /////////////////////////
  // Always Blocks
  /////////////////////////
  always_ff @(posedge clk_i or negedge rst_ni) begin : fifo_control_logic
    if(!rst_ni) begin
      w_ptr         <= '0;
      r_ptr         <= '0;
      full_reg      <= '0;
      empty_reg     <= '1;
      empty_delay   <= '1;
      empty_delay_o <= '1;
    end else begin
      full_reg      <= full_next;
      empty_delay   <= empty_o;
      empty_reg     <= empty_next;
      empty_delay_o <= empty_delay;
      if (clr_i) begin
        w_ptr <= '0;
        r_ptr <= '0;
      end else begin
        w_ptr <= w_ptr_next;
        r_ptr <= r_ptr_next;
      end
    end
  end

  always_comb begin
    w_ptr_succ = w_ptr + 1;
    r_ptr_succ = r_ptr + 1;
    w_ptr_next = w_ptr;
    r_ptr_next = r_ptr;
    full_next  = full_reg;
    empty_next = empty_reg;

    case ({wr_i, rd_i})
      // 2'b00: // no op
      2'b01: begin // read
        if(~empty_reg) begin
          r_ptr_next = r_ptr_succ;
          full_next  = 1'b0;
          if(r_ptr_succ == w_ptr) begin
            empty_next = 1'b1;
          end
        end
      end
      2'b10: begin // write
        if(~full_reg) begin
          w_ptr_next = w_ptr_succ;
          empty_next = 1'b0;
          if(w_ptr_succ == r_ptr) begin
            full_next = 1'b1;
          end
        end
      end
      2'b11: begin // write and read
        w_ptr_next = w_ptr_succ;
        r_ptr_next = r_ptr_succ;
      end
      default: begin
        w_ptr_next = w_ptr;
        r_ptr_next = r_ptr;
      end
    endcase
  end

  sram_fifo #(
    .AWIDTH ((ADDR_WIDTH - 2))
  )u_fifo(
    .rdata_o ( rdata_o ),
    .clk_i   ( clk_i   ),
    .cen_i   ( cen     ),
    .wen_i   ( ~wr_en  ),
    .addr_i  ( addr    ),
    .wdata_i ( wdata_i )
  );

endmodule