
module tluh_host_adapter_tb import tluh_pkg::*; ();

  // Parameters
  localparam int unsigned MAX_REQS = 1;

  //Ports
  logic  clk_i;
  logic  rst_ni;

  logic [2:0]                  param_i;
  logic [tluh_pkg::TL_SZW-1:0] data_byte_i;
  logic [1:0]                  operation_i;
  logic                        req_i;
  logic                        gnt_o;
  logic [tluh_pkg::TL_AW-1:0]  addr_i;
  logic                        we_i;
  logic [tluh_pkg::TL_DW-1:0]  wdata_i;
  logic [tluh_pkg::TL_DBW-1:0] be_i;
  logic                        valid_o;
  logic [tluh_pkg::TL_DW-1:0]  rdata_o;
  logic                        err_o;

  tluh_pkg::tluh_h2d_t tl_h_c_a;
  tluh_pkg::tluh_d2h_t tl_h_c_d;

  tluh_host_adapter # (
    .MAX_REQS(MAX_REQS)
  )
  tluh_host_adapter_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .param_i(param_i),
    .data_byte_i(data_byte_i),
    .operation_i(operation_i),
    .req_i(req_i),
    .gnt_o(gnt_o),
    .addr_i(addr_i),
    .we_i(we_i),
    .wdata_i(wdata_i),
    .be_i(be_i),
    .valid_o(valid_o),
    .rdata_o(rdata_o),
    .err_o(err_o),
    .tl_h_c_a(tl_h_c_a),
    .tl_h_c_d(tl_h_c_d)
  );

always #5  clk_i = ! clk_i ;

//. counter
int clk_cnt;
always #10 clk_cnt = clk_cnt + 1'b1;


function void host_send_request
  (input logic [2:0]                  param,
   input logic [tluh_pkg::TL_SZW-1:0] data_byte,
   input logic [1:0]                  operation,
   input logic                        req,
   input logic [tluh_pkg::TL_AW-1:0]  addr,
   input logic                        we,
   input logic [tluh_pkg::TL_DW-1:0]  wdata,
   input logic [tluh_pkg::TL_DBW-1:0] be);
  begin
    data_byte_i = data_byte;
    param_i     = param;
    operation_i = operation;
    req_i       = req;
    addr_i      = addr;
    we_i        = we;
    wdata_i     = wdata;
    be_i        = be;
  end
endfunction 

task wait_adapter_to_send_request();
  begin
    while(~(gnt_o == 1 && tl_h_c_a.a_valid == 1 && clk_i == 1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
    $display("Sending Req: clk_cnt = %d", clk_cnt);
    tl_h_c_d.a_ready  = 1'b0;
  end
endtask

function void validate_adapter_request
  (input tluh_a_m_op req_operation,
   input logic ignore_data = 0);
  begin
    //.$display("Receiving Req: clk_cnt = %d", clk_cnt);
  
    if (tl_h_c_a.a_opcode != req_operation) begin
      $display("Error: a_opcode should be %d but it is %d", req_operation.name(), tl_h_c_a.a_opcode.name());
    end
    if (tl_h_c_a.a_size != data_byte_i) begin
      $display("Error: a_size should be %d but it is %d", data_byte_i, tl_h_c_a.a_size);
    end
    if (tl_h_c_a.a_source != 0) begin
      $display("Error: a_source should be 0");
    end
    if (tl_h_c_a.a_address != addr_i) begin
      $display("Error: a_address should be %d but it is %d", addr_i, tl_h_c_a.a_address);
    end
    if(ignore_data == 0) begin
      if (tl_h_c_a.a_data != wdata_i) begin
        $display("Error: a_data should be %d but it is %d", $signed(wdata_i), $signed(tl_h_c_a.a_data));
        //.$display("a_valid = %d and the clk_cnt now is = %d ", tl_h_c_a.a_valid, clk_cnt);
      end
      else begin
        $display("Success: a_data is %d", tl_h_c_a.a_data);
      end
    end
  end
endfunction

function void respond_to_adapter
  (input tluh_d_m_op opcode,
  input [tluh_pkg::TL_DW-1:0] data = '0,
  input logic error = 0);
  begin
    tl_h_c_d.d_valid  = 1'b1;
    tl_h_c_d.d_opcode = opcode;
    tl_h_c_d.d_param  = 0;
    tl_h_c_d.d_size   = tl_h_c_a.a_size;
    tl_h_c_d.d_source = 0;
    tl_h_c_d.d_sink   = 0;
    tl_h_c_d.d_data   = data;
    tl_h_c_d.d_error  = error;
    tl_h_c_d.a_ready  = 1'b0;
  end
endfunction

task wait_adapter_to_receive_respond();
  begin
    while(~(tl_h_c_d.d_valid == 1 && tl_h_c_a.d_ready == 1 && clk_i == 1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
  end
endtask

task wait_adapter_responce();
  begin
    while(valid_o != 1'b1) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
  end
endtask

function void validate_adapter_read_respond (
    input [tluh_pkg::TL_DW-1:0] expected_rdata
);
    begin
        if(rdata_o != expected_rdata) begin
            $display("Error: rdata_o should be %d but it is %d", expected_rdata, rdata_o);
        end
        else begin
            $display("Success: rdata_o = %d", rdata_o);
        end

    end
endfunction

function void validate_adapter_write_respond ();
    begin
        if(err_o != 0) begin
            $display("Error: err_o should be %d but it is %d", 0, err_o);
        end
        else begin
            $display("Success: err_o = %d", err_o);
        end

    end
endfunction




initial begin
    clk_i = 1;
    rst_ni = 0;

    tl_h_c_d = '{
        d_valid: 0,
        d_opcode: '0,
        d_param: '0,
        d_size: '0,
        d_source: '0,
        d_sink: '0,
        d_data: '0,
        d_error: '0,
        a_ready: 1
    };

    #10
    rst_ni = 1;

    #10

// param_i,
// data_byte_i,
// operation_i,  the 0:arithmetic/ 1:logical/ 2:intent operation to be performed
// req_i,
// addr_i, 
// we_i,
// wdata_i,
// be_i,


//. Read request
    //. non-burst
    $display("Non-burst Read Test -------------------------------------------------");
    host_send_request('d0, 'd2, 'd3, 1, 'd0, 0, 'd0, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::Get, 1);
    req_i = 1'b0;
    respond_to_adapter(AccessAckData, 32'd17);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond(32'd17);
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;


    //. burst
    $display("burst Read Test ------------------------------------------------------");
    $display("first and only beat ------------------------------------------------------");
    host_send_request('d0, 'd3, 'd3, 1, 'd4, 0, 'd0, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::Get, 1);
    req_i = 1'b0;
    //. respond by the first beat
    respond_to_adapter(AccessAckData, 32'd1);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond(32'd1);
    #10
    //. respond by the second beat
    respond_to_adapter(AccessAckData, 32'd2);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond(32'd2);

    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;

//.
    
    
//. Write request
    //. non-burst
    $display("Non-burst Write Test -------------------------------------------------");
    host_send_request('d0, 'd2, 'd3, 1, 'd0, 1, 'd5, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::PutFullData, 1);
    req_i = 1'b0;
    respond_to_adapter(AccessAck);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_write_respond();
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;


    //. burst
    $display("burst Write Test -----------------------------------------------------");
    $display("first beat ------------------------------------------------------");
    host_send_request('d0, 'd3, 'd3, 1, 'd12, 1, 'd3, 'd2);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::PutPartialData, 1);
    req_i = 1'b0;
    respond_to_adapter(AccessAck);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_write_respond();
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;

    $display("second beat ------------------------------------------------------");
    host_send_request('d0, 'd3, 'd3, 1, 'd12, 1, 'd4, 'd2);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::PutPartialData, 1);
    req_i = 1'b0;
    validate_adapter_write_respond();
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;
//.    
    
    wait(clk_i == 0);
    wait(clk_i == 1); 
//. Atomic request
    //. non-burst
    $display("Non-burst Atomic Test -------------------------------------------------");
    host_send_request('d0, 'd2, 'd0, 1, 'd0, 0, 'd5, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::ArithmeticData);
    req_i = 1'b0;
    respond_to_adapter(AccessAckData,'d17);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond('d17);
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;


    //. burst
    $display("burst Atomic Test -----------------------------------------------------");
    $display("first beat ------------------------------------------------------");
    host_send_request('d1, 'd3, 'd1, 1, 'd4, 0, 'd6, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::LogicalData);
    req_i = 1'b0;
    respond_to_adapter(AccessAckData,'d1);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond('d1);
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;

    $display("second beat ------------------------------------------------------");
    host_send_request('d1, 'd3, 'd1, 1, 'd4, 0, 'd7, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::LogicalData);
    req_i = 1'b0;
    respond_to_adapter(AccessAckData,'d2);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_read_respond('d2);
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;
//.  
    
    
//. Intent request
    $display("Intent Request Test -------------------------------------------------");
    host_send_request('d0, 'd2, 'd2, 1, 'd0, 0, 'd0, '1);
    wait_adapter_to_send_request();
    tl_h_c_d.a_ready  = 1'b0;
    validate_adapter_request(tluh_pkg::Intent, 1);
    req_i = 1'b0;
    respond_to_adapter(HintAck);
    wait_adapter_to_receive_respond();
    wait_adapter_responce();
    validate_adapter_write_respond();
    tl_h_c_d.d_valid = 1'b0;
    tl_h_c_d.a_ready = 1'b1;
//.



    $display("reach end");
end

endmodule

