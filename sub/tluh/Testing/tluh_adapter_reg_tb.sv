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


logic [1:0]       intent_o;
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
  .clk_i    (clk_i ),
  .rst_ni   (rst_ni ),
  .tl_i     (tl_i ),
  .tl_o     (tl_o ),
  .intent_o (intent_o ),
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


//. requests
initial begin


  //. Burst write request
  wait(clk_cnt == 7);
  #1
  $display("Sending data to write to the reg");
  $display("-------first beat--------");
  //. check wdata_o
  if(wdata_o != 32'h5) begin
    $display("ERROR: wdata_o = %h", wdata_o);
  end
  //. check addr_o
  if(addr_o != 32'h4) begin
    $display("ERROR: addr_o = %h", addr_o);
  end

  wait(clk_cnt == 8);
  #1
  $display("Sending data to write to the reg");
  $display("-------second beat--------");
  //. check wdata_o
  if(wdata_o != 32'h6) begin
    $display("ERROR: wdata_o = %h", wdata_o);
  end
  //. check addr_o
  if(addr_o != 32'h8) begin
    $display("ERROR: addr_o = %h", addr_o);
  end

  //. ----------------------------------------------------
  //. Burst atomic request
  wait(clk_cnt == 38);
  tl_i.a_data = 32'hf0ff_ffff;
  wait(tl_o.a_ready);





end


//. responses
initial begin
  // clk_i   = 0;
  // rst_ni  = 0;
  // error_i = 0;
  // #5
  // rst_ni = 1;
  // clk_i  = 1'b1;
  // #10 
  // clk_i  = 1'b1;

  clk_i   = 1;
  rst_ni  = 0;
  error_i = 0;

  #10
  rst_ni = 1;
  //. Read Test ---------------------------------------------------------------
  //. test non-burst read request
  $display("Non-burst Read Test -------------------------------------------------");
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
  wait(tl_o.a_ready == 1'b1 && tl_i.a_valid == 1'b1);
  $display("Sending  : clk_cnt = %d", clk_cnt);

  #11
  wait(tl_o.d_valid == 1'b1);
  //. check the response
  $display("Receiving: clk_cnt = %d", clk_cnt);
  
  if (tl_o.d_valid != 1'b1) begin
    $display("Error: d_valid should be 1");
  end
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData");
  end
  if (tl_o.d_param != 0) begin
    $display("Error: d_param should be 0");
  end
  if (tl_o.d_size != 'h2) begin
    $display("Error: d_size should be 2");
  end
  if (tl_o.d_source != tl_i.a_source) begin
    $display("Error: d_source should be 0");
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (tl_o.d_error != 0) begin
    $display("Error: d_error should be 0");
  end
  if (addr_o != 0) begin
    $display("Error: addr_o should be 0");
  end
  if(re_o != 1'b1) begin
    $display("Error: re_o should be 1");
  end
  if(we_o != 1'b0) begin
    $display("Error: we_o should be 0");
  end
  if(be_o != tl_i.a_mask) begin
    $display("Error: be_o should be %b", tl_i.a_mask);
  end


  //. test the burst read request
  $display("Burst Read Test -------------------------------------------------");
  #10
  tl_i.a_size = 'h3;
  wait(tl_o.a_ready == 1'b1)
  $display("Sending  : clk_cnt = %d", clk_cnt);

  wait(tl_o.d_valid == 1'b1)
  $display("Receiving: clk_cnt = %d", clk_cnt);
  $display("-------first beat--------");
  //. check the response
  if (tl_o.d_valid != 1'b1) begin
    $display("Error: d_valid should be 1 but %b", tl_o.d_valid);
  end
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %b", tl_o.d_opcode);
  end
  if (tl_o.d_param != 0) begin
    $display("Error: d_param should be 0 but it is %b", tl_o.d_param);
  end
  if (tl_o.d_size != 'h3) begin
    $display("Error: d_size should be 3 but it is %b", tl_o.d_size);
  end
  if (tl_o.d_source != tl_i.a_source) begin
    $display("Error: d_source should be 0 but it is %b", tl_o.d_source);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be 3 but it is %b", tl_o.d_data);
  end
  if (addr_o != 0) begin
    $display("Error: addr_o should be 0 but it is %b", addr_o);
  end
  if(re_o != 1'b1) begin
    $display("Error: re_o should be 1");
  end
  if(we_o != 1'b0) begin
    $display("Error: we_o should be 0");
  end
  if(be_o != tl_i.a_mask) begin
    $display("Error: be_o should be %b", tl_i.a_mask);
  end

  #11
  $display("Receiving: clk_cnt = %d", clk_cnt);
  $display("-------second beat--------");
  if (addr_o != 'h4) begin
    $display("Error: addr_o should be 0x4 but it is %x", addr_o);
  end
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %x", tl_o.d_opcode);
  end
  if (tl_o.d_valid != 1'b1) begin
    $display("Error: d_valid should be 1 but %b", tl_o.d_valid);
  end
  if(re_o != 1'b1) begin
    $display("Error: re_o should be 1");
  end
  if(we_o != 1'b0) begin
    $display("Error: we_o should be 0");
  end
  if(be_o != tl_i.a_mask) begin
    $display("Error: be_o should be %b", tl_i.a_mask);
  end




  //. Write Test --------------------------------------------------------------
  //. test the non-burst write request
  $display("Non-burst Write Test -------------------------------------------------");
  tl_i = '{
    a_valid:   1'b1,
    a_opcode:  PutPartialData,
    a_param:   0,
    a_size:    'h2,
    a_mask:    '1,
    a_source:  0,
    a_address: 0,
    a_data:    32'h4,
    d_ready:   1'b1
  };
  wait(tl_o.a_ready == 1'b1)
  $display("Sending  : clk_cnt = %d", clk_cnt);
  
  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  //. check the response
  if (tl_o.d_opcode != AccessAck) begin
    $display("Error: d_opcode should be AccessAck but it is %b", tl_o.d_opcode);
  end
  if (tl_o.d_param != 0) begin
    $display("Error: d_param should be 0");
  end
  if (tl_o.d_size != 'h2) begin
    $display("Error: d_size should be 2 but it is %b", tl_o.d_size);
  end
  if (addr_o != 0) begin
    $display("Error: addr_o should be 0 but it is %b", addr_o);
  end
  if (wdata_o != tl_i.a_data) begin
    $display("Error: wdata_o should be 0x5 but it is %x", wdata_o);
  end
  if(re_o != 1'b0) begin
    $display("Error: re_o should be 0");
  end
  if(we_o != 1'b1) begin
    $display("Error: we_o should be 1");
  end
  if(be_o != tl_i.a_mask) begin
    $display("Error: be_o should be %b", tl_i.a_mask);
  end


  //. test the burst write request
  $display("Burst Write Test -------------------------------------------------");
  tl_i = '{
    a_valid:   1'b1,
    a_opcode:  PutFullData,
    a_param:   0,
    a_size:    'h3,
    a_mask:    '1,
    a_source:  0,
    a_address: 'h4,
    a_data:    32'h5,
    d_ready:   1'b1
  };
  wait(tl_o.a_ready == 1'b1);
  $display("Sending  : clk_cnt = %d", clk_cnt);  //. 9
  $display("-------first beat--------");

  #10
  wait(tl_o.a_ready == 1'b1);
  tl_i.a_data = 32'h6;
  $display("Sending  : clk_cnt = %d", clk_cnt);  //. 10
  $display("-------second beat--------");
  
  //. check the response
  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAck) begin
    $display("Error: d_opcode should be AccessAck but it is %b", tl_o.d_opcode);
  end
  if (tl_o.d_param != 0) begin
    $display("Error: d_param should be 0");
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be 3 but it is %b", tl_o.d_size);
  end

  

  //. Atomic Test -------------------------------------------------------------
  //. test the non-burst atomic request
  $display("Non-burst Atomic test -------------------------------------------------");
  //. 1- arithemetic
  $display("-------arithemetic--------");
  //. a- min
  $display("-------min--------");
  tl_i = '{
    a_valid:   1'b1,
    a_opcode:  ArithmeticData,
    a_param:   'h1,
    a_size:    'h2,
    a_mask:    '1,
    a_source:  0,
    a_address: 'h4, //. 1
    a_data:    32'hff00_0005,
    d_ready:   1'b1
  };
  wait(tl_o.a_ready == 1'b1);
  $display("Sending  : clk_cnt = %d", clk_cnt);

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);

  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hff00_0005) begin
    $display("Error: wdata_o should be 32'hff00_0005 but it is %x", wdata_o);
  end

  
  //. b- max
  $display("-------max--------");
  tl_i.a_param   = 'h2;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  //.tl_i.a_address = 'h4;


  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 'h1) begin
    $display("Error: wdata_o should be 1 but it is %x", wdata_o);
  end

  //. c- minu
  $display("-------minu--------");
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  tl_i.a_param   = 'h3;

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 'h1) begin
    $display("Error: wdata_o should be 5 but it is %x", wdata_o);
  end


  //. d- maxu
  $display("-------maxu--------");
  tl_i.a_param   = 'h4;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hff00_0005) begin
    $display("Error: wdata_o should be 32'hff00_0005 but it is %x", wdata_o);
  end


  //. e- add
  $display("-------add--------");
  tl_i.a_param   = 'h5;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hff00_0006) begin
    $display("Error: wdata_o should be 32'hff00_0006 but it is %x", wdata_o);
  end


  //. 2- logical
  $display("-------logical--------");
  //. a- xor
  $display("-------xor--------");
  tl_i.a_param   = 'h1;
  tl_i.a_opcode  = LogicalData;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);


  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hff00_0005 ^ 'h1) begin
    $display("Error: wdata_o should be 32'hff00_0005 but it is %x", wdata_o);
  end


  //. b- or
  $display("--------or--------");
  tl_i.a_param   = 'h2;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);


  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != (32'hff00_0005 | 'h1)) begin
    $display("Error: wdata_o should be 32'hff00_0005 but it is %x", wdata_o);
  end
  
  //. c- and
  $display("-------and--------");
  tl_i.a_param   = 'h3;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);


  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != (32'hff00_0005 & 'h1)) begin
    $display("Error: wdata_o should be %h but it is %x", (32'hff00_0005 & 'h1), wdata_o);
  end


  //. d- swap
  $display("-------swap-------");
  tl_i.a_param   = 'h4;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);
  

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != tl_i.a_data) begin
    $display("Error: wdata_o should be %h but it is %x", tl_i.a_data, wdata_o);
  end


  //. test the burst atomic request
  $display("-------burst atomic-------");
  $display("-------min--------");
  tl_i.a_opcode  = ArithmeticData;
  tl_i.a_param   = 'h1;
  tl_i.a_data    = 32'hff00_0005;
  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  $display("-------first beat--------");
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hff00_0005) begin
    $display("Error: wdata_o should be 32'hff00_0005 but it is %x", wdata_o);
  end

  wait(tl_o.a_ready == 1);
  $display("Sending  : clk_cnt = %d", clk_cnt);

  wait(tl_o.d_valid == 1'b1);
  $display("Receiving: clk_cnt = %d", clk_cnt);
  $display("-------second beat--------");
  if (tl_o.d_opcode != AccessAckData) begin
    $display("Error: d_opcode should be AccessAckData but it is %d", tl_o.d_opcode);
  end
  if (tl_o.d_param != tl_i.a_param) begin
    $display("Error: d_param should be %d but it is %d", tl_i.a_param, tl_o.d_param);
  end
  if (tl_o.d_size != tl_i.a_size) begin
    $display("Error: d_size should be %d but it is %d", tl_i.a_size, tl_o.d_size);
  end
  if (tl_o.d_data != data_to_read) begin
    $display("Error: d_data should be %d but it is %d", data_to_read, tl_o.d_data);
  end
  if (addr_o != tl_i.a_address) begin
    $display("Error: addr_o should be %x but it is %x", tl_i.a_address, addr_o);
  end
  if(wdata_o != 32'hf0ff_ffff) begin
    $display("Error: wdata_o should be 32'hf0ff_ffff but it is %x", wdata_o);
  end



  //. Intent Test -------------------------------------------------------------

end



endmodule