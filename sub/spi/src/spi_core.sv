module spi_core (
  // tlul signals
  input  logic        clk_i,        
  input  logic        rst_ni,        
  input  logic [7:0]  addr_i,            
  input  logic [31:0] wdata_i,              
  output reg   [31:0] rdata_o,             
  input  logic [3:0]  be_i,           
  input  logic        we_i,       
  input  logic        re_i,        
  output reg    			error_o,       
  output reg    			intr_rx_o,
  output reg    			intr_tx_o,         
                                                     
  // SPI signals                                     
  output logic     		ss_o,      // slave select
  output logic        sclk_o,    // serial clock
  output logic        sd_o,
  output reg          sd_oe,     // master out slave in
  input  logic        sd_i       // master in slave out
);

	assign error_o   = '0;

	localparam ADDR_CFG  = 'h0;
	localparam ADDR_PS   = 'h4;
	localparam ADDR_TXL	 = 'h8;
	localparam ADDR_TXU	 = 'hc;
	localparam ADDR_RXL  = 'h10;
	localparam ADDR_RXU  = 'h14;
	localparam ADDR_CTRL = 'h18;

	logic [20:0] configuration;
	logic [16:0] prescale;
	logic [63:0] tx_reg;
	logic [63:0] rx_reg;
	logic 			 control;
	logic [7:0]  num_tx_bits;
	logic [7:0]  num_rx_bits;
	logic 			 cpol;
	logic 			 cpha;
	logic 			 tx_en;
	logic 			 tlsb;
	logic				 rlsb;
	logic				 go_busy;
	logic				 ps_en;
	logic				 clock_en;

	// write logic 
	always_ff @(posedge clk_i or negedge rst_ni) begin
		if(!rst_ni) begin
			configuration <= 17'h0c000;
			prescale			<= '0;
			tx_reg        <= '0;
			control			  <= '0; 
		end else begin
			if(we_i) begin
				case (addr_i)
					ADDR_CFG:  configuration <= wdata_i[20:0];
					ADDR_PS:   prescale			 <= wdata_i[16:0];
					ADDR_TXL:	 tx_reg[31:0]	 <= wdata_i;
					ADDR_TXU:  tx_reg[63:32] <= wdata_i;
					ADDR_CTRL: control 			 <= wdata_i[0];
				endcase
			end else begin
				if (intr_tx_o || intr_rx_o) begin
					control	<= '0;
				end
			end
		end
	end

	always_comb begin
		// configuration register fields
		num_tx_bits = configuration[7:0];
		num_rx_bits = configuration[15:8];
		cpol				= configuration[16];
		cpha				= configuration[17];
		tx_en				= configuration[18];
		tlsb 				= configuration[19];
		rlsb				= configuration[20];
		// control bit
		go_busy			= control;
		// clock division enable;
		ps_en				= prescale[0];
	end

	// read data logic
	always_comb begin
		rdata_o	= '0;
		if (re_i) begin
			if(addr_i == ADDR_RXL) begin
				rdata_o	= rx_reg[31:0];
			end else if (addr_i == ADDR_RXU) begin
				rdata_o	= rx_reg[63:32];
			end else begin
				rdata_o	= '0;
			end
		end
	end

	spi_clgen u_clkdiv(
  	.clk_i			(clk_i),
  	.rst_ni			(rst_ni),
  	.enable_i		(ps_en),
  	.prescale_i	(prescale[16:1]),
  	.clken_o		(clock_en)
	);

	spi_shift u_shift(
	  .clk_i			(clk_i),
		.rst_ni			(rst_ni),
		.txd_i			(tx_reg),
		.tx_bits_i	(num_tx_bits),
		.rx_bits_i	(num_rx_bits),
		.enable_i		(go_busy),
		.clk_en_i		(clock_en),
		.cpol_i			(cpol),
		.cpha_i			(cpha),
		.tx_i				(tx_en),
		.tlsb_i			(tlsb),
		.rlsb_i			(rlsb),
		.rxd_o			(rx_reg),
		.sclk_o			(sclk_o),
		.csb_o			(ss_o),
		.sdo_o			(sd_o),
		.sdo_oeb		(sd_oe),
		.sdi_i			(sd_i),
		.intr_tdo   (intr_tx_o),
		.intr_tdi   (intr_rx_o)
	);

endmodule
