
// main XBAR 

module tl_xbar_main (

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


// host 1 IFU
  tlul_pkg::tl_h2d_t brqifu_to_s1n; 
  tlul_pkg::tl_d2h_t s1n_to_brqifu;
  logic [2:0] device_sel_1;

// host 2 LSU
  tlul_pkg::tl_h2d_t brqlsu_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_brqlsu;
  logic [3:0] device_sel_2;

// host 3 debug system bus access
  tlul_pkg::tl_h2d_t dbg_to_s1n;
  tlul_pkg::tl_d2h_t s1n_to_dbg;
  logic [3:0] device_sel_3;

// Dveice connections

  tlul_pkg::tl_h2d_t  h1_dv_i[3];
  tlul_pkg::tl_d2h_t  h1_dv_o[3];
  tlul_pkg::tl_h2d_t  h2_dv_i[11];
  tlul_pkg::tl_d2h_t  h2_dv_o[11];
  tlul_pkg::tl_h2d_t  h3_dv_i[10];
  tlul_pkg::tl_d2h_t  h3_dv_o[10];

// ICCM
  tlul_pkg::tl_h2d_t s1n_sm1_1[3];
  tlul_pkg::tl_d2h_t sm1_s1n_1[3];

// DCCM
  tlul_pkg::tl_h2d_t s1n_sm1_2[2];
  tlul_pkg::tl_d2h_t sm1_s1n_2[2];

// FLASH CTRL
  tlul_pkg::tl_h2d_t s1n_sm1_3[3];
  tlul_pkg::tl_d2h_t sm1_s1n_3[3];

// DEBUG ROM
  tlul_pkg::tl_h2d_t s1n_sm1_4[2];
  tlul_pkg::tl_d2h_t sm1_s1n_4[2];

// TIMER 1
  tlul_pkg::tl_h2d_t s1n_sm1_5[2];
  tlul_pkg::tl_d2h_t sm1_s1n_5[2];

// TIMER 2
  tlul_pkg::tl_h2d_t s1n_sm1_6[2];
  tlul_pkg::tl_d2h_t sm1_s1n_6[2];

// TIMER 3
  tlul_pkg::tl_h2d_t s1n_sm1_7[2];
  tlul_pkg::tl_d2h_t sm1_s1n_7[2];

// TIMER 4
  tlul_pkg::tl_h2d_t s1n_sm1_8[2];
  tlul_pkg::tl_d2h_t sm1_s1n_8[2];

// TIMER 5
  tlul_pkg::tl_h2d_t s1n_sm1_9[2];
  tlul_pkg::tl_d2h_t sm1_s1n_9[2];

// PLIC
  tlul_pkg::tl_h2d_t s1n_sm1_10[2];
  tlul_pkg::tl_d2h_t sm1_s1n_10[2];

// XBAR PERI
  tlul_pkg::tl_h2d_t s1n_sm1_11[2];
  tlul_pkg::tl_d2h_t sm1_s1n_11[2];


// Device 1 host connections (ICCM)
  assign h1_dv_o[0]   = sm1_s1n_1[0];
  assign h3_dv_o[2]   = sm1_s1n_1[1];
  assign h2_dv_o[10]  = sm1_s1n_1[2];
  assign s1n_sm1_1[0] = h1_dv_i[0];
  assign s1n_sm1_1[1] = h3_dv_i[2];
  assign s1n_sm1_1[2] = h2_dv_i[10];

// Device 2 host connections (DCCM)
  assign h2_dv_o[0] = sm1_s1n_2[0];
  assign h3_dv_o[0] = sm1_s1n_2[1];
  assign s1n_sm1_2[0] = h2_dv_i[0];
  assign s1n_sm1_2[1] = h3_dv_i[0];

// Device 3 host connections (FLASH CTRL)
  assign h1_dv_o[1] = sm1_s1n_3[0];
  assign h2_dv_o[1] = sm1_s1n_3[1];
  assign h3_dv_o[1] = sm1_s1n_3[2];
  assign s1n_sm1_3[0]       = h1_dv_i[1];
  assign s1n_sm1_3[1]       = h2_dv_i[1];
  assign s1n_sm1_3[2]       = h3_dv_i[1];

// Device 4 host connections (DEBUG ROM)
  assign h1_dv_o[2] = sm1_s1n_4[0];
  assign h2_dv_o[2] = sm1_s1n_4[1];
  assign s1n_sm1_4[0]    = h1_dv_i[2];
  assign s1n_sm1_4[1]    = h2_dv_i[2];

// Device 5 host connections
  assign h2_dv_o[3] = sm1_s1n_5[0];
  assign h3_dv_o[3] = sm1_s1n_5[1];
  assign s1n_sm1_5[0]   = h2_dv_i[3];
  assign s1n_sm1_5[1]   = h3_dv_i[3];

// Device 6 host connections
  assign h2_dv_o[4] = sm1_s1n_6[0];
  assign h3_dv_o[4] = sm1_s1n_6[1];
  assign s1n_sm1_6[0]   = h2_dv_i[4];
  assign s1n_sm1_6[1]   = h3_dv_i[4];

// Device 7 host connections
  assign h2_dv_o[5] = sm1_s1n_7[0];
  assign h3_dv_o[5] = sm1_s1n_7[1];
  assign s1n_sm1_7[0]   = h2_dv_i[5];
  assign s1n_sm1_7[1]   = h3_dv_i[5];

// Device 8 host connections
  assign h2_dv_o[6] = sm1_s1n_8[0];
  assign h3_dv_o[6] = sm1_s1n_8[1];
  assign s1n_sm1_8[0]   = h2_dv_i[6];
  assign s1n_sm1_8[1]   = h3_dv_i[6];

// Device 9 host connections
  assign h2_dv_o[7] = sm1_s1n_9[0];
  assign h3_dv_o[7] = sm1_s1n_9[1];
  assign s1n_sm1_9[0]   = h2_dv_i[7];
  assign s1n_sm1_9[1]   = h3_dv_i[7];

// Device 10 host connections
  assign h2_dv_o[8] = sm1_s1n_10[0];
  assign h3_dv_o[8] = sm1_s1n_10[1];
  assign s1n_sm1_10[0]   = h2_dv_i[8];
  assign s1n_sm1_10[1]   = h3_dv_i[8];

// Device 11 host connections
  assign h2_dv_o[9] = sm1_s1n_11[0];
  assign h3_dv_o[9] = sm1_s1n_11[1];
  assign s1n_sm1_11[0]     = h2_dv_i[9];
  assign s1n_sm1_11[1]     = h3_dv_i[9];

// hostv 1 connections
  assign brqifu_to_s1n  = tl_brqif_i;
  assign tl_brqif_o     = s1n_to_brqifu;
// hostv 2 connections
  assign brqlsu_to_s1n  = tl_brqlsu_i;
  assign tl_brqlsu_o    = s1n_to_brqlsu;
// host 3 connections
  assign dbg_to_s1n     = tl_dm_sba_i;
  assign tl_dm_sba_o    = s1n_to_dbg;

// host 1 device selection
  always_comb begin 
      device_sel_1 = 3'd3;
    if((brqifu_to_s1n.a_address & ~(ADDR_MASK_ICCM)) == ADDR_SPACE_ICCM) begin
      device_sel_1 = 3'd0;
    end else if ((brqifu_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
      device_sel_1 = 3'd1;
    end else if ((brqifu_to_s1n.a_address & ~(ADDR_MASK_DEBUG_ROM)) == ADDR_SPACE_DEBUG_ROM) begin
      device_sel_1 = 3'd2;
    end
  end

// host 1 socket 
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (12'h0),
    .DRspDepth (12'h0),
    .N         (3)
  ) host_1 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (brqifu_to_s1n),
    .tl_h_o       (s1n_to_brqifu),
    .tl_d_o       (h1_dv_i),
    .tl_d_i       (h1_dv_o),
    .dev_select_i (device_sel_1)
  );

// host 2 socket
  always_comb begin 
    
     device_sel_2 = 4'd15;

    if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
     device_sel_2 = 4'd0; 
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
      device_sel_2 = 4'd1;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_DEBUG_ROM)) == ADDR_SPACE_DEBUG_ROM) begin
      device_sel_2 = 4'd2;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER0)) == ADDR_SPACE_TIMER0) begin
      device_sel_2 = 4'd3;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER1)) == ADDR_SPACE_TIMER1) begin
      device_sel_2 = 4'd4;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER2)) == ADDR_SPACE_TIMER2) begin
      device_sel_2 = 4'd5;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER3)) == ADDR_SPACE_TIMER3) begin
      device_sel_2 = 4'd6;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER4)) == ADDR_SPACE_TIMER4) begin
      device_sel_2 = 4'd7;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_PLIC)) == ADDR_SPACE_PLIC) begin
      device_sel_2 = 4'd8;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_XBAR_PERI)) >= ADDR_SPACE_XBAR_PERI) begin
      device_sel_2 = 4'd9;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_ICCM)) == ADDR_SPACE_ICCM) begin
      device_sel_2 = 4'd10;
    end
  end

// host 2 socket

  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (11)
  ) host_2 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (brqlsu_to_s1n),
    .tl_h_o       (s1n_to_brqlsu),
    .tl_d_o       (h2_dv_i),
    .tl_d_i       (h2_dv_o),
    .dev_select_i (device_sel_2)
  );

// host 3 device selection

  always_comb begin 
    
     device_sel_3 = 4'd15;

    if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_DCCM)) == ADDR_SPACE_DCCM) begin
     device_sel_3 = 4'd0; 
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_FLASH_CTRL)) == ADDR_SPACE_FLASH_CTRL) begin
      device_sel_3 = 4'd1;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_ICCM)) == ADDR_SPACE_ICCM) begin
      device_sel_3 = 4'd2;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER0)) == ADDR_SPACE_TIMER0) begin
      device_sel_3 = 4'd3;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER1)) == ADDR_SPACE_TIMER1) begin
      device_sel_3 = 4'd4;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER2)) == ADDR_SPACE_TIMER2) begin
      device_sel_3 = 4'd5;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER3)) == ADDR_SPACE_TIMER3) begin
      device_sel_3 = 4'd6;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_TIMER4)) == ADDR_SPACE_TIMER4) begin
      device_sel_3 = 4'd7;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_PLIC)) == ADDR_SPACE_PLIC) begin
      device_sel_3 = 4'd8;
    end else if ((brqlsu_to_s1n.a_address & ~(ADDR_MASK_XBAR_PERI)) >= ADDR_SPACE_XBAR_PERI) begin
      device_sel_3 = 4'd9;
    end
  end

  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (36'h0),
    .DRspDepth (36'h0),
    .N         (10)
  ) host_3 (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (dbg_to_s1n),
    .tl_h_o       (s1n_to_dbg),
    .tl_d_o       (h3_dv_i),
    .tl_d_i       (h3_dv_o),
    .dev_select_i (device_sel_3)
  );


// Devices
  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (3)
  ) ICCM (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (s1n_sm1_1),
    .tl_h_o       (sm1_s1n_1),
    .tl_d_o       (tl_iccm_o),
    .tl_d_i       (tl_iccm_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) DCCM (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (s1n_sm1_2),
    .tl_h_o       (sm1_s1n_2),
    .tl_d_o       (tl_dccm_o),
    .tl_d_i       (tl_dccm_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (3)
  ) FLASH_CTRL (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (s1n_sm1_3),
    .tl_h_o       (sm1_s1n_3),
    .tl_d_o       (tl_flash_ctrl_o),
    .tl_d_i       (tl_flash_ctrl_i)
  );

  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) DEBUG_ROM (
    .clk_i        (clk_main_i),
    .rst_ni       (rst_main_ni),
    .tl_h_i       (s1n_sm1_4),
    .tl_h_o       (sm1_s1n_4),
    .tl_d_o       (tl_debug_rom_o),
    .tl_d_i       (tl_debug_rom_i)
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
    .tl_h_i       (s1n_sm1_5),
    .tl_h_o       (sm1_s1n_5),
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
    .tl_h_i       (s1n_sm1_6),
    .tl_h_o       (sm1_s1n_6),
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
    .tl_h_i       (s1n_sm1_7),
    .tl_h_o       (sm1_s1n_7),
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
    .tl_h_i       (s1n_sm1_8),
    .tl_h_o       (sm1_s1n_8),
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
    .tl_h_i       (s1n_sm1_9),
    .tl_h_o       (sm1_s1n_9),
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
    .tl_h_i       (s1n_sm1_10),
    .tl_h_o       (sm1_s1n_10),
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
    .tl_h_i       (s1n_sm1_11),
    .tl_h_o       (sm1_s1n_11),
    .tl_d_o       (tl_xbar_peri_o),
    .tl_d_i       (tl_xbar_peri_i)
  );


endmodule