// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designed by: Sajjad Ahmed <sajjad.ahmed3052@gmail.com>

module spi_programmer #(
  parameter ADDR_WIDTH = 13
)(
  input  logic                  clk_i,
  input  logic                  por_ni,
  // Chip IOs
  input  logic                  sck_i,
  input  logic                  sdi_i,
  input  logic                  csb_i,
  // Writing interface to ICCM
  output logic [ADDR_WIDTH-1:0] waddr_o,
  output logic [31:0]           wdata_o,
  output logic                  wvalid_o,
  output logic                  p_done,
  // Writing interface to QSPI module
  output logic [31:0]           q_wdata_o,
  output logic                  q_valid_o,
  // Reset request
  output logic                  reset_req_o,
  // Flash interface mux-sel
  output logic                  flash_intf_o,
  // Boot selection
  output logic                  target_mem_o
);

  typedef enum logic [2:0] {MIDLE, COMMAND, ICCM, FLASH, QSPI_CONFIG} m_state_t;
  typedef enum logic [1:0] {SIDLE, BYTE_WORD, U_ADDR} s_state_t;
  typedef enum logic [1:0] {QIDLE, WORD, CFG} q_state_t;
  typedef enum logic       {CIDLE, CSB_CNT} c_state_t;

  m_state_t main_next_state;
  s_state_t iccm_next_state;
  q_state_t qspi_next_state;
  c_state_t csb_next_state_q, csb_next_state_d;

  logic [7:0]            byte_reg;
  logic [3:0]            byte_cnt;
  logic [31:0]           word_reg;
  logic [ADDR_WIDTH-1:0] iccm_addr;
  logic [31:0]           iccm_data;
  logic                  iccm_valid;
  logic                  iccm_prog_done;
  logic [31:0]           qspi_data;
  logic                  qspi_valid;
  logic                  flash_intf;
  logic                  main_state_init;
  logic [ADDR_WIDTH-1:0] waddr;
  logic                  reset_req;
  logic                  target_memory;

  assign wdata_o      = iccm_data;
  assign wvalid_o     = iccm_valid;
  assign p_done       = iccm_prog_done;
  assign reset_req_o  = reset_req;
  assign q_wdata_o    = qspi_data;
  assign q_valid_o    = qspi_valid;
  assign flash_intf_o = flash_intf;
  assign waddr_o      = waddr;
  assign target_mem_o = target_memory;

  always_ff @(posedge sck_i or negedge por_ni) begin
    if(!por_ni) begin
      byte_reg <= '0;
    end else begin
      if(!csb_i) begin
        byte_reg <= { sdi_i, byte_reg[7:1] };
      end 
    end
  end

  always_ff @(posedge clk_i or negedge por_ni) begin
    if(!por_ni) begin
      csb_next_state_q <= CIDLE;
      main_state_init  <= 1'b0;
    end else begin
      csb_next_state_q <= csb_next_state_d;
      case(csb_next_state_q)
        CIDLE: begin
          if(csb_i) begin
            main_state_init <= 1'b0;
          end
        end
        CSB_CNT: begin
          if(csb_i) begin
            main_state_init <= 1'b1;
          end
        end
      endcase
    end
  end

  always_comb begin
    case(csb_next_state_q)
        CIDLE: begin
          if(!csb_i) begin
            csb_next_state_d = CSB_CNT;
          end else begin
            csb_next_state_d = CIDLE;
          end
        end
        CSB_CNT: begin
          if(!csb_i) begin
            csb_next_state_d = CSB_CNT;
          end else begin
            csb_next_state_d = CIDLE;
          end
        end
        default: begin
          csb_next_state_d = CIDLE;
        end
      endcase
  end

  always_ff @(posedge clk_i or negedge por_ni) begin
    if(!por_ni) begin
      main_next_state   <= MIDLE;
      iccm_next_state   <= SIDLE;
      qspi_next_state   <= QIDLE;
      word_reg          <= '0;
      iccm_addr         <= '0;
      iccm_data         <= '0;
      iccm_valid        <= '0;
      iccm_prog_done    <= '1;
      reset_req         <= '0;
      target_memory     <= '1;
      qspi_data         <= '0;
      qspi_valid        <= '0;
      flash_intf        <= '0;
      byte_cnt          <= '0;
      waddr             <= '0;
    end else begin
      case (main_next_state)
        MIDLE: begin
          qspi_valid        <= 1'b0;
          iccm_next_state   <= SIDLE;
          qspi_next_state   <= QIDLE;
          if(main_state_init) begin
            main_next_state <= COMMAND;
          end else begin
            main_next_state <= MIDLE;
          end
        end
        COMMAND: begin
          if(byte_reg == 8'hB1) begin
            main_next_state <=  ICCM;
            iccm_prog_done  <= 1'b0;
            reset_req       <= 1'b1;
          end else if(byte_reg == 8'hB2) begin
            main_next_state <= FLASH;
            iccm_prog_done  <= 1'b0;
            reset_req       <= 1'b1;
            flash_intf      <= 1'b1;
          end else if(byte_reg == 8'hB3) begin
            main_next_state <= QSPI_CONFIG;
          end else begin
            main_next_state <= MIDLE;
          end
        end
        ICCM: begin
          case (iccm_next_state)
            SIDLE: begin
              if(main_state_init) begin
                iccm_next_state <= BYTE_WORD;
              end else if(&byte_cnt && (word_reg != 32'h00FFFF00)) begin
                byte_cnt        <= '0;
                waddr           <= iccm_addr;
                iccm_data       <= word_reg;
                iccm_valid      <= 1'b1;
                iccm_next_state <= U_ADDR;
              end else begin
                iccm_next_state <= SIDLE;
                iccm_data       <= '0;
                iccm_valid      <= '0;
                reset_req       <= 1'b0;
                target_memory   <= 1'b0;
              end
            end
            BYTE_WORD: begin
              byte_cnt <= {byte_cnt[2:0], 1'b1};
              word_reg <= {byte_reg, word_reg[31:8]};
              if(word_reg != 32'h00FFFF00) begin
                iccm_next_state <= SIDLE;
              end else begin
                main_next_state <= MIDLE;
                iccm_valid      <= 1'b0;
                iccm_addr       <= '0;
                iccm_prog_done  <= 1'b1;
                word_reg        <= '0;
              end
            end
            U_ADDR: begin
              iccm_addr       <= iccm_addr + 1;
              iccm_next_state <= SIDLE;
            end
          endcase
        end
        FLASH: begin
          if (main_state_init) begin
            word_reg        <= { byte_reg, word_reg[31:8]};
            main_next_state <= FLASH;
          end else if (word_reg != 32'h00FFFF00) begin
            reset_req       <= 1'b0;
            target_memory   <= 1'b1;
            main_next_state <= FLASH;            
          end else begin
            main_next_state <= MIDLE;
            word_reg        <= '0;
            flash_intf      <= 1'b0;
            iccm_prog_done  <= 1'b1;
          end
        end
        QSPI_CONFIG: begin
          case (qspi_next_state)
            QIDLE: begin
              if(main_state_init) begin
                qspi_next_state <= WORD;
              end else if(&byte_cnt) begin
                byte_cnt        <= '0;
                qspi_data       <= word_reg;
                qspi_valid      <= 1'b1;
                qspi_next_state <= CFG;
              end else begin
                qspi_next_state <= QIDLE;
              end
            end
            WORD: begin
              byte_cnt <= {byte_cnt[2:0], 1'b1};
                word_reg        <= { byte_reg, word_reg[31:8]};
                qspi_next_state <= QIDLE;
            end
            CFG: begin
              word_reg        <= '0;
              qspi_valid      <= 1'b0;
              main_next_state <= MIDLE;
            end
          endcase
        end
      endcase
    end
  end
endmodule
