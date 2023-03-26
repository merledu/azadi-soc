// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module tx_spi #(
  parameter DPW = 8
)(
  input  logic           clk_i,
  input  logic           rst_ni,
  input  logic [DPW-1:0] rdata_i,
  input  logic           req_i,
  output logic           spi_o,
  output logic           spi_clk,
  output logic           spi_csb,
  output logic           spi_rdy
);

  typedef enum logic [1:0] {IDLE, LOAD, TX, TOGGLE} state_t;
  state_t next_state;
  logic [DPW-1:0]   shift_reg;
  logic [2*DPW-1:0] t_counter;

  assign spi_o = shift_reg[DPW-1];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      shift_reg  <= '0;
      t_counter  <= '0;
      spi_clk    <= '1;
      spi_csb    <= '1;
      spi_rdy    <= '0;
      next_state <= IDLE;
    end else begin
      case (next_state)
        IDLE: begin
          spi_clk   <= 1'b1;
          spi_csb   <= 1'b1;
          spi_rdy   <= 1'b0;
          t_counter <= '0;
          if(req_i) begin
            next_state <= LOAD;
            shift_reg  <= rdata_i;
          end else begin
            next_state <= IDLE;
            shift_reg  <= '0;
          end
        end
        LOAD: begin
          shift_reg  <= rdata_i;
          spi_csb    <= 1'b0;
          next_state <= TX;
        end
        TX: begin
          spi_clk    <= 1'b0;
          next_state <= TOGGLE;
          t_counter  <= {t_counter[2*DPW-2:0], 1'b1};
          if(t_counter[0]) begin
            shift_reg <= {shift_reg[DPW-2:0], 1'b0};
          end
          if(&t_counter[DPW-1:0]) begin
            spi_csb <= 1'b1;
          end else begin
            spi_csb <= 1'b0;
          end
        end
        TOGGLE: begin
          spi_clk <= 1'b1;
          if(&t_counter[DPW-1:0]) begin
            next_state <= IDLE;
            spi_rdy    <= 1'b1;
          end else begin
            next_state <= TX;
          end
        end
        default: begin
          shift_reg  <= '0;
          t_counter  <= '0;
          spi_clk    <= '1;
          spi_csb    <= '1;
          next_state <= IDLE;
        end
      endcase
    end
  end

endmodule
