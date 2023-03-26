
module uart_to_spi (
  input logic clk_i,
  input logic rst_ni,

  input  logic       rx_i,
  input  logic       lsb_i,
  input  logic       pspi_i,
  output logic       pspi_o,
  output logic       pspi_csb,
  output logic       pspi_clk
);
  
logic div_clk;

always_ff @(posedge clk_i or negedge rst_ni) begin 
  if(!rst_ni) begin
    div_clk <= '0;
  end else begin
    div_clk <= ~div_clk;
  end
end
  logic        star;
  logic        stop;
  logic        valid;
  logic [23:0] addr;
  logic [31:0] data;

  serial2word #(
    .AddrWidth (24),
    .DataWidth (32),
    .ClocksPerBit (217)
  ) u_uart (
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .rx_i     (rx_i),
    .lsb_i    (lsb_i),
    .start    (star),
    .stop     (stop),
    .valid_o  (valid),
    .addr_o   (addr),
    .wdata_o  (data)
  );

  
  t_spi u_si(
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .rdata_i    (data),
    .req_i      (valid),
    .spi_o      (pspi_o),
    .spi_clk    (pspi_clk),
    .spi_cs     (pspi_csb)
  );

endmodule 