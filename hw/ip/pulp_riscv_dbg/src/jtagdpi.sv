// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module jtagdpi #(
  parameter string Name = "jtag0", // name of the JTAG interface (display only)
  parameter int ListenPort = 44853 // TCP port to listen on
)(
  input  bit clk_i,
  input  bit rst_ni,

  output bit jtag_tck,
  output bit jtag_tms,
  output bit jtag_tdi,
  input  bit jtag_tdo,
  output bit jtag_trst_n,
  output bit jtag_srst_n
);

  import "DPI-C"
  function chandle jtagdpi_create(input string name, input int listen_port);

  import "DPI-C"
  function void jtagdpi_tick(input chandle ctx, output bit tck, output bit tms,
                             output bit tdi, output bit trst_n,
                             output bit srst_n, input bit tdo);

  import "DPI-C"
  function void jtagdpi_close(input chandle ctx);

  chandle ctx;

  initial begin
    ctx = jtagdpi_create(Name, ListenPort);
  end

  final begin
    jtagdpi_close(ctx);
    ctx = 0;
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    jtagdpi_tick(ctx, jtag_tck, jtag_tms, jtag_tdi, jtag_trst_n, jtag_srst_n,
                 jtag_tdo);
  end

endmodule
