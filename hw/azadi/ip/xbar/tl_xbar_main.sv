
// main XBAR 

module tl_xbar_main (

  input logic clk_i,
  input logic rst_ni,


  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_brqif_i,
  output tlul_pkg::tl_d2h_t tl_brqif_o,
  input  tlul_pkg::tl_h2d_t tl_brqlsu_i,
  output tlul_pkg::tl_d2h_t tl_brqlsu_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_iccm_o,
  input  tlul_pkg::tl_d2h_t tl_iccm_i,
  output tlul_pkg::tl_h2d_t tl_dccm_o,
  input  tlul_pkg::tl_d2h_t tl_dccm_i,
  output tlul_pkg::tl_h2d_t tl_timer0_o,
  input  tlul_pkg::tl_d2h_t tl_timer0_i,
  output tlul_pkg::tl_h2d_t tl_uart_o,
  input  tlul_pkg::tl_d2h_t tl_uart_i,
  output tlul_pkg::tl_h2d_t tl_spi_o,
  input  tlul_pkg::tl_d2h_t tl_spi_i,
  output tlul_pkg::tl_h2d_t tl_pwm_o,
  input  tlul_pkg::tl_d2h_t tl_pwm_i,
  output tlul_pkg::tl_h2d_t tl_gpio_o,
  input  tlul_pkg::tl_d2h_t tl_gpio_i,
  output tlul_pkg::tl_h2d_t tl_plic_o,
  input  tlul_pkg::tl_d2h_t tl_plic_i


);

  import tlul_pkg::*;
  import tl_main_pkg::*;


// host LSU
  tlul_pkg::tl_h2d_t brqlsu_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_brqlsu;
  logic [2:0] device_sel;

  tlul_pkg::tl_h2d_t  h_dv_o[7];
  tlul_pkg::tl_d2h_t  h_dv_i[7];

  assign brqlsu_to_s1n = tl_brqlsu_i;
  assign tl_brqlsu_o   = s1n_to_brqlsu;
// Dveice connections

  assign tl_iccm_o  = tl_brqif_i;
  assign tl_brqif_o = tl_iccm_i;

  assign tl_dccm_o = h_dv_o[0];
  assign h_dv_i[0] = tl_dccm_i;

  assign tl_timer0_o = h_dv_o[1];
  assign h_dv_i[1]   = tl_timer0_i;

  assign tl_uart_o   = h_dv_o[2];
  assign h_dv_i[2]   = tl_uart_i;

  assign tl_spi_o    = h_dv_o[3];
  assign h_dv_i[3]   = tl_spi_i;

  assign tl_pwm_o    = h_dv_o[4];
  assign h_dv_i[4]   = tl_pwm_i;

  assign tl_gpio_o   = h_dv_o[5];
  assign h_dv_i[5]   = tl_gpio_i;

  assign tl_plic_o   = h_dv_o[6];
  assign h_dv_i[6]   = tl_plic_i; 



// host  socket
  always_comb begin 
    
     device_sel = 3'd7;

    if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
     device_sel = 3'd0; 
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER0))    == ADDR_SPACE_TIMER0) begin
      device_sel = 3'd1;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_UART0))     == ADDR_SPACE_UART0) begin
      device_sel = 3'd2;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_SPI0))      == ADDR_SPACE_SPI0) begin
      device_sel = 3'd3;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_PWM))       == ADDR_SPACE_PWM) begin
      device_sel = 3'd4;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_GPIO))      == ADDR_SPACE_GPIO) begin
      device_sel = 3'd5;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_PLIC))      == ADDR_SPACE_PLIC) begin
      device_sel = 3'd6;
    end 
  end

// host 2 socket

  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (7)
  ) host_lsu (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .tl_h_i       (brqlsu_to_s1n),
    .tl_h_o       (s1n_to_brqlsu),
    .tl_d_o       (h_dv_o),
    .tl_d_i       (h_dv_i),
    .dev_select_i (device_sel)
  );



endmodule
