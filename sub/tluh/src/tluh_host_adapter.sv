// tluh_adapter (Host adapter) converts basic req/grant/rvalid into TL-UH interface. If
// MAX_REQS == 1 it is purely combinational logic. If MAX_REQS > 1 flops are required.
//
// The host driving the adapter is responsible for ensuring it doesn't have more requests in flight
// than the specified MAX_REQS.
//
// The outgoing address is always word aligned. The access size is always the word size (as
// specified by TL_DW). For write accesses that occupy all lanes the operation_i is PutFullData,
// otherwise it is PutPartialData, mask is generated from be_i. For reads all lanes are enabled as
// required by TL-UH (every logic in mask set).
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
    //.input logic                         ready_i,
    input logic [2:0]                   param_i,   //. the parameter determines the type of atomic/intent operation needed
    input logic [tluh_pkg::TL_SZW-1:0]  data_byte_i, //. in the form of Log2(DataWidth/8)
    input logic [1:0]                   operation_i,  //. the 0:arithmetic/ 1:logical/ 2:intent operation to be performed
    input logic                         req_i,
    output logic                        gnt_o,
    input logic [tluh_pkg::TL_AW-1:0]   addr_i, 
    input logic                         we_i,
    input logic [tluh_pkg::TL_DW-1:0]   wdata_i,
    input logic [tluh_pkg::TL_DBW-1:0]  be_i,
    output logic                        valid_o,
    output logic [tluh_pkg::TL_DW-1:0]  rdata_o,
    output logic                        err_o,
// interface with other tilelink agents or tluh interface
    output tluh_pkg::tluh_h2d_t          tl_h_c_a, // tilelink host channel A
    input  tluh_pkg::tluh_d2h_t          tl_h_c_d  // tilelink host channel D
);

    localparam int WordSize = $clog2(tluh_pkg::TL_DBW);

    logic [tluh_pkg::TL_AIW-1:0] tl_source;
    logic [tluh_pkg::TL_DBW-1:0] tl_be;

    logic atomic_req;

    logic wait_resp; //. flag to indicate whether we are waiting for a response or not
    logic new_req;       //. flag to indicate the beginning of a new request
    
    logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_no_to_receive = 0; //. number of beats expected to be received from the slave agent after sending the request
    logic [tluh_pkg::TL_BEATSMAXW-1:0] sent_burst_beat_cnt = 0; //. count the number of sent beats of the request (serves in case of burst requests)
    logic [tluh_pkg::TL_BEATSMAXW-1:0] total_beats_to_send = 0; //. total number of beats of the burst request (used in case of burst requests)

    //. assign the source id of the request
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

            if(req_i && gnt_o && ~wait_resp) begin
                if(source_q == MAX_REQS - 1) source_d = '0;
                else source_d = source_q + 1;
            end
        end

        assign tl_source = tluh_pkg::TL_AIW'(source_q);
    end


    //. requests and responses handling
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            wait_resp           <= 1'b0;
            beats_no_to_receive <= 0;
            sent_burst_beat_cnt <= 0;
        end

        //. requests
        if(req_i && gnt_o) begin
            if(new_req && ~wait_resp) begin //. indicate the beginning of a request
                //. first raise the wait_resp flag to indicate that we are waiting for the response
                wait_resp <= 1;

                //. beats_no_to_receive handling
                if(~we_i || atomic_req) //. Get or Atomic req
                    beats_no_to_receive <= $clog2(data_byte_i);
                else //. put or intent req
                    beats_no_to_receive <= 1;

                //. sent_burst_beat_cnt handling
                if((we_i || atomic_req) && (data_byte_i > $clog2(tluh_pkg::TL_DBW))) begin
                    sent_burst_beat_cnt <= 1;
                    total_beats_to_send <= $clog2(data_byte_i);
                end else begin //. Get or Intent req or any non-burst req
                    sent_burst_beat_cnt <= 0;
                    total_beats_to_send <= 0;
                end       
            end
            else if(~new_req) begin
                sent_burst_beat_cnt <= sent_burst_beat_cnt + 1;
            end
        end

        //. responses
        if(wait_resp && valid_o) begin
            //. only in case receiving the last beat of the burst request, we have to lower the wait_resp flag
            if(beats_no_to_receive == 1) begin  //. if it is the last beat or a non-burst req
                wait_resp           <= 0;
                beats_no_to_receive <= 0;
            end
            else
                beats_no_to_receive <= beats_no_to_receive - 1; 
        end
       
    end

    //. TO ASK: does the following mean that atomic reqs must also have their be_i set to 1?
    // For TL-UH Get opcode all active bytes must have their mask logic set, so all reads get all tl_be
    // logics set. For writes the supplied be_i is used as the mask.
    assign tl_be = (~we_i && (&operation_i)) ? {tluh_pkg::TL_DBW{1'b1}} : be_i;

    assign new_req = (sent_burst_beat_cnt == total_beats_to_send || sent_burst_beat_cnt == 0) ? 1'b1 : 0;  //. it is a new request if all beats are sent or if it is the first beat

    assign atomic_req = (operation_i < 'h2);

    assign tl_h_c_a = '{
        a_valid:    req_i,
        a_opcode:   (operation_i == '0)  ? tluh_pkg::ArithmeticData :
                    (operation_i == 'h1) ? tluh_pkg::LogicalData :
                    (operation_i == 'h2) ? tluh_pkg::Intent :
                    (~we_i)              ? tluh_pkg::Get :
                    (&be_i)              ? tluh_pkg::PutFullData : tluh_pkg::PutPartialData,

        a_param:    param_i,
                    
        a_size:     data_byte_i,
        a_mask:     tl_be,
        a_source:   tl_source,
        a_address:  {addr_i[31:WordSize], {WordSize{1'b0}}},
        a_data:     wdata_i,
        d_ready:    1'b1  // always ready to accept responses --> TO ASK: so no need for a buffer
    };

    assign gnt_o   = tl_h_c_d.a_ready;
    assign err_o   = tl_h_c_d.d_error;
    assign valid_o = tl_h_c_d.d_valid;
    assign rdata_o = tl_h_c_d.d_data;

endmodule