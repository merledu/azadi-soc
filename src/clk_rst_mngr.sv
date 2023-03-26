// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Zeeshan Rafique <zeeshanrafique23@gmail.com>

module clk_rst_mngr (
  input  logic clk_i,
  input  logic sys_rst_ni,

  input  logic rst_req_i,
  // output system reset
  output logic reset_o
);

  logic sync1, sync2;

  always_ff @(posedge clk_i or negedge sys_rst_ni) begin
    if (!sys_rst_ni) begin
      sync1 <= 1'b0;
      sync2 <= 1'b0;
    end else begin
      sync1 <= 1'b1; // tie hi
      sync2 <= sync1;
    end
  end

  assign reset_o = sync2 & ~rst_req_i;

  /* 
  // deprecated
  logic [15:0] clk_counter;

  always_ff @(posedge clk_i or negedge sys_rst_ni) begin
    if(!sys_rst_ni) begin
      clk_counter     <= '0;
      clk_enb_o       <= '0;
    end else begin
      if (clk_counter != 16'd1000) begin
        clk_counter <= clk_counter + 16'd1;
      end else begin
        clk_enb_o   <= 1'b1;
      end
    end
  end
  */
endmodule : clk_rst_mngr
