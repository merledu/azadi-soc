// `include "/home/merl/github_repos/azadi/src/spi_host/rtl/spi_defines.v"//
//`include "spi_defines.v"

module spi_clgen (
  input    wire                        clk_i,   // input clock (system clock)
  input    wire                        rst_ni,      // reset
  input    wire                        enable,   // clock enable
  input    wire                        go,       // start transfer
  input    wire                        last_clk, // last clock
  input    wire [`SPI_DIVIDER_LEN-1:0] divider,  // clock divider (output clock is divided by this value)
  output    reg                    clk_out,  // output clock
  output    reg                    pos_edge, // pulse marking positive edge of clk_out
  output    reg                    neg_edge // pulse marking negative edge of clk_out

); 
                            
  //reg                              clk_out;
  //reg                              pos_edge;
  //reg                              neg_edge;
  reg [15:0] cnt;                          
  wire cnt_zero;
	wire cnt_one;
	assign cnt_zero = cnt == {16 {1'b0}};
	assign cnt_one = cnt == {{15 {1'b0}}, 1'b1};
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			cnt <= {16 {1'b1}};
		else if (!enable || cnt_zero)
			cnt <= divider;
		else
			cnt <= cnt - {{15 {1'b0}}, 1'b1};
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			clk_out <= 1'b0;
		else
			clk_out <= ((enable && cnt_zero) && (!last_clk || clk_out) ? ~clk_out : clk_out);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			pos_edge <= 1'b0;
			neg_edge <= 1'b0;
		end
		else begin
			pos_edge <= (((enable && !clk_out) && cnt_one) || (!(|divider) && clk_out)) || ((!(|divider) && go) && !enable);
			neg_edge <= ((enable && clk_out) && cnt_one) || ((!(|divider) && !clk_out) && enable);
		end
endmodule
 
