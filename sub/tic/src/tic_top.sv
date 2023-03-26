
module tic_top(

  input logic clk_i,
  input logic rst_ni,

  input  tlul_pkg::tlul_h2d_t tl_i,
  output tlul_pkg::tlul_d2h_t tl_o,
  input  logic  [3:0]         int_src,
  output logic                intr_o
);

  localparam int AW = 4;
  localparam int DW = 32;

  logic         re;
  logic         we;
  logic [3:0]   be;
  logic [3:0]   addr;
  logic [31:0]  wdata;
  logic [31:0]  rdata;

  tic u_tic(
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .re_i     (re),
    .we_i     (we),
    .be_i     (be),
    .addr_i   (addr),
    .wdata_i  (wdata),
    .rdata_o  (rdata),
    .int_src  (int_src),
    .intr_o   (intr_o)
  );

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW)
  ) u_reg_if (
    .clk_i,
    .rst_ni,

    .tl_i    (tl_i),
    .tl_o    (tl_o),

    .we_o    (we),
    .re_o    (re),
    .addr_o  (addr),
    .wdata_o (wdata),
    .be_o    (be),
    .rdata_i (rdata),
    .error_i ('0)
  );

endmodule 
