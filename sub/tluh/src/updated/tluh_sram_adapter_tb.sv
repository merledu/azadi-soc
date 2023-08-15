module tluh_sram_adapter_tb import tluh_pkg::*; ();


parameter int SramDw      = 32;
parameter int SramAw      = 12;
localparam int SramByte = SramDw/8;
//. the clk and rst
reg clk_i;
reg rst_ni;

//. counter for the clk cycles
int clk_cnt;

//. the tl interface
tluh_h2d_t tl_i;
tluh_d2h_t tl_o;

logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o; //. intention blocks
logic [1:0]        intent_o;  //. intent operation (prefetchRead, prefetchWrite)
logic              intent_en_o; //. intent enable
logic              req_o;
logic              gnt_i;
logic              we_o;
logic [SramAw-1:0] addr_o;
logic [SramDw-1:0] wdata_o;
logic [SramDw-1:0] wmask_o;
logic [SramDw-1:0] rdata_i;
logic              rvalid_i;
logic [1:0]        rerror_i; // 2 bit error [1]: Uncorrectable, [0]: Correctable

//. in case of read request
logic [SramDw-1:0] data_to_read;

assign rerror_i = '0;
assign gnt_i = '1;


// Memory Address
// Address width within the block
  parameter int MemAw = 12;
  parameter logic [MemAw-1:0] GPIO_INTR_STATE_OFFSET = 12'h 0;
  parameter logic [MemAw-1:0] GPIO_INTR_ENABLE_OFFSET = 12'h 4;
  parameter logic [MemAw-1:0] GPIO_INTR_TEST_OFFSET = 12'h 8;
  parameter logic [MemAw-1:0] GPIO_DATA_IN_OFFSET = 12'h c;
  parameter logic [MemAw-1:0] GPIO_DIRECT_OUT_OFFSET = 12'h 10;
  parameter logic [MemAw-1:0] GPIO_MASKED_OUT_LOWER_OFFSET = 12'h 14;
  parameter logic [MemAw-1:0] GPIO_MASKED_OUT_UPPER_OFFSET = 12'h 18;
  parameter logic [MemAw-1:0] GPIO_DIRECT_OE_OFFSET = 12'h 1c;
  parameter logic [MemAw-1:0] GPIO_MASKED_OE_LOWER_OFFSET = 12'h 20;
  parameter logic [MemAw-1:0] GPIO_MASKED_OE_UPPER_OFFSET = 12'h 24;
  parameter logic [MemAw-1:0] GPIO_INTR_CTRL_EN_RISING_OFFSET = 12'h 28;
  parameter logic [MemAw-1:0] GPIO_INTR_CTRL_EN_FALLING_OFFSET = 12'h 2c;
  parameter logic [MemAw-1:0] GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 12'h 30;
  parameter logic [MemAw-1:0] GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 12'h 34;
  parameter logic [MemAw-1:0] GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 12'h 38;
//.

//. data array
logic [SramDw-1:0] data_array [0:14] = '{32'd17, 32'h1, 32'h2, 32'h3, 32'h4, 32'h5, 32'h6, 32'h7, 32'h8, 32'h9, 32'hA, 32'hB, 32'hC, 32'hD, 32'hE};

logic [14:0] addr_hit;  //. assume we have only 15 locations although we have 4k locatoins each contains 2 words
always_comb begin
  addr_hit = '0;
  addr_hit[ 0] = (addr_o == GPIO_INTR_STATE_OFFSET);
  addr_hit[ 1] = (addr_o == GPIO_INTR_ENABLE_OFFSET);
  addr_hit[ 2] = (addr_o == GPIO_INTR_TEST_OFFSET);
  addr_hit[ 3] = (addr_o == GPIO_DATA_IN_OFFSET);
  addr_hit[ 4] = (addr_o == GPIO_DIRECT_OUT_OFFSET);
  addr_hit[ 5] = (addr_o == GPIO_MASKED_OUT_LOWER_OFFSET);
  addr_hit[ 6] = (addr_o == GPIO_MASKED_OUT_UPPER_OFFSET);
  addr_hit[ 7] = (addr_o == GPIO_DIRECT_OE_OFFSET);
  addr_hit[ 8] = (addr_o == GPIO_MASKED_OE_LOWER_OFFSET);
  addr_hit[ 9] = (addr_o == GPIO_MASKED_OE_UPPER_OFFSET);
  addr_hit[10] = (addr_o == GPIO_INTR_CTRL_EN_RISING_OFFSET);
  addr_hit[11] = (addr_o == GPIO_INTR_CTRL_EN_FALLING_OFFSET);
  addr_hit[12] = (addr_o == GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET);
  addr_hit[13] = (addr_o == GPIO_INTR_CTRL_EN_LVLLOW_OFFSET);
  addr_hit[14] = (addr_o == GPIO_CTRL_EN_INPUT_FILTER_OFFSET);
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


//.assign rdata_i = data_to_read;//. (~we_o) ? data_to_read : 32'd60;


always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    rvalid_i <= 1'b0;
    rdata_i <= '0;
  end else if (we_o) begin
    rvalid_i <= 1'b0;
  end else begin
    rvalid_i <= req_o;
    if(req_o)
      rdata_i  <= data_to_read;
  end
end

//assign rvalid_i = req_o && ~we_o;


//. make a function to display the error messages
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
        $display("d_valid = %d and the clk_cnt now is = %d ", tl_o.d_valid, clk_cnt);
      end
      else begin
        $display("Success: d_data is %d", tl_o.d_data);
      end
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

initial begin
  wait(clk_cnt == 4)
  tl_i.a_valid = 1'b0;
end

//. responses
initial begin
  //. inital values
  tl_i = '{
    a_valid:   1'b1,
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
  #10
  $display("Non-burst Read Test -------------------------------------------------");
  wait(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  wait_response();
  //. check the response
  validate(AccessAckData, data_array[0]);
//.

  //. TO ASK
  // tl_i.a_valid = 0;
  // #10

//. test burst read request
  $display("Burst Read Test -----------------------------------------------------");
  tl_i.a_valid = 1'b1;
  tl_i.a_size = 'h3;
  tl_i.a_address = 'h4;
  wait(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  wait_response();
  tl_i.a_valid = 1'b0;
  $display("-------first beat--------");
  validate(AccessAckData, data_array[1]);
  //.tl_i.a_valid = 1'b0;
  //#20
  wait(clk_i == 1'b1);
  wait_response();
  $display("-------second beat-------");
  validate(AccessAckData, data_array[2]);
//.



//. Write Test --------------------------------------------------------------
//. test the non-burst write request
  $display("Non-burst Write Test -------------------------------------------------");  
  tl_i.a_size = 'h2;
  tl_i.d_ready = 1'b0;  //. TO ASK
  tl_i.a_valid = 1'b1;
  tl_i.a_opcode = PutFullData;
  tl_i.a_data = 32'd55;
  tl_i.a_address = 'h0;
  while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  tl_i.a_valid = 1'b0;
  $display("Sending  : clk_cnt = %d", clk_cnt);
  wait(req_o == 1'b1 && we_o == 1'b1);
  if(wdata_o != 32'd55) begin
    $display("Error: wdata_o should be 32'd55 but it is %d", wdata_o);
  end
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end
  tl_i.d_ready = 1'b1;
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
  //wait(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1);
  while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  $display("Sending  : clk_cnt = %d", clk_cnt);
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  while(~(req_o == 1 && we_o == 1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  if(wdata_o != 32'd66) begin
    $display("Error: wdata_o should be 32'd66 but it is %d", wdata_o);
  end
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end
  wait_response();
  validate(AccessAck, '0, 1'b1);
  //. send the second beeat
  wait(clk_i == 1'b0);
  wait(clk_i == 1'b1);
  tl_i.a_data = 32'd77;
  tl_i.a_valid = 1'b1;
  while(tl_o.a_ready != 1'b1) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  $display("Sending  : clk_cnt = %d", clk_cnt);
  $display("-------second beat--------");
  
  while(~(req_o == 1 && we_o == 1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  tl_i.a_valid = 1'b0;
  if(wdata_o != 32'd77) begin
    $display("Error: wdata_o should be 32'd77 but it is %d", wdata_o);
  end
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end
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
  while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  $display("Sending  : clk_cnt = %d", clk_cnt);
  tl_i.a_valid = 1'b0;
  while(~(req_o == 1 && we_o == 1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  if(wdata_o != 32'h3)
    $display("Error: wdata_o should be 32'h2 but it is %d", wdata_o);
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end
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
  while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  $display("Sending  : clk_cnt = %d", clk_cnt);
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  while(~(req_o == 1 && we_o == 1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  //. check the wdata_o
  if(wdata_o != 32'h5)
    $display("Error: wdata_o should be 32'h5 but it is %d", wdata_o);
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end  
  wait_response();
  validate(AccessAckData, data_array[1]);
  //. send the second beat
  tl_i.a_valid = 1'b1;
  tl_i.a_data = 32'd0;
  while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  $display("Sending  : clk_cnt = %d", clk_cnt);
  $display("-------second beat--------");
  tl_i.a_valid = 1'b0;
  while(~(req_o == 1 && we_o == 1)) begin
    wait(clk_i == 1'b0);
    wait(clk_i == 1'b1);
  end
  if(wdata_o != 32'h2)
    $display("Error: wdata_o should be 32'h2 but it is %d", wdata_o);
  else begin
    $display("Success: wdata_o = %d", wdata_o);
  end 
  wait_response();
  validate(AccessAckData, data_array[2]);
//.


  $display("reach end");
end

endmodule