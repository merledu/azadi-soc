
module pwm_channel(

input wire clock_1,
input wire clock_2,
input wire rst_ni,
input wire ctrl1,
input wire ctrl2,
input wire pwm_1,
input wire pwm_2,
input wire [15:0] period,
input wire [15:0] period_2,
input wire [15:0] DC_1,
input wire [15:0] DC_2,
output reg oe_pwm1,
output reg oe_pwm2,
output reg pts,
output reg pts_2
);

reg [15:0] period_counter1;
reg [15:0] period_counter2;
	always @(posedge clock_1 or negedge rst_ni)
		if (!rst_ni) begin
			pts <= 1'b0;
			oe_pwm1 <= 1'b0;
			period_counter1 <= 16'b0000000000000000;
		end
		else if (ctrl1) begin
			if (pwm_1) begin
				oe_pwm1 <= 1'b1;
				if (period_counter1 >= period)
					period_counter1 <= 16'b0000000000000000;
				else
					period_counter1 <= period_counter1 + 16'b0000000000000001;
				if (period_counter1 < DC_1)
					pts <= 1'b1;
				else
					pts <= 1'b0;
			end
		end

	always @(posedge clock_2 or negedge rst_ni)
		if (!rst_ni) begin
			pts_2 <= 1'b0;
			oe_pwm2 <= 1'b0;
			period_counter2 <= 16'b0000000000000000;
		end
		else if (ctrl2) begin
			if (pwm_2) begin
				oe_pwm2 <= 1'b1;
				if (period_counter2 >= period_2)
					period_counter2 <= 16'b0000000000000000;
				else
					period_counter2 <= period_counter2 + 16'b0000000000000001;
				if (period_counter2 < DC_2)
					pts_2 <= 1'b1;
				else
					pts_2 <= 1'b0;
			end
		end

endmodule 

