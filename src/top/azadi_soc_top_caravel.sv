// SPDX-FileCopyrightText: 2020 Efabless Corporation
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 
// SPDX-License-Identifier: Apache-2.0
   
// Designed by a Team at Micro Electronics Research Lab, Usman Institute of Technology.
// https://www.merledupk.org
`default_nettype wire
`define MPRJ_IO_PADS 38
module azadi_soc_top_caravel (
  `ifdef USE_POWER_PINS
      inout vdda1,	// User area 1 3.3V supply
      inout vdda2,	// User area 2 3.3V supply
      inout vssa1,	// User area 1 analog ground
      inout vssa2,	// User area 2 analog ground
      inout vccd1,	// User area 1 1.8V supply
      inout vccd2,	// User area 2 1.8v supply
      inout vssd1,	// User area 1 digital ground
      inout vssd2,	// User area 2 digital ground
  `endif

    // Wishbone Slave ports (WB MI A)
    input         wb_clk_i,
    input         wb_rst_i,
    input         wbs_stb_i,
    input         wbs_cyc_i,
    input         wbs_we_i,
    input [3:0]   wbs_sel_i,
    input [31:0]  wbs_dat_i,
    input [31:0]  wbs_adr_i,
    output        wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs, MPRJ_IO_PADS = 38
    input  [`MPRJ_IO_PADS-1:0] io_in,  
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

  wire clk_i;  
  wire rst_ni; 
  wire prog;
  
  // Clocks per bit
  wire [15:0] clks_per_bit;  

  // gpios interface
  wire [31:0] gpio_i;
  wire [31:0] gpio_o;
  wire [31:0] gpio_oe;

  // jtag interface 
  wire jtag_tck;   
  wire jtag_tms;   
  wire jtag_trst; 
  wire jtag_tdi;   
  wire jtag_tdo;   
  wire jtag_tdo_oe;

  // uart-periph interface
  wire uart_tx;
  wire uart_rx;

  // PWM interface  
  wire pwm_o_1;
  wire pwm_o_2;
  wire pwm1_oe;
  wire pwm2_oe;

  // SPI interface
  wire [3:0] ss_o;        
  wire       sclk_o;      
  wire       sd_o;
  wire       sd_oe;       
  wire       sd_i;

  // Note: Output enable is active low for IO pads
  assign io_oeb[0]    =  ~jtag_tdo_oe;
  assign jtag_tdi     =   io_in[0];
  assign io_out[0]    =   jtag_tdo;

  // SPI 0
  assign io_oeb[1]     = ~(sd_oe | gpio_oe[30]);
  assign io_out[1]     =  sd_oe ? sd_o : gpio_o[30];
  assign gpio_i[30]    =  io_in[1];

  assign io_oeb[2]     =  1'b1;
  assign io_out[2]     =  1'b0; 
  assign sd_i          =  io_in[2];

  assign io_oeb[3]     = ~(sd_oe | gpio_oe[31]);
  assign io_out[3]     =  sd_oe ? ss_o[0] : gpio_o[31];
  assign gpio_i[31]    =  io_in[3];

  assign io_oeb[4]     =  1'b0;
  assign io_out[4]     =  sclk_o;

  // UART 
  assign io_oeb[5]     =  1'b1;
  assign io_out[2]     =  1'b0;
  assign uart_rx       =  io_in[5];

  assign io_oeb[6]     =  1'b0;
  assign io_out[6]     =  uart_tx;
    
  // Programming Button 
  assign io_oeb[7]     =  1'b1;
  assign io_out[2]     =  1'b0;
  assign prog          =  io_in[7];

  // GPIO 0-18
  assign io_oeb[25:8]  = ~gpio_oe[17:0];
  assign gpio_i[17:0]  =  io_in  [25:8];
  assign io_out[25:8]  =  gpio_o [17:0];
  assign gpio_i[18]    = 1'b0;
  // GPIO 19-21, SPI SS
  assign io_oeb[27]    = ~(sd_oe | gpio_oe[19]);
  assign io_out[27]    =  sd_oe ?  ss_o[1] :  gpio_o [19];  // SPI slave sel[1]
  assign gpio_i[19]    =  io_in[27];

  assign io_oeb[28]    = ~(sd_oe | gpio_oe[20]);
  assign io_out[28]    =  sd_oe ?  ss_o[2] :  gpio_o [20];  // SPI slave sel[2]
  assign gpio_i[20]    =  io_in[28];

  assign io_oeb[29]    = ~(sd_oe | gpio_oe[21]);
  assign io_out[29]    =  sd_oe ?  ss_o[3] :  gpio_o [21];  // SPI slave sel[3]
  assign gpio_i[21]    =  io_in[29];

  // GPIO 22-24, JTAG in
  assign io_oeb[30]    =  ~gpio_oe[22];
  assign io_out[30]    =   gpio_o [22];  
  assign gpio_i[22]    =   io_in[30];
  assign jtag_tck      =   io_in[30];  // JTAG TCK

  assign io_oeb[31]    =  ~gpio_oe[23];
  assign io_out[31]    =   gpio_o [23];  
  assign gpio_i[23]    =   io_in[31];
  assign jtag_tms      =   io_in[31];  // JTAG TMS

  assign io_oeb[32]    =  ~gpio_oe[24];
  assign io_out[32]    =   gpio_o [24];  
  assign gpio_i[24]    =   io_in[32];
  assign jtag_trst     =   io_in[32];  // JTAG TRST
  
  // GPIO 25-26, PWM 1, 2
  assign io_oeb[33]     = ~(pwm1_oe | gpio_oe[25]);  // PWM1 
  assign io_out[33]     =   pwm1_oe ?  pwm_o_1 : gpio_o [25];
  assign gpio_i[25]     =   io_in[33];

  assign io_oeb[34]     = ~(pwm2_oe | gpio_oe[26]);  // PWM2 
  assign io_out[34]     =  pwm2_oe  ?  pwm_o_2 :  gpio_o [26];
  assign gpio_i[26]     =  io_in[34];

  // GPIO 27-29
  assign io_oeb[37:35]  = ~gpio_oe[29:27];
  assign gpio_i[29:27]  =  io_in  [37:35];
  assign io_out[37:35]  =  gpio_o [29:27];

  // Logic Analyzer ports
  assign clks_per_bit  = la_data_in[15:0];

  azadi_soc_top soc_top(
  `ifdef USE_POWER_PINS
    .VPWR(vccd1),
    .VGND(vssd1),
  `endif
    .clk_i(wb_clk_i),
    .rst_ni(~wb_rst_i),
    .prog(prog),

    // Clocks per bits
    .clks_per_bit(clks_per_bit), 

    // gpios interface
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_oe(gpio_oe),

    // jtag interface 
   /* .jtag_tck_i(jtag_tck),
    .jtag_tms_i(jtag_tms),
    .jtag_trst_ni(jtag_trst),
    .jtag_tdi_i(jtag_tdi),
    .jtag_tdo_o(jtag_tdo),
    .jtag_tdo_oe_o(jtag_tdo_oe),*/

    // uart-periph interface
    .uart_tx(uart_tx), // output
    .uart_rx(uart_rx), // input

    // PWM interface  
    .pwm_o(pwm_o_1),
    .pwm_o_2(pwm_o_2),
    .pwm1_oe(pwm1_oe),
    .pwm2_oe(pwm2_oe),

    // SPI interface
    .ss_o(ss_o),        // [3:0] 
    .sclk_o(sclk_o),      
    .sd_o(sd_o),
    .sd_oe(sd_oe),       
    .sd_i(sd_i)
  );

endmodule
