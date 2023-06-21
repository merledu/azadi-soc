module arithmetic_unit
    (
        input logic [31:0] a,
        input logic [31:0] b,
        input tluh_pkg::tluh_a_param_arith op,
        output logic [31:0] result
    );

    // 1: min, 2: max, 3: minu, 4: maxu, 5: add
    assign result = (op == tluh_pkg::MIN) ? $signedmin(a, b) :
                    (op == tluh_pkg::MAX) ? $signedmax(a, b) :
                    (op == tluh_pkg::MINU) ? $unsignedmin(a, b) :
                    (op == tluh_pkg::MAXU) ? $unsignedmax(a, b) :
                    (op == tluh_pkg::ADD) ? (a + b) : 0;
    //. TO ASK: what about the carry in case of add? Should we add a carry in port?
    //. TO ASK: is it ok to simply use the $unsignedmin/max functions?
    //. and also what about the + > < operators? are they ok? or we have to implement another adder (carry save adder, carry bypass adder, etc.) ?

endmodule