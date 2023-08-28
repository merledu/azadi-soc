module tluh_adapter_reg_tb import tluh_pkg::*; ();

parameter  int RegAw = 6;
parameter  int RegDw = 32; // Shall be matched with TL_DW
localparam int RegBw = RegDw/8;

//. the clk and rst
reg clk_i;
reg rst_ni;

//. counter for the clk cycles
int clk_cnt;

//. the tl interface
tluh_h2d_t tl_i;
tluh_d2h_t tl_o;


logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o;
logic             intent_o;
logic             ie_o;
logic             re_o;  //. read enable
logic             we_o;
logic [RegAw-1:0] addr_o;
logic [RegDw-1:0] wdata_o;
logic [RegBw-1:0] be_o;
logic [RegDw-1:0] rdata_i;
logic             error_i;

//. in case of read request
logic [RegDw-1:0] data_to_read;


// Register Address
// Address width within the block
  parameter int BlockAw = 6;
  parameter logic [BlockAw-1:0] GPIO_INTR_STATE_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] GPIO_INTR_ENABLE_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] GPIO_INTR_TEST_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] GPIO_DATA_IN_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] GPIO_DIRECT_OUT_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] GPIO_MASKED_OUT_LOWER_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] GPIO_MASKED_OUT_UPPER_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] GPIO_DIRECT_OE_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] GPIO_MASKED_OE_LOWER_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] GPIO_MASKED_OE_UPPER_OFFSET = 6'h 24;
  parameter logic [BlockAw-1:0] GPIO_INTR_CTRL_EN_RISING_OFFSET = 6'h 28;
  parameter logic [BlockAw-1:0] GPIO_INTR_CTRL_EN_FALLING_OFFSET = 6'h 2c;
  parameter logic [BlockAw-1:0] GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 6'h 30;
  parameter logic [BlockAw-1:0] GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 6'h 34;
  parameter logic [BlockAw-1:0] GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 6'h 38;
//.

//. data array
logic [RegDw-1:0] data_array [0:14] = '{32'd17, 32'h1, 32'h2, 32'h3, 32'h4, 32'h5, 32'h6, 32'h7, 32'h8, 32'h9, 32'hA, 32'hB, 32'hC, 32'hD, 32'hE};

logic [14:0] addr_hit;
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


tluh_adapter_reg 
#(
  .RegAw(RegAw ),
  .RegDw(RegDw )
  )
tluh_adapter_reg_dut (
  .intention_blocks_o(intention_blocks_o),
  .clk_i    (clk_i ),
  .rst_ni   (rst_ni ),
  .tl_i     (tl_i ),
  .tl_o     (tl_o ),
  .intent_o (intent_o ),
  .ie_o     (ie_o),
  .re_o     (re_o ),
  .we_o     (we_o ),
  .addr_o   (addr_o ),
  .wdata_o  (wdata_o ),
  .be_o     (be_o ),
  .rdata_i  (rdata_i ),
  .error_i  ( error_i)
);

//. clock
always #5 clk_i = ~clk_i;

//. counter
always #10 clk_cnt = clk_cnt + 1'b1;


assign rdata_i = re_o ? data_to_read : 32'd60;


//. make a function to display the error messages
function void validate
  (input tluh_d_m_op opcode,
  input [RegDw-1:0] expected_data,
  input logic ignore_data = 0);
  begin
    $display("Receiving: clk_cnt = %d", clk_cnt);
  
    if (tl_o.d_opcode != opcode) begin
      $display("Error: d_opcode should be %d but it is %d", opcode.name(), tl_o.d_opcode.name());
    end
    if (tl_o.d_size != tl_i.a_size) begin
      $display("Error: d_size should be 2");
    end
    if (tl_o.d_source != tl_i.a_source) begin
      $display("Error: d_source should be 0");
    end
    if(ignore_data == 0) begin
      if (tl_o.d_data != expected_data) begin
        $display("Error: d_data should be %d but it is %d", expected_data, tl_o.d_data);
      end
      else begin
        $display("Success: d_data is %d", tl_o.d_data);
      end
    end
  end
endfunction

task send_req(); 
  begin
    while(~(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1 && clk_i == 1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
    $display("Sending  : clk_cnt = %d", clk_cnt);
  end
endtask

task wait_reg_req();
  begin
    while(~(we_o == 1 && clk_i == 1)) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
  end
endtask

function void validate_reg_req
  (input[RegDw-1:0] wdata,
  input [RegAw-1:0] addr);
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
    while(tl_o.d_valid != 1'b1) begin
      wait(clk_i == 1'b0);
      wait(clk_i == 1'b1);
    end
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
  error_i = 0;

  #10
  rst_ni = 1;
  
//. Read Test ---------------------------------------------------------------
//. test non-burst read request
  tl_i.a_valid = 1'b1;
  $display("Non-burst Read Test -------------------------------------------------");
  send_req(); 
  tl_i.a_valid = 1'b0;
  wait_response();
  //. check the response
  validate(AccessAckData, data_array[0]);
//.


//. test burst read request
  $display("Burst Read Test -----------------------------------------------------");
  tl_i.a_size = 'h3;
  tl_i.a_address = 'h4;
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_response();
  $display("-------first beat--------");
  validate(AccessAckData, data_array[1]);
  wait(clk_i == 1'b0);
  wait(clk_i == 1'b1);
  wait_response();
  $display("-------second beat-------");
  validate(AccessAckData, data_array[2]);
//.


//. Write Test --------------------------------------------------------------
//. test the non-burst write request
  $display("Non-burst Write Test -------------------------------------------------");  
  tl_i.a_size = 'h2;
  tl_i.a_opcode = PutFullData;
  tl_i.a_data = 32'd55;
  tl_i.a_address = 'hc;
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_reg_req();
  validate_reg_req(32'd55, 'hc);
  wait_response();
  validate(AccessAck, '0, 1'b1);
//.


//. test the burst write request
  $display("Burst Write Test -----------------------------------------------------");
  tl_i.a_opcode = PutFullData;
  tl_i.a_size = 'h3;
  tl_i.a_data = 32'd66;
  tl_i.a_address = 'h4;
  tl_i.a_valid = 1'b1;
  //. send the first beeat
  send_req();
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  wait_reg_req();
  validate_reg_req(32'd66, 'h4);
  wait_response();
  validate(AccessAck, '0, 1'b1);
  //. send the second beat
  tl_i.a_data = 32'd77;
  tl_i.a_valid = 1'b1;
  send_req();
  $display("-------second beat--------");
  tl_i.a_valid = 1'b0;
  wait_reg_req();
  validate_reg_req(32'd77, 'h8);
//.

  
#10
//. Atomic Test -------------------------------------------------------------
//. test the non-burst atomic request
  $display("Non-burst Atomic test -------------------------------------------------");
  //. 1- arithemetic
  $display("-------arithemetic--------");
  //. a- min
  $display("-------min--------");
  tl_i.a_opcode = ArithmeticData;
  tl_i.a_size = 'h2;
  tl_i.a_param = 'h0;
  tl_i.a_address = 'h4;  //. data in this location is 1
  tl_i.a_data = 32'd0;
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_reg_req();
  validate_reg_req(32'd0, 'h4);
  wait_response();
  validate(AccessAckData, data_array[1]);
//.


//. test the burst atomic request
  $display("burst Atomic test-------------------------------------------------");
  //. 1- arithemetic
  $display("-------arithemetic--------");
  //. a- min
  $display("-------max--------");
  tl_i.a_valid = 1'b1;
  tl_i.a_size = 'h3;
  tl_i.a_param = 'h1;
  tl_i.a_address = 'h4;
  tl_i.a_data = 32'd5;
  send_req();
  $display("-------first beat--------");
  tl_i.a_valid = 1'b0;
  //. check the wdata_o
  wait_reg_req();
  validate_reg_req(32'd5, 'h4);
  wait_response();
  validate(AccessAckData, data_array[1]);
  //. send the second beat
  tl_i.a_data = 32'd1;
  tl_i.a_valid = 1'b1;
  send_req();
  $display("-------second beat--------");
  tl_i.a_valid = 1'b0;
  wait_reg_req();
  validate_reg_req(32'd2, 'h8);
  wait_response();
  validate(AccessAckData, data_array[2]);
//.


//. Intent Test -------------------------------------------------------------
  $display("Intent test -------------------------------------------------");
  tl_i.a_opcode = Intent;
  tl_i.a_size = 'h2;
  tl_i.a_param = 'h0;
  tl_i.a_valid = 1'b1;
  send_req();
  tl_i.a_valid = 1'b0;
  wait_response();
  validate(HintAck, '0, 1'b1);  
//.



  $display("reach end");
end

endmodule