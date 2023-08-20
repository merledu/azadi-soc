module arithmetic_unit
    (
        //. TO ASK: what if the operation is done on 64 bits? should we perform the operatoin in 2 steps?
        //. So, we have to out the carry out of the first operation and use it as carry in for the second operation?
        //. Or we can simply use the 64 bits operators?
        input logic                        enable_i,
        input logic [tluh_pkg::TL_DW-1:0]  op1_i,
        input logic [tluh_pkg::TL_DW-1:0]  op2_i,
        input logic                        cin_i, //. carry in
        input logic [2:0]                  operation_i,
        output logic [tluh_pkg::TL_DW-1:0] result_o,
        output logic                       cout_o //. carry out
    );

    //. 1: min, 2: max, 3: minu, 4: maxu, 5: add

    always_comb begin : perform_operation
        if(enable_i) begin
            case (operation_i)
                tluh_pkg::MIN: result_o  = $signed(op1_i) < $signed(op2_i) ? op1_i : op2_i;
                tluh_pkg::MAX: result_o  = $signed(op1_i) > $signed(op2_i) ? op1_i : op2_i;
                tluh_pkg::MINU: result_o = $unsigned(op1_i) < $unsigned(op2_i) ? op1_i : op2_i;
                tluh_pkg::MAXU: result_o = $unsigned(op1_i) > $unsigned(op2_i) ? op1_i : op2_i;
                tluh_pkg::ADD: begin 
                    {cout_o, result_o} = op1_i + op2_i + cin_i;
                end
                default: result_o = 0; //. to avoid latches
            endcase
        end
        
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