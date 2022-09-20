//`include "spi_defines.v"

module spi_shift (
  input  wire                        clk_i,          // system clock
  input  wire                        rst_ni,          // reset
  input  wire                        latch,        // latch signal for storing the data in shift register
  input  wire                  [3:0] byte_sel,     // byte select signals for storing the data in shift register
  input  wire [`SPI_CHAR_LEN_BITS-1:0] len,          // data len in bits (minus one)
  input  wire                        lsb,          // lbs first_ni on the line
  input  wire                        go,           // start stansfer
  input  wire                        pos_edge,     // recognize posedge of sclk_i
  input  wire                        neg_edge,     // recognize negedge of sclk_i
  input  wire                        rx_negedge,   // s_in is sampled on negative edge 
  input  wire                        tx_negedge,   // s_out is driven on negative edge
  output   reg                   tip,          // transfer in progress
  output wire                        last,         // last bit
  input  wire                 [31:0] p_in,         // parallel in
  output wire    [`SPI_MAX_CHAR-1:0] p_out,        // parallel out
  input  wire                        s_clk,        // serial clock
  input  wire                        s_in,         // serial in
  output   reg                   s_out,        // serial out
  input  wire                        rx_en         // serial rx enable  
);
                                   
 // reg                            s_out;        
 // reg                            tip;
                              
 reg [5:0] cnt;
	reg [31:0] data;
	reg [31:0] data_rx;
	wire [5:0] tx_bit_pos;
	wire [5:0] rx_bit_pos;
	wire rx_clk_i;
	wire tx_clk_i;
	assign p_out = data_rx;
	assign tx_bit_pos = (lsb ? {!(|len), len} - cnt : cnt - {{5 {1'b0}}, 1'b1});
	assign rx_bit_pos = (lsb ? {!(|len), len} - (rx_negedge ? cnt + {{5 {1'b0}}, 1'b1} : cnt) : (rx_negedge ? cnt : cnt - {{5 {1'b0}}, 1'b1}));
	assign last = !(|cnt);
	assign rx_clk_i = (rx_negedge ? neg_edge : pos_edge) && (!last || s_clk);
	assign tx_clk_i = (tx_negedge ? neg_edge : pos_edge) && !last;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			cnt <= {6 {1'b0}};
		else if (tip)
			cnt <= (pos_edge ? cnt - {{5 {1'b0}}, 1'b1} : cnt);
		else
			cnt <= (!(|len) ? {1'b1, {5 {1'b0}}} : {1'b0, len});
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			tip <= 1'b0;
		else if (go && ~tip)
			tip <= 1'b1;
		else if ((tip && last) && pos_edge)
			tip <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			s_out <= 1'b0;
		else
			s_out <= (tx_clk_i || !tip ? data[tx_bit_pos[4:0]] : s_out);
	always @(posedge clk_i)
		if (~rst_ni)
			data <= {32 {1'b0}};
		else if (latch && !tip) begin
			if (byte_sel[0])
				data[7:0] <= p_in[7:0];
			if (byte_sel[1])
				data[15:8] <= p_in[15:8];
			if (byte_sel[2])
				data[23:16] <= p_in[23:16];
			if (byte_sel[3])
				data[31:24] <= p_in[31:24];
		end
		else if (rx_en && tip)
			data_rx[rx_bit_pos[4:0]] <= (rx_clk_i ? s_in : data_rx[rx_bit_pos[4:0]]);
endmodule

