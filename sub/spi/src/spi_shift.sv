module spi_shift (
  input logic clk_i,
	input logic rst_ni,

	input  logic [63:0] txd_i,
	input  logic [7:0]	tx_bits_i,
	input  logic [7:0]	rx_bits_i,
	input  logic 			  enable_i,
	input  logic 			  clk_en_i,
	input  logic 			  cpol_i,
	input  logic 			  cpha_i,
	input  logic 			  tx_i,
	input  logic 			  tlsb_i,
	input  logic				rlsb_i,
	output logic [63:0] rxd_o,

	output logic sclk_o,
	output logic csb_o,
	output logic sdo_o,
	output logic sdo_oeb,
	input  logic sdi_i,

	output logic intr_tdo,
	output logic intr_tdi
);

	typedef enum logic [1:0] {IDLE, TRANSMIT, TOGGLE, RECIEVE} state_t;

	state_t 		 next_state;
	logic [63:0] t_shift_reg;
	logic [63:0] r_shift_reg;
	logic [7:0]	 cycle_count;
	logic 			 sck;
	logic 			 csb;
	logic        sdo;
	logic				 cpol;
	logic				 cpha; 
	logic 			 pha_reg;

	always_comb begin
		sclk_o = sck;
		csb_o  = csb;
		if(tlsb_i) begin
			sdo_o = t_shift_reg[0];
		end else begin
			sdo_o = t_shift_reg[63];
		end
	end

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if(!rst_ni) begin
			next_state  <= IDLE;
			t_shift_reg <= '0;
			r_shift_reg <= '0;
			cycle_count <= 8'b0;
			sck					<= 1'b1;
			csb					<= 1'b1;
			pha_reg			<= '0;
			rxd_o				<= '0;
			intr_tdo    <= '0;
			intr_tdi    <= '0;
			sdo_oeb			<= 1'b1;
		end else begin
			if(clk_en_i) begin
				case (next_state)
					IDLE: begin
						if(enable_i) begin
							t_shift_reg <= txd_i;
							csb 				<= 1'b0;
							sck					<= cpol_i;
							sdo_oeb			<= 1'b0;
							next_state  <= TRANSMIT;
						end else begin
							t_shift_reg <= '0;
							csb 				<= 1'b1;
							intr_tdo    <= 1'b0;
							intr_tdi    <= '0;
							sck					<= cpol_i;
							sdo_oeb			<= 1'b1;
							next_state  <= IDLE;
						end
					end
					TRANSMIT: begin
						if(cpha_i) begin
							if(tx_i) begin
								if(cycle_count < tx_bits_i) begin
									sck 				<= ~sck;
								end
							end else begin
								if(cycle_count < (tx_bits_i + rx_bits_i)) begin
									sck 				<= ~sck;
								end
							end
						end else begin
							sck 				<= cpol_i;
						end
						cycle_count <= cycle_count + 1;
						if (cycle_count <= tx_bits_i) begin
							if (cycle_count > 0) begin
								if (tlsb_i) begin
										pha_reg     <= t_shift_reg[0];
										t_shift_reg <= {1'b0, t_shift_reg[63:1]};
								end else begin
										pha_reg     <= t_shift_reg[63];
										t_shift_reg <= {t_shift_reg[62:0], 1'b0};
								end
							end
						end else begin
							t_shift_reg <= '0;
						end
						next_state  <= TOGGLE;
					end
					TOGGLE: begin
						if(cpha_i) begin
							sck 				<= cpol_i;
						end else begin
							if(tx_i) begin
								if(cycle_count <= tx_bits_i) begin
									sck 				<= ~sck;
								end
							end else begin
								if(cycle_count <= (tx_bits_i + rx_bits_i)) begin
									sck 				<= ~sck;
								end
							end
						end
						if(tx_i) begin
							if(cycle_count <= tx_bits_i) begin
								next_state <= TRANSMIT;
							end else begin
								next_state  <= IDLE;
								csb 				<= 1'b1;
								cycle_count <= 8'b0;
								intr_tdo		<= 1'b1;
							end
						end else begin			
							if(cycle_count > tx_bits_i) begin
								if(rlsb_i) begin
									r_shift_reg <= {r_shift_reg[62:0], sdi_i};
								end else begin
									r_shift_reg <= {sdi_i, r_shift_reg[63:1]};
								end
							end 
							if (cycle_count != (rx_bits_i + tx_bits_i)) begin
								next_state <= TRANSMIT;
							end else begin
								next_state  <= RECIEVE;
								cycle_count <= '0;
							end
						end
					end
					RECIEVE: begin
						sck        <= cpol_i;
						csb        <= 1'b1;
						rxd_o      <= r_shift_reg;
						intr_tdi   <= 1'b1;
						next_state <= IDLE;
					end
				endcase
			end
		end
	end
endmodule
