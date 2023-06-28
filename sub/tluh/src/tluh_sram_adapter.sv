/**
 * Tile-Link UL adapter for SRAM-like devices
 *
 * - Intentionally omitted BaseAddr in case of multiple memory maps are used in a SoC,
 *   it means that aliasing can happen if target device size in TL-UH crossbar is bigger
 *   than SRAM size    //. TO ASK
 */

 //. TO ASK: I guess we don't need to do anything in this module in order to support get burst operation in TL-UH, right? No, I guess we have to make some changes
module tluh_sram_adapter #(
  parameter int SramAw      = 12, //. it takes values like 13, 8, 24 in the modules that use the tlul version of this module
  parameter int SramDw      = 32, // Must be multiple of the TL width
  parameter int Outstanding = 1,  //. TO ASK:  // Only one request is accepted  //. always takes the value of 2 in all the modules that use the tlul version of this module
  parameter bit ByteAccess  = 1,  // 1: true, 0: false //. TO ASK: why byte access? I thought it will be 4 byte access cuz SramDw = 32
  parameter bit ErrOnWrite  = 0,  // 1: Writes not allowed, automatically error
  parameter bit ErrOnRead   = 0   // 1: Reads not allowed, automatically error
) (
  input   logic clk_i,
  input   logic rst_ni,

  // TL-UH interface
  input   tluh_pkg::tluh_h2d_t  tl_i,
  output  tluh_pkg::tluh_d2h_t  tl_o,

  // SRAM interface
  output logic              req_o,
  input  logic              gnt_i,
  output logic              we_o,
  output logic [SramAw-1:0] addr_o,  //. This question is cancelled TO ASK: does the SRAM always check for this address to put the data in this address in the rdata? Cause the req signal is activated only in case of write requests (not read requests)
  output logic [SramDw-1:0] wdata_o,
  output logic [SramDw-1:0] wmask_o,
  input  logic [SramDw-1:0] rdata_i,
  input  logic              rvalid_i,
  input  logic [1:0]        rerror_i // 2 bit error [1]: Uncorrectable, [0]: Correctable
);

  import tluh_pkg::*;

  localparam int SramByte = SramDw/8;  //. sramByte = 4 bytes
  localparam int DataBitWidth = tluh_pkg::vbits(SramByte); //. DataBitWidth = 2 bits. this variable is used to calculate the width of the offset (the 4 bytes can be represented by 2 bits)
  localparam int WidthMult = SramDw / tluh_pkg::TL_DW; //. WidthMult = 32 bits / 32 bits = 1 bit (multiple of the TL width)
  localparam int WoffsetWidth = (SramByte == tluh_pkg::TL_DBW) ? 1 :
                                DataBitWidth - tluh_pkg::vbits(tluh_pkg::TL_DBW);

  typedef struct packed {
    logic [tluh_pkg::TL_DBW-1:0] mask ; // Byte mask within the TL-UH word   //. mask = 4 bits
    logic [WoffsetWidth-1:0]     woffset ; // Offset of the TL-UH word within the SRAM word  //. woffset = 1 bits
  } sram_req_t ; //. t stands for struct

  //. TO ASK: Should we add another type for the atomic operation  //. but we will either remove the 
  //. or we can insert 2 requests in the req fifo (one for the read and one for the write)
  //. or just make it read to be inserted in responsefifo and the sramreqfifo  //. this is what I will do
  typedef enum logic [1:0] {
    OpWrite,
    OpRead,
    OpAtomic,
    OpHint               //. added response message in TL-UH
    //.OpUnknown   //. TO ASK: this is not used in the code so I replaced it withe OpHint instead of increasing the size of the enum
  } req_op_e ; //. e stands for enum

  typedef struct packed {
    req_op_e                     op ;
    logic                        error ;
    logic [tluh_pkg::TL_SZW-1:0] size ; //. size = 2 bits  //. the size of the data in the form of log2
    logic [tluh_pkg::TL_AIW-1:0] source ; //. source = 8 bits  //. The master source identifier issuing this request.
  } req_t ;

  typedef struct packed {
    logic [SramDw-1:0] data ;  //. 32 bits (4 bytes) (single locatin in SRAM memory)
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
  req_t reqfifo_wdata,  reqfifo_rdata;  //. wdata = write data, rdata = read data

  logic sramreqfifo_wvalid, sramreqfifo_wready;
  logic sramreqfifo_rready;
  sram_req_t sramreqfifo_wdata, sramreqfifo_rdata;

  logic rspfifo_wvalid, rspfifo_wready;
  logic rspfifo_rvalid, rspfifo_rready;
  rsp_t rspfifo_wdata,  rspfifo_rdata;

  //. Burst response
  logic burst_enable;
  int   beat_no = 0;  //. TODO: change the type to logic of 2 bits

  //. Atomic request
  logic [tluh_pkg::TL_DW-1:0]  op_data1;
  logic [tluh_pkg::TL_DW-1:0]  op_data2;
  logic [tluh_pkg::TL_DW-1:0]  op_result;
  logic [2:0]                  op_function;
  bit                          op_cin;
  bit                          op_cout;
  bit                          op_type;   //. 1: arithmetic, 0: logical
  bit                          op_enable;
  logic [tluh_pkg::TL_DBW-1:0] op_mask;
  int                          op_beat_no = 0;

  logic error_internal; // Internal protocol error checker
  logic wr_attr_error;
  logic wr_vld_error;
  logic rd_vld_error;
  logic tlul_error;     // Error from `tluh_err` module

  logic a_ack, d_ack, sram_ack;
  assign a_ack    = tl_i.a_valid & tl_o.a_ready ;
  assign d_ack    = tl_o.d_valid & tl_i.d_ready ;
  assign sram_ack = req_o        & gnt_i ;

  // Valid handling
  logic d_valid, d_error;
  always_comb begin
    d_valid = 1'b0;
    //. TO ASK: I think no need to change the valid signal for the burst mode, right?
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

  //. Error handling
  always_comb begin
    d_error = 1'b0;

    if (reqfifo_rvalid) begin
      if (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) begin
        d_error = rspfifo_rdata.error | reqfifo_rdata.error;
      end else begin
        d_error = reqfifo_rdata.error;  //. if it is write request then no response is waited for (won't be read from the response fifo)
      end
    end else begin
      d_error = 1'b0;
    end
  end

  assign tl_o = '{
      d_valid  : d_valid ,
      //d_opcode : (d_valid && reqfifo_rdata.op != OpRead) ? AccessAck : AccessAckData,   //. TO ASK: Why don't we check for d_valid in case of assigning AccessAckData to the opCode? I think we can remove the d_valid from the condition
      d_opcode : (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) ? AccessAckData :
                 (reqfifo_rdata.op == OpHint) ? HintAck : AccessAck,
      d_param  : '0,
      d_size   : (d_valid) ? reqfifo_rdata.size : '0,
      d_source : (d_valid) ? reqfifo_rdata.source : '0,
      d_sink   : 1'b0,
      d_data   : (d_valid && rspfifo_rvalid && (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic))
                 ? rspfifo_rdata.data : '0,  //. in case of atomic operatoin we reteru the extant data value
      d_error  : d_valid && d_error,

      a_ready  : (gnt_i | error_internal) & reqfifo_wready & sramreqfifo_wready  //. TO ASK: why do we need error_internal here?
  };

  // a_ready depends on the FIFO full condition and grant from SRAM (or SRAM arbiter)
  // assemble response, including read response, write response, and error for unsupported stuff

  // Output to SRAM:
  //    Generate request only when no internal error occurs. If error occurs, the request should be
  //    dropped and returned error response to the host. So, error to be pushed to reqfifo.
  //    In this case, it is assumed the request is granted (may cause ordering issue later?)  //. TO ASK: Why may this cause ordering issue later?
  assign req_o    = ((tl_i.a_valid & reqfifo_wready) || burst_enable) & ~error_internal;  //. TO ASK: why don't we generate a req in case it is a read request? Does write here refer to write data or write any request?
  assign we_o     = (tl_i.a_valid || op_enable) & logic'(tl_i.a_opcode inside {PutFullData, PutPartialData, ArithmeticData, LogicalData}); //. TODO: || atomic
  assign addr_o   = (tl_i.a_valid) ? tl_i.a_address[DataBitWidth+:SramAw] : //.//. [2+:12] = [13:2] //. I guess we use [] because of aliasing (but this doesn't happen in our case I guess)
                    (burst_enable && beat_no == 1) ? (addr_o + 1) % (2^SramAw) : '0; //. TO ASK: Is this correct?   //. TODO: Burst && atomic

  // Support SRAMs wider than the TL-UH word width by mapping the parts of the
  // TL-UH address which are more fine-granular than the SRAM width to the
  // SRAM write mask.
  logic [WoffsetWidth-1:0] woffset;
  if (tluh_pkg::TL_DW != SramDw) begin : gen_wordwidthadapt  //. the gen_wordwidthadapt is a label for the begin-end block
    assign woffset = tl_i.a_address[DataBitWidth-1:tluh_pkg::vbits(tluh_pkg::TL_DBW)]; //. [1:2]
  end else begin : gen_no_wordwidthadapt
    assign woffset = '0;   //. why will it always be 0? we have 2 words in each location in the SRAM
  end


  //. Begin: In case of write request
  // Convert byte mask to SRAM bit mask for writes, and only forward valid data
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] wmask_int;  //. bit mask for SRAM
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] wdata_int;  //. int stands for internal

  always_comb begin
    wmask_int = '0;
    wdata_int = '0;

    if (tl_i.a_valid) begin
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin  //. loop over the bytes
        wmask_int[woffset][8*i +: 8] = {8{op_mask}}; //.  {8{tl_i.a_mask[i]}};  //. TODO: I guess we have to buffer the tl_i.a_mask   //. check here
        wdata_int[woffset][8*i +: 8] = (op_mask && we_o) ? op_enable ? op_result : tl_i.a_data[8*i+:8] : '0;  //. (tl_i.a_mask[i] && we_o) ?  tl_i.a_data[8*i+:8] : '0;  //. check here
      end
    end

    //. TODO: in case of atomic operation, assign the result of the atomic operation to wdata_int
    
  end

  assign wmask_o = wmask_int;
  assign wdata_o = wdata_int;  //. TODO: assign it to the result of the atomic operation if it is an atomic operation
  //. End: In case of write request

  // Begin: Request Error Detection

  // wr_attr_error: Check if the request size,mask are permitted.
  //    Basic check of size, mask, addr align is done in tluh_err module.
  //    Here it checks any partial write if ByteAccess isn't allowed.
  assign wr_attr_error = (tl_i.a_opcode == PutFullData || tl_i.a_opcode == PutPartialData || tl_i.a_opcode == ArithmeticData || tl_i.a_opcode == LogicalData) ?  //. TODO: add ArithmeticData & LogicalData
                         (ByteAccess == 0) ? (tl_i.a_mask != '1 || tl_i.a_size != 2'h2) : 1'b0 :
                         1'b0;

  if (ErrOnWrite == 1) begin : gen_no_writes
    assign wr_vld_error = (tl_i.a_opcode != Get || tl_i.a_opcode != Intent);   //. TODO: add Intent (|| tl_i.a_opcode != Intent)
  end else begin : gen_writes_allowed
    assign wr_vld_error = 1'b0;
  end

  if (ErrOnRead == 1) begin: gen_no_reads
    assign rd_vld_error = (tl_i.a_opcode == Get || tl_i.a_opcode == ArithmeticData || tl_i.a_opcode == LogicalData);   //. TODO: add arithmetic & logical  (TO ASK: what about Intent?)
  end else begin : gen_reads_allowed
    assign rd_vld_error = 1'b0;
  end

  //. TODO: Replace this module by tluh_err module once it is upgraded
  tlul_err u_err (
    .tl_i   (tl_i),
    .err_o (tlul_error)
  );

  assign error_internal = wr_attr_error | wr_vld_error | rd_vld_error | tlul_error;
  // End: Request Error Detection

  assign reqfifo_wvalid = a_ack; // Push to FIFO only when granted  //.(~burst_enable) ? a_ack : 0 ;   //. changed here
  assign reqfifo_wdata  = '{
    op:     (tl_i.a_opcode == Get) ? OpRead :  // To return AccessAck for opcode error
            (tl_i.a_opcode == ArithmeticData || tl_i.a_opcode == LogicalData) ? OpAtomic :
            (tl_i.a_opcode == Intent) ? OpHint : OpWrite , 
    error:  error_internal,
    size:   tl_i.a_size,
    source: tl_i.a_source
  }; // Store the request only. Doesn't have to store data //. this means if the req contians datapayload to be written in the SRAK, so no need to store it, just send it directly to the SRAM   //. cause it is already in SRAM (Important) Wrong
  assign reqfifo_rready = (((beat_no == 2) && (reqfifo_rdata.size == 3) && ((reqfifo_rdata.op == OpAtomic) || (reqfifo_rdata.op == OpRead))) || (reqfifo_rdata.size < 3))  && d_ack;  //. (beat_no == 0) ? d_ack : 1'b0; //. Pop from FIFO only when granted (after sending all beats)  //. changed here ;

  // push together with ReqFIFO, pop upon returning read
  assign sramreqfifo_wdata = '{
    mask    : tl_i.a_mask,
    woffset : woffset
  };
  assign sramreqfifo_wvalid = sram_ack & ~we_o;  //. TO ASK: why ~we_o? why don't we store the request in case of a write request?
  assign sramreqfifo_rready = rspfifo_wvalid;

  assign rspfifo_wvalid = rvalid_i & (reqfifo_rvalid || burst_enable);  //. changes here


  //. Begin: In case of read request
  // Make sure only requested bytes are forwarded
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rdata;
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rmask;
  //logic [SramDw-1:0] rmask;
  logic [tluh_pkg::TL_DW-1:0] rdata_tlword;

  always_comb begin
    rmask = '0;
    for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin  //. loop over the bytes to get the mask
      rmask[sramreqfifo_rdata.woffset][8*i +: 8] = {8{sramreqfifo_rdata.mask[i]}};
    end
  end

  assign rdata = rdata_i & rmask;
  assign rdata_tlword = rdata[sramreqfifo_rdata.woffset]; //. The target word to be read  //. we have only 1 word in location 0 and no other locations in our case
  //. End: In case of read request

  assign rspfifo_wdata  = '{
    data : rdata_tlword,
    error: rerror_i[1] // Only care for Uncorrectable error
  };
  assign rspfifo_rready = ((reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) & ~reqfifo_rdata.error)
                        ? (reqfifo_rready || (beat_no == 1)) : 1'b0 ;  //. no need to put || beat_no == 2 as if so then reqfifo_rready will be 1


  //. Begin: In case of atomic request
  //. TODO: We need to check if it is burst --> check the size
  assign op_enable = (reqfifo_rdata.op == OpAtomic && rspfifo_rvalid) ? 1'b1 : 1'b0;
  assign op_data1  = rvalid_i ? rdata_tlword : '0;  //. TO ASK: which on is correct? this one or the next one?
  //. assign op_data1 = rspfifo_rvalid ? rspfifo_rdata.data : '0;
  //. assign op_data2  = tl_i.a_valid ? tl_i.a_data : op_data2;  //. latch the data  TO ASK: is this fine? OR make it synchronous with the clock?
  assign op_data2  = rspfifo_rdata.data;
  assign op_mask   = tl_i.a_valid ? tl_i.a_mask : op_mask;   //. latch the mask  //. TO ASK: should we take it from the sramfifo?
  //. now we have to handle the burst atomic case --> we have to let carry out of the first beat to be carry in of the second beat
  assign op_cin = (op_beat_no == 1) ? op_cout : 1'b0;
  always @ (posedge clk_i) begin
    if(op_beat_no == 2)
      op_beat_no <= 0;
    if(reqfifo_rvalid && reqfifo_rdata.size == 3 && (reqfifo_rdata.op == OpAtomic)) begin
      //. check if the response is stored in the FIFO
      if(rspfifo_wready && rspfifo_wvalid) begin  //. instead of cheking the Sram_ack
        op_beat_no <= op_beat_no + 1;
      end
    end
  end
  //. End: In case of atomic request


  //. Begin: In case of burst response
  //. assign burst_enable = (reqfifo_rvalid && reqfifo_rdata.size == 3 && beat_no < 2) ? 1'b1 : 1'b0;

  //. burst_enable Handling
  //. TO ASK: I think it should be combinational, right?
  always_comb begin
    if(reqfifo_rvalid && reqfifo_rdata.size == 3 && ((reqfifo_rdata.op == OpAtomic) || (reqfifo_rdata.op == OpRead))) begin
      burst_enable = 1'b1;
    end
    if(beat_no == 2) begin
      burst_enable = 1'b0;
    end
  end
  
  //. beat_no Handling  
  //. TO ASK: I think it should be synchronized with the clock, right?
  always @ (posedge clk_i) begin
    if(beat_no == 2)
      beat_no <= 0;
    if(burst_enable) begin
      //. check if the response is stored in the FIFO
      if(rspfifo_wready && rspfifo_wvalid) begin  //. instead of cheking the Sram_ack
        beat_no <= beat_no + 1;
      end
    end
  end
  //. End: In case of burst response


  // This module only cares about uncorrectable errors.
  logic unused_rerror;
  assign unused_rerror = rerror_i[0];   //. TO ASK: so why do we have this although we don't usy it?

  // FIFO instance: REQ, RSP

  // ReqFIFO is to store the Access type to match to the Response data.
  //    For instance, SRAM accepts the write request but doesn't return the
  //    acknowledge. In this case, it may be hard to determine when the D
  //    response for the write data should send out if reads/writes are
  //    interleaved. So, to make it in-order (even TL-UH allows out-of-order
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
    .clk_i,  //. TO ASK: why don't we assign the clock to the clock of the module? I think because the name is the same so it is assigned automatically.
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
    .rvalid_o(),
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
    .Depth   (Outstanding)
  ) u_rspfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(rspfifo_wvalid),
    .wready_o(rspfifo_wready),
    .wdata_i (rspfifo_wdata),
    .depth_o (),
    .rvalid_o(rspfifo_rvalid),
    .rready_i(rspfifo_rready),
    .rdata_o (rspfifo_rdata),
    .full_o  ()
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
