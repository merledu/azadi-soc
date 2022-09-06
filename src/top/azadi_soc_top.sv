
// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module azadi_soc_top (
`ifdef USE_POWER_PINS
   inout vccd1,
   inout vssd1,
`endif
  input  logic        clk_main_i,
  input  logic        rst_ni,
  input  logic        por_ni,     // Power on reset
  input  logic        pll_lock_i,
  input  logic        boot_sel_i,
  output logic        led_alive_o,

  // House keeping SPI
  input  logic        hk_sck_i,
  input  logic        hk_sdi_i,
  input  logic        hk_csb_i,
  output logic        hk_sdo_o,  // will be high when program is successfully loaded into ICCM/QSPI

  // GPIO interface
  input  logic [23:0] gpio_in_i,
  output logic [23:0] gpio_out_o,
  output logic [23:0] gpio_oe_o,

  // uart-periph interface
  output logic [ 3:0] uart_tx_o,
  input  logic [ 3:0] uart_rx_i,
  output logic [ 3:0] uart_oe_o,

  // SPI interface
  output logic [ 3:0] ss_o,
  output logic [ 3:0] sclk_o,
  output logic [ 3:0] sd_o,
  output logic [ 3:0] sd_oe_o,
  input  logic [ 3:0] sd_i,

  // PWM interface
  output logic [ 3:0] pwm1_o,
  output logic [ 3:0] pwm2_o,
  output logic [ 3:0] pwm1_oe_o,
  output logic [ 3:0] pwm2_oe_o,

  // QSPI interface
  input  logic [ 3:0] qspi_sdi_i,
  output logic [ 3:0] qspi_oe_o,
  output logic [ 3:0] qspi_sdo_o,
  output logic        qspi_clk_o,
  output logic        qspi_csb_o
  `ifdef SIM
  ,output logic       clk_enb_o
  `endif
);

  ////////////////////////////////
  // Local Parameters
  ////////////////////////////////
  localparam ADDR_WIDTH = 13;

  ////////////////////////////////
  // Local Signals
  ////////////////////////////////
  // Clock & Resets
  logic clk_i;
  logic clk_enb;

  // Boot address
  logic [31:0] boot_addr;
  logic [31:0] boot_reg_val;

  // QSPI mux signals
  logic [3:0]  qspi_oe;
  logic [3:0]  qspi_sdo;
  logic        qspi_clk;
  logic        qspi_csb;

  // ICCM controller output signals
  logic [31:0]           iccm_ctrl_data;
  logic                  iccm_ctrl_we;
  logic [ADDR_WIDTH-1:0] iccm_ctrl_addr;

  // Instruction sram interface
  logic                  instr_csb;
  logic [ADDR_WIDTH-1:0] instr_addr;
  logic [31:0]           instr_wdata;
  logic [3:0]            instr_wmask;
  logic                  instr_we;
  logic [31:0]           instr_rdata;

  // Data sram interface
  logic                  data_csb;
  logic [ADDR_WIDTH-1:0] data_addr;
  logic [31:0]           data_wdata;
  logic [3:0]            data_wmask;
  logic                  data_we;
  logic [31:0]           data_rdata;

  // Hosts
  tlul_pkg::tlul_h2d_t ifu_to_xbar;
  tlul_pkg::tlul_d2h_t xbar_to_ifu;

  tlul_pkg::tlul_h2d_t lsu_to_xbar;
  tlul_pkg::tlul_d2h_t xbar_to_lsu;

  // Devices
  tlul_pkg::tlul_h2d_t xbar_to_qspi;
  tlul_pkg::tlul_d2h_t qspi_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_iccm;
  tlul_pkg::tlul_d2h_t iccm_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_dccm;
  tlul_pkg::tlul_d2h_t dccm_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_timer[3];
  tlul_pkg::tlul_d2h_t timer_to_xbar[3];

  tlul_pkg::tlul_h2d_t xbar_to_tic;
  tlul_pkg::tlul_d2h_t tic_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_periph;
  tlul_pkg::tlul_d2h_t periph_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_plic;
  tlul_pkg::tlul_d2h_t plic_to_xbar;

  tlul_pkg::tlul_h2d_t xbar_to_rom;
  tlul_pkg::tlul_d2h_t rom_to_xbar;

  tlul_pkg::tlul_h2d_t xbarp_to_gpio;
  tlul_pkg::tlul_d2h_t gpio_to_xbarp;

  tlul_pkg::tlul_h2d_t xbarp_to_uart[4];
  tlul_pkg::tlul_d2h_t uart_to_xbarp[4];

  tlul_pkg::tlul_h2d_t xbarp_to_spi[4];
  tlul_pkg::tlul_d2h_t spi_to_xbarp[4];

  tlul_pkg::tlul_h2d_t xbarp_to_pwm[4];
  tlul_pkg::tlul_d2h_t pwm_to_xbarp[4];

  // External interrupt vector
  logic [40:0] ext_intr_vector;

  // Timer interrupt vector
  logic [3:0] timer_intr_vector;

  // Interrupt source list
  logic        irq_external;
  logic        irq_uart0_tx;
  logic	       irq_uart0_rx;
  logic        irq_uart1_tx;
  logic	       irq_uart1_rx;
  logic        irq_uart2_tx;
  logic	       irq_uart2_rx;
  logic        irq_uart3_tx;
  logic	       irq_uart3_rx;
  logic        irq_spi0_rx;
  logic        irq_spi0_tx;
  logic        irq_spi1_rx;
  logic        irq_spi1_tx;
  logic        irq_spi2_rx;
  logic        irq_spi2_tx;
  logic        irq_spi3_rx;
  logic        irq_spi3_tx;
  logic [31:0] irq_gpio;

  logic        irq_timer;
  logic        irq_timer0;
  logic        irq_timer1;
  logic        irq_timer2;

  ////////////////////////////////
  // Continous Assignment
  ////////////////////////////////

  `ifdef SIM
    assign clk_enb_o = clk_enb;
  `endif

  assign led_alive_o = gpio_out_o[0];

  // Timer interrupt vector
  assign timer_intr_vector = {
    irq_timer2,
    irq_timer1,
    irq_timer0,
    1'b0
  };

  // External interrupt vector
  assign ext_intr_vector = {
    irq_uart0_tx,
    irq_uart0_rx,
    irq_uart1_tx,
    irq_uart1_rx,
    irq_uart2_tx,
    irq_uart2_rx,
    irq_uart3_tx,
    irq_uart3_rx,
    irq_spi0_rx,
    irq_spi0_tx,
    irq_spi1_rx,
    irq_spi1_tx,
    irq_spi2_rx,
    irq_spi2_tx,
    irq_spi3_rx,
    irq_spi3_tx,
    irq_gpio,
    1'b0
  };

  // Boot address selection. por_ni = 0: ROM; else boot_sel = 1: QSPI, 0: ICCM
  boot_addr_mngr u_boot_addr_mngr (
    .clk_i          ( clk_i        ),
    .rst_ni         ( rst_ni       ),
    .por_ni         ( por_ni       ),
    .prog_done_i    ( hk_sdo_o     ),
    .boot_sel_i     ( boot_sel_i   ),
    .boot_addr_o    ( boot_addr    ),
    .boot_reg_val_o ( boot_reg_val )
  );

  // Mux QSPI interface for programming
  always_comb begin
    if (!hk_csb_i) begin
      qspi_oe_o [0] = 1'b0;
      qspi_sdo_o[0] = hk_sdi_i;
      qspi_clk_o    = hk_sck_i;
      qspi_csb_o    = hk_csb_i;
    end else begin
      qspi_oe_o  = qspi_oe;
      qspi_sdo_o = qspi_sdo;
      qspi_clk_o = qspi_clk;
      qspi_csb_o = qspi_csb;
    end
  end

  ////////////////////////////////
  // Modules Instantiations
  ////////////////////////////////

  // Slave SPI controller
  spi_controller_iccm #(
    .ADDR_WIDTH(ADDR_WIDTH)
  ) u_spi_controller (
    .clk_i    ( clk_i          ),
    .rst_ni   ( rst_ni         ),
    .sck_i    ( hk_sck_i       ),
    .sdi_i    ( hk_sdi_i       ),
    .csb_i    ( hk_csb_i       ),
    .sdo_o    ( hk_sdo_o       ),
    .waddr_o  ( iccm_ctrl_addr ),
    .wdata_o  ( iccm_ctrl_data ),
    .wvalid_o ( iccm_ctrl_we   )
  );

  // Buraq core top
  ibex_core_top #(
    .PMPEnable        ( 0                  ),
    .PMPGranularity   ( 0                  ),
    .PMPNumRegions    ( 4                  ),
    .MHPMCounterNum   ( 0                  ),
    .MHPMCounterWidth ( 40                 ),
    .RV32E            ( 10                 ),
    .RV32M            ( ibex_pkg::RV32MSlow ),
    .RV32B            ( ibex_pkg::RV32BNone ),
    .RegFile          ( ibex_pkg::RegFileFF ),
    .BranchTargetALU  ( 1                  ),
    .WritebackStage   ( 1                  ),
    .ICache           ( 0                  ),
    .ICacheECC        ( 0                  ),
    .BranchPredictor  ( 0                  ),
    .DbgTriggerEn     ( 1                  ),
    .DbgHwBreakNum    ( 1                  ),
    .SecureIbex        ( 0                  ),
    .DmHaltAddr       ( 0                  ),
    .DmExceptionAddr  ( 0                  )
  ) u_ibex_core_top (
    .clk_i          ( clk_i         ),
    .rst_ni         ( rst_ni        ),
    // instruction memory interface
    .tl_i_i         ( xbar_to_ifu   ),
    .tl_i_o         ( ifu_to_xbar   ),
    // data memory interface
    .tl_d_i         ( xbar_to_lsu   ),
    .tl_d_o         ( lsu_to_xbar   ),
    .hart_id_i      ( 32'h00000000  ),
    .boot_addr_i    ( boot_addr     ),
    // Interrupt inputs
    .irq_software_i ( 1'b0          ),
    .irq_timer_i    ( irq_timer     ),
    .irq_external_i ( irq_external  ),
    .irq_fast_i     ( '0            ),
    // non-maskeable interrupt
    .irq_nm_i       ( 1'b0          ),
    // Debug Interface
    .debug_req_i    ( '0            ),
    // CPU Control Signals
    .fetch_enable_i ( 1'b1          ),
    .alert_minor_o  (),
    .alert_major_o  (),
    .core_sleep_o   (),
    .test_en_i      (1'b0)
  );

  //////////////////////////
  //     Main cross bar
  //////////////////////////
  tlul_xbar_main u_tlul_xbar_main (
    .clk_i       ( clk_i         ),
    .rst_ni      ( rst_ni        ),

    // Host interfaces
    .tl_ibexifu_i ( ifu_to_xbar   ),
    .tl_ibexifu_o ( xbar_to_ifu   ),
    .tl_ibexlsu_i ( lsu_to_xbar   ),
    .tl_ibexlsu_o ( xbar_to_lsu   ),

    // Device interfaces
    .tl_qspi_o   ( xbar_to_qspi ),
    .tl_qspi_i   ( qspi_to_xbar ),

    .tl_iccm_o   ( xbar_to_iccm   ),
    .tl_iccm_i   ( iccm_to_xbar   ),
    .tl_dccm_o   ( xbar_to_dccm   ),
    .tl_dccm_i   ( dccm_to_xbar   ),

    .tl_timer0_o ( xbar_to_timer[0] ),
    .tl_timer0_i ( timer_to_xbar[0] ),
    .tl_timer1_o ( xbar_to_timer[1] ),
    .tl_timer1_i ( timer_to_xbar[1] ),
    .tl_timer2_o ( xbar_to_timer[2] ),
    .tl_timer2_i ( timer_to_xbar[2] ),

    .tl_tic_o    ( xbar_to_tic    ),
    .tl_tic_i    ( tic_to_xbar    ),

    .tl_periph_o ( xbar_to_periph ),
    .tl_periph_i ( periph_to_xbar ),

    .tl_plic_o   ( xbar_to_plic   ),
    .tl_plic_i   ( plic_to_xbar   ),

    .tl_rom_o    ( xbar_to_rom    ),
    .tl_rom_i    ( rom_to_xbar    )
  );

  // Reset manager
  clk_rst_mngr u_clk_rst_mngr (
    .clk_i      ( clk_main_i ),
    .sys_rst_ni ( rst_ni     ),
    .por_ni     ( por_ni     ),
    .ndm_rst_ni ( ),
    .pll_lock_i ( pll_lock_i ),
    .clk_enb_o  ( clk_enb    )
  );

  prim_clock_gating u_cg_main(
    .clk_i     ( clk_main_i ),
    .en_i      ( clk_enb    ),
    .test_en_i ( 1'b0       ),
    .clk_o     ( clk_i      )
  );

  // ROM top wrapper
  rom_top #(
    .ADDR(8),
    .DW  (32)
  ) u_rom_top (
    .clk_i  ( clk_i       ),
    .rst_ni ( rst_ni      ),
    .tl_d_i ( xbar_to_rom ),
    .tl_d_o ( rom_to_xbar )
  );

  // QSPI instantiation
  qspi_top u_qspi(
    .clk_i    ( clk_i        ),
    .rst_ni   ( rst_ni       ),
    .tl_i     ( xbar_to_qspi ),
    .tl_o     ( qspi_to_xbar ),
    .qspi_i   ( qspi_sdi_i   ),
    .qspi_o   ( qspi_sdo     ),
    .qspi_oe  ( qspi_oe      ),
    .qspi_csb ( qspi_csb     ),
    .qspi_clk ( qspi_clk     )
  );

  // Instruction memory tlul wrapper
  instr_mem_top iccm_adapter(
    .clk_i           ( clk_i          ),
    .rst_ni          ( rst_ni         ),
    .tl_i            ( xbar_to_iccm   ),
    .tl_o            ( iccm_to_xbar   ),
    .iccm_ctrl_addr  ( iccm_ctrl_addr ),
    .iccm_ctrl_wdata ( iccm_ctrl_data ),
    .iccm_ctrl_we    ( iccm_ctrl_we   ),
    .prog_rst_ni     ( hk_csb_i       ),
    .csb             ( instr_csb      ),
    .addr_o          ( instr_addr     ),
    .wdata_o         ( instr_wdata    ),
    .wmask_o         ( instr_wmask    ),
    .we_o            ( instr_we       ),
    .rdata_i         ( instr_rdata    )
  );
  sram u_iccm_mem (
    .clock        (clk_i),
    .reset        (rst_ni),
    .readEnable   (instr_csb),
    .Address      (instr_addr),
    .readData     (instr_rdata),
    .writeEnable  (instr_we),
    .writeData    (instr_wdata)
  );

  // Data memory tlul wrapper
  data_mem_top dccm_adapter(
    .clk_i       ( clk_i        ),
    .rst_ni      ( rst_ni       ),
    .tl_d_i      ( xbar_to_dccm ),
    .tl_d_o      ( dccm_to_xbar ),
    .boot_reg_i  ( boot_reg_val ),
    .csb         ( data_csb     ),
    .addr_o      ( data_addr    ),
    .wdata_o     ( data_wdata   ),
    .wmask_o     ( data_wmask   ),
    .we_o        ( data_we      ),
    .rdata_i     ( data_rdata   )
  );
sram u_dccm_mem (
    .clock        (clk_i),
    .reset        (rst_ni),
    .readEnable   (instr_csb),
    .Address      (instr_addr),
    .readData     (instr_rdata),
    .writeEnable  (instr_we),
    .writeData    (instr_wdata)
  );
  // Timer 0
  rv_timer u_rv_timer_0(
    .clk_i        ( clk_i            ),
    .rst_ni       ( rst_ni           ),
    .tl_i         ( xbar_to_timer[0] ),
    .tl_o         ( timer_to_xbar[0] ),
    .irq_timer_o  ( irq_timer0       )
  );

  // Timer 1
  rv_timer u_rv_timer_1(
    .clk_i        ( clk_i            ),
    .rst_ni       ( rst_ni           ),
    .tl_i         ( xbar_to_timer[1] ),
    .tl_o         ( timer_to_xbar[1] ),
    .irq_timer_o  ( irq_timer1       )
  );

  // Timer 2
  rv_timer u_rv_timer_2(
    .clk_i        ( clk_i            ),
    .rst_ni       ( rst_ni           ),
    .tl_i         ( xbar_to_timer[2] ),
    .tl_o         ( timer_to_xbar[2] ),
    .irq_timer_o  ( irq_timer2       )
  );

  // Timer Interrupt Controller
  tic_top u_tic_top(
    .clk_i    ( clk_i             ),
    .rst_ni   ( rst_ni            ),
    .tl_i     ( xbar_to_tic       ),
    .tl_o     ( tic_to_xbar       ),
    .int_src  ( timer_intr_vector ),
    .intr_o   ( irq_timer         )
  );

  // Platform Level Interrupt Controller to
  // priortize and send external interupt to CPU
  rv_plic u_rv_plic (
    .clk_i      ( clk_i           ),
    .rst_ni     ( rst_ni          ),
    .tl_i       ( xbar_to_plic    ),
    .tl_o       ( plic_to_xbar    ),
    .intr_src_i ( ext_intr_vector ),
    .irq_o      ( irq_external    ),
    .msip_o     (                 )
  );

  //////////////////////////
  //  Peripheral cross bar
  //////////////////////////
  tlul_xbar_periph u_tlul_xbar_periph (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),

    // Host interfaces
    .tl_periph_i ( xbar_to_periph ),
    .tl_periph_o ( periph_to_xbar ),

    // Device interfaces
    .tl_gpio_o   ( xbarp_to_gpio  ),
    .tl_gpio_i   ( gpio_to_xbarp  ),

    .tl_uart0_o  ( xbarp_to_uart[0] ),
    .tl_uart0_i  ( uart_to_xbarp[0] ),
    .tl_uart1_o  ( xbarp_to_uart[1] ),
    .tl_uart1_i  ( uart_to_xbarp[1] ),
    .tl_uart2_o  ( xbarp_to_uart[2] ),
    .tl_uart2_i  ( uart_to_xbarp[2] ),
    .tl_uart3_o  ( xbarp_to_uart[3] ),
    .tl_uart3_i  ( uart_to_xbarp[3] ),

    .tl_spi0_o   ( xbarp_to_spi[0]  ),
    .tl_spi0_i   ( spi_to_xbarp[0]  ),
    .tl_spi1_o   ( xbarp_to_spi[1]  ),
    .tl_spi1_i   ( spi_to_xbarp[1]  ),
    .tl_spi2_o   ( xbarp_to_spi[2]  ),
    .tl_spi2_i   ( spi_to_xbarp[2]  ),
    .tl_spi3_o   ( xbarp_to_spi[3]  ),
    .tl_spi3_i   ( spi_to_xbarp[3]  ),

    .tl_pwm0_o   ( xbarp_to_pwm[0]  ),
    .tl_pwm0_i   ( pwm_to_xbarp[0]  ),
    .tl_pwm1_o   ( xbarp_to_pwm[1]  ),
    .tl_pwm1_i   ( pwm_to_xbarp[1]  ),
    .tl_pwm2_o   ( xbarp_to_pwm[2]  ),
    .tl_pwm2_i   ( pwm_to_xbarp[2]  ),
    .tl_pwm3_o   ( xbarp_to_pwm[3]  ),
    .tl_pwm3_i   ( pwm_to_xbarp[3]  )
  );

  // UART 0
  uart_top u_uart_top_0 (
    .clk_i   ( clk_i            ),
    .rst_ni  ( rst_ni           ),
    .tl_i    ( xbarp_to_uart[0] ),
    .tl_o    ( uart_to_xbarp[0] ),
    .tx_o    ( uart_tx_o[0]     ),
    .rx_i    ( uart_rx_i[0]     ),
    .intr_tx ( irq_uart0_tx     ),
    .intr_rx ( irq_uart0_rx     )
  );

  // UART 1
  uart_top u_uart_top_1 (
    .clk_i   ( clk_i            ),
    .rst_ni  ( rst_ni           ),
    .tl_i    ( xbarp_to_uart[1] ),
    .tl_o    ( uart_to_xbarp[1] ),
    .tx_o    ( uart_tx_o[1]     ),
    .rx_i    ( uart_rx_i[1]     ),
    .intr_tx ( irq_uart1_tx     ),
    .intr_rx ( irq_uart1_rx     )
  );

  // UART 2
  uart_top u_uart_top_2 (
    .clk_i   ( clk_i            ),
    .rst_ni  ( rst_ni           ),
    .tl_i    ( xbarp_to_uart[2] ),
    .tl_o    ( uart_to_xbarp[2] ),
    .tx_o    ( uart_tx_o[2]     ),
    .rx_i    ( uart_rx_i[2]     ),
    .intr_tx ( irq_uart2_tx     ),
    .intr_rx ( irq_uart2_rx     )
  );

  // UART 3
  uart_top u_uart_top_3 (
    .clk_i   ( clk_i            ),
    .rst_ni  ( rst_ni           ),
    .tl_i    ( xbarp_to_uart[3] ),
    .tl_o    ( uart_to_xbarp[3] ),
    .tx_o    ( uart_tx_o[3]     ),
    .rx_i    ( uart_rx_i[3]     ),
    .intr_tx ( irq_uart3_tx     ),
    .intr_rx ( irq_uart3_rx     )
  );

  // SPI 0
  spi_top u_spi_top_0 (
    .clk_i     ( clk_i           ),
    .rst_ni    ( rst_ni          ),
    .tl_i      ( xbarp_to_spi[0] ),
    .tl_o      ( spi_to_xbarp[0] ),
    .intr_rx_o ( irq_spi0_rx     ),
    .intr_tx_o ( irq_spi0_tx     ),
    .ss_o      ( ss_o[0]         ),
    .sclk_o    ( sclk_o[0]       ),
    .sd_o      ( sd_o[0]         ),
    .sd_oe     ( sd_oe_o[0]      ),
    .sd_i      ( sd_i[0]         )
  );

  // SPI 1
  spi_top u_spi_top_1 (
    .clk_i     ( clk_i           ),
    .rst_ni    ( rst_ni          ),
    .tl_i      ( xbarp_to_spi[1] ),
    .tl_o      ( spi_to_xbarp[1] ),
    .intr_rx_o ( irq_spi1_rx     ),
    .intr_tx_o ( irq_spi1_tx     ),
    .ss_o      ( ss_o[1]         ),
    .sclk_o    ( sclk_o[1]       ),
    .sd_o      ( sd_o[1]         ),
    .sd_oe     ( sd_oe_o[1]      ),
    .sd_i      ( sd_i[1]         )
  );

  // SPI 2
  spi_top u_spi_top_2 (
    .clk_i     ( clk_i           ),
    .rst_ni    ( rst_ni          ),
    .tl_i      ( xbarp_to_spi[2] ),
    .tl_o      ( spi_to_xbarp[2] ),
    .intr_rx_o ( irq_spi2_rx     ),
    .intr_tx_o ( irq_spi2_tx     ),
    .ss_o      ( ss_o[2]         ),
    .sclk_o    ( sclk_o[2]       ),
    .sd_o      ( sd_o[2]         ),
    .sd_oe     ( sd_oe_o[2]      ),
    .sd_i      ( sd_i[2]         )
  );

  // SPI 3
  spi_top u_spi_top_3 (
    .clk_i     ( clk_i           ),
    .rst_ni    ( rst_ni          ),
    .tl_i      ( xbarp_to_spi[3] ),
    .tl_o      ( spi_to_xbarp[3] ),
    .intr_rx_o ( irq_spi3_rx     ),
    .intr_tx_o ( irq_spi3_tx     ),
    .ss_o      ( ss_o[3]         ),
    .sclk_o    ( sclk_o[3]       ),
    .sd_o      ( sd_o[3]         ),
    .sd_oe     ( sd_oe_o[3]      ),
    .sd_i      ( sd_i[3]         )
  );

  // PWM 0
  pwm_top u_pwm_top_0 (
    .clk_i   ( clk_i           ),
    .rst_ni  ( rst_ni          ),
    .tl_i    ( xbarp_to_pwm[0] ),
    .tl_o    ( pwm_to_xbarp[0] ),
    .pwm1_o  ( pwm1_o[0]       ),
    .pwm2_o  ( pwm2_o[0]       ),
    .pwm1_oe ( pwm1_oe_o[0]    ),
    .pwm2_oe ( pwm2_oe_o[0]    )
  );

  // PWM 1
  pwm_top u_pwm_top_1 (
    .clk_i   ( clk_i           ),
    .rst_ni  ( rst_ni          ),
    .tl_i    ( xbarp_to_pwm[1] ),
    .tl_o    ( pwm_to_xbarp[1] ),
    .pwm1_o  ( pwm1_o[1]       ),
    .pwm2_o  ( pwm2_o[1]       ),
    .pwm1_oe ( pwm1_oe_o[1]    ),
    .pwm2_oe ( pwm2_oe_o[1]    )
  );

  // PWM 2
  pwm_top u_pwm_top_2 (
    .clk_i   ( clk_i           ),
    .rst_ni  ( rst_ni          ),
    .tl_i    ( xbarp_to_pwm[2] ),
    .tl_o    ( pwm_to_xbarp[2] ),
    .pwm1_o  ( pwm1_o[2]       ),
    .pwm2_o  ( pwm2_o[2]       ),
    .pwm1_oe ( pwm1_oe_o[2]    ),
    .pwm2_oe ( pwm2_oe_o[2]    )
  );

  // PWM 3
  pwm_top u_pwm_top_3 (
    .clk_i   ( clk_i           ),
    .rst_ni  ( rst_ni          ),
    .tl_i    ( xbarp_to_pwm[3] ),
    .tl_o    ( pwm_to_xbarp[3] ),
    .pwm1_o  ( pwm1_o[3]       ),
    .pwm2_o  ( pwm2_o[3]       ),
    .pwm1_oe ( pwm1_oe_o[3]    ),
    .pwm2_oe ( pwm2_oe_o[3]    )
  );

  //GPIO
  gpio u_gpio (
    .clk_i         ( clk_i         ),
    .rst_ni        ( rst_ni        ),
    .tl_i          ( xbarp_to_gpio ),
    .tl_o          ( gpio_to_xbarp ),
    .cio_gpio_i    ( gpio_in_i     ),
    .cio_gpio_o    ( gpio_out_o    ),
    .cio_gpio_en_o ( gpio_oe_o     ),
    .intr_gpio_o   ( irq_gpio      )
  );

endmodule
