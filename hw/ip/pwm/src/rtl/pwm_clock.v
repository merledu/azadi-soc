
module pwm_clock(
input wire clk_i,
input wire rst_ni,
input wire pwm_1,
input wire pwm_2,
input wire [15:0] divisor,
input wire [15:0] divisor_2,
output reg clock_p1,
output reg clock_p2
);
 reg [15:0] counter_p1;
 reg [15:0] counter_p2;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			clock_p1 <= 1'b0;
			clock_p2 <= 1'b0;
			counter_p1 <= 16'b0000000000000000;
			counter_p2 <= 16'b0000000000000000;
		end
		else begin
			if (pwm_1) begin
				counter_p1 <= counter_p1 + 16'b0000000000000001;
				if (counter_p1 == (divisor - 1)) begin
					counter_p1 <= 16'b0000000000000000;
					clock_p1 <= ~clock_p1;
				end
			end
			if (pwm_2) begin
				counter_p2 <= counter_p2 + 16'b0000000000000001;
				if (counter_p2 == (divisor_2 - 1)) begin
					counter_p2 <= 16'b0000000000000000;
					clock_p2 <= ~clock_p2;
				end
			end
		end
endmodule 
