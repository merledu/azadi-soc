module arithmetic_unit
    (
        //. TO ASK: what if the operation is done on 64 bits? should we perform the operatoin in 2 steps?
        //. So, we have to out the carry out of the first operation and use it as carry in for the second operation?
        //. Or we can simply use the 64 bits operators?
        input logic [31:0] a,
        input logic [31:0] b,
        input bit cin, //. carry in
        input tluh_pkg::tluh_a_param_arith op,
        output logic [31:0] result,
        output bit cout //. carry out
    );

    //. 1: min, 2: max, 3: minu, 4: maxu, 5: add

    always_comb begin : blockName
        case (op)
            tluh_pkg::MIN: result = $signedmin(a, b);
            tluh_pkg::MAX: result = $signedmax(a, b);
            tluh_pkg::MINU: result = $unsignedmin(a, b);
            tluh_pkg::MAXU: result = $unsignedmax(a, b);
            tluh_pkg::ADD: begin 
                {cout, result} = a + b + cin;
            end
            default: result = 0; //. to avoid latches
        endcase
        
    end

    // assign result = (op == tluh_pkg::MIN) ? $signedmin(a, b) :
    //                 (op == tluh_pkg::MAX) ? $signedmax(a, b) :
    //                 (op == tluh_pkg::MINU) ? $unsignedmin(a, b) :
    //                 (op == tluh_pkg::MAXU) ? $unsignedmax(a, b) :
    //                 (op == tluh_pkg::ADD) ? (a + b) : 0;


    //. TO ASK: what about the carry in case of add? Should we add a carry in port?
    //. TO ASK: is it ok to simply use the $unsignedmin/max functions?
    //. and also what about the + > < operators? are they ok? or we have to implement another adder (carry save adder, carry bypass adder, etc.) ?

endmodule