
module azadi_soc_top (
`ifdef USE_POWER_PINS
   inout vccd1,
   inout vssd1,
`endif
  input  logic        clk_i,
  input  logic        rst_ni,

  // programming switch
  input  logic        prog_i,

  input  logic [15:0] clks_per_bit,
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_oe,

  // uart-periph interface
  output logic        uart_tx,
  input  logic        uart_rx,

  // PWM interface  
  output logic        pwm_o,
  output logic        pwm_o_2,
  output logic        pwm1_oe,
  output logic        pwm2_oe,

  // SPI interface
  output logic [3:0]  ss_o,
  output logic        sclk_o,
  output logic        sd_o,
  output logic        sd_oe,
  input  logic        sd_i
);

  logic        prog_rst_ni;
  logic        system_rst_ni;

  logic [31:0] gpio_in;
  logic [31:0] gpio_out;

  logic        instr_valid;
  logic [11:0] tlul_addr;
  logic        req_i;
  logic [31:0] tlul_data;

  // instruction sram interface
  logic        instr_csb;
  logic [11:0] instr_addr;
  logic [31:0] instr_wdata;
  logic [3:0]  instr_wmask;
  logic        instr_we;
  logic [31:0] instr_rdata;
  
  // data sram interface
  logic        data_csb;
  logic [11:0] data_addr;
  logic [31:0] data_wdata;
  logic [3:0]  data_wmask;
  logic        data_we;
  logic [31:0] data_rdata;
  
  logic [31:0] iccm_ctrl_data;
  logic        iccm_ctrl_we;
  logic [11:0] iccm_ctrl_addr_o;

  tlul_pkg::tl_h2d_t ifu_to_xbar;
  tlul_pkg::tl_d2h_t xbar_to_ifu;
  tlul_pkg::tl_h2d_t xbar_to_iccm;
  tlul_pkg::tl_d2h_t iccm_to_xbar;

  tlul_pkg::tl_h2d_t lsu_to_xbar;
  tlul_pkg::tl_d2h_t xbar_to_lsu;

  tlul_pkg::tl_h2d_t xbar_to_dccm;
  tlul_pkg::tl_d2h_t dccm_to_xbar;

  tlul_pkg::tl_h2d_t xbarp_to_gpio;
  tlul_pkg::tl_d2h_t gpio_to_xbarp;

  tlul_pkg::tl_h2d_t plic_req;
  tlul_pkg::tl_d2h_t plic_resp;

  tlul_pkg::tl_h2d_t xbar_to_uart;
  tlul_pkg::tl_d2h_t uart_to_xbar;

  tlul_pkg::tl_h2d_t xbar_to_timer;
  tlul_pkg::tl_d2h_t timer_to_xbar;

  tlul_pkg::tl_h2d_t xbar_to_pwm;
  tlul_pkg::tl_d2h_t pwm_to_xbar;

  tlul_pkg::tl_h2d_t xbar_to_spi;
  tlul_pkg::tl_d2h_t spi_to_xbar;

  // interrupt vector
  logic [36:0] intr_vector;

  assign intr_vector = {
    intr_srx,
    intr_stx,
    intr_u_tx,
    intr_u_rx,
    intr_gpio,
    1'b0
  };

  // Interrupt source list
  logic [31:0] intr_gpio;
  logic        intr_uart0_tx_watermark;
  logic        intr_uart0_rx_watermark;
  logic        intr_uart0_tx_empty;
  logic        intr_uart0_rx_overflow;
  logic        intr_uart0_rx_frame_err;
  logic        intr_uart0_rx_break_err;
  logic        intr_uart0_rx_timeout;
  logic        intr_uart0_rx_parity_err;
  logic        intr_req;
  logic        intr_srx;
  logic        intr_stx;
  logic        intr_timer;
  logic        intr_u_tx;
  logic        intr_u_rx;

  ibex_core_top #(
    .PMPEnable        (0),
    .PMPGranularity   (0),
    .PMPNumRegions    (4),
    .MHPMCounterNum   (0),
    .MHPMCounterWidth (40),
    .RV32E            (0),
    .RV32M            (ibex_pkg::RV32MSlow),
    .RV32B            (ibex_pkg::RV32BNone),
    .RegFile          (ibex_pkg::RegFileFF),
    .BranchTargetALU  (1),
    .WritebackStage   (1),
    .ICache           (0),
    .ICacheECC        (0),
    .BranchPredictor  (0),
    .DbgTriggerEn     (1),
    .DbgHwBreakNum    (1),
    .SecureIbex       (0),
    .DmHaltAddr       (0),
    .DmExceptionAddr  (0)
  ) u_ibex_core_top (

    .clk_i          ( clk_i         ),
    .rst_ni         ( system_rst_ni ),

    // instruction memory interface 
    .tl_i_i         ( xbar_to_ifu   ),
    .tl_i_o         ( ifu_to_xbar   ),

    // data memory interface 
    .tl_d_i         ( xbar_to_lsu   ),
    .tl_d_o         ( lsu_to_xbar   ),

    .test_en_i      ( 1'b0          ),
    .hart_id_i      ( 32'b0         ),
    .boot_addr_i    ( 32'h20000000  ),

    // Interrupt inputs
    .irq_software_i ( 1'b0          ),
    .irq_timer_i    ( intr_timer    ),
    .irq_external_i ( intr_req      ),
    .irq_fast_i     (   '0          ),
    .irq_nm_i       (   '0          ),

    // Debug Interface
    .debug_req_i    ( 1'b0          ),

    // CPU Control Signals
    .fetch_enable_i ( system_rst_ni ),
    .alert_minor_o  ( ),
    .alert_major_o  ( ),
    .core_sleep_o   ( )
  );

  // main xbar
  tl_xbar_main u_tl_xbar_main (
    .clk_i         ( clk_i         ),
    .rst_ni        ( system_rst_ni ),

    // Host interfaces
    .tl_ibexif_i   ( ifu_to_xbar   ),
    .tl_ibexif_o   ( xbar_to_ifu   ),
    .tl_ibexlsu_i  ( lsu_to_xbar   ),
    .tl_ibexlsu_o  ( xbar_to_lsu   ),

    // Device interfaces
    .tl_iccm_o     ( xbar_to_iccm  ),
    .tl_iccm_i     ( iccm_to_xbar  ),
    .tl_dccm_o     ( xbar_to_dccm  ),
    .tl_dccm_i     ( dccm_to_xbar  ),
    .tl_timer0_o   ( xbar_to_timer ),
    .tl_timer0_i   ( timer_to_xbar ),
    .tl_uart_o     ( xbar_to_uart  ),
    .tl_uart_i     ( uart_to_xbar  ),
    .tl_spi_o      ( xbar_to_spi   ),
    .tl_spi_i      ( spi_to_xbar   ),
    .tl_pwm_o      ( xbar_to_pwm   ),
    .tl_pwm_i      ( pwm_to_xbar   ),
    .tl_gpio_o     ( xbarp_to_gpio ),
    .tl_gpio_i     ( gpio_to_xbarp ),
    .tl_plic_o     ( plic_req      ),
    .tl_plic_i     ( plic_resp     )
  );

  // timer
  rv_timer u_rv_timer( 
    .clk_i  ( clk_i         ),
    .rst_ni ( system_rst_ni ),

    .tl_i   ( xbar_to_timer ),
    .tl_o   ( timer_to_xbar ),

    .intr_timer_expired_o ( intr_timer )
  );

  // peripheral PWM
  pwm_top u_pwm_top(
    .clk_i   ( clk_i         ),
    .rst_ni  ( system_rst_ni ),
    .tl_i    ( xbar_to_pwm   ),
    .tl_o    ( pwm_to_xbar   ),
    .pwm_o   ( pwm_o         ),
    .pwm_o_2 ( pwm_o_2       ),
    .pwm1_oe ( pwm1_oe       ),
    .pwm2_oe ( pwm2_oe       )
  );

  // peripheral spi
  spi_top u_spi_top(
    .clk_i       ( clk_i         ),
    .rst_ni      ( system_rst_ni ),

    .tl_i        ( xbar_to_spi   ),
    .tl_o        ( spi_to_xbar   ),

    // SPI signals
    .intr_rx_o   ( intr_srx      ),
    .intr_tx_o   ( intr_stx      ),
    .ss_o        ( ss_o          ),
    .sclk_o      ( sclk_o        ),
    .sd_o        ( sd_o          ),
    .sd_oe       ( sd_oe         ),
    .sd_i        ( sd_i          )
  );

  // peripheral GPIOs
  gpio u_gpio (
    .clk_i         ( clk_i         ),
    .rst_ni        ( system_rst_ni ),

    // Below Regster interface can be changed
    .tl_i          ( xbarp_to_gpio ),
    .tl_o          ( gpio_to_xbarp ),
    .cio_gpio_i    ( gpio_in       ),
    .cio_gpio_o    ( gpio_out      ),
    .cio_gpio_en_o ( gpio_oe       ),
    .intr_gpio_o   ( intr_gpio     )
  );

  // peripheral UART 
  uart_top  u_uart_top(
    .clk_i   ( clk_i         ),
    .rst_ni  ( system_rst_ni ),
    
    .tl_i    ( xbar_to_uart  ),
    .tl_o    ( uart_to_xbar  ),
    
    .tx_o    ( uart_tx       ),
    .rx_i    ( uart_rx       ),
    
    .intr_tx ( intr_u_tx     ),
    .intr_rx ( intr_u_rx     )
  );
  
  // reset manager
  rstmgr u_rstmgr(
    .clk_i       ( clk_i         ),
    .rst_ni      ( rst_ni        ),
    .prog_rst_ni ( prog_rst_ni   ),
    .sys_rst_ni  ( system_rst_ni )
  );
  
  // external interrupt controller
  rv_plic u_rv_plic (
    .clk_i      ( clk_i         ),
    .rst_ni     ( system_rst_ni ),

    // Bus Interface (device)
    .tl_i       ( plic_req      ),
    .tl_o       ( plic_resp     ),

    // Interrupt Sources
    .intr_src_i ( intr_vector   ),

    // Interrupt notification to targets
    .irq_o      ( intr_req      ),
    .msip_o     (               )
  );

  // instruction loader
  programmer u_programmer(
    .clk_i	      ( clk_i            ),
    .rst_ni	      ( rst_ni           ),

    .prog_i	      ( prog_i           ),
    .rx_i		      ( uart_rx          ),
    .clks_per_bit	( clks_per_bit     ),

    .we_o		      ( iccm_ctrl_we     ),
    .addr_o	      ( iccm_ctrl_addr_o ),
    .wdata_o	    ( iccm_ctrl_data   ),
    .reset_o	    ( prog_rst_ni      )
  );

  // instruction memory interface
  instr_mem_top u_instr_mem_top(
    .clk_i            (clk_i),
    .rst_ni           (system_rst_ni),
  
    .tl_i             ( xbar_to_iccm     ),
    .tl_o             ( iccm_to_xbar     ),
    // iccm controller interface 
    .iccm_ctrl_addr   ( iccm_ctrl_addr_o ),
    .iccm_ctrl_wdata  ( iccm_ctrl_data   ),
    .iccm_ctrl_we     ( iccm_ctrl_we     ),
    .prog_rst_ni      ( prog_rst_ni      ),

    // instruction sram interface 
    .csb              ( instr_csb        ),
    .addr_o           ( instr_addr       ),
    .wdata_o          ( instr_wdata      ),
    .wmask_o          ( instr_wmask      ),
    .we_o             ( instr_we         ),
    .rdata_i          ( instr_rdata      )
  );
  
  // intruction memory
  sram_32x1024 u_iccm(
    .clk_i	 ( clk_i         ),
    .rst_ni	 ( system_rst_ni ),
    
    .csb_i	 ( instr_csb     ),
    .web_i	 ( instr_we      ),
    .wmask_i ( instr_wmask   ),
    .addr_i	 ( instr_addr    ),
    .wdata_i ( instr_wdata   ),
    .rdata_o ( instr_rdata   )
  );

  // data memory interface
  data_mem_top u_data_mem_top(
    .clk_i   ( clk_i         ),
    .rst_ni  ( system_rst_ni ),

    // tl-ul insterface
    .tl_d_i  ( xbar_to_dccm  ),
    .tl_d_o  ( dccm_to_xbar  ),
  
    // sram interface
    .csb     ( data_csb      ),
    .addr_o  ( data_addr     ),
    .wdata_o ( data_wdata    ),
    .wmask_o ( data_wmask    ),
    .we_o    ( data_we       ),
    .rdata_i ( data_rdata    )
  );
  
  // data memory
  sram_32x1024 u_dccm(
    .clk_i	 ( clk_i         ),
    .rst_ni	 ( system_rst_ni ),

    .csb_i	 ( data_csb      ),
    .web_i	 ( data_we       ),
    .wmask_i ( data_wmask    ),
    .addr_i	 ( data_addr     ),
    .wdata_i ( data_wdata    ),
    .rdata_o ( data_rdata    )
  );

  assign gpio_in = gpio_i;
  assign gpio_o  = gpio_out;

endmodule
