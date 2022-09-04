// `include "/home/merl/github_repos/azadi/src/spi_host/rtl/spi_defines.v"
//`include "/home/zeeshan/fyp/azadi/src/spi_host/rtl/spi_defines.v"
//`include "spi_defines.v"
module spi_core
(
  // tlul signals
  input  logic        clk_i,        
  input  logic        rst_ni,        
  input  logic [7:0]  addr_i,            
  input  logic [31:0] wdata_i,              
  output reg   [31:0] rdata_o,             
  input  logic [3:0]  be_i,           
  input  logic        we_i,       
  input  logic        re_i,        
  output reg    error_o,       
  output reg    intr_rx_o,
  output reg    intr_tx_o,         
                                                     
  // SPI signals                                     
  output logic    [`SPI_SS_NB-1:0] ss_o,         // slave select
  output logic                     sclk_o,       // serial clock
  output logic                     sd_o,
  output reg                       sd_oe,       // master out slave in
  input  logic                     sd_i       // master in slave out
);

                                               
  // Internal signals
 reg [15:0] divider;
	reg [15:0] ctrl;
	reg [3:0] ss;
	reg [31:0] wb_dat;
	wire [31:0] rx;
	wire rx_negedge;
	wire tx_negedge;
	wire [4:0] char_len;
	wire go;
	wire lsb;
	wire ie;
	wire ass;
	wire spi_divider_sel;
	wire spi_ctrl_sel;
	wire spi_tx_sel;
	wire spi_ss_sel;
	wire tip;
	wire pos_edge;
	wire neg_edge;
	wire last_bit;
	wire tx_en;
	wire rx_en;
	assign spi_divider_sel = (we_i & ~re_i) & (addr_i[6:0] == 7'h14);
	assign spi_ctrl_sel = (we_i & ~re_i) & (addr_i[6:0] == 7'h10);
	assign spi_tx_sel = ((we_i & ~re_i) & (addr_i[6:0] == 7'h0));
	assign spi_ss_sel = (we_i & ~re_i) & (addr_i[6:0] == 7'h18);
	always @(addr_i or rx or ctrl or divider or ss)
		case (addr_i[6:2])
			8: wb_dat = rx[31:0];
			default: wb_dat = 32'b00000000000000000000000000000000;
		endcase
	always @(posedge clk_i)
		if (~rst_ni)
			rdata_o <= 32'b00000000000000000000000000000000;
		else
			rdata_o <= wb_dat;
	wire [1:1] sv2v_tmp_46A40;
	assign sv2v_tmp_46A40 = 1'b0;
	always @(*) error_o = sv2v_tmp_46A40;
	always @(posedge clk_i)
		if (~rst_ni)
			intr_tx_o <= 1'b0;
		else if ((((ie && tip) && last_bit) && pos_edge) && tx_en)
			intr_tx_o <= 1'b1;
		else
			intr_tx_o <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			intr_rx_o <= 1'b0;
		else if ((((ie && tip) && last_bit) && pos_edge) && rx_en)
			intr_rx_o <= 1'b1;
		else
			intr_rx_o <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			divider <= {16 {1'b0}};
		else if ((spi_divider_sel && we_i) && !tip) begin
			if (be_i[0])
				divider[7:0] <= wdata_i[7:0];
			if (be_i[1])
				divider[15:8] <= wdata_i[15:8];
		end
	always @(posedge clk_i)
		if (~rst_ni)
			ctrl <= {16 {1'b0}};
		else if ((spi_ctrl_sel && we_i) && !tip) begin
			if (be_i[0])
				ctrl[7:0] <= wdata_i[7:0] | {7'b0000000, ctrl[0]};
			if (be_i[1])
				ctrl[15:8] <= wdata_i[15:8];
		end
		else if ((tip && last_bit) && pos_edge)
			ctrl[8] <= 1'b0;
	assign rx_negedge = ctrl[9];
	assign tx_negedge = ctrl[10];
	assign go = ctrl[8];
	assign char_len = ctrl[6:0];
	assign lsb = ctrl[11];
	assign ie = ctrl[12];
	assign ass = ctrl[13];
	assign rx_en = ctrl[15];
	assign tx_en = ctrl[14];
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			sd_oe <= 1'b0;
		else if (tx_en & !rx_en)
			sd_oe <= 1'b1;
		else
			sd_oe <= 1'b0;
	always @(posedge clk_i)
		if (~rst_ni)
			ss <= {4 {1'b0}};
		else if ((spi_ss_sel && we_i) && !tip)
			if (be_i[0])
				ss <= wdata_i[3:0];
	assign ss_o = ~((ss & {4 {tip & ass}}) | (ss & {4 {!ass}}));
	spi_clgen clgen(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.go(go),
		.enable(tip),
		.last_clk(last_bit),
		.divider(divider),
		.clk_out(sclk_o),
		.pos_edge(pos_edge),
		.neg_edge(neg_edge)
	);
	spi_shift shift(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.len(char_len[4:0]),
		.latch(spi_tx_sel & we_i),
		.byte_sel(be_i),
		.lsb(lsb),
		.go(go),
		.pos_edge(pos_edge),
		.neg_edge(neg_edge),
		.rx_negedge(rx_negedge),
		.tx_negedge(tx_negedge),
		.tip(tip),
		.last(last_bit),
		.p_in(wdata_i),
		.p_out(rx),
		.s_clk(sclk_o),
		.s_in(sd_i),
		.s_out(sd_o),
		.rx_en(rx_en)
	);
endmodule
  
