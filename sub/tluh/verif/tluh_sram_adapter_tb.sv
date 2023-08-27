module tluh_sram_adapter_tb import tluh_pkg::*; ();


parameter int SramDw      = 32;
parameter int SramAw      = 12;
localparam int SramByte = SramDw/8;
localparam int DataBitWidth = tluh_pkg::vbits(SramByte);
//. the clk and rst
reg clk_i;
reg rst_ni;

//. counter for the clk cycles
int clk_cnt;

//. the tl interface
tluh_h2d_t tl_i;
tluh_d2h_t tl_o;

logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o;
logic              intent_o;
logic              intent_en_o;
logic              req_o;
logic              gnt_i;
logic              we_o;
logic [SramAw-1:0] addr_o;
logic [SramDw-1:0] wdata_o;
logic [SramDw-1:0] wmask_o;
logic [SramDw-1:0] rdata_i;
logic              rvalid_i;
logic [1:0]        rerror_i;

//. in case of read request
logic [SramDw-1:0] data_to_read;

assign rerror_i = '0;
assign gnt_i = '1;


// Memory Address
// Address width within the block
  parameter int MemAw = 12;
  parameter logic [MemAw-1:0] LOC_0 = 12'h 0;
  parameter logic [MemAw-1:0] LOC_1 = 12'h 1;
  parameter logic [MemAw-1:0] LOC_2 = 12'h 2;
  parameter logic [MemAw-1:0] LOC_3 = 12'h 3;
  parameter logic [MemAw-1:0] LOC_4 = 12'h 4;
  parameter logic [MemAw-1:0] LOC_5 = 12'h 5;
  parameter logic [MemAw-1:0] LOC_6 = 12'h 6;
  parameter logic [MemAw-1:0] LOC_7 = 12'h 7;
  parameter logic [MemAw-1:0] LOC_8 = 12'h 8;
  parameter logic [MemAw-1:0] LOC_9 = 12'h 9;
  parameter logic [MemAw-1:0] LOC_A = 12'h A;
  parameter logic [MemAw-1:0] LOC_B = 12'h B;
  parameter logic [MemAw-1:0] LOC_C = 12'h C;
  parameter logic [MemAw-1:0] LOC_D = 12'h D;
  parameter logic [MemAw-1:0] LOC_E = 12'h E;
//.

//. data array
logic [SramDw-1:0] data_array [0:14] = '{32'd17, 32'h1, 32'h2, 32'h3, 32'h4, 32'h5, 32'h6, 32'h7, 32'h8, 32'h9, 32'hA, 32'hB, 32'hC, 32'hD, 32'hE};

logic [14:0] addr_hit;  //. assume we have only 15 locations although we have 4k locatoins each contains 2 words
always_comb begin
  addr_hit = '0;
  addr_hit[ 0] = (addr_o == LOC_0);
  addr_hit[ 1] = (addr_o == LOC_1);
  addr_hit[ 2] = (addr_o == LOC_2);
  addr_hit[ 3] = (addr_o == LOC_3);
  addr_hit[ 4] = (addr_o == LOC_4);
  addr_hit[ 5] = (addr_o == LOC_5);
  addr_hit[ 6] = (addr_o == LOC_6);
  addr_hit[ 7] = (addr_o == LOC_7);
  addr_hit[ 8] = (addr_o == LOC_8);
  addr_hit[ 9] = (addr_o == LOC_9);
  addr_hit[10] = (addr_o == LOC_A);
  addr_hit[11] = (addr_o == LOC_B);
  addr_hit[12] = (addr_o == LOC_C);
  addr_hit[13] = (addr_o == LOC_D);
  addr_hit[14] = (addr_o == LOC_E);
end


// Read data return
always_comb begin
  data_to_read = '0;
  unique case (1'b1)
    addr_hit[0]: begin
      data_to_read[31:0] = 32'd17;
    end

    addr_hit[1]: begin
      data_to_read[31:0] = 32'h1;
    end

    addr_hit[2]: begin
      data_to_read[31:0] = 32'h2;
    end

    addr_hit[3]: begin
      data_to_read[31:0] = 32'h3;
    end

    addr_hit[4]: begin
      data_to_read[31:0] = 32'h4;
    end

    addr_hit[5]: begin
      data_to_read[31:0] = 32'h5;
    end

    addr_hit[6]: begin
      data_to_read[31:0] = 32'h6;
    end

    addr_hit[7]: begin
      data_to_read[31:0] = 32'h7;
    end

    addr_hit[8]: begin
      data_to_read[31:0] = 32'h8;
    end

    addr_hit[9]: begin
      data_to_read[31:0] = 32'h9;
    end

    addr_hit[10]: begin
      data_to_read[31:0] = 32'hA;
    end

    addr_hit[11]: begin
      data_to_read[31:0] = 32'hB;
    end

    addr_hit[12]: begin
      data_to_read[31:0] = 32'hC;
    end

    addr_hit[13]: begin
      data_to_read[31:0] = 32'hD;
    end

    addr_hit[14]: begin
      data_to_read[31:0] = 32'hE;
    end

    default: begin
      data_to_read = '1;
    end
  endcase
end


tluh_sram_adapter
  tluh_sram_adapter_inst (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .tl_i(tl_i),
    .tl_o(tl_o),
    .intention_blocks_o(intention_blocks_o),
    .intent_o(intent_o),
    .intent_en_o(intent_en_o),
    .req_o(req_o),
    .gnt_i(gnt_i),
    .we_o(we_o),
    .addr_o(addr_o),
    .wdata_o(wdata_o),
    .wmask_o(wmask_o),
    .rdata_i(rdata_i),
    .rvalid_i(rvalid_i),
    .rerror_i(rerror_i)
  );

//. clock
always #5 clk_i = ~clk_i;

//. counter
always #10 clk_cnt = clk_cnt + 1'b1;



always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    rvalid_i <= 1'b0;
    rdata_i <= '0;
  end else if (we_o || intent_en_o) begin  //. TO ASK: intent_en_o
    rvalid_i <= 1'b0;
  end else begin
    rvalid_i <= req_o;
    if(req_o)
      rdata_i  <= data_to_read;
  end
end




function void validate
  (input tluh_d_m_op opcode,
  input [SramDw-1:0] expected_data,
  input logic ignore_data = 0);
  begin
    $display("Receiving: clk_cnt = %d", clk_cnt);
  
    if (tl_o.d_opcode != opcode) begin
      $display("Error: d_opcode should be %d but it is %d", opcode.name(), tl_o.d_opcode.name());
    end
    if (tl_o.d_size != tl_i.a_size) begin
      $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
    end
    if (tl_o.d_source != tl_i.a_source) begin
      $display("Error: d_source should be 0");
    end
    if(ignore_data == 0) begin
      if (tl_o.d_data != expected_data) begin
        $display("Error: d_data should be %d but it is %d", $signed(expected_data), $signed(tl_o.d_data));
      end
      else begin
        $display("Success: d_data is %d", tl_o.d_data);
      end
    end
  end
endfunction

task wait_sram_req();
  begin
    while(~(req_o == 1 && we_o == 1 && clk_i == 1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
  end
endtask

function void validate_sram_req
  (input[SramDw-1:0] wdata,
  input [SramAw-1:0] addr);
  begin
    if(wdata_o != wdata) begin
      $display("Error: wdata_o should be %d but it is %d", wdata, wdata_o);
    end
    else begin
      $display("Success: wdata_o = %d", wdata_o);
    end
    if(addr_o != addr) begin
      $display("Error: addr_o should be %d but it is %d", addr, addr_o);
    end
    else begin
      $display("Success: addr_o = %d", addr_o);
    end
  end
endfunction

task wait_response();
  begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
    while(tl_o.d_valid != 1'b1) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
  end
endtask

task send_req(); 
  begin
    while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
    $display("Sending  : clk_cnt = %d", clk_cnt);
  end
endtask


initial begin
  //. inital values
  tl_i = '{
    a_valid:   1'b0,
    a_opcode:  Get,
    a_param:   0,
    a_size:    'h2,
    a_mask:    '1,
    a_source:  0,
    a_address: 0,
    a_data:    '0,
    d_ready:   1'b1
  };

  clk_i   = 1;
  rst_ni  = 0;

  #10
  rst_ni = 1;

//. Read Test ---------------------------------------------------------------
//. test non-burst read request
  $display("Non-burst Read Test -------------------------------------------------");
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_response();
  //. check the response
  validate(AccessAckData, data_array[0]);
//.



//. test burst read request
  $display("Burst Read Test -----------------------------------------------------");
  tl_i.a_valid = 1'b1;
  tl_i.a_size = 'h3;
  tl_i.a_address = 'h4;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_response();
  $display("-------first beat--------");
  validate(AccessAckData, data_array[1]);
  wait_response();
  $display("-------second beat-------");
  validate(AccessAckData, data_array[5]);
//.



//. Write Test --------------------------------------------------------------
//. test the non-burst write request
  $display("Non-burst Write Test -------------------------------------------------");  
  tl_i.a_size = 'h2;
  tl_i.a_valid = 1'b1;
  tl_i.a_opcode = PutFullData;
  tl_i.a_data = 32'd55;
  tl_i.a_address = 'h0;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'd55, '0);
  wait_response();
  validate(AccessAck, '0, 1'b1);

//.

#10
//. test the burst write request
  $display("Burst Write Test -----------------------------------------------------");
  tl_i.a_valid = 1'b1;
  tl_i.a_opcode = PutFullData;
  tl_i.a_size = 'h3;
  tl_i.a_data = 32'd66;
  //. send the first beat
  send_req();
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'd66, '0);
  wait_response();
  validate(AccessAck, '0, 1'b1);
  //. send the second beeat
  wait(clk_i == 1'b0);
  wait(clk_i == 1'b1);
  tl_i.a_data = 32'd77;
  tl_i.a_valid = 1'b1;
  send_req();
  $display("-------second beat--------");
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'd77,'d4);
//.

  
  #10
//. Atomic Test --------------------------------------------------------------
//. test non-burst atomic request
  $display("Non-burst Atomic test -------------------------------------------------");
  //. 1- arithemetic
  $display("-------arithemetic--------");
  //. a- min
  $display("-------min--------");
  tl_i.a_opcode = ArithmeticData;
  tl_i.a_size = 'h2;
  tl_i.a_param = 'h0;
  tl_i.a_address = 'hc;
  tl_i.a_data = 32'd5;
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'h3,tl_i.a_address[DataBitWidth+:SramAw]);
  wait_response();
  validate(AccessAckData, data_array[3]);
//.



//. test the burst atomic request
  $display("burst Atomic test-------------------------------------------------");
  //. 1- arithemetic
  $display("-------arithemetic--------");
  //. a- min
  $display("-------max--------");
  tl_i.a_size = 'h3;
  tl_i.a_param = 'h1;
  tl_i.a_address = 'h4;
  tl_i.a_data = 32'd5;
  tl_i.a_valid = 1'b1;
  send_req();
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'h5,tl_i.a_address[DataBitWidth+:SramAw]);
  wait_response();
  validate(AccessAckData, data_array[1]);
  //. send the second beat
  tl_i.a_valid = 1'b1;
  tl_i.a_data = 32'd4;
  send_req();
  $display("-------second beat--------");
  tl_i.a_valid = 1'b0;
  wait_sram_req();
  validate_sram_req(32'h5, tl_i.a_address[DataBitWidth+:SramAw] + 4);
  wait_response();
  validate(AccessAckData, data_array[5]);
//.



//. Intent Test -------------------------------------------------------------
  $display("Intent test -------------------------------------------------");
  tl_i.a_valid = 1'b1;
  tl_i.a_opcode = Intent;
  tl_i.a_size = 'h2;
  tl_i.a_address = 'h2;
  tl_i.a_param = 'h0;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_response();
  validate(HintAck, '0, 1'b1);  
//.


  $display("reach end");
end

endmodule