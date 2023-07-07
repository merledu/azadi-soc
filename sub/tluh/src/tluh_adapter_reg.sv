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
  logic [tluh_pkg::TL_DW-1:0]  op_latch_result;
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
  assign addr_o   = op_rvalid ? op_addr         : {tl_i.a_address[RegAw-1:2], 2'b00}; // generate always word-align  //. TODO: in case of burst response, it should be changed
  assign wdata_o  = op_rvalid ? op_latch_result : tl_i.a_data;  //. TODO: in case of atomic, it should be op_result
  assign be_o     = op_rvalid ? op_mask         : tl_i.a_mask;
  assign intent_o = (a_ack & (tl_i.a_opcode == Intent)) ? tl_i.a_param : 0;


  //. Begin: Get response
  typedef enum logic {  //. State machine states
    GET_IDLE,
    READ_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } get_state_t;

  get_state_t get_state;
  bit get_burst_enable = 0;
  int beat_no = 0;  //. TODO: change the type to logic of 2 bits

  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) get_state <= GET_IDLE;
    else begin
      case(get_state)
        GET_IDLE: begin
          if(a_ack && tl_i.a_opcode == Get) begin
            rd_req = 1;

            if(tl_i.a_size > $log2(TL_DBW)) begin
              get_state <= READ_NEXT_BEAT;
              get_burst_enable = 1;
              beat_no = $log2(tl_i.a_size);
            end
          end
        end

        READ_NEXT_BEAT: begin
          if(d_ack) begin
            beat_no = beat_no - 1;
            if(beat_no == 0) begin
              get_state <= GET_IDLE;
              get_burst_enable = 0;
              rd_req = 0;   //. TO ASK: not sure if we have to let it 0 in this cycle or in the prev cycle  --> what if another read request is received in the same cycle?
            end
          end

        end
      endcase
    end
  end
  //. End: Get response

  //. Begin: Put response
  typedef enum logic {  //. State machine states
    PUT_IDLE,
    WRITE_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } put_state_t;

  put_state_t put_state;
  bit put_burst_enable = 0;
  int put_beat_no = 0; 

  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(rst_ni) put_state <= PUT_IDLE;
    else begin
      case(put_state)
        PUT_IDLE: begin
          if(a_ack && tl_i.a_opcode inside {PutFullData, PutPartialData}) begin
            wr_req = 1;

            if(tl_i.a_size > $log2(TL_DBW)) begin
              put_state <= WRITE_NEXT_BEAT;
              put_burst_enable = 1;
              put_beat_no = $log2(tl_i.a_size);
            end
          end
        end
        WRITE_NEXT_BEAT: begin
          if(a_ack) begin
            put_beat_no = put_beat_no - 1;
            if(put_beat_no == 0) begin
              put_state <= PUT_IDLE;
              put_burst_enable = 0;
              wr_req = 0; 
            end
          end
        end
      endcase
    end
  end
  //. End: Put response

  //. Begin: Atomic Response
  typedef enum logic [1:0] {  //. State machine states
    IDLE,
    PERFORM_WRITE,  //. perform the operation and write the result to the register
    NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } atomic_state_t;
  
  atomic_state_t atomic_state;
  bit wait_next_beat  = 0;
  int beats_sent      = 0;
  int beats_received  = 0;

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
    if(!rst_ni) atomic_state <= IDLE;
    else begin
      case(atomic_state)
        IDLE: begin
          op_rvalid     = 0;
          if(a_ack && logic'(tl_i.a_opcode inside {ArithmeticData, LogicalData})) begin
            atomic_state = PERFORM_WRITE;
            op_addr     = {tl_i.a_address[RegAw-1:2], 2'b00};
            op_mask     = tl_i.a_mask;
            rd_req      = 1;
            op_data1    = tl_i.a_data;
            op_enable   = 1;
            op_function = tl_i.a_param;
            op_type     = ~tl_i.a_opcode[0];
            if(tl_i.a_size > $log2(TL_DBW)) begin
              op_burst_enable = 1;
              op_beat_no   = $log2(tl_i.a_size);
              total_beats  = $log2(tl_i.a_size);
            end
          end
        end

        PERFORM_WRITE: begin
          op_data2        = rdata_i;
          op_latch_result = op_result;
          rd_req          = 0;
          op_rvalid       = 1;
          wr_req          = 1;
          op_beat_no      = op_beat_no - 1;
          //.op_cin          = op_cout;

          if(op_beat_no == 0) begin
            atomic_state    = IDLE;
            op_enable       = 0;
            op_burst_enable = 0;
            op_cin          = 0;
            wr_req          = 0;
            rd_req          = 0;
            total_beats     = 0;
          end
          else
            atomic_state = NEXT_BEAT;   
        end

        NEXT_BEAT: begin
          //. first make sure the previous beat is sent to the master
          if(beats_sent + op_beat_no == total_beats && !wait_next_beat) begin
            wr_req      = 0;
            op_cin      = op_cout;
            op_addr     = op_addr + RegBw; //. TO ASK: should we increment it by one or by 4? I guess by 4 because it is word aligned
            rd_req      = 1;
            op_data2    = rdata_i;  //. should we take the reading in the same cycle or in the next cycle? I guess in the same cycle cause it is combinational in the top module 
          end

          //. then make sure the next beat of the request is received
          if(beats_received + op_beat_no == total_beats) begin
            atomic_state = PERFORM_WRITE;
            wait_next_beat = 0;
          end
          else
            wait_next_beat = 1;
          
        end
      endcase
    end
  end
  //. End: Atomic Response


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)                      outstanding <= 1'b0;
    else if (a_ack)                   outstanding <= 1'b1;
    else if (d_ack && (beat_no == 0)) outstanding <= 1'b0;  //. changes here
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reqid <= '0;
      reqsz <= '0;
      rspop <= AccessAck;
    end else if (a_ack) begin
      reqid <= tl_i.a_source;
      reqsz <= tl_i.a_size;
      // Return AccessAckData regardless of error
      rspop <= (rd_req) ? AccessAckData : (wr_req & ~op_enable) ? AccessAck : HintAck;  //. changes here
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata  <= '0;
      error <= 1'b0;
    end else if (a_ack) begin
      rdata <= (err_internal) ? '1 : rdata_i;
      error <= error_i | err_internal;
    end
  end

  assign tl_o = '{
    a_ready:  ~outstanding,
    d_valid:  outstanding,  //. TODO
    d_opcode: rspop,
    d_param:  '0,
    d_size:   reqsz,
    d_source: reqid,
    d_sink:   '0,
    d_data:   rdata,
    d_error: error
  };

  ////////////////////
  // Error Handling //
  ////////////////////
  assign err_internal = addr_align_err | tl_err ;

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
 tlul_err u_err (
    .tl_i (tl_i),
    .err_o (tl_err)
  );

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
