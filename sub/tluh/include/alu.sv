module ALU (
    input bit                          enable_i,
    input logic [tluh_pkg::TL_DW-1:0]  op1_i,
    input logic [tluh_pkg::TL_DW-1:0]  op2_i,
    input bit                          cin_i,
    input bit                          operation_i,  //. 0: Logical, 1: Arithmetic
    input logic [2:0]                  function_i,
    output logic [tluh_pkg::TL_DW-1:0] result_o,
    output bit                         cout_o
  );

  //. according to the operation_i either logical or arithmetic, we will decide which module to enable

  bit enable_arithmetic, enable_logical;

  assign enable_arithmetic = (enable_i && operation_i) ? 1'b1 : 1'b0;
  assign enable_logical    = (enable_i && ~operation_i) ? 1'b1 : 1'b0;

  arithmetic_unit
    arithmetic_unit_dut (
      .enable_i    (enable_arithmetic),
      .op1_i       (op1_i),
      .op2_i       (op2_i),
      .cin_i       (cin_i),
      .operation_i (function_i),
      .result_o    (result_o),
      .cout_o      (cout_o)
    );

  logical_unit
    logical_unit_dut (
      .enable_i    (enable_logical),
      .op1_i       (op1_i),
      .op2_i       (op2_i),
      .cin_i       (cin_i),
      .operation_i (function_i),
      .result_o    (result_o),
      .cout_o      (cout_o)
    );


endmodule
