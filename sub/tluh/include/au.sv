module arithmetic_unit
    (
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

endmodule