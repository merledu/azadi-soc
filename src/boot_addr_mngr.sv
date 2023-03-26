// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Zeeshan Rafique <zeeshanrafique23@gmail.com>

module boot_addr_mngr (
  input  logic        clk_i,        // main clock
  input  logic        por_ni,
  // Management, boot selection and done signal
  input  logic        management_i,
  input  logic        prog_done_i,  // Program loading into ICCM/QSPI done
  input  logic        boot_sel_i,   // Boot select pin
  // Boot address
  output logic [31:0] boot_addr_o,
  output logic [31:0] boot_reg_val_o
);

  logic [31:0] boot_addr_d,    boot_addr_q;
  logic [31:0] boot_reg_val_d, boot_reg_val_q;
  logic        boot_lock;

  always_ff @(posedge clk_i or negedge por_ni) begin
    if (!por_ni) begin
      boot_addr_q    <= 32'h6000_0000;
      boot_reg_val_q <= 32'h4252_4F4D; // BROM
      boot_lock      <= '0;
    end else begin
      if (management_i || !prog_done_i) begin
        boot_addr_q <= boot_addr_d;
      end
      boot_reg_val_q <= boot_reg_val_d;
    end
  end

  always_comb begin
    if (prog_done_i) begin
      if (boot_sel_i) begin // QSPI
        boot_addr_d    = 32'h8000_0008;
        boot_reg_val_d = 32'h5153_5049;
      end else begin        // ICCM
        boot_addr_d    = 32'h1000_0000;
        boot_reg_val_d = 32'h4943_434D;
      end
    end else begin
      boot_addr_d    = 32'h6000_0000;
      boot_reg_val_d = 32'h4252_4F4D;
    end
  end

  assign boot_addr_o = boot_addr_q;
  assign boot_reg_val_o = boot_reg_val_q;

endmodule : boot_addr_mngr
