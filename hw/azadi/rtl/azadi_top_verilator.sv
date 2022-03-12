 
module azadi_top_verilator (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic [19:0] gpio_i,
  output logic [19:0] gpio_o,

  input  logic        uart_rx,
  output logic        uart_tx,
  
  input logic         uart_rx_i
);

  logic pwm_o;
  logic pwm_o_2;

  logic [`SPI_SS_NB-1:0] ss_o;
  logic                  sclk_o;
  logic                  sd_o;
  logic                  sd_i;

  /* The frequency of the output clk_out = The frequency of the input clk_in divided by DIVISOR
  For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
  You will modify the DIVISOR parameter value to 28'd50.000.000
  Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz */
  // logic clk_i; 
  // reg[27:0] counter=28'd0;
  // parameter DIVISOR = 28'd6000;
  // always @(posedge clk_i) begin
  //   counter <= counter + 28'd1;
  //   if(counter >= (DIVISOR-1)) counter <= 28'd0;
  //   clk_i <= (counter < DIVISOR/2) ? 1'b1 : 1'b0;
  // end

  //localparam logic [31:0] JTAG_IDCODE = 32'h04F5484D;
  localparam logic [31:0] JTAG_IDCODE = {
    4'h0,     // Version
    16'h4F54, // Part Number: "OT"
    11'h426,  // Manufacturer Identity: Google
    1'b1      // (fixed)
  };

  logic cio_jtag_tck;
  logic cio_jtag_tdi;
  logic cio_jtag_tdo;
  logic cio_jtag_tms;
  logic cio_jtag_trst_n;
  logic cio_jtag_srst_n;
  logic i2c0_scl_in;
  logic i2c0_scl_out;
  logic i2c0_sda_in;
  logic i2c0_sda_out;

  azadi_soc_top soc_top_verilator(
    .clk_i   ( clk_i     ),
    .rst_ni  ( rst_ni    ),  
    .gpio_i  ( gpio_i    ),
    .gpio_o  ( gpio_o    ),
    .uart_tx ( uart_tx   ),
    .uart_rx ( uart_rx   ),

    .prog    ( uart_rx_i ),

    .pwm_o   ( pwm_o     ),
    .pwm_o_2 ( pwm_o_2   ),
    .pwm1_oe (           ),
    .pwm2_oe (           ),

    // spi interface 
    .ss_o    ( ss_o      ),         
    .sclk_o  ( sclk_o    ),       
    .sd_o    ( sd_o      ),       
    .sd_i    ( sd_i      )
  );

  // jtagdpi u_jtagdpi (
  //   .clk_i(clk_i),
  //   .rst_ni(rst_ni),
  //   .jtag_tck    (cio_jtag_tck),
  //   .jtag_tms    (cio_jtag_tms),
  //   .jtag_tdi    (cio_jtag_tdi),
  //   .jtag_tdo    (cio_jtag_tdo),
  //   .jtag_trst_n (cio_jtag_trst_n),
  //   .jtag_srst_n (cio_jtag_srst_n)
  // );

endmodule