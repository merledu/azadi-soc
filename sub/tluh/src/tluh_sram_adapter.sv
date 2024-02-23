/**
 * Tile-Link UH adapter for SRAM-like devices
 *
 * - Intentionally omitted BaseAddr in case of multiple memory maps are used in a SoC,
 *   it means that aliasing can happen if target device size in TL-UH crossbar is bigger
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

  // TL-UH interface
  input   tluh_pkg::tluh_h2d_t  tl_i,
  output  tluh_pkg::tluh_d2h_t  tl_o,

  // SRAM interface
  output logic [tluh_pkg::TL_BEATSMAXW-1:0] intention_blocks_o, //. intention blocks
  output logic              intent_o,  //. intent operation (0:prefetchRead, 1:prefetchWrite)
  output logic              intent_en_o, //. intent enable
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
    logic [tluh_pkg::TL_DBW-1:0] mask ; // Byte mask within the TL-UH word
    logic [WoffsetWidth-1:0]    woffset ; // Offset of the TL-UH word within the SRAM word
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

  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rdata;
  logic [WidthMult-1:0][tluh_pkg::TL_DW-1:0] rmask;
  logic [tluh_pkg::TL_DW-1:0] rdata_tlword;

  localparam int RspFIFODepthW = vbits((Outstanding * TL_BEATSMAX)+1);
  logic [RspFIFODepthW-1:0] rspfifo_depth;
  logic [Outstanding-1:0] reqfifo_depth;

  logic rspfifo_ack, rspfifo_full;

  logic already_ack; // Burst already acknowledged - in case of burst put request, to make sure that the only one ack is sent for the whole burst

  logic update_addr;

  logic [SramAw-1:0] next_addr;

  logic rd_req, wr_req, atomic_req, intent_req;

  logic error_internal; // Internal protocol error checker
  logic wr_attr_error;
  logic wr_vld_error;
  logic rd_vld_error;
  logic tluh_error;     // Error from `tluh_err` module

//. Atomic signals
  logic [tluh_pkg::TL_DW-1:0]  op_data1;
  logic [tluh_pkg::TL_DW-1:0]  op_data2;
  logic [tluh_pkg::TL_DW-1:0]  op_result;
  logic [2:0]                  op_function;
  logic [tluh_pkg::TL_DBW-1:0] op_mask;
  logic                        op_cin;
  logic                        op_cout;
  logic                        op_type;   //. 1: arithmetic, 0: logical
  logic                        op_enable;
  logic                        atomic_rd;
  logic                        atomic_wr;
//.



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

  logic remove_req; //. remove the request from the reqfifo

  //. Burst responses
  logic burst;
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_to_push;
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_to_send;
  logic [tluh_pkg::TL_BEATSMAXW-1:0] beats_to_write;

  logic a_ack, d_ack, sram_ack;
  assign a_ack    = tl_i.a_valid & tl_o.a_ready ;
  assign d_ack    = tl_o.d_valid & tl_i.d_ready ;
  assign sram_ack = req_o        & gnt_i ;


  logic d_valid, d_error;
  always_comb begin
    atomic_req = (reqfifo_rdata.op == OpAtomic) && (reqfifo_rvalid || reqfifo_wvalid) || (a_ack && ((tl_i.a_opcode == LogicalData) || (tl_i.a_opcode == ArithmeticData)));
   
    if(atomic_req) begin
      if(a_ack) begin
        op_type     = (tl_i.a_opcode == LogicalData) ? 1'b0 : 1'b1;
        op_function = tl_i.a_param;
        op_cin      = 1'b0;
        op_enable   = 1'b1;
        op_data1    = tl_i.a_data;
        if(~burst)
          atomic_rd   = 1'b1;
        else begin
          if(atomic_rd) begin
            if(rvalid_i)
              atomic_rd = update_addr;
          end
          else 
            atomic_rd = update_addr;
        end        
      end
      else if(atomic_wr) begin
        atomic_rd = 1'b0;
      end
      else begin
        if(atomic_rd) begin
          if(rvalid_i)
            atomic_rd = update_addr;
        end
        else 
          atomic_rd = update_addr;
      end
    end
    else begin
      atomic_rd = 1'b0;
    end

    wr_req     = atomic_wr || (reqfifo_rdata.op == OpWrite && (reqfifo_rvalid)) || (a_ack && (tl_i.a_opcode == PutFullData || tl_i.a_opcode == PutPartialData)); 
    rd_req     = atomic_rd || ((reqfifo_rdata.op == OpRead) && (reqfifo_rvalid || reqfifo_wvalid)) || (a_ack && (tl_i.a_opcode == Get)); 
    intent_req = ((reqfifo_rdata.op == OpHint) && (reqfifo_rvalid || reqfifo_wvalid) ) || (a_ack && (tl_i.a_opcode == Intent));
  end

//. Valid handling
  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      d_valid <= 1'b0;
    end else begin
      if (reqfifo_rvalid && reqfifo_rdata.error) begin
        // Return error response. Assume no request went out to SRAM
        d_valid <= 1'b1;
      end 
      else if ((rd_req || atomic_req)) begin
        if(rspfifo_depth == 0) begin
          if(d_valid) begin  //. this is just to latch the d_valid signal until it is received by the host
            if(d_ack) begin
              d_valid <= 1'b0;
            end
          end
          else 
            d_valid <= rvalid_i;
        end
        else
          d_valid <= rspfifo_rvalid;
      end
      else if (wr_req) begin
        if(d_ack) begin
          d_valid <= 1'b0;
        end
        else
          d_valid <= ~already_ack;
      end
      else if (intent_req) begin
        if(d_ack)
          d_valid <= 1'b0;
        else 
          d_valid <= reqfifo_rvalid;
      end
      else begin
        d_valid <= 1'b0;
      end
      
    end
  end
//.


//. Error handling
  always_comb begin
    d_error = 1'b0;

    if (reqfifo_rvalid) begin
      if (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) begin
        if(rspfifo_depth > 0)
          d_error = rspfifo_rdata.error | reqfifo_rdata.error;
        else
          d_error = rerror_i[1] | reqfifo_rdata.error;
      end else begin
        d_error = reqfifo_rdata.error;
      end
    end else begin
      d_error = 1'b0;
    end
  end
//.

  assign tl_o = '{
      d_valid  : d_valid ,
      d_opcode : (reqfifo_rdata.op == OpRead || reqfifo_rdata.op == OpAtomic) ? AccessAckData :
                 (reqfifo_rdata.op == OpHint) ? HintAck : AccessAck,
      d_param  : '0,
      d_size   : tl_i.a_valid ? tl_i.a_size : tl_o.d_size,
      d_source : (d_valid) ? reqfifo_rdata.source : '0,
      d_sink   : 1'b0,
      d_data   : (rspfifo_rvalid)
                 ? rspfifo_rdata.data : rdata_tlword,
      d_error  : d_valid && d_error,

      a_ready  : (gnt_i | error_internal) & reqfifo_wready & sramreqfifo_wready
  };
// a_ready depends on the FIFO full condition and grant from SRAM (or SRAM arbiter)
// assemble response, including read response, write response, and error for unsupported stuff


  //. Intent signals
  always_comb begin
    if(a_ack && intent_req) begin
      intention_blocks_o = $clog2(tl_i.a_size);
      intent_o           = tl_i.a_param[0];
      intent_en_o        = 1'b1;
    end
    else begin
      intention_blocks_o = '0;
      intent_o           = 0;
      intent_en_o        = 1'b0;
    end
  end

  // Output to SRAM:
  //    Generate request only when no internal error occurs. If error occurs, the request should be
  //    dropped and returned error response to the host. So, error to be pushed to reqfifo.
  //    In this case, it is assumed the request is granted (may cause ordering issue later?)


  assign we_o = (a_ack && logic'(tl_i.a_opcode inside {PutFullData, PutPartialData})) || atomic_wr || wr_req;


  // Support SRAMs wider than the TL-UH word width by mapping the parts of the
  // TL-UH address which are more fine-granular than the SRAM width to the
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

    if (tl_i.a_valid || atomic_req || burst) begin
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
        wmask_int[woffset][8*i +: 8] = {8{tl_i.a_mask[i]}};
        wdata_int[woffset][8*i +: 8] = we_o ? atomic_req ? op_mask[i] ? op_result[8*i+:8] : '0 : tl_i.a_mask[i] ? tl_i.a_data[8*i+:8] : '0 : '0;
        //.wdata_int[woffset][8*i +: 8] = (tl_i.a_mask[i] && we_o) ?  tl_i.a_data[8*i+:8] : '0; //. old code
      end
    end
  end

  assign wmask_o = wmask_int;
  assign wdata_o = wdata_int;



//. Begin: Req FIFO
  assign reqfifo_wvalid = a_ack ; // Push to FIFO only when granted
  assign reqfifo_wdata  = '{
    op:     (tl_i.a_opcode == Get) ? OpRead :
            (tl_i.a_opcode == ArithmeticData || tl_i.a_opcode == LogicalData) ? OpAtomic :
            (tl_i.a_opcode == Intent) ? OpHint : OpWrite , // To return AccessAck for opcode error
    error:  error_internal,
    size:   tl_i.a_size,
    source: tl_i.a_source
  }; // Store the request only. Doesn't have to store data


  logic req_served;
  logic req_ack_sram;
  logic req_ack_host;
  always_comb begin
    if(a_ack) begin
      req_ack_host = 1'b0;
      req_ack_sram = 1'b0;
    end
    else begin
      if(atomic_req) begin
        if(d_ack)
          req_ack_host = 1'b1;
        if(atomic_wr && sram_ack)
          req_ack_sram = 1'b1;
      end
      else if (intent_req) begin
        if(sram_ack)
          req_ack_sram = 1'b1;
        if(d_ack)
          req_ack_host = 1'b1;
      end
      else if (wr_req) begin
        if(remove_req) begin
          req_ack_host = 1'b1;
          req_ack_sram = 1'b1;
        end
      end
      else if (rd_req) begin
        if(d_ack && (rspfifo_depth == 0) && (beats_to_send == 1)) begin
          req_ack_host = 1'b1;
          req_ack_sram = 1'b1;
        end
      else begin
        req_ack_host = 1'b0;
        req_ack_sram = 1'b0;
      end

      end
    end
  end

  assign req_served = req_ack_host && req_ack_sram;

  assign reqfifo_rready = req_served;


  logic keep_req;
  logic current_data_is_written;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      remove_req <= 1'b0;
      keep_req   <= 1'b0;
      current_data_is_written <= 1'b0;
    end
    else begin
      //. first check if this is the last beat of the burst
      //. if so then keep it in the reqfifo in case already_ack is low until it become high
      //. if it is not the last beat, then keep it for one clock cycle (to make sure the data is written in the sram) then check sram_ack and if it is not raised then keep the req and if it is raised then remove it
      if(wr_req) begin
        if(a_ack) begin
          keep_req   <= 1'b1;
          remove_req <= 1'b0;
          if(sram_ack) begin
            current_data_is_written <= 1'b1;
          end
        end
        else if (keep_req) begin
          //. if this is the last beat of the burst
          if(beats_to_write == 1) begin
            if((already_ack || d_ack) && (current_data_is_written || sram_ack)) begin
              keep_req   <= 1'b0;
              remove_req <= 1'b1;
              current_data_is_written <= 1'b0;
            end
            else if (sram_ack) begin
              current_data_is_written <= 1'b1;
            end
          end
          else if (current_data_is_written || sram_ack) begin
            keep_req   <= 1'b0;
            remove_req <= 1'b1;
            current_data_is_written <= 1'b0;
          end
        end
        else begin
          remove_req <= 1'b0;
        end
      end
      else 
        remove_req <= 1'b0;
    end
  end

//. End: Req FIFO
  

//. Begin: srmareq FIFO
  // push together with ReqFIFO, pop upon returning read
  assign sramreqfifo_wdata = '{
    mask    : tl_i.a_mask,
    woffset : woffset
  };
  assign sramreqfifo_wvalid = sram_ack & ~we_o;
  assign sramreqfifo_rready = reqfifo_rready;
//. End: srmareq FIFO

  assign rdata_tlword = rdata[sramreqfifo_rdata.woffset];
  assign op_data2 = rdata_tlword;

//.Begin: Rsp FIFO
  assign rspfifo_wvalid = (~tl_i.d_ready || (rspfifo_depth > 0)) && reqfifo_rvalid && rvalid_i;
  assign rspfifo_wdata  = '{
    data : rdata_tlword,
    error: rerror_i[1] // Only care for Uncorrectable error
  };
  
  
  assign rspfifo_rready = tl_i.d_ready && (rspfifo_depth > 0) && ~reqfifo_rdata.error;

  assign rspfifo_ack = rspfifo_wvalid & rspfifo_wready;
//.End:   Rsp FIFO


  always_comb begin
    // Make sure only requested bytes are forwarded
    if(sramreqfifo_rvalid) begin
      rmask = '0;
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
        rmask[sramreqfifo_rdata.woffset][8*i +: 8] = {8{sramreqfifo_rdata.mask[i]}};
      end
    end
    else if (a_ack) begin
      rmask = '0;
      for (int i = 0 ; i < tluh_pkg::TL_DW/8 ; i++) begin
        rmask[woffset][8*i +: 8] = {8{tl_i.a_mask[i]}};
      end
    end
    
    if(a_ack && ~burst) begin
      if(tl_i.a_valid)begin
        addr_o = tl_i.a_address[DataBitWidth+:SramAw];
        req_o  = ~error_internal;
      end 
    end
    else if(update_addr) begin
      addr_o = next_addr;
      req_o  = 1'b1;
    end
    else if (atomic_req) begin
      req_o = atomic_rd || atomic_wr;
    end
    else if (intent_req) begin
      req_o = ~req_ack_sram && ~reqfifo_rready;
    end
    else begin
      req_o = 1'b0;
    end
  end


  always_comb begin
    if(rvalid_i) begin
      rdata  = rdata_i & rmask;  
    end
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      burst          <= 1'b0;
      get_state      <= GET_IDLE;
      put_state      <= PUT_IDLE;
      atomic_state   <= ATOMIC_IDLE;
      next_addr      <= '0;
      beats_to_push  <= '0;
      beats_to_send  <= '0;
      beats_to_write <= 0;
      already_ack    <= 0; 
      atomic_wr      <= 0;
      op_mask        <= '0;
      update_addr    <= '0;
    end 

    else begin
      if(d_ack) begin
        if(wr_req && ~atomic_req) begin
          already_ack <= 1'b1;
        end
        else begin
          if(beats_to_send > 0) begin
            beats_to_send <= (beats_to_send - 1);
            if(beats_to_send == 1) begin
              beats_to_push <= '0;
            end
          end
        end
      end
  
      if(rspfifo_ack) begin
        beats_to_push <= beats_to_push - 1;
      end

      if(sram_ack && wr_req) begin
        beats_to_write <= beats_to_write - 1;
      end

      if(a_ack && ~wr_req && already_ack) begin
        already_ack <= 1'b0;
      end

      if(burst) begin
        if(((beats_to_push == 1 && rspfifo_ack) || (beats_to_send == 1 && d_ack) || (beats_to_write == 1 && sram_ack && already_ack)) && ~a_ack) begin
          burst <= 1'b0;
          update_addr <= 1'b0;
        end 
        else if (update_addr) 
          update_addr <= 1'b0;
        else begin
          if(rd_req && ((d_ack && rspfifo_depth == 0) || rspfifo_ack)) begin
            update_addr <= 1'b1;
          end
          else if (wr_req && (a_ack))
            update_addr <= 1'b1;
          else if (atomic_req && a_ack)
            update_addr <= 1'b1;
          else begin
            update_addr <= 1'b0;
          end
        end
      end 
      else if (update_addr) begin 
        update_addr <= 1'b0;
      end

  
      if (a_ack || req_o) begin
        if(atomic_req) begin
          case(atomic_state)
            ATOMIC_IDLE: begin
              if(a_ack) begin
                beats_to_send  <= $clog2(tl_i.a_size);
                beats_to_push  <= $clog2(tl_i.a_size);
                beats_to_write <= $clog2(tl_i.a_size);
                atomic_state   <= PERFORM_WRITE;
                op_mask        <= tl_i.a_mask;
                if(sram_ack)  //. if the data is already read from the sram
                  atomic_wr <= 1'b1;
                //. check if burst
                if(tl_i.a_size > $clog2(TL_DBW)) begin
                  burst     <= 1'b1;
                  next_addr <= ((tl_i.a_address[DataBitWidth+:SramAw] + SramByte) % (2**SramAw));
                end
                else
                  burst <= 1'b0;
              end
            end
            PERFORM_WRITE: begin
              //. make sure the data is read from the sram if it wasn't already
              if(atomic_wr) begin
                //. check if the data is written in the sram (sram_ack)
                if(sram_ack) begin
                  atomic_wr <= 1'b0;
                  //. determine whether to go back to idle state or proceed to next_beat
                  if(~burst || (beats_to_send == 1 && d_ack) || (beats_to_push == 1 && rspfifo_ack))
                    atomic_state <= ATOMIC_IDLE;
                  else
                    atomic_state <= NEXT_BEAT;
                end
              end
              else
                if(sram_ack)
                  atomic_wr <= 1'b1;
            end
            NEXT_BEAT: begin
              //. check if the next beat is receivd
              if(a_ack) begin
                if(sram_ack)  //. check if the data is already read from the sram
                  atomic_wr <= 1'b1;
                atomic_state <= PERFORM_WRITE;
              end
            end
          endcase
        end

        else if(rd_req) begin
          case(get_state)
            GET_IDLE: begin
              if(a_ack) begin
                beats_to_send <= $clog2(tl_i.a_size);
                beats_to_push <= $clog2(tl_i.a_size);
                //. check if burst
                if(tl_i.a_size > $clog2(TL_DBW)) begin
                  get_state <= READ_NEXT_BEAT;
                  burst     <= 1'b1;
                  next_addr <= ((tl_i.a_address[DataBitWidth+:SramAw] + SramByte) % (2**SramAw));
                end
                else
                  burst <= 1'b0;
              end
            end
            READ_NEXT_BEAT: begin
              //. make sure the previous beat was either pushed into the FIFO or sent to the host
              if((beats_to_send == 1 && d_ack) || (beats_to_push == 1 && rspfifo_ack))
                get_state <= GET_IDLE;
              else if (rspfifo_ack || d_ack)
                next_addr <= ((addr_o + SramByte) % (2**SramAw));
            end
          endcase
        end

        else if (wr_req) begin
          case(put_state)
            PUT_IDLE: begin
              if(a_ack) begin
                already_ack <= 1'b0;
                if(sram_ack)
                  beats_to_write <= $clog2(tl_i.a_size) - 1;
                else
                  beats_to_write <= $clog2(tl_i.a_size);
                //. check if burst
                if(tl_i.a_size >  $clog2(TL_DBW)) begin
                  put_state <= WRITE_NEXT_BEAT;
                  burst     <= 1'b1;
                  next_addr <= ((tl_i.a_address[DataBitWidth+:SramAw] + SramByte) % (2**SramAw));
                end
                else
                  burst <= 1'b0;
              end
            end
            WRITE_NEXT_BEAT: begin
              //.make sure the previous beat was written in the sram
              if(sram_ack && beats_to_write == 1)
                put_state <= PUT_IDLE;
              else if (sram_ack)
                next_addr <= ((addr_o + SramByte) % (2**SramAw));
            end
          endcase
        end
      end
    end
  end


//Begin: Request Error Detection
  // wr_attr_error: Check if the request size,mask are permitted.
  //    Basic check of size, mask, addr align is done in tluh_err module.
  //    Here it checks any partial write if ByteAccess isn't allowed.
  assign wr_attr_error = (tl_i.a_opcode == PutFullData || tl_i.a_opcode == PutPartialData) ?
                         (ByteAccess == 0) ? (tl_i.a_mask != '1 || tl_i.a_size != 2'h2) : 1'b0 :
                         1'b0;

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

tluh_err u_err (
    .tl_i   (tl_i),
    .err_o (tluh_error)
  );

  logic tluh_err;

  always_comb begin
    if(a_ack) 
      tluh_err = tluh_error;
  end

  assign error_internal = wr_attr_error | wr_vld_error | rd_vld_error | tluh_err;
//End: Request Error Detection

  // This module only cares about uncorrectable errors.
  logic unused_rerror;
  assign unused_rerror = rerror_i[0];



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
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(reqfifo_wvalid),
    .wready_o(reqfifo_wready),
    .wdata_i (reqfifo_wdata),
    .depth_o (reqfifo_depth),
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