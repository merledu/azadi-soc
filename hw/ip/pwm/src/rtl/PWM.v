/*
control register [7:0]ctrl:
bit 0:	When set, external clock is chosen for PWM/timer. When cleared, wb clock is used for PWM/timer.
bit 1:	When set,  PWM is enabled. When cleared,  timer is enabled.
bit 2:	When set,  PWM/timer starts. When cleared, PWM/timer stops.
bit 3:	When set, timer runs continuously. When cleared, timer runs one time.
bit 4:	When set, o_pwm enabled.
bit 5:	timer interrupt bit	When it is written with 0, interrupt request is cleared. 
bit 6:	When set, a 16-bit external signal i_DC is used as duty cycle. When cleared, register DC is used.
bit 7:	When set, counter reset for PWM/timer, it's output and bit 5 will also be cleared. When changing from PWM mode to timer mode reset is needed before timer starts.
*/
module	PWM(
//tlul interface
	input 					clk_i,												
	input 					rst_ni,												

	input 					re_i,											
	input 					we_i,											
	input  [7:0]    addr_i,											
	input  [31:0]   wdata_i,											
	input  [3:0]		be_i,										
	output [31:0]   rdata_o,												
	output          error_o,												

	input						i_extclk,
	input	 [15:0]		i_DC,
	input						i_valid_DC,
	output					o_pwm,
	output          o_pwm_2

);

////////////////////control logic////////////////////////////
parameter	 adr_ctrl_1			=	0,
					 adr_divisor_1	=	4,
					 adr_period_1		=	8,
					 adr_DC_1				=	12;

parameter  adr_ctrl_2		=	16,
					 adr_divisor_2=	20,
					 adr_period_2	=	24,
					 adr_DC_2			=	28;



					 
reg	[7:0]  ctrl;
reg	[15:0] period;		
reg	[15:0] DC;		
reg	[15:0] divisor;	

reg	[7:0]  ctrl_2;
reg	[15:0] period_2;		
reg	[15:0] DC_2;		
reg	[15:0] divisor_2;	

wire	     write;

assign	   write = we_i & ~re_i;

always@(posedge clk_i)
	if(~rst_ni)begin
		ctrl[4:2]	<=	0;
		ctrl[0]  	<=	0;
		ctrl[7:6]	<=	0;
		DC				<=	0;
		period		<=	0;
		divisor		<=	0;

		
		ctrl_2[4:2]	<=	0;
		ctrl_2[0]  	<=	0;
		ctrl_2[7:6]	<=	0;
		DC_2				<=	0;
		period_2		<=	0;
		divisor_2		<=	0;
	end
	else if(write)begin
		case(addr_i)
			adr_ctrl_1:begin
				ctrl[0]	<=	wdata_i[0];
				ctrl[4:2]	<=	wdata_i[4:2];
				ctrl[7:6]	<=	wdata_i[7:6];
			end

			adr_ctrl_2:begin
				ctrl_2[0]	<=	wdata_i[0];
				ctrl_2[4:2]	<=	wdata_i[4:2];
				ctrl_2[7:6]	<=	wdata_i[7:6];
			end

			adr_divisor_1	:  divisor	<=	wdata_i[15:0];
			adr_period_1	:  period		<=	wdata_i[15:0];
			adr_DC_1			:  DC				<=	wdata_i[15:0];

			adr_divisor_2	:  divisor_2	<=	wdata_i[15:0];
			adr_period_2	:  period_2		<=	wdata_i[15:0];
			adr_DC_2			:  DC_2				<=	wdata_i[15:0];
		endcase
	end



wire		  pwm;
always @(posedge clk_i) begin
  	ctrl[1] <= 1'b1;
end


assign		pwm 	  = ctrl[1];

wire		  pwm_1;
always @(posedge clk_i) begin
    ctrl_2[1]   <= 1'b1;
end

assign		pwm_1 	  = ctrl_2[1];
wire	    eclk_2,oclk_2;
///////////////////////////////////////////////////////////

//////down clocking for pwm///////////////////
wire	  clk_source;
wire	  eclk,oclk;
assign	clk_source = clk_i;
down_clocking_even	clock_div_ev(
	.i_clk			(clk_source) ,
	.i_rst			(rst_ni),
	.i_divisor	({1'b0,divisor[15:1]}),
	.o_clk			(eclk)
);
down_clocking_odd	clock_div_od(
	.i_clk			(clk_source),
	.i_rst			(rst_ni),
	.i_divisor	({1'b0,divisor[15:1]}),
	.o_clk			(oclk)
);
wire	  clk;
assign	clk = divisor[0]? oclk: eclk;




down_clocking_even	clock_div_ev_2(
	.i_clk			(clk_source) ,
	.i_rst			(rst_ni),
	.i_divisor	({1'b0,divisor_2[15:1]}),
	.o_clk			(eclk_2)
);
down_clocking_odd	clock_div_od_2(
	.i_clk			(clk_source),
	.i_rst			(rst_ni),
	.i_divisor	({1'b0,divisor_2[15:1]}),
	.o_clk			(oclk_2)
);
wire	  clk_2;
assign	clk_2 = divisor_2[0]? oclk_2: eclk_2;

///////////////////////////////////////////////////////

/////////////////main counter //////////////////////////
reg		[15:0]   		ct;
reg								pts;	//PWM signal 
reg		[15:0]			extDC;
wire	[15:0]			DC_1;
assign						DC_1 =	ctrl[6]?	extDC:	DC;	//external or internal duty cycle toggle
wire	[15:0]			period_1;
assign						period_1	=	(period==0)?	0:	(period-1);

wire							rst_ct;
assign						rst_ct	=	~rst_ni|ctrl[7];


reg		[15:0]   		ct_2;
reg								pts_2;	//PWM signal 
reg		[15:0]			extDC_2;
wire	[15:0]			DCw_2;
assign						DCw_2 =	ctrl_2[6]?	extDC_2:	DC_2;	//external or internal duty cycle toggle
wire	[15:0]			period_P2;
assign						period_P2	=	(period_2==0)?	0:	(period_2-1);

wire							rst_ct_2;
assign						rst_ct_2	=	~rst_ni|ctrl_2[7];

always@(posedge clk )
	if(rst_ct)begin
		pts<=0;
		ct<=0;
		extDC<=0;
	end
	else begin
	if(i_valid_DC)	extDC	<=	i_DC;
	if(ctrl[2])begin
		if(pwm) begin
			if(ct	>=	period_1) ct	<=	0;
			else ct	<=	ct+1;

			if(ct	<	DC_1)	pts	<=	1;
			else pts	<=	0;
		end
	end
	else begin
			pts	<=	0;
			ct	<=	0;
	end
end



always@(posedge clk_2 )
	if(rst_ct_2)begin
		pts_2		<=	0;
		ct_2	<=	0;
		extDC_2	<=	0;
	end
	else begin
	if(i_valid_DC)	extDC_2	<=	i_DC;
	if(ctrl_2[2])begin
		if(pwm_1) begin
			if(ct_2	>=	period_P2) ct_2	<=	0;
			else ct_2	<=	ct_2+1;

			if(ct_2	<	DCw_2)	pts_2	<=	1;
			else pts_2	<=	0;
		end
	end
	else begin
			pts_2	<=	0;
			ct_2	<=	0;
	end
end
//////////////////////////////////////////////////////////

assign	o_pwm = ctrl[4]? pts: 0;
assign	o_pwm_2 = ctrl_2[4]? pts_2: 0;
assign	rdata_o =	 (addr_i == adr_ctrl_1)		? {8'h0,ctrl}		:
			  					 (addr_i == adr_divisor_1)? divisor		 		:
			  					 (addr_i == adr_period_1)	? period		 		:
			  					 (addr_i == adr_DC_1)			? DC				 		: 
									 (addr_i == adr_DC_2)			? DC_2			 		:
									 (addr_i == adr_period_2) ? period_2	 		:
									 (addr_i == adr_divisor_2)? divisor_2  		:
									 (addr_i == adr_ctrl_2)   ? {8'h0,ctrl_2} :0;


endmodule