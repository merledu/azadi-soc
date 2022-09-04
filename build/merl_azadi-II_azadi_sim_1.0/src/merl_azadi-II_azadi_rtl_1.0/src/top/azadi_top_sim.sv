// Top module for simulation

`define SIM
`define ARM_UD_MODEL
`define TEST_ROM
module azadi_top_sim
  import prog_image_loader_pkg::*;
(
`ifdef VERILATOR
  input logic clk_i,
  input logic rst_ni,
  input logic por_ni,
  input logic pll_lock,
  input logic boot_sel
`endif
);
  //////////////////////
  // Local Signals
  //////////////////////
  string     HEX;
  string     ROM_BIN;
  integer    fd;
  bit [7:0]  prog_image [int];
  bit [7:0]  w_byte;
  bit        tx_done;
  bit        tx_en;
  int        index;
  bit [3:0]  qspi_i;
  bit [3:0]  qspi_o;
  bit [3:0]  qspi_oe;
  bit        qspi_clk;
  bit        qspi_csb;
  bit [31:0] vcc;
  wire [3:0] q_io;
  logic      clk_enb;

  // programing interface
  logic sck_tb;
  logic sdi_tb;
  logic csb_tb;
  logic sdo_tb;
  logic tx_ready;

  // fetching internal register values
  // to automate test checking
  logic [4:0]  wreg_addr;
  logic [31:0] wreg_data;
  logic        wreg_wen;

`ifndef VERILATOR
  logic clk_i;
  logic rst_ni;
  logic por_ni;
  logic pll_lock;
  logic boot_sel;

  initial begin
    clk_i    = 0;
    rst_ni   = 1;
    por_ni   = 1;
    pll_lock = 0;
    boot_sel = 0;
    csb_tb   = 1;
    #100ns;

    por_ni = 0;
    #100ns;
    por_ni = 1;
    #200ns;
    rst_ni   = 0;
    pll_lock = 1;

    `ifdef QSPI
      boot_sel = 1;
      vcc      = 32'd3000;
      #150e0ns; // qspi flash power-up delay
      #100ns rst_ni = 1;
    `else
      #100ns rst_ni = 1;
      wait(clk_enb)
      csb_tb = 0;
      // sdo_tb tells that the code is successfully loaded
      wait (sdo_tb) begin
        csb_tb = 1;
        #5000ns $finish;
      end
    `endif
  end

  always #20 clk_i = ~clk_i;
`endif

  initial begin
    // Initializing ROM
    if ($value$plusargs("ROM_BIN=%s", ROM_BIN))
      $display("Reading ROM bin: %s", ROM_BIN);
    $readmemb(ROM_BIN, u_azadi_soc_top.u_rom_top.u_rom.mem);

    // Feeding hex file to ICCM/QSPI loader
    if ($value$plusargs("HEX=%s", HEX))
      $display("Reading hex: %s", HEX);
    read_hex(HEX, prog_image);
  end

  // writing result value in file for comparison
  initial fd = $fopen("expected.result", "w");
  final $fclose(fd);

  always @ (posedge clk_i) begin
    wreg_addr <= u_azadi_soc_top.u_ibex_core_top.u_ibex_core.gen_regfile_ff.register_file_i.waddr_a_i;
    wreg_data <= u_azadi_soc_top.u_ibex_core_top.u_ibex_core.gen_regfile_ff.register_file_i.rf_reg[31];
    wreg_wen  <= u_azadi_soc_top.u_ibex_core_top.u_ibex_core.gen_regfile_ff.register_file_i.we_a_i;

    if (wreg_wen && (wreg_addr == 5'h1F)) begin
      $display("Writing Final Value of reg 'x31' to expected.result file to compare!");
      $display("Reg[31] is equals to 0x%8x", wreg_data);
      $fstrobeh(fd, wreg_data);
    end
  end

  // gpio interface
  logic [31:0] gpio_in;
  logic [31:0] gpio_out;
  logic [31:0] gpio_oe;

  // uart-periph interface
  logic [3:0] uart_tx;
  logic [3:0] uart_rx;
  logic [3:0] uart_oe;

  // SPI interface
  logic [3:0] ss_o;
  logic [3:0] sclk_o;
  logic [3:0] sd_o;
  logic [3:0] sd_oe;
  logic [3:0] sd_i;

  // PWM interface
  logic [3:0] pwm1_o;
  logic [3:0] pwm2_o;
  logic [3:0] pwm1_oe;
  logic [3:0] pwm2_oe;

  // SoC top instantiation
  azadi_soc_top u_azadi_soc_top (
    .clk_main_i ( clk_i    ),
    .rst_ni     ( rst_ni   ),
    .por_ni     ( por_ni   ),
    .pll_lock_i ( pll_lock ),
    .boot_sel_i ( boot_sel ),
    .led_alive_o( ),

    // SPI slave to write ICCM
    .hk_sck_i   ( sck_tb   ),
    .hk_sdi_i   ( sdi_tb   ),
    .hk_csb_i   ( csb_tb   ),
    .hk_sdo_o   ( sdo_tb   ),

    // gpio interface
    .gpio_in_i  ( gpio_in  ),
    .gpio_out_o ( gpio_out ),
    .gpio_oe_o  ( gpio_oe  ),

    // uart interface
    .uart_tx_o  ( uart_tx  ),
    .uart_rx_i  ( uart_rx  ),
    .uart_oe_o  ( uart_oe  ),

    // spi interface
    .ss_o       ( ss_o     ),
    .sclk_o     ( sclk_o   ),
    .sd_o       ( sd_o     ),
    .sd_oe_o    ( sd_oe    ),
    .sd_i       ( sd_i     ),

    // pwm interface
    .pwm1_o     ( pwm1_o   ),
    .pwm2_o     ( pwm2_o   ),
    .pwm1_oe_o  ( pwm1_oe  ),
    .pwm2_oe_o  ( pwm2_oe  ),

    // QSPI interface
    .qspi_sdi_i ( qspi_i   ),
    .qspi_oe_o  ( qspi_o   ),
    .qspi_sdo_o ( qspi_oe  ),
    .qspi_clk_o ( qspi_csb ),
    .qspi_csb_o ( qspi_clk )
    `ifdef SIM
    ,.clk_enb_o ( clk_enb  )
    `endif
  );

  // SPI Master to host SoC
  SPI_Master #(
    .SPI_MODE (1),
    .CLKS_PER_HALF_BIT (2)
  ) u_SPI_Master (
    // Control/Data Signals,
    .i_Rst_L    ( rst_ni   ),
    .i_Clk      ( clk_i    ),
    // TX (MOSI) Signals
    .i_TX_Byte  ( w_byte   ),
    .i_TX_DV    ( tx_en    ),
    .o_TX_Ready ( tx_ready ),
    // RX (MISO) Signals
    .o_RX_DV    (          ),
    .o_RX_Byte  (          ),
    // SPI Interface
    .o_SPI_Clk  ( sck_tb   ),
    .i_SPI_MISO ( '0       ),
    .o_SPI_MOSI ( sdi_tb   )
  );

  // Flash behavioural model for simulation only
  // N25Qxxx u_flash (
  //   .S        ( qspi_csb ),
  //   .C_       ( qspi_clk ),
  //   .HOLD_DQ3 ( q_io[3]  ),
  //   .DQ0      ( q_io[0]  ),
  //   .DQ1      ( q_io[1]  ),
  //   .Vcc      ( vcc      ),
  //   .Vpp_W_DQ2( q_io[2]  )
  // );

  // IOBUF Q0(.io_in(qspi_o[0]), .io_out(qspi_i[0]), .io_oeb(~qspi_oe[0]), .io(q_io[0]));
  // IOBUF Q1(.io_in(qspi_o[1]), .io_out(qspi_i[1]), .io_oeb(~qspi_oe[1]), .io(q_io[1]));
  // IOBUF Q2(.io_in(qspi_o[2]), .io_out(qspi_i[2]), .io_oeb(~qspi_oe[2]), .io(q_io[2]));
  // IOBUF Q3(.io_in(qspi_o[3]), .io_out(qspi_i[3]), .io_oeb(~qspi_oe[3]), .io(q_io[3]));

  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      w_byte <= '0;
      tx_en  <= '0;
      index  <=  0;
    end
    else if (!csb_tb && !tx_en && tx_ready && !boot_sel) begin
      tx_en <= 1;
      w_byte <= prog_image[index];
      index  <= index + 1;
      $display("prog_image[%x] = 0x%x",index, prog_image[index]);
    end else
      tx_en  <= 0;
  end

endmodule
