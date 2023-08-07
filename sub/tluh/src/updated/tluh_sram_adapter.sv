/**
 * Tile-Link UL adapter for SRAM-like devices
 *
 * - Intentionally omitted BaseAddr in case of multiple memory maps are used in a SoC,
 *   it means that aliasing can happen if target device size in TL-UL crossbar is bigger
 *   than SRAM size
 */
 module tluh_sram_adapter #(
  parameter int SramAw      = 12,
  parameter int SramDw      = 32, // Must be multiple of the TL width
  parameter int Outstanding = 1,  // Only one request is accepted
  parameter bit ByteAccess  = 1,  // 1: true, 0: false
  parameter bit ErrOnWrite  = 0,  // 1: Writes not allowed, automatically error
  parameter bit ErrOnRead   = 0   // 1: Reads not allowed, automatically error
) (
  input   logic clk_i,
  input   logic rst_ni,

  // TL-UL interface
  input   tluh_pkg::tluh_h2d_t  tl_i,
  output  tluh_pkg::tluh_d2h_t  tl_o,

  // SRAM interface
  output logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o, //. intention blocks
  output logic [1:0]        intent_o,  //. intent operation (prefetchRead, prefetchWrite)
  output logic              ie_o, //. intent enable
  output logic              req_o,
  input  logic              gnt_i,
  output logic              we_o,
  output logic [SramAw-1:0] addr_o,
  output logic [SramDw-1:0] wdata_o,
  output logic [SramDw-1:0] wmask_o,
  input  logic [SramDw-1:0] rdata_i,
  input  logic              rvalid_i,
  input  logic [1:0]        rerror_i // 2 bit error [1]: Uncorrectable, [0]: Correctable
);

  import tluh_pkg::*;

  localparam int SramByte = SramDw/8;
  localparam int DataBitWidth = tluh_pkg::vbits(SramByte);
  localparam int WidthMult = SramDw / tluh_pkg::TL_DW;
  localparam int WoffsetWidth = (SramByte == tluh_pkg::TL_DBW) ? 1 :
                                DataBitWidth - tluh_pkg::vbits(tluh_pkg::TL_DBW);

  typedef struct packed {
    logic [tluh_pkg::TL_DBW-1:0] mask ; // Byte mask within the TL-UL word
    logic [WoffsetWidth-1:0]    woffset ; // Offset of the TL-UL word within the SRAM word
  } sram_req_t ;

  typedef enum logic [1:0] {
    OpWrite,
    OpRead,
    OpAtomic,
    OpHint
  } req_op_e ;

  typedef struct packed {
    req_op_e                    op ;
    logic                       error ;
    logic [tluh_pkg::TL_SZW-1:0] size ;
    logic [tluh_pkg::TL_AIW-1:0] source ;
  } req_t ;

  typedef struct packed {
    logic [SramDw-1:0] data ;
    logic              error ;
  } rsp_t ;

  localparam int SramReqFifoWidth = $bits(sram_req_t) ;
  localparam int ReqFifoWidth = $bits(req_t) ;
  localparam int RspFifoWidth = $bits(rsp_t) ;

  // FIFO signal in case OutStand is greater than 1
  // If request is latched, {write, source} is pushed to req fifo.
  // Req fifo is popped when D channel is acknowledged (v & r)
  // D channel valid is asserted if it is write request or rsp fifo not empty if read.
  logic reqfifo_wvalid, reqfifo_wready;
  logic reqfifo_rvalid, reqfifo_rready;
  req_t reqfifo_wdata,  reqfifo_rdata;

  logic sramreqfifo_wvalid, sramreqfifo_wready;
  logic sramreqfifo_rvalid ,sramreqfifo_rready;
  sram_req_t sramreqfifo_wdata, sramreqfifo_rdata;

  logic rspfifo_wvalid, rspfifo_wready;
  logic rspfifo_rvalid, rspfifo_rready;
  rsp_t rspfifo_wdata,  rspfifo_rdata;

  logic rspfifo_ack, rspfifo_full, rspfifo_depth;

  logic error_internal; // Internal protocol error checker
  logic wr_attr_error;
  logic wr_vld_error;
  logic rd_vld_error;
  logic tluh_error;     // Error from `tluh_err` module


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

  //. Burst responses
  logic burst;
  logic wait_till_sending_current, wait_till_pushing_last;
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_to_push;
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_to_send;

  logic a_ack, d_ack, sram_ack;
  assign a_ack    = tl_i.a_valid & tl_o.a_ready ;
  assign d_ack    = tl_o.d_valid & tl_i.d_ready ;
  assign sram_ack = req_o        & gnt_i ;

  // Valid handling
  logic d_valid, d_error;
  always_comb begin
    d_valid = 1'b0;

    if (reqfifo_rvalid) begin
      if (reqfifo_rdata.error) begin
        // Return error response. Assume no request went out to SRAM
        d_valid = 1'b1;
      end else if (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) begin
        d_valid = rspfifo_rvalid;
      end else begin
        // Write without error
        d_valid = 1'b1;
      end
    end else begin
      d_valid = 1'b0;
    end
  end

  always_comb begin
    d_error = 1'b0;

    // if (reqfifo_rvalid) begin
    //   if (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) begin
    //     d_error = rspfifo_rdata.error | reqfifo_rdata.error;
    //   end else begin
    //     d_error = reqfifo_rdata.error;
    //   end
    // end else begin
    //   d_error = 1'b0;
    // end
  end

  assign tl_o = '{
      d_valid  : d_valid ,
      d_opcode : (reqfifo_rdata.op == OpWrite) ? AccessAck : 
                 (reqfifo_rdata.op == OpHint)  ? HintAck   : AccessAckData,  //. TO ASK: in the TL_UL version, it checks for the d_valid as well. Is it ok to remove this check from here?
      d_param  : '0,
      d_size   : (d_valid) ? reqfifo_rdata.size : '0,
      d_source : (d_valid) ? reqfifo_rdata.source : '0,
      d_sink   : 1'b0,
      d_data   : (d_valid && rspfifo_rvalid && (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic))
                 ? rspfifo_rdata.data : '0,
      d_error  : '0, //. d_valid && d_error,

      a_ready  : (gnt_i | error_internal) & reqfifo_wready & sramreqfifo_wready
  };


  logic [SramAw-1:0] next_addr;

  //. Atomic signals
  logic [tluh_pkg::TL_DW-1:0]  op_data1;
  logic [tluh_pkg::TL_DW-1:0]  op_data2;
  logic [tluh_pkg::TL_DW-1:0]  op_result;
  logic [2:0]                  op_function;
  logic                        op_cin;
  logic                        op_cout;
  logic                        op_type;   //. 1: arithmetic, 0: logical
  logic                        op_enable;


  logic rd_req, wr_req, atomic_req;

  assign wr_req     = a_ack & ((tl_i.a_opcode == PutFullData) | (tl_i.a_opcode == PutPartialData));
  assign rd_req     = a_ack ? (tl_i.a_opcode == Get) : burst ? rd_req : 1'b0; //. latch the rd_req signal for burst response of get request
  assign atomic_req = a_ack ? ((tl_i.a_opcode == ArithmeticData) | (tl_i.a_opcode == LogicalData)) : ((atomic_state == PERFORM_WRITE || burst)) ? atomic_req : 1'b0; //. latch the atomic_req signal for burst response of burst atomic request or for the cycle of writing the result of atomic operation to the register






  // a_ready depends on the FIFO full condition and grant from SRAM (or SRAM arbiter)
  // assemble response, including read response, write response, and error for unsupported stuff

  // Output to SRAM:
  //    Generate request only when no internal error occurs. If error occurs, the request should be
  //    dropped and returned error response to the host. So, error to be pushed to reqfifo.
  //    In this case, it is assumed the request is granted (may cause ordering issue later?)
  assign req_o    = ((tl_i.a_valid & reqfifo_wready) || burst) & ~error_internal;
  assign we_o     = (a_ack && logic'(tl_i.a_opcode inside {PutFullData, PutPartialData})) || (atomic_state == PERFORM_WRITE);  //.tl_i.a_valid & logic'(tl_i.a_opcode inside {PutFullData, PutPartialData});

  logic wait_till_address_updated;




  //assign addr_o   = ~burst ? (tl_i.a_valid) ? tl_i.a_address[0+:SramAw] : '0 : (req_o || we_o) ? next_addr : addr_o; //. (tl_i.a_valid) ? tl_i.a_address[DataBitWidth+:SramAw] : '0;  //. [13:2]

  // Support SRAMs wider than the TL-UL word width by mapping the parts of the
  // TL-UL address which are more fine-granular than the SRAM width to the
  // SRAM write mask.
  logic [WoffsetWidth-1:0] woffset;
  if (tluh_pkg::TL_DW != SramDw) begin : gen_wordwidthadapt
    assign woffset = tl_i.a_address[DataBitWidth-1:tluh_pkg::vbits(tluh_pkg::TL_DBW)];
  end else begin : gen_no_wordwidthadapt
    assign woffset = '0;
  end

  // Convert byte mask to SRAM bit mask for writes, and only forward valid data
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] wmask_int;
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] wdata_int;

  always_comb begin
    wmask_int = '0;
    wdata_int = '0;

    if (tl_i.a_valid) begin  //. TODO: change the condition
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
        wmask_int[woffset][8*i +: 8] = {8{tl_i.a_mask[i]}};
        wdata_int[woffset][8*i +: 8] = (tl_i.a_mask[i] && we_o) ? tl_i.a_data[8*i+:8] : '0; //. TODO: in case of burst or atomic
      end
    end
  end

  assign wmask_o = wmask_int;
  assign wdata_o = wdata_int;

  // Begin: Request Error Detection

  // wr_attr_error: Check if the request size,mask are permitted.
  //    Basic check of size, mask, addr align is done in tluh_err module.
  //    Here it checks any partial write if ByteAccess isn't allowed.
  assign wr_attr_error = '0; //(tl_i.a_opcode == PutFullData || tl_i.a_opcode == PutPartialData) ?
                             //(ByteAccess == 0) ? (tl_i.a_mask != '1 || tl_i.a_size != 2'h2) : 1'b0 :
                             //1'b0;

  if (ErrOnWrite == 1) begin : gen_no_writes
    assign wr_vld_error = tl_i.a_opcode != Get;
  end else begin : gen_writes_allowed
    assign wr_vld_error = 1'b0;
  end

  if (ErrOnRead == 1) begin: gen_no_reads
    assign rd_vld_error = tl_i.a_opcode == Get;
  end else begin : gen_reads_allowed
    assign rd_vld_error = 1'b0;
  end

// tlul_err u_err (
//     .tl_i   (tl_i),
//     .err_o (tluh_error)
//   );

  assign error_internal = '0; //.wr_attr_error | wr_vld_error | rd_vld_error | tluh_error;
  // End: Request Error Detection

  assign reqfifo_wvalid = a_ack ; // Push to FIFO only when granted
  assign reqfifo_wdata  = '{
    op:     (tl_i.a_opcode == Get) ? OpRead :  // To return AccessAck for opcode error
            (tl_i.a_opcode == ArithmeticData || tl_i.a_opcode == LogicalData) ? OpAtomic :
            (tl_i.a_opcode == Intent) ? OpHint : OpWrite , 
    error:  error_internal,
    size:   tl_i.a_size,
    source: tl_i.a_source
  }; // Store the request only. Doesn't have to store data
  assign reqfifo_rready = rd_req ? ((beats_to_send == 1) && d_ack) : d_ack ; //. TODO: what if the req is Get and the a_size indicates that that rsp is burst? so we need to pop the req only when all beats that correspond to this req are popped from rspfifo

  // push together with ReqFIFO, pop upon returning read
  assign sramreqfifo_wdata = '{
    mask    : tl_i.a_mask,
    woffset : woffset
  };
  assign sramreqfifo_wvalid = sram_ack & ~we_o;
  assign sramreqfifo_rready = rspfifo_wvalid; //. TODO: what if the req is Get and the a_size indicates that that rsp is burst? so we need to pop the req only when all beats that correspond to this req are popped from rspfifo

  //assign rspfifo_wvalid = wait_till_address_updated ? 1'b0 : rvalid_i & reqfifo_rvalid; 

  // Make sure only requested bytes are forwarded
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rdata;
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rmask;
  //logic [SramDw-1:0] rmask;
  logic [tluh_pkg::TL_DW-1:0] rdata_tlword;

  // always_comb begin
  //   //.rmask = '0;
  //   for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
  //     rmask[sramreqfifo_rdata.woffset][8*i +: 8] = {8{sramreqfifo_rdata.mask[i]}};
  //   end
  // end

  //assign rdata = rdata_i & rmask;
  logic wait_rspfifo_ack;

  assign rdata_tlword = rdata[sramreqfifo_rdata.woffset];

  assign rspfifo_wdata  = '{
    data : rdata_tlword,
    error: rerror_i[1] // Only care for Uncorrectable error
  };
  assign rspfifo_rready = (reqfifo_rdata.op == OpRead & ~reqfifo_rdata.error)
                        ? reqfifo_rready : 1'b0 ;  //. TODO: in case of burst

  assign rspfifo_ack = rspfifo_wvalid & rspfifo_wready;

  // This module only cares about uncorrectable errors.
  logic unused_rerror;
  assign unused_rerror = rerror_i[0];

  // always_comb begin
  //   rmask = '0;
  //   for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
  //     rmask[sramreqfifo_rdata.woffset][8*i +: 8] = {8{sramreqfifo_rdata.mask[i]}};
  //   end
  //   if(rvalid_i) begin
  //     if(wait_rspfifo_ack == 1'b0) begin
  //       rdata = rdata_i & rmask;
  //     end
  //   end
  // end

  always_comb begin
    if(sramreqfifo_rvalid) begin
      rmask = '0;
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
        rmask[sramreqfifo_rdata.woffset][8*i +: 8] = {8{sramreqfifo_rdata.mask[i]}};
      end
    end
    
    if(~burst) begin
      if(tl_i.a_valid)
        addr_o = tl_i.a_address[0+:SramAw]; // tl_i.a_address[DataBitWidth+:SramAw]
      else
        addr_o = '0;
    end
    else if(req_o && we_o) begin
      addr_o = next_addr;
    end

    if(reqfifo_rvalid && rvalid_i) begin
      if(rspfifo_depth == 0) begin
        rspfifo_wvalid = 1'b1;
        rdata = rdata_i & rmask;
      end
      else if(rspfifo_ack) begin
        //. update the address
        addr_o = next_addr;
        rspfifo_wvalid = 1'b1;
        rdata = rdata_i & rmask;
      end
      else
        rspfifo_wvalid = 1'b0;
    end
    else begin
      rspfifo_wvalid = 1'b0;
    end
  end



  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      burst        <= 1'b0;
      //rdata        <= '0;
      op_data2     <= '0;
      get_state    <= GET_IDLE;
      put_state    <= PUT_IDLE;
      atomic_state <= ATOMIC_IDLE;
      next_addr    <= '0;
      beats_to_push <= '0;
      wait_till_sending_current <= 1'b0;
      wait_rspfifo_ack <= 1'b0;
    end 

    else begin
      if (wait_till_pushing_last) begin
        if(rspfifo_ack)
          wait_till_pushing_last <= 1'b0;
      end
  
      if(wait_till_sending_current) begin
        if(d_ack) begin 
          //outstanding <= 1'b0;
          beats_to_send <= beats_to_send - 1;
          if(beats_to_send == 1)
            wait_till_sending_current <= 1'b0;
        end
      end
  
      else if (a_ack | burst | d_ack) begin
        //. case 1: get request
        if(rd_req) begin
          case(get_state)
            GET_IDLE: begin
              beats_to_send <= $clog2(tl_i.a_size);
              //. check if burst
              if(tl_i.a_size > $clog2(TL_DBW)) begin
                get_state <= READ_NEXT_BEAT;
                burst     <= 1'b1;
                next_addr <= ((tl_i.a_address[0+:SramAw] + SramByte) % (2**SramAw));
                beats_to_push <= $clog2(tl_i.a_size) - 1;   
              end
              else
                wait_till_sending_current <= 1'b1;
            end
            READ_NEXT_BEAT: begin
              //. make sure the previous beat was pushed into the FIFO
              if(rspfifo_ack) begin
                wait_rspfifo_ack <= 1'b0;
                beats_to_push <= beats_to_push - 1;
                if(beats_to_push == 1) begin  //. == 1 means that in this cycle it will be 0 (non-blocking assignment)
                  burst                  <= 1'b0;
                  get_state              <= GET_IDLE;
                  wait_till_pushing_last <= 1'b1;
                  if(beats_to_send > 0 && ~d_ack)
                    wait_till_sending_current <= 1'b1;
                end
                else
                  next_addr <= ((addr_o + SramByte) % (2**SramAw));
              end
              else
                wait_rspfifo_ack <= 1'b1;
              if(d_ack)
              begin
                beats_to_send <= beats_to_send - 1;
                if(beats_to_send == 1)
                  wait_till_sending_current <= 1'b0;
                else
                  wait_till_sending_current <= 1'b1;
              end
            end
          endcase
        end 
        
        //. case 2: put request  
        else if (wr_req || (put_state != PUT_IDLE)) begin
          case(put_state)
            PUT_IDLE: begin
              //outstanding <= 1'b1;
              //. check if burst
              if(tl_i.a_size > $clog2(TL_DBW)) begin
                put_state <= WRITE_NEXT_BEAT;
                burst     <= 1'b1;
                next_addr <= ((addr_o + SramByte) % (2**SramAw));
                beats_to_push <= $clog2(tl_i.a_size) - 1;
              end
              else
                wait_till_sending_current <= 1'b1;
            end
            WRITE_NEXT_BEAT: begin
              //. make sure the ack signal is sent and received by the master
              if(d_ack) begin
                //outstanding <= 1'b0;
              end
              //. make sure the next beat arrives
              if(a_ack) begin
                beats_to_push <= beats_to_push - 1;
                if(beats_to_push == 1) begin
                  burst     <= 1'b0;
                  put_state <= PUT_IDLE;
                  // if(~d_ack && outstanding)
                  //   wait_till_sending_current = 1'b1;
                end
                else
                  next_addr <= ((addr_o + SramByte) % (2**SramAw));
              end
            end
          endcase
        end 
  
        //. case 3: atomic request  
        else if (atomic_req) begin
          case(atomic_state)
            ATOMIC_IDLE: begin
              //rdata        <= rdata_i;
              op_data2     <= rdata_i;
              //outstanding  <= 1'b1;
              op_cin       <= 1'b0;
              op_enable    <= 1'b1;
              atomic_state <= PERFORM_WRITE;
              //. check if burst
              if(tl_i.a_size > $clog2(TL_DBW)) begin
                burst     <= 1'b1;
                next_addr <= addr_o;  //. I have to do this to avoid incrementing addr_o twice
                beats_to_push <= $clog2(tl_i.a_size) - 1;
              end
            end
            PERFORM_WRITE: begin
              if(d_ack) begin
               // outstanding  <= 1'b0;
              end
              else begin
                wait_till_sending_current = 1'b1;
              end
              if(burst) begin
                //. at this moment we are sure that the result is written in the register
                if(beats_to_push == 0) begin
                  burst        <= 1'b0;
                  op_enable    <= 1'b0;
                  atomic_state <= ATOMIC_IDLE;
                end
                else begin
                  atomic_state <= NEXT_BEAT;
                  next_addr    <= ((addr_o + SramByte) % (2**SramAw));
                  op_cin       <= op_cout;
                end              
              end 
              else begin
                atomic_state <= ATOMIC_IDLE;
              end
            end
            NEXT_BEAT: begin
              if(a_ack) begin
                //rdata        <= rdata_i;
                op_data2     <= rdata_i;
                //outstanding  <= 1'b1;
                atomic_state <= PERFORM_WRITE;
                beats_to_push    <= beats_to_push - 1;
              end
            end
          endcase
  
        end
        
        //. case 4: Intent request
        else if (ie_o) begin
          //outstanding               <= 1'b1;
          wait_till_sending_current <= 1'b1;
        end
  
        //. TO ASK: I think no need to put else statement here case the latches will be desirable, right?
  
      end
    end
    
  end



  // FIFO instance: REQ, RSP

  // ReqFIFO is to store the Access type to match to the Response data.
  //    For instance, SRAM accepts the write request but doesn't return the
  //    acknowledge. In this case, it may be hard to determine when the D
  //    response for the write data should send out if reads/writes are
  //    interleaved. So, to make it in-order (even TL-UL allows out-of-order
  //    responses), storing the request is necessary. And if the read entry
  //    is write op, it is safe to return the response right away. If it is
  //    read reqeust, then D response is waiting until read data arrives.

  // Notes:
  // The oustanding+1 allows the reqfifo to absorb back to back transactions
  // without any wait states.  Alternatively, the depth can be kept as
  // oustanding as long as the outgoing ready is qualified with the acceptance
  // of the response in the same cycle.  Doing so however creates a path from
  // ready_i to ready_o, which may not be desireable.
  fifo_sync #(
    .Width   (ReqFifoWidth),
    .Pass    (1'b0),
    .Depth   (Outstanding)
  ) u_reqfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(reqfifo_wvalid),
    .wready_o(reqfifo_wready),
    .wdata_i (reqfifo_wdata),
    .depth_o (),
    .rvalid_o(reqfifo_rvalid),
    .rready_i(reqfifo_rready),
    .rdata_o (reqfifo_rdata),
    .full_o ()
  );

  // sramreqfifo:
  //    While the ReqFIFO holds the request until it is sent back via TL-UH, the
  //    sramreqfifo only needs to hold the mask and word offset until the read
  //    data returns from memory.
  fifo_sync #(
    .Width   (SramReqFifoWidth),
    .Pass    (1'b0),
    .Depth   (Outstanding)
  ) u_sramreqfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(sramreqfifo_wvalid),
    .wready_o(sramreqfifo_wready),
    .wdata_i (sramreqfifo_wdata),
    .depth_o (),
    .rvalid_o(sramreqfifo_rvalid),
    .rready_i(sramreqfifo_rready),
    .rdata_o (sramreqfifo_rdata),
    .full_o  ()
  );

  // Rationale having #Outstanding depth in response FIFO.
  //    In normal case, if the host or the crossbar accepts the response data,
  //    response FIFO isn't needed. But if in any case it has a chance to be
  //    back pressured, the response FIFO should store the returned data not to
  //    lose the data from the SRAM interface. Remember, SRAM interface doesn't
  //    have back-pressure signal such as read_ready.
  fifo_sync #(
    .Width   (RspFifoWidth),
    .Pass    (1'b1),
    .Depth   (Outstanding * TL_BEATSMAX)
  ) u_rspfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(rspfifo_wvalid),
    .wready_o(rspfifo_wready),
    .wdata_i (rspfifo_wdata),
    .depth_o (rspfifo_depth),
    .rvalid_o(rspfifo_rvalid),
    .rready_i(rspfifo_rready),
    .rdata_o (rspfifo_rdata),
    .full_o  (rspfifo_full)
  );


  //. Arithmetic & Logic Units to perform the operation in case of atomic requests
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
