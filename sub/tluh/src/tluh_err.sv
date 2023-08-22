

module tluh_err import tluh_pkg::*; (

  input tluh_h2d_t tl_i,

  output logic err_o
);

  localparam int IW  = $bits(tl_i.a_source);
  localparam int SZW = $bits(tl_i.a_size);
  localparam int DW  = $bits(tl_i.a_data);
  localparam int MW  = $bits(tl_i.a_mask);
  localparam int SubAW = $clog2(DW/8);

  logic opcode_allowed, a_config_allowed, param_allowed;

  logic op_full, op_partial, op_get, op_arith, op_log, op_intent;
  assign op_full    = (tl_i.a_opcode == PutFullData);
  assign op_partial = (tl_i.a_opcode == PutPartialData);
  assign op_get     = (tl_i.a_opcode == Get);
  assign op_arith   = (tl_i.a_opcode == ArithmeticData);
  assign op_log     = (tl_i.a_opcode == LogicalData);
  assign op_intent  = (tl_i.a_opcode == Intent);


  // Anything that doesn't fall into the permitted category, it raises an error
  assign err_o = ~(opcode_allowed & a_config_allowed & param_allowed);

  // opcode check
  assign opcode_allowed = (tl_i.a_opcode == PutFullData)
                        | (tl_i.a_opcode == PutPartialData)
                        | (tl_i.a_opcode == Get)
                        | (tl_i.a_opcode == ArithmeticData)
                        | (tl_i.a_opcode == LogicalData)
                        | (tl_i.a_opcode == Intent);

  //. param check
  always_comb begin
    param_allowed = 1'b0;
    if (tl_i.a_valid) begin
      case (tl_i.a_opcode)
        PutFullData: begin
          param_allowed = (tl_i.a_param == 0);
        end

        PutPartialData: begin
          param_allowed = (tl_i.a_param == 0);
        end

        Get: begin
          param_allowed = (tl_i.a_param == 0);
        end

        ArithmeticData: begin
          param_allowed = (tl_i.a_param == MIN) | (tl_i.a_param == MAX) | (tl_i.a_param == MINU) | (tl_i.a_param == MAXU) | (tl_i.a_param == ADD);
        end

        LogicalData: begin
          param_allowed = (tl_i.a_param == XOR) | (tl_i.a_param == OR) | (tl_i.a_param == AND) | (tl_i.a_param == SWAP);
        end

        Intent: begin
          param_allowed = (tl_i.a_param == PrefetchRead) | (tl_i.a_param == PrefetchWrite);
        end

        default: begin
          param_allowed = 1'b0;
        end
      endcase
    end else begin
      param_allowed = 1'b0;
    end
  end                  

  // a channel configuration check
  logic addr_sz_chk;    // address and size alignment check
  logic mask_chk;       // inactive lane a_mask check
  logic fulldata_chk;   // PutFullData should have size match to mask

  logic [MW-1:0] mask;

  assign mask = (1 << tl_i.a_address[SubAW-1:0]);

  always_comb begin
    addr_sz_chk  = 1'b0;
    mask_chk     = 1'b0;
    fulldata_chk = 1'b0; // Only valid when opcode is PutFullData

    if (tl_i.a_valid) begin
      unique case (tl_i.a_size)
        'h0: begin // 1 Byte
          addr_sz_chk  = 1'b1;
          mask_chk     = ~|(tl_i.a_mask & ~mask);
          fulldata_chk = |(tl_i.a_mask & mask);
        end

        'h1: begin // 2 Byte
          addr_sz_chk  = ~tl_i.a_address[0];
          // check inactive lanes if lower 2B, check a_mask[3:2], if uppwer 2B, a_mask[1:0]
          mask_chk     = (tl_i.a_address[1]) ? ~|(tl_i.a_mask & 4'b0011)
                       : ~|(tl_i.a_mask & 4'b1100);
          fulldata_chk = (tl_i.a_address[1]) ? &tl_i.a_mask[3:2] : &tl_i.a_mask[1:0] ;
        end

        'h2: begin // 4 Byte
          addr_sz_chk  = ~|tl_i.a_address[SubAW-1:0];
          mask_chk     = 1'b1;
          fulldata_chk = &tl_i.a_mask[3:0];
        end

        'h3: begin // 8 Byte
          addr_sz_chk  = ~|tl_i.a_address[SubAW-1:0];
          mask_chk     = 1'b1;
          fulldata_chk = &tl_i.a_mask[3:0];
        end

        default: begin // else
          addr_sz_chk  = 1'b0;
          mask_chk     = 1'b0;
          fulldata_chk = 1'b0;
        end
      endcase
    end else begin
      addr_sz_chk  = 1'b0;
      mask_chk     = 1'b0;
      fulldata_chk = 1'b0;
    end
  end

  assign a_config_allowed = addr_sz_chk
                          & mask_chk
                          & (op_get | op_partial | fulldata_chk | op_arith | op_log | op_intent) ;


endmodule