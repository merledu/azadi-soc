module tluh_adapter_reg import tluh_pkg::*; #(
  parameter  int RegAw = 8,
  parameter  int RegDw = 32, // Shall be matched with TL_DW
  localparam int RegBw = RegDw/8
) (
  input logic clk_i,
  input logic rst_ni,

  // TL-UL interface
  input  tluh_h2d_t tl_i,
  output tluh_d2h_t tl_o,

  // Register interface
  output logic [1:0]       intent_o,
  output logic             re_o,  //. read enable
  output logic             we_o,
  output logic [RegAw-1:0] addr_o,
  output logic [RegDw-1:0] wdata_o,
  output logic [RegBw-1:0] be_o,
  input  logic [RegDw-1:0] rdata_i,
  input  logic             error_i
);

  localparam int IW  = $bits(tl_i.a_source);
  localparam int SZW = $bits(tl_i.a_size);

  logic outstanding;    // Indicates current request is pending
  logic a_ack, d_ack;

  logic [RegDw-1:0] rdata;
  logic [RegDw-1:0] wdata;
  logic             error, err_internal;

  logic addr_align_err;     // Size and alignment
  logic tl_err;             // Common TL-UL error checker

  logic [IW-1:0]         reqid;
  logic [SZW-1:0]        reqsz;
  tluh_pkg::tluh_d_m_op  rspop;

  logic rd_req, wr_req, intent_req;



  //. Atomic request
  logic [tluh_pkg::TL_DW-1:0]  op_data1;
  logic [tluh_pkg::TL_DW-1:0]  op_data2;
  logic [tluh_pkg::TL_DW-1:0]  op_result;
  logic [RegAw-1:0]            op_addr;
  logic [2:0]                  op_function;
  bit                          op_rvalid;  //. result valid
  bit                          op_cin;
  bit                          op_cout;
  bit                          op_type;   //. 1: arithmetic, 0: logical
  bit                          op_enable;
  logic [tluh_pkg::TL_DBW-1:0] op_mask;
  int                          op_beat_no = 0;
  int                          total_beats = 0;
  logic                        op_burst_enable = 0;

  assign a_ack   = tl_i.a_valid & tl_o.a_ready;
  assign d_ack   = tl_o.d_valid & tl_i.d_ready;
  // Request signal
  //assign wr_req     = a_ack & logic'(tl_i.a_opcode inside {PutFullData, PutPartialData, ArithmeticData, LogicalData});  //. TODO
  //assign rd_req     = a_ack & logic'(tl_i.a_opcode inside {Get, ArithmeticData, LogicalData});  //. TODO
  //assign intent_req = a_ack & (tl_i.a_opcode == Intent);

  assign we_o     = wr_req & ~err_internal;
  assign re_o     = rd_req & ~err_internal;
 //. assign addr_o   = {tl_i.a_address[RegAw-1:2], 2'b00}; // generate always word-align  //. TODO: in case of burst response, it should be changed
  assign wdata_o  = op_rvalid ? op_result : wdata;  //. TODO: in case of atomic, it should be op_result
  //.assign be_o     = op_rvalid ? op_mask   : tl_i.a_mask;
  assign intent_o = (a_ack & (tl_i.a_opcode == Intent)) ? tl_i.a_param : 0;

  assign op_data2 = rd_req ? rdata_i : op_data2;

  //. Get
  typedef enum logic {  //. State machine states
    GET_IDLE,
    READ_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } get_state_t;

  get_state_t get_state;
  bit get_burst_enable = 0;
  int beat_no = 0;  //. TODO: change the type to logic of 2 bits


  //. Put
  typedef enum logic {  //. State machine states
    PUT_IDLE,
    WRITE_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } put_state_t;

  put_state_t put_state;
  bit put_burst_enable = 0;
  int put_beat_no = 0;  

  //. Atomic
  typedef enum logic [1:0] {  //. State machine states
    ATOMIC_IDLE,
    PERFORM_WRITE,  //. perform the operation and write the result to the register
    NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } atomic_state_t;
  
  atomic_state_t atomic_state;
  bit wait_next_beat  = 0;
  int beats_sent      = 0;
  int beats_received  = 0;

  


  //. Begin: Get response ------------------------------------------------------------------------------------
  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) get_state <= GET_IDLE;
    else begin
      if (d_ack && (get_state == GET_IDLE) && (atomic_state != PERFORM_WRITE)) outstanding = 1'b0;
      if(get_state != GET_IDLE && beat_no == 0) begin 
        get_state         = GET_IDLE;
        get_burst_enable <= 0;
        //.rd_req           = 0;
      end
      case(get_state)
        GET_IDLE: begin
          if((a_ack || (~outstanding && tl_i.a_valid)) && tl_i.a_opcode == Get) begin
            rspop       <= AccessAckData;
            addr_o      <= {tl_i.a_address[RegAw-1:2], 2'b00};
            wr_req      <= 0;
            rd_req      <= 1'b1;
            outstanding <= 1'b1;  
            be_o        <= tl_i.a_mask;

            reqid       <= tl_i.a_source;
            reqsz       <= tl_i.a_size;

            if(tl_i.a_size > $clog2(TL_DBW)) begin
              get_state        <= READ_NEXT_BEAT;
              get_burst_enable <= 1'b1;
              beat_no          <= $clog2(tl_i.a_size) - 1;
            end
          end
        end

        READ_NEXT_BEAT: begin
          //. make sure the master received the previous beat
          if(d_ack) begin
            addr_o  <= (addr_o + RegBw) % (2**RegAw);
            beat_no <= beat_no - 1;
          end

        end
      endcase
    end
  end
  //. End: Get response



  //. Begin: Put response & Hint response ------------------------------------------------------------------------------------
  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) put_state <= PUT_IDLE;
    else begin
      if(put_state != PUT_IDLE && put_beat_no == 0) begin
        rspop            <= AccessAck;
        outstanding      = 1'b1;
        put_state        = PUT_IDLE;
        put_burst_enable <= 0;
        //.wr_req           = 0; 
      end
      if (d_ack && (get_state == GET_IDLE) && (atomic_state != PERFORM_WRITE)) begin 
        outstanding = 1'b0;
      end
      case(put_state)
        PUT_IDLE: begin
          if((a_ack || (~outstanding && tl_i.a_valid)) && tl_i.a_opcode inside {PutFullData, PutPartialData}) begin            
            addr_o <= {tl_i.a_address[RegAw-1:2], 2'b00};
            rd_req <= 0;
            wr_req <= 1'b1;

            reqid <= tl_i.a_source;
            reqsz <= tl_i.a_size;

            wdata    <= tl_i.a_data;  
            be_o     <= tl_i.a_mask;
            

            if(tl_i.a_size > $clog2(TL_DBW)) begin
              put_state        <= WRITE_NEXT_BEAT;
              put_burst_enable <= 1'b1;
              put_beat_no      <= $clog2(tl_i.a_size) - 1;
            end
            else begin
              rspop       <= AccessAck;
              outstanding <= 1'b1;
            end
          end
          //. TO ASK: in case it is hintack --> I don't know where to put it
          else if (intent_o != 0) begin
            rd_req <= 0;
            wr_req <= 0;
            rspop  <= HintAck;
            addr_o <= {tl_i.a_address[RegAw-1:2], 2'b00};
          end
        end
        WRITE_NEXT_BEAT: begin
          //. make sure the next beat arrives
          if(a_ack) begin
            addr_o      <= (addr_o + RegBw) % (2**RegAw);
            put_beat_no <= put_beat_no - 1;
            wdata       <= tl_i.a_data;
            be_o        <= tl_i.a_mask;
          end
        end
      endcase
    end
  end
  //. End: Put response



  //. Begin: Atomic Response ------------------------------------------------------------------------------------
  //. beats_sent and beats_received handling (burst response)
  always_ff @ (negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      beats_sent     <= 0;
      beats_received <= 0;
    end
    else begin
      if(op_burst_enable) begin
        if(a_ack)
          beats_received <= beats_received + 1;
        if(d_ack)
          beats_sent     <= beats_sent + 1;
      end 
      else begin
        beats_sent     <= 0;
        beats_received <= 0;
      end    
    end
  end

  //. Response to atomic request
  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) atomic_state <= ATOMIC_IDLE;
    else begin
      if (d_ack && (get_state == GET_IDLE) && (atomic_state != PERFORM_WRITE)) outstanding = 1'b0;
      if(atomic_state != ATOMIC_IDLE && op_beat_no == 0) begin
        atomic_state     = ATOMIC_IDLE;
        wait_next_beat  <= 0;
        op_burst_enable <= 0;
        op_enable       <= 0;
        total_beats     <= 0;
        op_rvalid       <= 0;
      end
      case(atomic_state)
        ATOMIC_IDLE: begin
          if((a_ack || (~outstanding && tl_i.a_valid)) && logic'(tl_i.a_opcode inside {ArithmeticData, LogicalData})) begin
            atomic_state <= PERFORM_WRITE;
            rspop        <= AccessAckData;
            addr_o       <= {tl_i.a_address[RegAw-1:2], 2'b00};
            wr_req       <= 0;
            rd_req       <= 1'b1;
            op_data1     <= tl_i.a_data;
            op_enable    <= 1'b1;
            op_function  <= tl_i.a_param;
            op_type      <= ~tl_i.a_opcode[0];
            op_rvalid    <= 1'b1;
            op_beat_no   <= $clog2(tl_i.a_size); 
            be_o         <= tl_i.a_mask;

            reqid        <= tl_i.a_source;
            reqsz        <= tl_i.a_size;

            
            if(tl_i.a_size > $clog2(TL_DBW)) begin
              op_burst_enable <= 1'b1;
              total_beats     <= $clog2(tl_i.a_size);
            end
          end
        end

        PERFORM_WRITE: begin
          rdata           = rdata_i;
          rd_req          = 0;
          wr_req          = 1'b1;
          outstanding     = 1'b1;
          op_beat_no      = op_beat_no - 1;
          //.op_cin          = op_cout;

          if(op_beat_no != 0)
            atomic_state = NEXT_BEAT;

          // if(op_beat_no == 0) begin
          //   atomic_state    = ATOMIC_IDLE;
          //   op_enable       = 0;
          //   op_burst_enable = 0;
          //   op_cin          = 0;
          //   wr_req          = 0;
          //   rd_req          = 0;
          //   total_beats     = 0;
          // end
          // else
          //   atomic_state = NEXT_BEAT;   
        end

        NEXT_BEAT: begin
          //. first make sure the previous beat is sent to the master
          if(beats_sent + op_beat_no == total_beats && !wait_next_beat) begin
            wr_req      = 0;
            op_cin      = op_cout;
            addr_o      = (addr_o + RegBw) % (2**RegAw); //. TO ASK: should we increment it by one or by 4? I guess by 4 because it is word aligned
            rd_req      = 1'b1;
          end

          //. then make sure the next beat of the request is received
          if(beats_received + op_beat_no == total_beats) begin
            atomic_state   = PERFORM_WRITE;
            wait_next_beat = 0;
          end
          else
            wait_next_beat = 1'b1;
          
        end
      endcase
    end
  end
  //. End: Atomic Response


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)                               outstanding <= 1'b0;
    //.else if (a_ack)                            outstanding <= 1'b1;
    //.else if (d_ack && (get_state == GET_IDLE) && (atomic_state != PERFORM_WRITE)) outstanding <= 1'b0;  //. changes here
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reqid <= '0;
      reqsz <= '0;
      rspop <= AccessAck;
    end 
    // else if (a_ack) begin
    //   reqid <= tl_i.a_source;
    //   reqsz <= tl_i.a_size;
    //   // Return AccessAckData regardless of error
    //   //.rspop <= (rd_req) ? AccessAckData : (wr_req & ~op_enable) ? AccessAck : HintAck;  //. changes here
    // end
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata  <= '0;
      error  <= 1'b0;
    end else if (a_ack) begin
      //. rdata <= (err_internal) ? '1 : rdata_i;
      error <= error_i | err_internal;
    end
  end

  assign tl_o = '{
    a_ready:  ~outstanding,
    d_valid:  outstanding,  //. TODO
    d_opcode: rspop,
    d_param:  tl_i.a_valid ? tl_i.a_param : '0,
    d_size:   reqsz,
    d_source: reqid,
    d_sink:   '0,
    d_data:   re_o ? rdata_i : tl_o.d_data,  //.rdata,
    d_error: error
  };

  ////////////////////
  // Error Handling //
  ////////////////////
  assign err_internal = '0;//.addr_align_err | tl_err ;

  // addr_align_err
  //    Raised if addr isn't aligned with the size
  //    Read size error is checked in tluh_assert.sv
  //    Here is it added due to the limitation of register interface.
  always_comb begin
    if (wr_req) begin
      // Only word-align is accepted based on comportability spec
      addr_align_err = |tl_i.a_address[1:0];
    end else begin
      // No request
      addr_align_err = 1'b0;
    end
  end

  // tl_err : separate checker
    assign tl_err = 0;
//  tlul_err u_err (
//     .tl_i (tl_i),
//     .err_o (tl_err)
//   );

  //. ALU 
  ALU 
  ALU_dut (
    .enable_i    (op_enable),
    .op1_i       (op_data1),
    .op2_i       (op_data2),
    .cin_i       (op_cin),
    .operation_i (op_type),
    .function_i  (op_function),
    .result_o    (op_result),
    .cout_o      (op_cout)
  );

endmodule
