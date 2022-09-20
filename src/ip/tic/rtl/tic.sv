// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Timer interrupt controller

module tic(
  input logic clk_i,
  input logic rst_ni,

  input logic         re_i,
  input logic         we_i,
  input logic  [3:0]  be_i,
  input logic  [3:0]  addr_i,
  input logic  [31:0] wdata_i,
  output logic [31:0] rdata_o,

  input logic  [3:0]  int_src,
  output logic        intr_o
);

  // Claim complete reg address
  localparam CC_ADDR  = 8;
  localparam INTR_ENB = 4;

  logic [3:0] ia;       // Interrupt active
  logic [3:0] ip;       // Interrupt pending
  logic [3:0] claim;   
  logic [3:0] complete; 
  logic [3:0] irq_id;   // Interrupt request id
  logic       intr_enb;

  // Interrupt gateway
  // Interrupt pending is set by source (depends on le_i), cleared by claim_i.
  // Until interrupt is claimed, set doesn't affect ip_o.
 always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ip <= '0;
    end else begin
      ip <= (ip | (irq_id & ~ia & ~ip)) & (~(ip & claim));
    end
  end

  // Interrupt active is to control ip_o. If ip_o is set then until completed
  // by target, ip_o shouldn't be set by source even claim_i can clear ip_o.
  // ia can be cleared only when ia was set. If `set` and `complete_i` happen
  // at the same time, always `set` wins.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ia <= '0;
    end else begin
      ia <= (ia | (irq_id & ~ia)) & (~(ia & complete & ~ip));
    end
  end

  // Interrup ids
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      irq_id <= '0;
    end else begin
      if(int_src[3]) begin
        irq_id <= 4'd8;
      end else if(int_src[2] && ~int_src[3]) begin
        irq_id <= 4'd4;
      end else if(int_src[1] && ~int_src[3] && ~int_src[2]) begin
        irq_id <= 4'd2;
      end else if ((addr_i == CC_ADDR) && we_i) begin
        irq_id <= wdata_i[3:0];
      end
    end
  end

  // Interrupt enable write reg
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      intr_enb <= '0;
    end else begin
      if((addr_i == INTR_ENB) && we_i) begin
        intr_enb <= wdata_i[0];
      end else if(|complete) begin
        intr_enb <= '0;
      end
    end
  end

  // Claim complete logic
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      complete <= '0;
      claim    <= '0;
    end else begin
      complete[1] <= (addr_i == CC_ADDR) & we_i & irq_id[1];
      complete[2] <= (addr_i == CC_ADDR) & we_i & irq_id[2];
      complete[3] <= (addr_i == CC_ADDR) & we_i & irq_id[3];
      
      claim[1]    <= (addr_i == CC_ADDR) & re_i & irq_id[1];
      claim[2]    <= (addr_i == CC_ADDR) & re_i & irq_id[2];
      claim[3]    <= (addr_i == CC_ADDR) & re_i & irq_id[3];
    end
  end

  // Interrupt id read
  assign rdata_o = ((addr_i == CC_ADDR) && re_i) ? {28'b0, irq_id} : '0;

  // Interrupt output
  assign intr_o = (|ip) & intr_enb;

endmodule