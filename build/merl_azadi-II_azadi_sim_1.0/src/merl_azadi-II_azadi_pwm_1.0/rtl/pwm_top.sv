
module pwm_top #(
  parameter int AW = 8,
  parameter int DW = 32,

  // do not change
  localparam int DBW = DW/8
)(
  input  logic                clk_i,
  input  logic                rst_ni,
  input  tlul_pkg::tlul_h2d_t tl_i,
  output tlul_pkg::tlul_d2h_t tl_o,
  output logic                pwm1_o,
  output logic                pwm2_o,
  output logic                pwm1_oe,
  output logic                pwm2_oe
);

  logic          re;
  logic          we;
  logic [AW-1:0] addr;
  logic [DW-1:0] wdata;
  logic [   3:0] be;
  logic [DW-1:0] rdata;
  logic          err;

  pwm pwm_core(
    .clk_i   ( clk_i   ),
    .rst_ni  ( rst_ni  ),												
    .re_i    ( re      ),												
    .we_i    ( we      ),												
    .addr_i  ( addr    ),												
    .wdata_i ( wdata   ),												
    .be_i    ( be      ),
    .rdata_o ( rdata   ),												
    .o_pwm   ( pwm1_o  ),
    .o_pwm_2 ( pwm2_o  ),
    .oe_pwm1 ( pwm1_oe ),
    .oe_pwm2 ( pwm2_oe )
  );

  tlul_adapter_reg #(
    .RegAw( AW ),
    .RegDw( DW )
  ) u_reg_if (
    .clk_i   ( clk_i  ),
    .rst_ni  ( rst_ni ),
    .tl_i    ( tl_i   ),
    .tl_o    ( tl_o   ),
    .we_o    ( we     ),
    .re_o    ( re     ),
    .addr_o  ( addr   ),
    .wdata_o ( wdata  ),
    .be_o    ( be     ),
    .rdata_i ( rdata  ),
    .error_i ( 1'b0   )
  );

endmodule
