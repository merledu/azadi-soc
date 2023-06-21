module logical_unit
    (
        input logic [31:0] a,
        input logic [31:0] b,
        input bit cin,
        input tluh_pkg::tluh_a_param_log op,
        output logic [31:0] result,
        output bit cout
    );

    // 1: XOR – 2: OR – 3: AND – 4: SWAP
    assign {cout, result} = (op == tluh_pkg::XOR) ? a ^ b ^ cin :
                            (op == tluh_pkg::OR) ? a | b | cin :
                            (op == tluh_pkg::AND) ? a & b & cin :
                            (op == tluh_pkg::SWAP) ? a : 0;   //. Not sure about this one
   
endmodule