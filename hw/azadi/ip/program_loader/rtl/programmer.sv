
module programmer
(

  input logic clk_i,
  input logic rst_ni,

  input logic        prog_i,
  input logic        rx_i,
  input logic [15:0] clks_per_bit, 

  output logic 	      we_o,
  output logic [11:0] addr_o,
  output logic [31:0] wdata_o,
  output logic 	      reset_o
);

  logic       rx_dv;
  logic [7:0] rx_byte;

iccm_controller u_iccm_ctrl(
 .clk_i		(clk_i),
 .rst_ni	(rst_ni),
 .prog_i	(prog_i),
 .rx_dv_i	(rx_dv),
 .rx_byte_i	(rx_byte),
 .we_o		(we_o),
 .addr_o	(addr_o),
 .wdata_o	(wdata_o),
 .reset_o	(reset_o)
);


uart_rx_prog u_prog_uart(
  .clk_i	(clk_i),
  .rst_ni	(rst_ni),
  .i_Rx_Serial	(rx_i),
  .CLKS_PER_BIT	(clks_per_bit),
  .o_Rx_DV	(rx_dv),
  .o_Rx_Byte	(rx_byte)
);


endmodule
