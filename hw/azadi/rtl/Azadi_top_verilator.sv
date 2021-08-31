 
module Azadi_top_verilator #(
  parameter  logic DirectDmiTap = 1'b1
)(
  input clock,
  input reset_ni,

  input  logic [19:0] gpio_i,
  output logic [19:0] gpio_o,

  input               uart_rx,
  output              uart_tx
);


  logic pwm_o;
  logic pwm_o_2;

  logic [`SPI_SS_NB-1:0] ss_o;        
  logic                  sclk_o;      
  logic                  sd_o;       
  logic                  sd_i; 

//logic clock; // output clock after dividing the input clock by divisor
//reg[27:0] counter=28'd0;
//parameter DIVISOR = 28'd6000;
//// The frequency of the output clk_out
////  = The frequency of the input clk_in divided by DIVISOR
//// For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
//// You will modify the DIVISOR parameter value to 28'd50.000.000
//// Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
//always @(posedge clock_i) begin
// counter <= counter + 28'd1;
// if(counter>=(DIVISOR-1))
//  counter <= 28'd0;
//
// clock <= (counter<DIVISOR/2)?1'b1:1'b0;
//end

//  clock <= (counter<DIVISOR/2)?1'b1:1'b0;
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
    

  azadi_soc_top #(
    .JTAG_ID(JTAG_IDCODE),
    .DirectDmiTap (DirectDmiTap)
  ) top_verilator(
    .clock(clock_i),
    .reset_ni(reset_ni),  
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
    
    .i2c0_scl_in(i2c0_scl_in),   
    .i2c0_scl_out(i2c0_scl_out), 
    .i2c0_sda_in(i2c0_sda_in),   
    .i2c0_sda_out(i2c0_sda_out), 
  
  // jtag interface 
    .jtag_tck_i(cio_jtag_tck),
    .jtag_tms_i(cio_jtag_tms),
    .jtag_trst_ni(cio_jtag_trst_n),
    .jtag_tdi_i(cio_jtag_tdi),
    .jtag_tdo_o(cio_jtag_tdo),

    .uart_rx_i(uart_rx_i),

  // spi interface 
    .ss_o        (ss_o),         
    .sclk_o      (sclk_o),       
    .sd_o        (sd_o),       
    .sd_i        (sd_i)
  );


   //if(DirectDmiTap) begin
   //   bind rv_dm dmidpi u_dmidpi (
   //   .clk_i(clock),
   //   .rst_ni(reset_ni),
   //   .dmi_req_valid,
   //   .dmi_req_ready,
   //   .dmi_req_addr   (dmi_req.addr),
   //   .dmi_req_op     (dmi_req.op),
   //   .dmi_req_data   (dmi_req.data),
   //   .dmi_rsp_valid,
   //   .dmi_rsp_ready,
   //   .dmi_rsp_data   (dmi_rsp.data),
   //   .dmi_rsp_resp   (dmi_rsp.resp),
   //   .dmi_rst_n      (dmi_rst_n)
   // );
   //end else begin
     // jtag dpi for openocd
    jtagdpi u_jtagdpi (
      .clk_i(clock_i),
      .rst_ni(reset_ni),
      .jtag_tck    (cio_jtag_tck),
      .jtag_tms    (cio_jtag_tms),
      .jtag_tdi    (cio_jtag_tdi),
      .jtag_tdo    (cio_jtag_tdo),
      .jtag_trst_n (cio_jtag_trst_n),
      .jtag_srst_n (cio_jtag_srst_n)
    );

  // end


endmodule