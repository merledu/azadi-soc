
module t_spi (

  input logic clk_i,
  input logic rst_ni,

  input logic [31:0] rdata_i,
  input logic        req_i,

  output logic       spi_o,
  output logic       spi_clk,
  output logic       spi_cs
);

  typedef enum logic [1:0] {IDLE, LOAD, TX, TOGGLE} state_t;
  logic [31:0] shift_reg;
  logic [63:0] t_counter;
  state_t next_state;
  assign spi_o = shift_reg[31];
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      shift_reg  <= '0;
      t_counter  <= '0;
      spi_clk    <= '1;
      spi_cs     <= '1;
      next_state <= IDLE;
    end else begin
      case (next_state) 
        IDLE: begin
              
              t_counter <= '0;
              spi_clk   <= '1;
              spi_cs <= 1'b1;
              
              if(req_i) begin
                next_state <= LOAD;
                shift_reg <= rdata_i;
                //spi_cs    <= '0;
              end else begin
                next_state <= IDLE;
                shift_reg <= '0;
              end
        end
        LOAD: begin
              shift_reg  <= rdata_i;
              spi_cs     <= '0;
              next_state <= TX;
        end
        TX: begin

            spi_clk     <= 1'b0;
            if(t_counter[0]) begin
                shift_reg   <= {shift_reg[30:0], 1'b0};
            end
            t_counter   <= {t_counter[62:0], 1'b1};
             if((&t_counter[31:0])) begin
               spi_cs <= 1'b1;
             end else begin
               spi_cs <= 1'b0;
             end
            next_state <= TOGGLE;
        end
        TOGGLE: begin
            
                if(&t_counter[31:0]) begin
                  next_state <= IDLE;
                  
                end else begin
                  next_state <= TX;
                end
                spi_clk    <= 1'b1;
        end
        default: begin
              shift_reg  <= '0;
              t_counter  <= '0;
              spi_clk    <= '1;
              spi_cs     <= '1;
              next_state <= IDLE;
        end
      endcase
    end
  end

endmodule 
