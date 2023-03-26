
module spi_clgen (
  input  logic        clk_i,      // input clock (system clock)
  input  logic        rst_ni,     // reset
  input  logic        enable_i,   // enable
  input  logic [15:0] prescale_i, // clock divider (output clock is divided by this value in 2**n)
  output logic        clken_o     // output clock clock enb
);

	logic [15:0] count_rg;

	assign clken_o = (count_rg == prescale_i);
	always @ (posedge clk_i or negedge rst_ni) begin
	  if (!rst_ni) begin
	    count_rg   <= 0;      
	  end else begin
			if (enable_i) begin
	      count_rg   <= count_rg + 1;      
	      if (clken_o) begin         
					count_rg  <= '0;
	      end
			end
	  end
	end

endmodule
