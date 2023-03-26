// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Top module for simulation

`define ARM_UD_MODEL
`define TEST_ROM
`define AZADI

module azadi_top_sim
  import prog_loader_pkg::*;
(
`ifdef VERILATOR
  input logic clk_2,
  input logic clk_i,
  input logic por_ni,
  input logic rst_ni,
  input logic pll_lock
`endif
);
  //////////////////////
  // Local Signals
  //////////////////////
  string     HEX;
  string     ROM_BIN;
  string     BOOT_MODE;
  string     TEST_STATUS;
  integer    fd;
  bit [7:0]  prog_image [int];
  bit [7:0]  w_byte;
  bit        tx_en;
  int        index;
  bit [3:0]  qspi_i;
  bit [3:0]  qspi_o;
  bit [3:0]  qspi_oe;
  bit        qspi_clk;
  bit        qspi_csb;
  bit [31:0] vcc;
  wire [3:0] q_io;
  bit        clk_enb;
  bit        prog;
  logic      prog_done;
  bit        init;
  bit        init_done;
  byte       spi_cmd;

  logic      boot_sel;

  bit        finish_count;
  bit        simulation_end;
  logic      rx_done;

  wire hi;
  bit [31:0] vccs;

  // programing interface
  logic sck_tb;
  logic sdi_tb;
  logic csb_tb;
  logic sdo_tb;
  logic tx_ready;

  // fetching internal register values
  // to automate test checking
  logic [4:0]  wreg_addr_d, wreg_addr_q;
  logic [31:0] wreg_data_d, wreg_data_q;
  logic        wreg_wen_d,  wreg_wen_q;

  logic         o_Rx_DV;
  logic   [7:0] o_Rx_Byte;

  logic soc_uart_tx_to_rx;

  logic [207:0] rx_msg; 

`ifndef VERILATOR
  logic clk_2;
  logic clk_i;
  logic por_ni;
  logic rst_ni;
  logic pll_lock;

  initial begin
    clk_i    = 0;
    clk_2    = 0;
    rst_ni   = 1;
    por_ni   = 1;
    pll_lock = 0;
    prog     = 1;
    init     = 0;

    rx_done        = 0;
    #200ns;
    rst_ni   = 0;
    #200ns;
    vccs     = 32'd3000;
    vcc      = 32'd3000;
    #150e0ns; // qspi flash power-up delay
    rst_ni = 1;
    #200ns;
    por_ni = 0;
    #200ns;
    por_ni = 1;
    pll_lock = 1;


    
    if (BOOT_MODE=="QSPI") begin
      init = 1;
      wait(init_done) init = 0;
    end else begin
      #37700ns; 
      #5320ns;
      #5240ns;
      #80 init = 1;
      wait(init_done) 
        init = 0;
      prog = 1;
      wait(o_Rx_DV)
        if (!boot_sel) begin
          $write("------------------------------\n  ");
        end      
    end
    
    /*wait(rx_done) begin
      #10ns;
      rst_ni = 0;
      #100ns;
      rst_ni = 1;
    end*/

    wait(simulation_end) begin
      #160ns;
      if (boot_sel) begin
        $display("------------------------------");
        $display("  %s", rx_msg);
        $display("------------------------------");
      end else begin
        $display("\n------------------------------");
      end
      $display("Writing Final Value of reg 'x31' to expected.result file to compare!");
      $display("Test Status = %s", TEST_STATUS);
      //$finish;
    end
  end

  always #20 clk_i = ~clk_i;
  always #37 clk_2 = ~clk_2;
`endif

  initial begin
    // Initializing ROM
    if ($value$plusargs("ROM_BIN=%s", ROM_BIN)) begin
      $display("Reading ROM bin: %s", ROM_BIN);
    end

    $readmemb(ROM_BIN, u_azadi_soc_top.u_rom_top.u_rom.mem);

    // Feeding hex file to ICCM/QSPI loader
    if ($value$plusargs("HEX=%s", HEX)) begin
      $display("Reading hex: %s", HEX);
    end
    read_hex(HEX, prog_image);

    // Selecting boot mode
    if ($value$plusargs("BOOT_MODE=%s", BOOT_MODE)) begin
      $display("Selected BOOT MODE: %s", BOOT_MODE);
      if (BOOT_MODE == "ICCM") begin
        spi_cmd = 8'hB1;
      end else if (BOOT_MODE == "FLASH") begin
        spi_cmd = 8'hB2;
      end else if (BOOT_MODE == "QSPI_CONFIG") begin
        spi_cmd = 8'hB3;
      end else if (BOOT_MODE == "QSPI") begin
        spi_cmd = '0;
      end else begin
        $display("Incorrect parameter, setting default value of BOOT MODE to ICCM");
        spi_cmd = 8'hB1;
      end
    end else begin
      $display("!!! BOOT MODE is not selected !!!");
      $display("Setting default BOOT MODE: ICCM");
    end
    #4620us;
    if (!boot_sel) begin
      $display("\n------------------------------");
    end
    $display("Timeout has occured!");
    $display("Test Status = TIMEOUT");
   // $finish;
  end

  // writing result value in file for comparison
  initial fd = $fopen("expected.result", "w");
  final $fclose(fd);

  assign wreg_data_d = u_azadi_soc_top.u_ibex_core_top.ibex_core_i.wb_stage_i.rf_wdata_wb_o;
  assign wreg_addr_d = u_azadi_soc_top.u_ibex_core_top.ibex_core_i.wb_stage_i.rf_waddr_wb_o;
  assign wreg_wen_d  = u_azadi_soc_top.u_ibex_core_top.ibex_core_i.wb_stage_i.rf_we_wb_o;

  always_ff @(posedge clk_i) begin  
    wreg_data_q <= wreg_data_d;
    wreg_addr_q <= wreg_addr_d;
    wreg_wen_q  <= wreg_wen_d;

    if (wreg_wen_q && (wreg_addr_q == 5'h1F)) begin
      if(!finish_count || boot_sel)
        $display("Reg[31] is equals to 0x%8x", wreg_data_q);

      $fstrobeh(fd, wreg_data_q);
      if (wreg_data_q == 'b1) begin
        TEST_STATUS = "PASS";
      end else begin
        TEST_STATUS = "FAIL";
      end
      finish_count <= 1;
      if (finish_count) begin
        simulation_end <= 1;
      end
      
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
  wire [3:0] ss_o;
  wire [3:0] sclk_o;
  wire [3:0] sd_o;
  wire [3:0] sd_oe;
  wire [3:0] sd_i;

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
    .boot_sel_o ( boot_sel ),
    .pll_lock_i ( pll_lock ),
    .led_alive_o( prog_done),

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
    .uart_rx_i  ( {3'b11, uart_tx[1]} ),
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
    .qspi_oe_o  ( qspi_oe  ),
    .qspi_sdo_o ( qspi_o   ),
    .qspi_clk_o ( qspi_clk ),
    .qspi_csb_o ( qspi_csb )
  );

  tx_spi transmitter_SPI(
    .clk_i   ( clk_2    ),
    .rst_ni  ( rst_ni   ),
    .rdata_i ( w_byte   ),
    .req_i   ( tx_en    ),
    .spi_o   ( sdi_tb   ),
    .spi_clk ( sck_tb   ),
    .spi_csb ( csb_tb   ),
    .spi_rdy ( tx_ready )
  );

  // Flash behavioural model for simulation only
  N25Qxxx u_flash (
    .S        ( qspi_csb ),
    .C_       ( qspi_clk ),
    .HOLD_DQ3 ( q_io[3]  ),
    .DQ0      ( q_io[0]  ),
    .DQ1      ( q_io[1]  ),
    .Vcc      ( vcc      ),
    .Vpp_W_DQ2( q_io[2]  )
  );

  N25Qxxx u_spi_slave (
    .S        ( ss_o[0]  ),
    .C_       ( sclk_o[0]),
    .HOLD_DQ3 ( hi       ),
    .DQ0      ( sd_o[0]  ),
    .DQ1      ( sd_i[0]  ),
    .Vcc      ( vccs     ),
    .Vpp_W_DQ2( hi       )
  );

  IOBUF Q0(.io_in(qspi_o[0]), .io_out(qspi_i[0]), .io_oeb(qspi_oe[0]), .io(q_io[0]));
  IOBUF Q1(.io_in(qspi_o[1]), .io_out(qspi_i[1]), .io_oeb(qspi_oe[1]), .io(q_io[1]));
  IOBUF Q2(.io_in(qspi_o[2]), .io_out(qspi_i[2]), .io_oeb(qspi_oe[2]), .io(q_io[2]));
  IOBUF Q3(.io_in(qspi_o[3]), .io_out(qspi_i[3]), .io_oeb(qspi_oe[3]), .io(q_io[3]));

  IOBUF Q4(.io_in(1'b1), .io_out(), .io_oeb(1'b0), .io(hi));

  always_ff @ (posedge clk_2 or negedge rst_ni) begin
    if (!rst_ni) begin
      w_byte    <= '0;
      tx_en     <= '0;
      index     <= '0;
      init_done <= '0;
    end else if (init) begin // sending command for boot sel
      tx_en     <= 1;
      w_byte    <= spi_cmd;
      init_done <= 1'b1;
    end
    else if (!prog || (!tx_en && tx_ready && (BOOT_MODE=="ICCM" || BOOT_MODE=="FLASH"))) begin
      if (index < 1) begin
        tx_en  <= 1;
      end else begin
        tx_en  <= 1 & !prog_done;
      end
      w_byte <= prog_image[index];
      index  <= index + 1;
    end else
      tx_en  <= 0;
  end

  assign soc_uart_tx_to_rx = uart_tx[3];
`ifndef NETLIST
  uart_rx u_uart_capture (
`else
  tb_uart u_uart_capture (
`endif
    .clk_i        (     clk_i ),
    .rst_ni       ( u_azadi_soc_top.sys_rst ),

    .i_Rx_Serial  ( soc_uart_tx_to_rx ),
    
    .CLKS_PER_BIT (     'd217 ),
    .sbit_o       (           ),
    .o_Rx_DV      (   o_Rx_DV ),
    .o_Rx_Byte    ( o_Rx_Byte )
  );

  always @ (negedge o_Rx_DV) begin
    rx_msg = {rx_msg[199:0], o_Rx_Byte};
    $write("%s", o_Rx_Byte);
    if (o_Rx_Byte == 67)
      rx_done <= 1;
  end

endmodule
