module qspi_xip (

  input logic clk_i,
  input logic rst_ni,
  input logic por_ni,
    
  input  logic [23:0] addr_i,
  input  logic        req_i,
  output logic [31:0] rdata_o,
  output logic        rvalid_o,

  // qspi write configuration intf
  input  logic [31:0] wdata_i,
  input  logic        we_i,
    
  input  logic [3:0] qspi_i,
  output logic [3:0] qspi_o,
  output logic [3:0] qspi_oe,
  output logic       qspi_csb,
  output logic       qspi_clk

);

  typedef enum logic [1:0] {IDLE, TRANSMIT, TOGGLE, RECEIVE} xip_state_t;

  xip_state_t  next_state;
  logic [6:0]  cycle_cnt;
  logic [31:0] shift_reg;

  logic [23:0]  addr_reg;
  logic [1:0]   config_reg;
  logic [5:0]   dummy_cycles;
  logic [23:0]  shift_out_addr;

  // Configuration register fields
  //                      7-2                       1          0
  //////////////////////////////////////////////////////////////////////
  //                   res                   //   ec_xip   //  e_xip  //
  //////////////////////////////////////////////////////////////////////

  logic clr_exip;

  always_ff @(posedge clk_i or negedge por_ni) begin
    if(!por_ni) begin
      addr_reg      <= '0;
      config_reg    <= 2'b00;
      dummy_cycles  <= 6'd10;
    end else begin
      if(we_i) begin
        addr_reg     <= wdata_i[23:0];
        config_reg   <= wdata_i[25:24];
        dummy_cycles <= wdata_i[31:26];
      end else begin
        if (clr_exip) begin
          config_reg[0] <= '0;
        end
      end
    end
  end 

  always_comb begin
    if(config_reg[1]) begin
      qspi_o   = shift_reg[31:28];
    end else begin
      qspi_o[0]   = shift_reg[31];
      qspi_o[1]   = '0;
      qspi_o[3:2] = 2'b11;
    end
  end
  assign shift_out_addr = addr_i + addr_reg;
  always_ff @( posedge clk_i or negedge rst_ni ) begin
    if(!rst_ni) begin
      next_state <= IDLE;
      cycle_cnt  <= '0;
      qspi_clk   <= 1'b1;
      qspi_csb   <= 1'b1;
      qspi_oe    <= 4'b1110;
      rvalid_o   <= '0;
      rdata_o    <= '0;
      shift_reg  <= '0;
      clr_exip   <= '0;
    end else begin
      case(next_state)
        IDLE: begin
          if(config_reg[1] && req_i) begin // run in XIP
            next_state <= TRANSMIT;
            if(config_reg[0]) begin
              shift_reg  <= {24'h0, 4'b0001, 4'b0}; // exit XIP
            end else begin
              shift_reg  <= {shift_out_addr, 8'h0};
            end
            qspi_oe    <= 4'b0000;
            qspi_csb   <= 1'b0;
            rvalid_o   <= 1'b0;
            cycle_cnt  <= '0;
          end else if(req_i && ~config_reg[1]) begin // spi
            next_state <= TRANSMIT;
            shift_reg  <= {8'h03, shift_out_addr};
            qspi_oe    <= 4'b1110;
            qspi_csb   <= 1'b0;
            rvalid_o   <= 1'b0;
            cycle_cnt  <= '0;
          end else begin
            next_state <= IDLE;
            shift_reg  <= {8'h03, shift_out_addr};
            qspi_oe    <= 4'b1110;
            qspi_csb   <= 1'b1;
            rvalid_o   <= 1'b0;
            qspi_clk   <= 1'b1;
            cycle_cnt  <= '0;
            clr_exip   <= 1'b0;
          end
        end
        TRANSMIT: begin
          qspi_clk <= 1'b0;
          next_state <= TOGGLE;
          if(config_reg[1]) begin
            if(config_reg[0]) begin 
              if((cycle_cnt > 0)) begin
                shift_reg  <= {shift_reg[27:0], 4'b0};
              end 
              if(cycle_cnt >= 6) begin
                qspi_oe    <= 4'b1110;
              end
            end else begin
                if((cycle_cnt > 0) && (cycle_cnt <= (6 + dummy_cycles))) begin // qspi mode
                  shift_reg  <= {shift_reg[27:0], 4'b0};
                end
                if(cycle_cnt >= (6 + (dummy_cycles-1))) begin
                  qspi_oe    <= 4'b1111;
                end
            end 
          end else begin
            if((cycle_cnt > 0) && (cycle_cnt <= 32)) begin // spi mode
              shift_reg  <= {shift_reg[30:0], 1'b0};
            end
          end
          cycle_cnt <= cycle_cnt + 1;
        end
        TOGGLE: begin
          if(config_reg[1]) begin
            if(config_reg[0]) begin
              if(cycle_cnt != (6 + dummy_cycles + 2)) begin
                next_state <= TRANSMIT;
              end else begin
                next_state <= IDLE;
                clr_exip  <= 1'b1;
                cycle_cnt  <= '0;
              end
            end else begin
              if(cycle_cnt > (6 + dummy_cycles)) begin
                shift_reg <= {shift_reg[27:0], qspi_i};
              end
              if(cycle_cnt != (6 + dummy_cycles + 8)) begin
                next_state <= TRANSMIT;
              end else begin
                next_state <= RECEIVE;
                cycle_cnt  <= '0;
              end
            end
          end else begin
            if(cycle_cnt > 32) begin
              shift_reg <= {shift_reg[31:0], qspi_i[1]};
            end
            if(cycle_cnt != 64) begin
              next_state <= TRANSMIT;
            end else begin
              next_state <= RECEIVE;
              cycle_cnt  <= '0;
            end
          end
          qspi_clk <= 1'b1;
        end
        RECEIVE: begin
          if(cycle_cnt != 3) begin
            cycle_cnt  <= cycle_cnt + 1;
            next_state <= RECEIVE;
          end else begin
            next_state <= IDLE;
            cycle_cnt  <= '0;
          end
          qspi_csb   <= 1'b1;
          rdata_o    <= shift_reg;
          if(cycle_cnt < 1) begin
            rvalid_o   <= 1'b1;
          end else begin
            rvalid_o   <= 1'b0;
          end
        end 
        default: begin
          next_state <= IDLE;
          shift_reg  <= '0;
          rdata_o    <= '0;
          qspi_csb   <= 1'b1;
          rvalid_o   <= 1'b0;
          qspi_clk   <= 1'b1;
        end
      endcase
    end
  end

endmodule
