

module prim_subreg_ext #(
  parameter int unsigned DW = 32
) (
  input logic         re,
  input logic         we,
  input logic [DW-1:0] wd,

  input logic [DW-1:0] d,

  // output to HW and Reg Read
  output logic          qe,
  output logic          qre,
  output logic [DW-1:0] q,
  output logic [DW-1:0] qs
);

  assign qs = d;
  assign q = wd;
  assign qe = we;
  assign qre = re;

endmodule
