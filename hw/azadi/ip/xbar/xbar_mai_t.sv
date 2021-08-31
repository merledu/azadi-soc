// Copyright lowRISC contributors.


module xbar_main_t (
  input clk_main_i,
  input rst_main_ni,


  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_brqif_i,
  output tlul_pkg::tl_d2h_t tl_brqif_o,
  input  tlul_pkg::tl_h2d_t tl_brqlsu_i,
  output tlul_pkg::tl_d2h_t tl_brqlsu_o,
  input  tlul_pkg::tl_h2d_t tl_dm_sba_i,
  output tlul_pkg::tl_d2h_t tl_dm_sba_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_iccm_o,
  input  tlul_pkg::tl_d2h_t tl_iccm_i,
  output tlul_pkg::tl_h2d_t tl_debug_rom_o,
  input  tlul_pkg::tl_d2h_t tl_debug_rom_i,
  output tlul_pkg::tl_h2d_t tl_dccm_o,
  input  tlul_pkg::tl_d2h_t tl_dccm_i,
  output tlul_pkg::tl_h2d_t tl_flash_ctrl_o,
  input  tlul_pkg::tl_d2h_t tl_flash_ctrl_i,
  output tlul_pkg::tl_h2d_t tl_timer0_o,
  input  tlul_pkg::tl_d2h_t tl_timer0_i,
  output tlul_pkg::tl_h2d_t tl_timer1_o,
  input  tlul_pkg::tl_d2h_t tl_timer1_i,
  output tlul_pkg::tl_h2d_t tl_timer2_o,
  input  tlul_pkg::tl_d2h_t tl_timer2_i,
  output tlul_pkg::tl_h2d_t tl_timer3_o,
  input  tlul_pkg::tl_d2h_t tl_timer3_i,
  output tlul_pkg::tl_h2d_t tl_timer4_o,
  input  tlul_pkg::tl_d2h_t tl_timer4_i,
  output tlul_pkg::tl_h2d_t tl_plic_o,
  input  tlul_pkg::tl_d2h_t tl_plic_i,
  output tlul_pkg::tl_h2d_t tl_xbar_peri_o,
  input  tlul_pkg::tl_d2h_t tl_xbar_peri_i,

  input scanmode_i
);

  import tlul_pkg::*;
  import tl_main_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = scanmode_i;

  tlul_pkg::tl_h2d_t brqifu_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_brqifu;
  logic [1:0] device_sel_h1;

  assign brqifu_to_s1n = tl_brqif_i;
  assign tl_brqif_o    = s1n_to_brqifu; 

  // host 1 socket connections
  tlul_pkg::tl_h2d_t s1n_to_dv[2];
  tlul_pkg::tl_d2h_t dv_to_s1n[2];

  // host 1 device connections
  // ICCM
  assign tl_iccm_o    = s1n_to_dv[0];
  assign dv_to_s1n[0] = tl_iccm_i;

  // DEBUG_ROM
  assign dv_to_s1n[1]   = tl_debug_rom_i;
  assign tl_debug_rom_o = s1n_to_dv[1];

  //FLASH CONTROLLER
//  assign dv_to_s1n[2]    = tl_flash_ctrl_i;
//  assign tl_flash_ctrl_o = s1n_to_dv[2];

  // host 2 socket connections

  tlul_pkg::tl_h2d_t brqlsu_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_brqlsu;

  assign brqlsu_to_s1n =  tl_brqlsu_i;
  assign tl_brqlsu_o   = s1n_to_brqlsu;
  logic [3:0] device_sel_h2;

  // host 2 devices and connections
  tlul_pkg::tl_h2d_t h2_s1n_sm1[9];
  tlul_pkg::tl_d2h_t sm1_s1n_h2[9]; // to be connected with 

  // host 3 connections
  tlul_pkg::tl_h2d_t dm_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_dm;
  logic [3:0] device_sel_h3;

  assign dm_to_s1n   = tl_dm_sba_i;
  assign tl_dm_sba_o = s1n_to_dm;

  // host 3 devices and connection
  tlul_pkg::tl_h2d_t h3_s1n_sm1[9];
  tlul_pkg::tl_d2h_t sm1_s1n_h3[9];

  // socket mx1 1 connections
  tlul_pkg::tl_h2d_t socket_m1_0_i[2];
  tlul_pkg::tl_d2h_t socket_m1_0_o[2];

  // device 1 connections
  assign socket_m1_0_i[0] = h2_s1n_sm1[0]; 
  assign socket_m1_0_i[1] = h3_s1n_sm1[0];
  assign sm1_s1n_h2[0]    = socket_m1_0_o[0];
  assign sm1_s1n_h3[0]    = socket_m1_0_o[1];

  tlul_pkg::tl_h2d_t socket_m1_1_i[2];
  tlul_pkg::tl_d2h_t socket_m1_1_o[2];
 
  // device 2 connections
  assign socket_m1_1_i[0] = h2_s1n_sm1[1];
  assign socket_m1_1_i[1] = h3_s1n_sm1[1];
  assign sm1_s1n_h2[1]    = socket_m1_1_o[0];
  assign sm1_s1n_h3[1]    = socket_m1_1_o[1];

  tlul_pkg::tl_h2d_t socket_m1_2_i[2];
  tlul_pkg::tl_d2h_t socket_m1_2_o[2];

  // device 3 connections
  assign socket_m1_2_i[0]  = h2_s1n_sm1[2];
  assign socket_m1_2_i[1]  = h3_s1n_sm1[2];
  assign sm1_s1n_h2[2]     = socket_m1_2_o[0];
  assign sm1_s1n_h3[2]     = socket_m1_2_o[1];

  tlul_pkg::tl_h2d_t socket_m1_3_i[2];
  tlul_pkg::tl_d2h_t socket_m1_3_o[2];

  // device 4 connections
  assign socket_m1_3_i[0]  = h2_s1n_sm1[3];
  assign socket_m1_3_i[1]  = h3_s1n_sm1[3];
  assign sm1_s1n_h2[3]     = socket_m1_3_o[0];
  assign sm1_s1n_h3[3]     = socket_m1_3_o[1];

  tlul_pkg::tl_h2d_t socket_m1_4_i[2];
  tlul_pkg::tl_d2h_t socket_m1_4_o[2];

  // device 5 connections
  assign socket_m1_4_i[0]  = h2_s1n_sm1[4];
  assign socket_m1_4_i[1]  = h3_s1n_sm1[4];
  assign sm1_s1n_h2[4]     = socket_m1_4_o[0];
  assign sm1_s1n_h3[4]     = socket_m1_4_o[1];

  tlul_pkg::tl_h2d_t socket_m1_5_i[2];
  tlul_pkg::tl_d2h_t socket_m1_5_o[2];

  // device 6 connections
  assign socket_m1_5_i[0]  = h2_s1n_sm1[5];
  assign socket_m1_5_i[1]  = h3_s1n_sm1[5];
  assign sm1_s1n_h2[5]     = socket_m1_5_o[0];
  assign sm1_s1n_h3[5]     = socket_m1_5_o[1];

  tlul_pkg::tl_h2d_t socket_m1_6_i[2];
  tlul_pkg::tl_d2h_t socket_m1_6_o[2];

  // device 7 connections
  assign socket_m1_6_i[0]  = h2_s1n_sm1[6];
  assign socket_m1_6_i[1]  = h3_s1n_sm1[6];
  assign sm1_s1n_h2[6]     = socket_m1_6_o[0];
  assign sm1_s1n_h3[6]     = socket_m1_6_o[1];

  tlul_pkg::tl_h2d_t socket_m1_7_i[2];
  tlul_pkg::tl_d2h_t socket_m1_7_o[2];

  // device 8 connections
  assign socket_m1_7_i[0]  = h2_s1n_sm1[7];
  assign socket_m1_7_i[1]  = h3_s1n_sm1[7];
  assign sm1_s1n_h2[7]     = socket_m1_7_o[0];
  assign sm1_s1n_h3[7]     = socket_m1_7_o[1];

  tlul_pkg::tl_h2d_t socket_m1_8_i[2];
  tlul_pkg::tl_d2h_t socket_m1_8_o[2];

  // device 9 connections
  assign socket_m1_8_i[0]  = h2_s1n_sm1[8];
  assign socket_m1_8_i[1]  = h3_s1n_sm1[8];
  assign sm1_s1n_h2[8]     = socket_m1_8_o[0];
  assign sm1_s1n_h3[8]     = socket_m1_8_o[1];

  // host 1 address decoding and device selection
  always_comb begin
    
    device_sel_h1 = 2'd3;
    if((brqifu_to_s1n.a_address & ~(ADDR_MASK_ICCM)) == ADDR_SPACE_ICCM) begin
      device_sel_h1 = 2'd0;
    end else if ((brqifu_to_s1n.a_address & ~(ADDR_MASK_DEBUG_ROM)) == ADDR_SPACE_DEBUG_ROM) begin
      device_sel_h1 = 2'd1;
   // end else if ((brqifu_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
   //   device_sel_h1 = 2'd2;
    end
      
  end
  // host 1 device switching socket
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (12'h0),
    .DRspDepth (12'h0),
    .N         (2)
  ) host_1 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (brqifu_to_s1n),
    .tl_h_o       (s1n_to_brqifu),
    .tl_d_o       (s1n_to_dv),
    .tl_d_i       (dv_to_s1n),
    .dev_select_i (device_sel_h1)
  );

  // host 2 address decoding and device selection
  always_comb begin
      device_sel_h2 = 4'd9;

    if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
      device_sel_h2 = 4'd0;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
      device_sel_h2 = 4'd1;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER0)) == ADDR_SPACE_TIMER0) begin
      device_sel_h2 = 4'd2;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER1)) == ADDR_SPACE_TIMER1) begin
      device_sel_h2 = 4'd3;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER2)) == ADDR_SPACE_TIMER2) begin
      device_sel_h2 = 4'd4;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER3)) == ADDR_SPACE_TIMER3) begin
      device_sel_h2 = 4'd5;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER4)) == ADDR_SPACE_TIMER4) begin
      device_sel_h2 = 4'd6;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_PLIC)) == ADDR_SPACE_PLIC) begin
      device_sel_h2 = 4'd7; 
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_XBAR_PERI)) >= ADDR_SPACE_XBAR_PERI) begin
      device_sel_h2 = 4'd8;
    end
  end

// host 1 device socket

  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (9)
  ) host_2 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (brqlsu_to_s1n),
    .tl_h_o       (s1n_to_brqlsu),
    .tl_d_o       (h2_s1n_sm1),
    .tl_d_i       (sm1_s1n_h2),
    .dev_select_i (device_sel_h2)
  );


  // host 3 address decoding and device selection 
  always_comb begin
      device_sel_h3 = 4'd9;

    if ((dm_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
      device_sel_h3 = 4'd0;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
      device_sel_h3 = 4'd1;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_TIMER0)) == ADDR_SPACE_TIMER0) begin
      device_sel_h3 = 4'd2;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_TIMER1)) == ADDR_SPACE_TIMER1) begin
      device_sel_h3 = 4'd3;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_TIMER2)) == ADDR_SPACE_TIMER2) begin
      device_sel_h3 = 4'd4;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_TIMER3)) == ADDR_SPACE_TIMER3) begin
      device_sel_h3 = 4'd5;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_TIMER4)) == ADDR_SPACE_TIMER4) begin
      device_sel_h3 = 4'd6;
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_PLIC)) == ADDR_SPACE_PLIC) begin
      device_sel_h3 = 4'd7; 
    end else if ((dm_to_s1n.a_address & ~(ADDR_MASK_XBAR_PERI)) >= ADDR_SPACE_XBAR_PERI) begin
      device_sel_h3 = 4'd8;
    end
  end

// host 3 device socket
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (9)
  ) host_3 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (dm_to_s1n),
    .tl_h_o       (s1n_to_dm),
    .tl_d_o       (h3_s1n_sm1),
    .tl_d_i       (sm1_s1n_h3),
    .dev_select_i (device_sel_h3)
  );

// H2             H3
//  |              |
// ===            ===
//  |              |
// ___________________
// |                 |
// |    priority     |
// |    arbitter     |
// |_________________|
//          |
//         ===
//          |
//         Dv1

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) DCCM (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_0_i),
    .tl_h_o       (socket_m1_0_o),
    .tl_d_o       (tl_dccm_o),
    .tl_d_i       (tl_dccm_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) FLASH_CTRL (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_1_i),
    .tl_h_o       (socket_m1_1_o),
    .tl_d_o       (tl_flash_ctrl_o),
    .tl_d_i       (tl_flash_ctrl_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) TIMER_0 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_2_i),
    .tl_h_o       (socket_m1_2_o),
    .tl_d_o       (tl_timer0_o),
    .tl_d_i       (tl_timer0_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) TIMER_1 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_3_i),
    .tl_h_o       (socket_m1_3_o),
    .tl_d_o       (tl_timer1_o),
    .tl_d_i       (tl_timer1_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) TIMER_2 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_4_i),
    .tl_h_o       (socket_m1_4_o),
    .tl_d_o       (tl_timer2_o),
    .tl_d_i       (tl_timer2_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) TIMER_3 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_5_i),
    .tl_h_o       (socket_m1_5_o),
    .tl_d_o       (tl_timer3_o),
    .tl_d_i       (tl_timer3_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) TIMER_4 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_6_i),
    .tl_h_o       (socket_m1_6_o),
    .tl_d_o       (tl_timer4_o),
    .tl_d_i       (tl_timer4_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) PLIC (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_7_i),
    .tl_h_o       (socket_m1_7_o),
    .tl_d_o       (tl_plic_o),
    .tl_d_i       (tl_plic_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) XBAR_PERI (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (socket_m1_8_i),
    .tl_h_o       (socket_m1_8_o),
    .tl_d_o       (tl_xbar_peri_o),
    .tl_d_i       (tl_xbar_peri_i)
  );



endmodule
