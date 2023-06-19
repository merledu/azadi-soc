// tluh_adapter (Host adapter) converts basic req/grant/rvalid into TL-UL interface. If
// MAX_REQS == 1 it is purely combinational logic. If MAX_REQS > 1 flops are required.
//
// The host driving the adapter is responsible for ensuring it doesn't have more requests in flight
// than the specified MAX_REQS.
//
// The outgoing address is always word aligned. The access size is always the word size (as
// specified by TL_DW). For write accesses that occupy all lanes the operation_i is PutFullData,
// otherwise it is PutPartialData, mask is generated from be_i. For reads all lanes are enabled as
// required by TL-UL (every bit in mask set).
//
// When MAX_REQS > 1 tluh_adapter_host does not do anything to order responses from the TL-UL
// interface which could return them out of order. It is the host's responsibility to either only
// have outstanding requests to an address space it knows will return responses in order or to not
// care about out of order responses (note that if read data is returned out of order there is no
// way to determine this).

// what I need to do now is to change the tluh_adapter_host to be parametrized so that it can be
// either tluh or tluh interface
// to do that I need to change the tluh_adapter_host to be a module and not a interface
module tluh_host_adapter #(
    parameter int unsigned MAX_REQS = 1
) (
    
    input logic clk_i,
    input logic rst_ni, // ni stands for negative edge triggered and i stands for input
// interface with host agent 
    input logic [2:0]                   operation_i, // parameter for the operation
    input bit                           arithmetic_i, // if 1 then it is an arithmetic operation. if 0 then it is a logic operation
    input                               req_i, // request from host agent it is either a read or write request
    output logic                        gnt_o, // grant to host agent this means the adapter is ready to accept a request
    input logic [tluh_pkg::TL_AW-1:0]   addr_i, // address of the request from host agent to be sent to the TL-UL interface so that it can be sent to the target agent
    input logic                         we_i, // write enable
    input logic [tluh_pkg::TL_DW-1:0]   wdata_i, // write data
    input logic [tluh_pkg::TL_DBW-1:0]  be_i, // byte enable for write data
    output logic                        valid_o,
    output logic [tluh_pkg::TL_DW-1:0]  rdata_o, // received data from the device (D channel)
    output logic                        err_o, // error response
// interface with other tilelink agents or tluh interface
    output tluh_pkg::tluh_h2d_t          tl_h_c_a, // tilelink host channel A -- it is output as it send the request to the TL-UL interface
    input  tluh_pkg::tluh_d2h_t          tl_h_c_d  // tilelink host channel D
);

    localparam int WordSize = $clog2(tluh_pkg::TL_DBW);

    logic [tluh_pkg::TL_AIW-1:0] tl_source; // AIW is the width of the source field in the TL-UL spec
    logic [tluh_pkg::TL_DBW-1:0] tl_be;
    int counter = 0; // counter to count the number of beats (its max is 4 as the max number of beats is 4)

    //. we will need to create a buffer to store the data that is received from the TL-UL interface
    //. the buffer will serve in 2 cases: case2 & case3
    //. 1- the request is burst while the response is not burst --> the buffer will store the response data until the last beat is sent to the host agent
    //. 2- both request and response are burst --> the buffer will store the response data until the last beat is sent to the host agent
    logic [1:0][tluh_pkg::TL_DW-1:0] buffer; // buffer to store the data that is received from the TL-UL interface
    bit read_form_buffer = 0; // flag to indicate whether to take the value form the buffer or just take the value from the TL-UL interface
    bit buffer_index_read = 0; // index to indicate which beat to take from the buffer
    bit buffer_index_write = 0; // index to indicate which beat to write to the buffer

    // first case --> if MAX_REQS == 1 then the source is always 0 cause there is only one request
    // as the source refers to the source of the request which is the host agent
    if(MAX_REQS == 1) begin
        assign tl_source = '0;   
    end else begin
        localparam int ReqNumW = $clog2(MAX_REQS);
        logic [ReqNumW-1:0] source_d, source_q; // d stands for destination and q stands for query

        // the 2 always blocks below are used to assign the value of source_q to source_d
        // as the source_q is the query and source_d is the destination
        // the query is the value of the source before the clock edge and the destination is the value of the source after the clock edge
        // the combinational always block is used to increment the value of source_d by 1 every time a request is sent
        // the source_d is incremented by 1 only when the request is sent and the grant is asserted
        // the ff always block is used to assign the value of source_q to source_d only when the reset is asserted 



        //. TODO 1
        //. 1- support burst mode for responses
        //. to know whether or not it is a burst response, we have to check for the opcode of the request
        //. if it is get, then its response is AccessAckData which is a burst response (2 beats) and if it is PutFullData or PutPartialData then its response is AccessAck which is not a burst response
        //. once again, if it is a burst respone, then wait for the last beat to be sent to the host agent
        //. we can do that by checking the opcode of the request and if it is a get then we wait for the last beat to be sent to the host agent
        //. so the source_q will not be incremented until the last beat is sent to the host agent
        //. as we have to wait for the last beat to be sent to the host agent, we have to wait for the last beat to be sent to the TL-UL interface

        //. TODO 2
        //. 2- support burst mode for requests (putfulldata, putpartialdata)
        //. to know whether or not it is a burst request, we have to check for the opcode of the request
        //. for putfulldata, putpartialdata, it has to be a burst request
        //. noting that the master interface must accept
        //. a concurrent AccessAck, even before it has finished sending the PutFullData/putpartialdata message. It may,
        //. however, buffer the AccessAck message and leave it pending there until it completes sending the request.

        //. TODO 3
        //. 3- support the case where both requests and responses are burst
        //. this is the case for both arithmetic and logical operations


        // this always block is used to assign the value of source_d to source_q 
        always_ff @(posedge clk_i) begin
            if(!rst_ni) begin
                source_q <= '0;
            end else begin
                source_q <= source_d;
            end
        end
    
        // this always block is used to increment the value of source_d by 1 every time a request is sent
        always_comb begin
            source_d = source_q;

            // if req_i is asserted and gnt_o is asserted then increment the value of source_d by 1
            // as this means that the host agent has sent a request and the adapter is ready to accept another request
            if((req_i && gnt_o) | valid_o) begin
                if(counter == 0) begin
                    if(read_form_buffer & buffer_index_write == 1) begin
                        buffer_index_read = 1;
                        buffer_index_write = 0;
                    end
                    else begin
                        read_form_buffer = 0;

                        if(source_q == MAX_REQS - 1) source_d = '0;
                        else source_d = source_q + 1;
    
                        //. case1: check if the request is get (i.e., the response is supposed to be a burst response)
                        if(tl_h_c_a.a_opcode == tluh_pkg::Get) begin
                            counter = counter + 1; // indicating that I have to wait untill all the beats are sent to the host agent before proceeding to the next request
                        end
                        
                        //. case2: check if the request is (putfulldata, putpartialdata)
                        if(tl_h_c_a.a_opcode < 2)
                            counter = counter + 1;
    
                        //. case3: check if the request is (arith, logic)
                        if(operation_i != 0)
                            counter = counter + 1;
                    end

                end 
                else begin
                    //. in case of burst request --> check if the resposne is received during sending the beats to buffer it
                    if(tl_h_c_a.a_opcode < 2 & tl_h_c_d.d_valid) begin  //. TODO: no need to check for the d_valid as it is already checked in the outer if
                        buffer[buffer_index_write] = tl_h_c_d.d_data;
                        read_form_buffer = 1;
                        buffer_index_read = 0;  //. can remove this line
                    end

                    //. in case of burst request and response --> check if the resposne is received to buffer it
                    if(operation_i != 0 & tl_h_c_d.d_valid) begin  //. not sure that operation_i will remain asserted untill the response is received   --> TO ASK
                        //. should I make sure the buffer is empty before buffering the response? I don't think so  --> TO ASK
                        buffer[buffer_index_write] = tl_h_c_d.d_data;
                        read_form_buffer = 1;
                        buffer_index_write = (buffer_index_write + 1); // % 2;
                    end
    
                    //. update the counter
                    if(counter == 2) begin
                        // if(read_form_buffer)begin
                        //     if(buffer_index_write == 1) begin 
                        //         buffer_index_read = 0;
                        //         buffer_index_write = 0;
                        //     end
                        // end


                        counter = 0;
                        end else if (counter == 1)begin

                        //. case 1
                        //. check for the arrival of the first beat
                        //. TO ASK: Is it correct to check for the arrival of the first beat only?
                        //. Cause I guess that once the firt beat arrives (after an arbitrary number of cycles (delay)), then the other beats will arrive in sequence (one after the other)
                        //. Should we check for the type of the response message to be AccessAckData (burst response) or it is not the responsibility of the adapter and it will never be a wrong response?
                        if(tl_h_c_d.d_valid & tl_h_c_d.d_opcode == tluh_pkg::AccessAckData) begin  //. TODO --> change this condition to indicate the request was GET
                            counter = counter + 1;
                        end
                        
                        //. case 2
                        else if(tl_h_c_a.a_opcode < 2)
                            //. it is expected that wdata_i will contain the second beat in the next clock cycle in case it was received by the slave (I guess no need to check for this, right?) TO ASK
                            counter = counter + 1;

                        //. case 3
                        else if(operation_i != 0) begin
                            //. it is expected that wdata_i will contain the second beat in the next clock cycle in case it was received by the slave (I guess no need to check for this, right?) TO ASK
                            counter = counter + 1;
                        end
                    
                        end
                        else begin
                            // the response will be assigned below outside the always block
                            counter = counter + 1;
                        end
                    end                    
                    
                end
            end
            assign tl_source = tluh_pkg::TL_AIW'(source_q); // ' is a casting operator in system verilog which casts the value of source_q to the width of the signal tl_source as tl_source is of type tluh_pkg::TL_AIW and source_q is of type logic [ReqNumW-1:0] so the value of source_q is casted to the width of tl_source
        end

// For TL-UL Get opcode all active bytes must have their mask bit set, so all reads get all tl_be
// bits set. For writes the supplied be_i is used as the mask.
    assign tl_be = ~we_i ? {tluh_pkg::TL_DBW{1'b1}} : be_i;

    assign tl_h_c_a = '{
        a_valid:    req_i,
        a_opcode:   (arithmetic_i) ? tluh_pkg::ArithmeticData :
                    (operation_i != 0 & we_i) ? tluh_pkg::LogicalData :
                    (operation_i != 0) ? tluh_pkg::Intent :
                    (~we_i & ~operation_i) ? tluh_pkg::Get :
                    (&be_i) ? tluh_pkg::PutFullData :
                              tluh_pkg::PutPartialData,

        a_param:    (arithmetic_i)? tluh_pkg::tluh_a_param_arith'(operation_i) :
                    (we_i & operation_i > 0)? tluh_pkg::tluh_a_param_log'(operation_i) :
                    (~we_i & operation_i > 0) ? tluh_pkg::tluh_a_param_intent'(operation_i) : '0,
                    
        a_size:     tluh_pkg::TL_SZW'(WordSize),
        a_mask:     tl_be,
        a_source:   tl_source,
        a_address:  {addr_i[31:WordSize], {WordSize{1'b0}}},
        a_data:     wdata_i,
        d_ready:    1'b1  // always ready to accept responses
    };

    assign gnt_o = tl_h_c_d.a_ready;
    //assign rdata_0 = tl_h_c_d.d_data;
    assign err_o   = tl_h_c_d.d_error;
    assign valid_o = read_form_buffer ? 1 : tl_h_c_d.d_valid;
    logic [31:0] rddata;
    //. TO ASK: why don't we simply let rdata_o = tl_h_c_d.d_data? why do we need to assign it to rddata first?
    assign rddata = tl_h_c_d.d_data;
    assign rdata_o = read_form_buffer ? buffer[buffer_index_read] : rddata;

endmodule