
module	pwm_core(
//tlul interface
input wire clk_i,												
input wire rst_ni,												
input wire re_i,											
input wire we_i,											
input wire  [7:0]    addr_i,											
input wire [31:0]   wdata_i,											
input wire [3:0]	be_i,										
output wire [31:0]rdata_o, 																						output wire         o_pwm,
output wire         o_pwm_2,
output  wire     oe_pwm1,
output  wire     oe_pwm2

);

////////////////////control logic////////////////////////////
parameter  adr_ctrl_1	=	0,
		   adr_divisor_1=	4,
		   adr_period_1	=	8,
		   adr_DC_1		=	12;

parameter  adr_ctrl_2	=	16,
		   adr_divisor_2=	20,
		   adr_period_2	=	24,
		   adr_DC_2		=	28;



	reg [2:0] ctrl;
	reg [15:0] period;
	reg [15:0] DC_1;
	reg [15:0] divisor;
	reg [2:0] ctrl_2;
	reg [15:0] period_2;
	reg [15:0] DC_2;
	reg [15:0] divisor_2;
	wire write;
	assign write = we_i & ~re_i;
	always @(posedge clk_i) begin
		if (!rst_ni) begin
			ctrl <= 3'b000;
			DC_1 <= 16'b0000000000000000;
			period <= 16'b0000000000000000;
			divisor <= 16'b0000000000000000;
			ctrl_2 <= 3'b000;
			DC_2 <= 16'b0000000000000000;
			period_2 <= 16'b0000000000000000;
			divisor_2 <= 16'b0000000000000000;
		end
		else if (write) begin
			case (addr_i)
				adr_ctrl_1: ctrl <= wdata_i[2:0];
				adr_ctrl_2: ctrl_2 <= wdata_i[2:0];
				adr_divisor_1: divisor <= wdata_i[15:0];
				adr_period_1: period <= wdata_i[15:0];
				adr_DC_1: DC_1 <= wdata_i[15:0];
				adr_divisor_2: divisor_2 <= wdata_i[15:0];
				adr_period_2: period_2 <= wdata_i[15:0];
				adr_DC_2: DC_2 <= wdata_i[15:0];
			endcase
		end
	end
	wire pwm_1;
	assign pwm_1 = ctrl[1];
	wire pwm_2;
	assign pwm_2 = ctrl_2[1];
	wire clock1;
	wire clock2;
	wire pts;
	wire pts_2;
pwm_clock pwm_clk(
.clk_i 	    (clk_i),
.rst_ni	    (rst_ni),
.pwm_1	    (pwm_1),
.pwm_2	    (pwm_2),
.divisor    (divisor),
.divisor_2  (divisor_2),
.clock_p1   (clock1),
.clock_p2   (clock2)
);

pwm_channel pwm_chnl(

.clock_1	(clock1),
.clock_2	(clock2),
.rst_ni		(rst_ni),
.ctrl1		(ctrl[0]),
.ctrl2		(ctrl_2[0]),
.pwm_1		(pwm_1),
.pwm_2		(pwm_2),
.period		(period),
.period_2	(period_2),
.DC_1		(DC_1),
.DC_2		(DC_2),
.oe_pwm1	(oe_pwm1),
.oe_pwm2	(oe_pwm2),
.pts		(pts),
.pts_2		(pts_2)
);

	assign o_pwm = (ctrl[2] ? pts : 1'b0);
	assign o_pwm_2 = (ctrl_2[2] ? pts_2 : 1'b0);
	assign rdata_o = (addr_i == adr_ctrl_1 ? {13'h0, ctrl} : (addr_i == adr_divisor_1 ? divisor : (addr_i == adr_period_1 ? period : (addr_i == adr_DC_1 ? DC_1 : (addr_i == adr_DC_2 ? DC_2 : (addr_i == adr_period_2 ? period_2 : (addr_i == adr_divisor_2 ? divisor_2 : (addr_i == adr_ctrl_2 ? {13'h0, ctrl_2} : 32'b00000000000000000000000000000000))))))));
endmodule

