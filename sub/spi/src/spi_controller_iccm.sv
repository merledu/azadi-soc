// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Sajjad Ahmed <sajjad.ahmed3052@gmail.com>

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
  localparam logic [31:0] ENDING_INSTRUCTION = 32'h00FF_FF00 ; // ie: 32'h0000_0FFF;
  typedef enum logic [1:0] {IDLE, SYNCD, U_ADDR} state_t;
  typedef enum logic [1:0] {P_IDLE, P_START, P_DONE} p_state_t;
  //////////////////////
  // Local Signals
  //////////////////////
  state_t next_state;
  p_state_t p_next_state;
  logic                  csb_rst;
  logic [ADDR_WIDTH-1:0] waddr_q;
  logic [31:0]           wdata_q;
  logic                  wvalid_q;
  logic                  wvalid_qqs;
  logic [ADDR_WIDTH-1:0] waddr_qs; // stable
  logic [31:0]           wdata_qs;
  logic                  wvalid_qs;
  logic                  sdo_q;
  logic [31:0]           cntr_q;    // Counter Shift Register
  logic [2:0]            sync_cntr;
  logic [31:0]           wdata_swp; // For swapping the bytes
  logic                  s_valid;
  logic                  s_valid_delay;
  logic                  s_valid_delay2;
  logic                  r_valid;
  logic [ADDR_WIDTH-1:0] waddr_q_dst,  waddr_qq_dst;
  logic [31:0]           wdata_q_dst,  wdata_qq_dst;
  logic                  wvalid_q_dst, wvalid_qq_dst;

  assign csb_rst = ~csb_i | rst_ni;

  /////////////////////////////////////////
  // Logic to convert spi data_in to word
  /////////////////////////////////////////
  always_ff @ (posedge sck_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wdata_q   <= '0;
      cntr_q    <= '0;
      sdo_q     <= '0;
    end else begin
        if(!csb_i) begin
          wdata_q <= {wdata_q[30:0], sdi_i};
        end else begin
          wdata_q <= wdata_q;
        end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      s_valid      <= '0;
      p_next_state <= P_IDLE;
    end else begin
      case (p_next_state)
        P_IDLE : begin
          s_valid <= '0;
          if(!csb_i) begin
            p_next_state <= P_START;
          end else begin
            p_next_state <= P_IDLE;
          end
        end
        P_START: begin
          if(!csb_i) begin
            p_next_state <= P_START;
          end else begin
            p_next_state <= P_DONE;
          end
        end
        P_DONE: begin
          s_valid      <= 1'b1;
          p_next_state <= P_IDLE;
        end 
      endcase
    end
  end

  ///////////////////////////////////////////
  //                                       //
  //  Clock Domain Crossing State Machine  //
  //                                       //
  ///////////////////////////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      next_state    <= IDLE;
      waddr_q_dst   <= '0;
      wdata_q_dst   <= '0;
      waddr_q       <= '0;
      r_valid       <= '0;
      sdo_o         <= '0;
      wvalid_q      <= '0;
      wvalid_q_dst  <= '0;
      sync_cntr     <= '0;
      sdo_o         <= '0;
    end else begin
      case (next_state) 
        IDLE: begin
          if(!csb_i) begin
            sdo_o <= 1'b0;
          end
          if(s_valid) begin
            next_state <= SYNCD;
          end else begin
            next_state <= IDLE;
          end
        end
        SYNCD: begin
          if(!sync_cntr[2]) begin
            if(sync_cntr[1]) begin
              wvalid_q_dst <= 1'b1;
            end
            sync_cntr   <= {sync_cntr[1:0], 1'b1};
            next_state  <= SYNCD;
            wdata_q_dst <= {wdata_q[7:0], wdata_q[15:8], wdata_q[23:16], wdata_q[31:24]};
            if(wdata_q_dst == ENDING_INSTRUCTION) begin
              next_state  <= IDLE;
              sdo_o       <= 1'b1;
              wdata_q_dst <= '0;
              waddr_q_dst <= '0;
            end else begin
              next_state  <= SYNCD;
            end
          end else begin
            sync_cntr    <= '0;
            next_state   <= U_ADDR;
            wvalid_q_dst <= 1'b0;
          end
        end
        U_ADDR: begin
          waddr_q_dst <= waddr_q_dst + 1;
          next_state  <= IDLE;
        end
        default: begin
          next_state    <= IDLE;
          waddr_q_dst   <= '0;
          wdata_q_dst   <= '0;
          wvalid_q_dst  <= '0;
          sync_cntr     <= '0;
          sdo_o         <= '0;
        end
      endcase
    end
  end

  assign waddr_o  = waddr_q_dst; // waddr_qs;
  assign wdata_o  = wdata_q_dst; // wdata_swp;
  assign wvalid_o = wvalid_q_dst; // wvalid_qs;
endmodule : spi_controller_iccm
// 00 FF FF 00 FF FF FF FF FF FF FF FF