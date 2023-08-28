 module tluh_adapter_reg import tluh_pkg::*; #(
  parameter  int RegAw = 8,
  parameter  int RegDw = 32, // Shall be matched with TL_DW
  localparam int RegBw = RegDw/8
) (
  input logic clk_i,
  input logic rst_ni,

  // TL-UH interface
  input  tluh_h2d_t tl_i,
  output tluh_d2h_t tl_o,

  // Register interface
  output logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o, //. intention blocks
  output logic             intent_o,  //. intent operation (0:prefetchRead, 1:prefetchWrite)
  output logic             ie_o,      //. intent enable
  output logic             re_o,
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
  logic tl_err;             // Common TL-UH error checker

  logic [IW-1:0]         reqid;
  logic [SZW-1:0]        reqsz;
  tluh_pkg::tluh_d_m_op  rspop;

  logic [RegAw-1:0] next_addr;


  logic rd_req, wr_req, atomic_req;

  //. Atomic signals
  logic [tluh_pkg::TL_DW-1:0]  op_data1;
  logic [tluh_pkg::TL_DW-1:0]  op_data2;
  logic [tluh_pkg::TL_DW-1:0]  op_result;
  logic [2:0]                  op_function;
  logic                        op_cin;
  logic                        op_cout;
  logic                        op_type;   //. 1: arithmetic, 0: logical
  logic                        op_enable;
  logic                        atomic_rd;
  logic                        atomic_wr;


  // States
  //. Get
  typedef enum logic {  //. State machine states
    GET_IDLE,
    READ_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } get_state_t;
  get_state_t get_state;

  //. Put
  typedef enum logic {  //. State machine states
    PUT_IDLE,
    WRITE_NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } put_state_t;
  put_state_t put_state;

  //. Atomic
  typedef enum logic [1:0] {  //. State machine states
    ATOMIC_IDLE,
    PERFORM_WRITE,  //. perform the operation and write the result to the register
    NEXT_BEAT       //. read the next beat from the register and wait for the next beat request
  } atomic_state_t;
  atomic_state_t atomic_state;


  logic burst;  //. indicates if the current request is a burst request
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_cnt;



  assign a_ack   = tl_i.a_valid & tl_o.a_ready;
  assign d_ack   = tl_o.d_valid & tl_i.d_ready;


  // Request signal
  assign rd_req     = a_ack ? (tl_i.a_opcode == Get) : get_state != GET_IDLE;
  assign wr_req     = a_ack ? ((tl_i.a_opcode == PutFullData) | (tl_i.a_opcode == PutPartialData)) : put_state != PUT_IDLE;
  assign atomic_req = a_ack ? ((tl_i.a_opcode == ArithmeticData) | (tl_i.a_opcode == LogicalData)) : atomic_state != ATOMIC_IDLE;

  assign atomic_rd  = a_ack ? (tl_i.a_opcode == ArithmeticData) | (tl_i.a_opcode == LogicalData) : 0;

  assign we_o       = ((a_ack && (((tl_i.a_opcode == PutFullData) || (tl_i.a_opcode == PutPartialData)))) || atomic_wr) & ~err_internal;
  assign re_o       = (rd_req || atomic_rd) & ~err_internal;
  assign wdata_o    = atomic_req ? op_result : tl_i.a_data;
  
  assign be_o       = tl_i.a_mask;
  
  
  always_comb begin
    if(a_ack && ~burst) begin
      addr_o = {tl_i.a_address[RegAw-1:2], 2'b00};
    end
    else if (burst) begin
      if (wr_req || atomic_req) begin
        if(a_ack)
          addr_o = next_addr;
      end
      else if(rd_req) begin
        if(d_ack)
          addr_o = next_addr;
      end
    end
  end



  //. Intent signals
  assign intention_blocks_o = $clog2(tl_i.a_size);
  assign intent_o           = tl_i.a_param[0];
  assign ie_o               = a_ack & (tl_i.a_opcode == Intent);

  //. Atomic signals
  assign op_data1    = a_ack ? tl_i.a_data       : op_data1;
  assign op_data2    = rdata;
  assign op_type     = a_ack ? ~tl_i.a_opcode[0] : op_type;
  assign op_function = a_ack ? tl_i.a_param      : op_function;




  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      burst        <= 1'b0;
      rdata        <= '0;
      outstanding  <= 1'b0;
      get_state    <= GET_IDLE;
      put_state    <= PUT_IDLE;
      atomic_state <= ATOMIC_IDLE;
      next_addr    <= '0;
      beats_cnt    <= '0;
      atomic_wr    <= 1'b0;
    end 
    else begin

      if(d_ack && ~burst && ~atomic_req) begin
        outstanding <= 1'b0;
      end

      else if (a_ack | burst | d_ack) begin
        //. case 1: get request
        if(rd_req) begin
          case(get_state)
            GET_IDLE: begin
              if(a_ack) begin
                rdata       <= (err_internal) ? '1 : rdata_i;
                outstanding <= 1'b1;
                //. check if burst
                if(tl_i.a_size > $clog2(TL_DBW)) begin
                  get_state <= READ_NEXT_BEAT;
                  burst     <= 1'b1;
                  beats_cnt <= $clog2(tl_i.a_size) - 1;
                  next_addr <= ((addr_o + RegBw) % (2**RegAw));
                end
              end
            end
            READ_NEXT_BEAT: begin
              if(d_ack) begin
                rdata       <= (err_internal) ? '1 : rdata_i;
                beats_cnt <= beats_cnt - 1;
                outstanding <= 1'b1;
                if(beats_cnt == 1) begin  //. == 1 means that in this cycle it will be 0 (non-blocking assignment)
                  burst     <= 1'b0;
                  get_state <= GET_IDLE;
                end
                else
                  next_addr <= ((addr_o + RegBw) % (2**RegAw));
              end
            end
          endcase
        end 
        
        //. case 2: put request  
        else if (wr_req) begin
          case(put_state)
            PUT_IDLE: begin
              if(a_ack) begin
                outstanding <= 1'b1;
                //. check if burst
                if(tl_i.a_size > $clog2(TL_DBW)) begin
                  put_state <= WRITE_NEXT_BEAT;
                  burst     <= 1'b1;
                  next_addr <= ((addr_o + RegBw) % (2**RegAw));
                  beats_cnt <= $clog2(tl_i.a_size) - 1;
                end
              end
            end
            WRITE_NEXT_BEAT: begin
              //. make sure the ack signal is sent and received by the master
              if(d_ack) begin
                outstanding <= 1'b0;
              end
              //. make sure the next beat arrives
              if(a_ack) begin
                beats_cnt <= beats_cnt - 1;
                if(beats_cnt == 1) begin
                  burst     <= 1'b0;
                  put_state <= PUT_IDLE;
                end
                else
                  next_addr <= ((addr_o + RegBw) % (2**RegAw));
              end
            end
          endcase
        end 
  
        //. case 3: atomic request  
        else if (atomic_req) begin
          case(atomic_state)
            ATOMIC_IDLE: begin
              if(a_ack) begin
                rdata        <= (err_internal) ? '1 : rdata_i;
                atomic_wr    <= 1'b1;
                outstanding  <= 1'b1;
                op_cin       <= 1'b0;
                op_enable    <= 1'b1;
                atomic_state <= PERFORM_WRITE;
                //. check if burst
                if(tl_i.a_size > $clog2(TL_DBW)) begin
                  burst     <= 1'b1;
                  next_addr <= addr_o;  //. I have to do this to avoid incrementing addr_o twice
                  beats_cnt <= $clog2(tl_i.a_size);
                end
              end
            end
            PERFORM_WRITE: begin
              atomic_wr   <= 1'b0;
              if(d_ack) begin
                outstanding  <= 1'b0;
                if(burst) begin
                  beats_cnt <= beats_cnt - 1;
                  //. at this moment we are sure that the result is written in the register
                  if(beats_cnt == 1) begin
                    burst        <= 1'b0;
                    op_enable    <= 1'b0;
                    atomic_state <= ATOMIC_IDLE;
                  end
                  else begin
                    atomic_state <= NEXT_BEAT;
                    next_addr    <= ((addr_o + RegBw) % (2**RegAw));
                    //.op_cin       <= op_cout;
                  end              
                end 
                else begin
                  atomic_state <= ATOMIC_IDLE;
                end
              end
            end
            NEXT_BEAT: begin
              if(a_ack) begin
                rdata        <= (err_internal) ? '1 : rdata_i;
                atomic_wr    <= 1'b1;
                outstanding  <= 1'b1;
                atomic_state <= PERFORM_WRITE;
              end
            end
          endcase
  
        end
        
        //. case 4: Intent request
        else if (ie_o) begin
          outstanding               <= 1'b1;
        end
    
      end
    end
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
      rspop <= (atomic_req || rd_req) ? AccessAckData : (ie_o) ? HintAck : AccessAck;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      error <= 1'b0;
    end else if (a_ack) begin
      error <= error_i | err_internal;
    end
  end


  logic ready;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ready <= 1'b0;
    end else if (a_ack) begin
      ready <= 1'b0;
    end
    else if (d_ack) begin
      if(burst) begin
        if(rd_req) begin
          ready <= 1'b0;
        end
        else begin
          ready <= 1'b1;
        end
      end
      else 
        ready <= 1'b1;
    end
    else begin
      ready <= 1'b1;
    end
  end



  assign tl_o = '{
    a_ready:  ready, //. (~a_ack || d_ack) && ~outstanding,  //. TODO: check if this is correct
    d_valid:  outstanding,
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

  logic tl_error;

  assign err_internal = addr_align_err | tl_error;

  always_comb begin
    if(a_ack) begin
      tl_error = tl_err;
    end
  end

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
  tluh_err u_err (
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
