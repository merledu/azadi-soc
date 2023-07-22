module logical_unit
    (
        input logic                        enable_i,
        input logic [tluh_pkg::TL_DW-1:0]  op1_i,
        input logic [tluh_pkg::TL_DW-1:0]  op2_i,
        input logic                        cin_i,  //. TO ASK: I think no need for cin in logical operations
        input logic [2:0]                  operation_i,
        output logic [tluh_pkg::TL_DW-1:0] result_o,
        output logic                       cout_o
    );

    // 1: XOR – 2: OR – 3: AND – 4: SWAP
    assign {cout_o, result_o} = (enable_i != 1)                 ? '0 :
                                (operation_i == tluh_pkg::XOR)  ? op1_i ^ op2_i:
                                (operation_i == tluh_pkg::OR)   ? op1_i | op2_i:
                                (operation_i == tluh_pkg::AND)  ? op1_i & op2_i:
                                (operation_i == tluh_pkg::SWAP) ? op1_i : 0;   //. Not sure about this one
   
endmodule