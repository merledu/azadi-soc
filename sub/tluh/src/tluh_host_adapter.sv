// tluh_adapter (Host adapter) converts basic req/grant/rvalid into TL-UH interface. If
// MAX_REQS == 1 it is purely combinational logic. If MAX_REQS > 1 flops are required.
//
// The host driving the adapter is responsible for ensuring it doesn't have more requests in flight
// than the specified MAX_REQS.
//
// The outgoing address is always word aligned. The access size is always the word size (as
// specified by TL_DW). For write accesses that occupy all lanes the operation_i is PutFullData,
// otherwise it is PutPartialData, mask is generated from be_i. For reads all lanes are enabled as
// required by TL-UH (every bit in mask set).
//
// When MAX_REQS > 1 tluh_adapter_host does not do anything to order responses from the TL-UH
// interface which could return them out of order. It is the host's responsibility to either only
// have outstanding requests to an address space it knows will return responses in order or to not
// care about out of order responses (note that if read data is returned out of order there is no
// way to determine this).

module tluh_host_adapter #(
    parameter int unsigned MAX_REQS = 1
) (
    
    input logic clk_i,
    input logic rst_ni,
// interface with host agent 
    input logic [tluh_pkg::TL_SZW-1:0]  data_width_i, //. in the form of Log2(DataWidth/8)
    input logic [2:0]                   operation_i, //. the arithmetic/logical/intent operation to be performed
    input bit                           arithmetic_i, //. 1 --> arithmetic operation, 0 --> logical operation
    input                               req_i,
    output logic                        gnt_o,
    input logic [tluh_pkg::TL_AW-1:0]   addr_i, 
    input logic                         we_i, //. write enable
    input logic [tluh_pkg::TL_DW-1:0]   wdata_i, //. write data
    input logic [tluh_pkg::TL_DBW-1:0]  be_i, //. byte enable for write data
    output logic                        valid_o,
    output logic [tluh_pkg::TL_DW-1:0]  rdata_o, //. received data from the device (D channel)
    output logic                        err_o, //. error response
// interface with other tilelink agents or tluh interface
    output tluh_pkg::tluh_h2d_t          tl_h_c_a, //. tilelink host channel A
    input  tluh_pkg::tluh_d2h_t          tl_h_c_d  //. tilelink host channel D
);

    localparam int WordSize = $clog2(tluh_pkg::TL_DBW);

    logic [tluh_pkg::TL_AIW-1:0] tl_source;
    logic [tluh_pkg::TL_DBW-1:0] tl_be;
    int counter = 0; //. counter to count the number of requests sent (serves in case of burst requests)

    //. we will need to create a buffer to store the data that is received from the slave agent
    //. the buffer will serve in 2 cases:
    //. 1- the request is burst while the response is not burst --> the buffer will store the response data until the last beat is sent to the host agent
    //. 2- both request and response are burst --> the buffer will store the response data until the last beat is sent to the host agent
    logic [1:0][tluh_pkg::TL_DW-1:0] buffer; //. buffer to store the data that is received from the slave agent
    bit read_form_buffer = 0; //. flag to indicate whether to take the value form the buffer or just take the value from the TL-UH interface
    bit buffer_index_read = 0; //. index to indicate which beat to take from the buffer
    bit buffer_index_write = 0; //. index to indicate where to write the beat in the buffer

    bit wait_resp = 0; //. flag to indicate whether to wait for the response or not
    bit beats_no = 0; //. number of beats expected to be received from the slave agent


    //. first case --> if MAX_REQS == 1 then the source is always 0 cause there is only one request
    //. as the source refers to the source of the request which is the host agent
    if(MAX_REQS == 1) begin
        assign tl_source = '0;   
    end else begin
        localparam int ReqNumW = $clog2(MAX_REQS);
        logic [ReqNumW-1:0] source_d, source_q; //. d stands for destination and q stands for query

        
        always_ff @(posedge clk_i) begin
            if(!rst_ni) begin
                source_q <= '0;
            end else begin
                source_q <= source_d;
            end
        end

        always_comb begin
            source_d = source_q;

            if(req_i && gnt_o && beats_no == 0) begin
                if(source_q == MAX_REQS - 1) source_d = '0;
                else source_d = source_q + 1;
            end
        end

        assign tl_source = tluh_pkg::TL_AIW'(source_q);
    end


    //. requests
    always @(posedge clk_i) begin
        if(counter == 2)
        begin
            if(~read_form_buffer)
                wait_resp = 1;                
            counter = 0; //. reset the counter
        end
        if(req_i && gnt_o && ~wait_resp) begin

            if(counter == 0) begin //. indicate the beginning of a request
                
                //. case 1 --> Get request
                if(~we_i & (operation_i == 0)) begin
                    wait_resp = 1;
                    beats_no = $clog2(data_width_i);
                end

                //. case 2 --> PutFullData or PutPartialData requests
                else if(we_i & (operation_i == 0)) begin
                    //. check the number of beats to send
                    if(data_width_i == 3)
                        counter = counter + 1;
                    beats_no = 1;
                    //. we will not make wait_resp = 1 untill we make sure it is not received duirng sending the beats (i.e., it is not buffered)
                end

                //. case 3 --> Arithmetic or Logical requests
                else if(operation_i > 0) begin
                    if(data_width_i == 3)
                        counter = counter + 1;
                    beats_no = $clog2(data_width_i); //. the size of the arithmetic/logical request data should match the size of the AccessAckData response.
                    //. we will not make wait_resp = 1 untill we make sure it is not received duirng sending the beats (i.e., it is not buffered)
                end

                //. I guess we have to make else statement for the intent request to just raise the flag of wait_resp and make number of beats = 1
                else begin
                    beats_no = 1;
                    wait_resp = 1;
                end
            end
            else begin
                counter = counter + 1;

                //. case 3 --> Arithmetic or Logical requests
                if(operation_i > 0) begin
                    if(read_form_buffer == 0)
                        wait_resp = 1;
                end

            end

        end

    end


    //. responses
    //. TO ASK --> can the master receive and send at the same time
    //. I assuem it can't that's why I buffer the data in case it reaches while the master is busy sending
    //. TO ASK --> can we check for the responsed at negative edge of the clock? 
    //. Cause I guess it is one of the RTL requirement to work on one edge of the clock all the time to avoid tconfusing the static timing analysis tools
    always @(negedge clk_i) begin

        if(beats_no == 0 && buffer_index_write == 1) begin //. this means that the first element in the buffer has been seen by the master as it is always ready to accept responses (d_ready = 1)
            buffer_index_read = 1; //. TO ASK: Does reaching here guarantee that the master has seen the first element in the buffer? cause I guess it reads the response in the same cycel of sending it
            buffer_index_write = 0; //. reset the index of writing in the buffer
        end else
            buffer_index_read = 0; //. reset it

        if(valid_o && beats_no > 0) begin
            //. need to decide whether to put in the buffer or not

            //. in case it is a response to the Get or intent request, then no need to buffer the beats
            //. TO ASK: as it is allowed to receive the response to Get/Intent in the same clock cycle of sending the req, should we buffer them?
            if(counter == 0) begin 
                //. case 1 --> 2nd response beat of burst request....so put it in the buffer
                if(read_form_buffer == 1) begin
                    buffer[buffer_index_write] = tl_h_c_d.d_data;
                    buffer_index_read = 0;
                    // wait_resp = 0; // moved down
                end
                //. case 2 --> 1st response beat of burst request....no buffering is needed

                //. case 3 --> response beat to non-burst request (Get/Intent).....no buffering is needed

                beats_no -= 1;
            end

            //. case 2 --> in case it is a response to burst request
            //. then buffer it in case it is the same clock cycle of either first or second beat of the request message
            else if(counter == 1) begin  //. same clock cycle as the request
                buffer[buffer_index_write] = tl_h_c_d.d_data;
                if(beats_no == 2)
                    buffer_index_write += 1; 
                read_form_buffer = 1;
                beats_no -= 1;
            end

            else begin  //. in case the counter = 2 
                buffer[buffer_index_write] = tl_h_c_d.d_data;
                if(beats_no == 2)
                    buffer_index_write += 1;
                read_form_buffer = 1;
                beats_no -= 1;
            end
        
            if(beats_no == 0)
                wait_resp = 0;
        end

    end

// For TL-UH Get opcode all active bytes must have their mask bit set, so all reads get all tl_be
// bits set. For writes the supplied be_i is used as the mask.
    assign tl_be = ~we_i ? {tluh_pkg::TL_DBW{1'b1}} : be_i;

    assign tl_h_c_a = '{
        a_valid:    req_i,
        a_opcode:   (arithmetic_i) ? tluh_pkg::ArithmeticData :
                    (operation_i != 0 & we_i) ? tluh_pkg::LogicalData :
                    (operation_i != 0) ? tluh_pkg::Intent :
                    (~we_i & (operation_i == 0)) ? tluh_pkg::Get :
                    (&be_i) ? tluh_pkg::PutFullData :
                              tluh_pkg::PutPartialData,

        a_param:    (arithmetic_i)? tluh_pkg::tluh_a_param_arith'(operation_i) :
                    (we_i & operation_i > 0)? tluh_pkg::tluh_a_param_log'(operation_i) :
                    (~we_i & operation_i > 0) ? tluh_pkg::tluh_a_param_intent'(operation_i) : '0,
                    
        a_size:     data_width_i,
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