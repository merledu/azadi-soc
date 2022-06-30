
module rx_timer 
(
  input logic clk_i,
  input logic rst_ni,
  
  input logic ten_i,
  input logic rx_start_i,
  input logic [31:0] wdata_i,
  
  output logic rx_timeout_o

);


  typedef enum logic [1:0] {RESET, COUNT, INTERRUPT, FLUSH} t_state;
  logic [31:0] rx_time;
  logic [31:0] rx_timeout;
  t_state state_reg;
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      rx_timeout <= 32'hf;
      rx_time    <= '0; 
      rx_timeout_o <= 1'b0;
      state_reg  <= RESET;
    end else begin
      rx_timeout <= wdata_i;
      unique case(state_reg)
	RESET: begin
		rx_time    <= '0;
		rx_timeout_o <= 1'b0;
		if(ten_i & ~rx_start_i) begin
		  state_reg <= COUNT;
		end else begin
		  state_reg <= RESET;
	        end
	       end
	COUNT: begin
		rx_time   <= rx_time + 32'b1;
		rx_timeout_o <= 1'b0;
		state_reg <= INTERRUPT; 
	       end
	INTERRUPT: begin
		if(rx_start_i) begin
		  state_reg <= FLUSH;
		end else if (rx_time >= rx_timeout) begin
		  rx_timeout_o <= 1'b1;
		  rx_timeout <= 32'hf;
		end else begin
		  state_reg <= COUNT;
		end
	       end
	FLUSH: begin
		state_reg <= RESET;
	       end
      endcase
    end
  end
  
  
  
  
  

endmodule 