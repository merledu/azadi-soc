// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Zeeshan Rafique <zeeshanrafique23@gmail.com>

module spi_controller_iccm #(
  parameter ADDR_WIDTH = 13
)(
  input  logic  clk_i,
  input  logic  rst_ni,
  // Chip IOs
  input  logic  sck_i,
  input  logic  sdi_i,
  input  logic  csb_i,
  output logic  sdo_o,
  // Writing Interface to ICCM
  output logic [ADDR_WIDTH-1:0] waddr_o,
  output logic [31:0]           wdata_o,
  output logic                  wvalid_o
);
  //////////////////////
  // Local Parameters
  //////////////////////
  localparam logic [31:0] ENDING_INSTRUCTION = 32'h7F87_8000 ; // ie: 32'h0000_0FFF;

  //////////////////////
  // Local Signals
  //////////////////////
  logic                  csb_rst;
  logic [ADDR_WIDTH-1:0] waddr_q;
  logic [31:0]           wdata_q;
  logic                  wvalid_q;
  logic [ADDR_WIDTH-1:0] waddr_qs; // stable
  logic [31:0]           wdata_qs;
  logic                  wvalid_qs;
  logic                  sdo_q;
  logic [31:0]           cntr_q;    // Counter Shift Register
  logic [31:0]           wdata_swp; // For swapping the bytes

  assign csb_rst = ~csb_i | rst_ni;

  /////////////////////////////////////////
  // Logic to convert spi data_in to word
  /////////////////////////////////////////
  always_ff @ (negedge sck_i or negedge csb_rst) begin
    if (!csb_rst) begin
      waddr_q   <= '0;
      wdata_q   <= '0;
      wvalid_q  <= '0;
      waddr_qs  <= '0;
      wdata_qs  <= '0;
      wvalid_qs <= '0;
      cntr_q    <= '0;
      sdo_q     <= '0;
    end else begin
      if (wdata_q == ENDING_INSTRUCTION) begin
        // wdata_q  <= wdata_q;
        wvalid_q <= 1'b0;
        sdo_q    <= 1'b1; // setting LED high that indicates successfully received complete program
      end else begin
        // Receiving bits, writing to word register
        wdata_q   <= {wdata_q[30:0], sdi_i};
        wvalid_qs <= wvalid_q; // 1 cycle delayed valid to align with stable signals

        // Retention until next valid
        if (wvalid_q) begin
          wdata_qs  <= wdata_q;
          waddr_qs  <= waddr_q;
        end

        // Restting the counter & check for ending instruction
        if (cntr_q[30]) begin
          cntr_q   <= '0;   // only resets when (cntr == '1 && wdata_q != ENDING_INSTRUCTION)
          wvalid_q <= 1'b1;
        end else begin
          wvalid_q <= 1'b0;
          waddr_q  <= waddr_q + wvalid_q; // update address
          cntr_q   <= {cntr_q[30:0], 1'b1};
        end
      end
    end
  end

  //////////////////////////
  // Clock Domain Crossing
  //////////////////////////
  logic [ADDR_WIDTH-1:0] waddr_q_dst,  waddr_qq_dst;
  logic [31:0]           wdata_q_dst,  wdata_qq_dst;
  logic                  wvalid_q_dst, wvalid_qq_dst;

  // Dual Flip Flop synchronizer
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      waddr_q_dst   <= '0;
      wdata_q_dst   <= '0;
      wvalid_q_dst  <= '0;
      waddr_qq_dst  <= '0;
      wdata_qq_dst  <= '0;
      wvalid_qq_dst <= '0;
    end else begin
      waddr_q_dst   <= waddr_qs;
      wdata_q_dst   <= wdata_swp;
      wvalid_q_dst  <= wvalid_qs;
      waddr_qq_dst  <= waddr_q_dst;
      wdata_qq_dst  <= wdata_q_dst;
      wvalid_qq_dst <= wvalid_q_dst;
    end
  end

  // swappping bytes to align instruction correctly
  assign wdata_swp = {wdata_qs[7:0], wdata_qs[15:8], wdata_qs[23:16], wdata_qs[31:24]};

  // Final output assignment
  assign sdo_o    = sdo_q;
  assign waddr_o  = waddr_qq_dst; // waddr_qs;
  assign wdata_o  = wdata_qq_dst; // wdata_swp;
  assign wvalid_o = wvalid_qq_dst; // wvalid_qs;
endmodule : spi_controller_iccm
