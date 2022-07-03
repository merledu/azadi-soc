// Top module for verilator simulation

module azadi_top_verilator (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        prog_btn
);

  import prog_image_loader_pkg::*;

  string HEX;// = "/home/merl-lab/GSoC/verif/tests/basic_test/test.hex";
  int CLKS_PER_BIT, CLK_FREQ, BAUD_RATE;
  bit [7:0] prog_image [int];
  bit [7:0] w_byte;
  bit       tx_done;
  bit       tx_en;
  int       index;

  logic pwm_o;
  logic pwm_o_2;

  logic [19:0] gpio_i;
  logic [19:0] gpio_o;

  logic        uart_recv;
  logic        uart_trans;

  logic [`SPI_SS_NB-1:0] ss_o;
  logic                  sclk_o;
  logic                  sd_o;
  logic                  sd_i;

  //localparam logic [31:0] JTAG_IDCODE = 32'h04F5484D;
  localparam logic [31:0] JTAG_IDCODE = {
    4'h0,     // Version
    16'h4F54, // Part Number: "OT"
    11'h426,  // Manufacturer Identity: Google
    1'b1      // (fixed)
  };

  azadi_soc_top soc_top_verilator(
    .clk_i        ( clk_i        ),
    .rst_ni       ( rst_ni       ),
    .clks_per_bit ( CLKS_PER_BIT ),
    .gpio_i       ( gpio_i       ),
    .gpio_o       ( gpio_o       ),
    .gpio_oe      (              ),
    .uart_tx      ( uart_trans   ),
    .uart_rx      ( uart_recv    ),
    .prog_i       ( prog_btn     ),

    .pwm_o        ( pwm_o        ),
    .pwm_o_2      ( pwm_o_2      ),
    .pwm1_oe      (              ),
    .pwm2_oe      (              ),

    // spi interface
    .ss_o         ( ss_o         ),
    .sclk_o       ( sclk_o       ),
    .sd_o         ( sd_o         ),
    .sd_oe        (              ),
    .sd_i         ( sd_i         )
  );

  uart_tx programmer_TX (
    .clk_i        ( clk_i        ),
    .rst_ni       ( rst_ni       ),
    .tx_en        ( tx_en        ),
    .i_TX_Byte    ( w_byte       ),
    .CLKS_PER_BIT ( CLKS_PER_BIT ),
    .o_TX_Serial  ( uart_recv    ),
    .o_TX_Done    ( tx_done      )
  );

  initial begin
    CLK_FREQ = 25000000;
    BAUD_RATE = 115200;
    CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    if ($value$plusargs("HEX=%s",HEX))
      $display("Reading hex: %s", HEX);
    read_hex(HEX, prog_image);
  end

  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      w_byte <= '0;
      tx_en  <= '0;
      index  <=  0;
    end 
    else if (prog_btn || tx_done) begin
      tx_en <= 1;
      w_byte <= prog_image[index];
      index  <= index + 1;
      // $display("prog_image[%x] = 0x%x",index, prog_image[index]);
    end else
      tx_en  <= 0;
  end

endmodule
