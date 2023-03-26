
module pwm(
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        re_i,
  input  logic        we_i,
  input  logic [7:0]  addr_i,
  input  logic [31:0] wdata_i,
  input  logic [3:0]	be_i,
  output logic [31:0] rdata_o,
  output logic        o_pwm,
  output logic        o_pwm_2,
  output logic        oe_pwm1,
  output logic        oe_pwm2
);

  ///////// local parameters /////////
  parameter int unsigned adr_ctrl 	   =	0;
  parameter int unsigned adr_divisor_1 =	4;
  parameter int unsigned adr_period_1  =	8;
  parameter int unsigned adr_DC_1 		 =	12;
  parameter int unsigned adr_divisor_2 =	20;
  parameter int unsigned adr_period_2  =	24;
  parameter int unsigned adr_DC_2 		 =	28;

  logic [2:0]  ctrl,    ctrl_2;
  logic [15:0] DC_1,    DC_2;
  logic [15:0] period,  period_2;
  logic [15:0] divisor, divisor_2;
  logic        write;

  logic        pwm_1;
  logic        pwm_2;
  logic        clock1;
  logic        clock2;
  logic        pts;
  logic        pts_2;
  logic [15:0] counter_p1;
  logic [15:0] counter_p2;

  assign write = we_i & ~re_i;
  assign pwm_1 = ctrl[1];
  assign pwm_2 = ctrl_2[1];

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      ctrl      <= '0;
      DC_1      <= '0;
      period    <= '0;
      divisor   <= '0;
      ctrl_2    <= '0;
      DC_2      <= '0;
      period_2  <= '0;
      divisor_2 <= '0;
    end
    else if (write) begin
      case (addr_i)
        adr_ctrl:      {ctrl_2, ctrl} <= wdata_i[5:0]; // bits[2:0] for channel0 and bits[5:3] for channel1
        adr_divisor_1: divisor        <= wdata_i[15:0];
        adr_period_1:  period         <= wdata_i[15:0];
        adr_DC_1:      DC_1           <= wdata_i[15:0];
        adr_divisor_2: divisor_2      <= wdata_i[15:0];
        adr_period_2:  period_2       <= wdata_i[15:0];
        adr_DC_2:      DC_2           <= wdata_i[15:0];
      endcase
    end
  end

  always @(posedge clk_i or negedge rst_ni)
    if (~rst_ni) begin
      clock1     <= '0;
      clock2     <= '0;
      counter_p1 <= '0;
      counter_p2 <= '0;
    end
    else begin
    if (pwm_1) begin
      counter_p1 <= counter_p1 + 16'd1;
      if (counter_p1 == (divisor - 1)) begin
        clock1     <= ~clock1;
        counter_p1 <= 16'b0;
      end
    end
    if (pwm_2) begin
      counter_p2 <= counter_p2 + 16'd1;
      if (counter_p2 == (divisor_2 - 1)) begin
        clock2     <= ~clock2;
        counter_p2 <= 16'b0;
      end
    end
  end

  pwm_channel pwm_chnl(
    .clock_1	( clock1    ),
    .clock_2	( clock2    ),
    .rst_ni		( rst_ni    ),
    .ctrl1		( ctrl[0]   ),
    .ctrl2		( ctrl_2[0] ),
    .pwm_1		( pwm_1     ),
    .pwm_2		( pwm_2     ),
    .period		( period    ),
    .period_2	( period_2  ),
    .DC_1			( DC_1      ),
    .DC_2			( DC_2      ),
    .oe_pwm1	( oe_pwm1   ),
    .oe_pwm2	( oe_pwm2   ),
    .pts			( pts       ),
    .pts_2		( pts_2     )
  );

  assign o_pwm   = ctrl[2] ? pts : 1'b0;
  assign o_pwm_2 = ctrl_2[2] ? pts_2 : 1'b0;
  assign rdata_o = addr_i == adr_ctrl      ? {13'h0, ctrl} :
                   addr_i == adr_divisor_1 ? divisor       :
                   addr_i == adr_period_1  ? period        :
                   addr_i == adr_DC_1      ? DC_1          :
                   addr_i == adr_DC_2      ? DC_2          :
                   addr_i == adr_period_2  ? period_2      :
                   addr_i == adr_divisor_2 ? divisor_2     : '0;
endmodule
