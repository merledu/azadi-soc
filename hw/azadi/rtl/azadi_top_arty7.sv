
module azadi_top_arty7(

  input  clk_i,
  input  rst_ni,


  input  IO1, // tck
  input  IO2, // tms
  input  IO3, // tdi
  input  IO4, // trst
  output IO5, // tdo
  inout  IO6, // gpio0
  inout  IO7, // gpio1
  inout  IO8, // gpio2
  inout  IO9, // gpio3
  inout  IO10,// gpio4
  inout  IO11,// gpio5
  inout  IO12,// gpio6
  inout  IO13,// gpio7
  inout  IO14,// gpio8
  inout  IO15,// gpio9
  inout  IO16,// gpio10
  inout  IO17,// gpio11
  inout  IO18,// gpio12
  inout  IO19,// gpio13
  inout  IO20,// gpio14
  inout  IO22,// gpio15
  inout  IO23,// gpio16
  inout  IO24,// gpio17
  inout  IO25,// gpio18
  inout  IO26,// gpio19
  inout  IO27,// gpio20
  inout  IO28,// gpio21
  inout  IO29,// gpio22
  inout  IO30,// gpio23
  inout  IO31,// gpio24
  inout  IO32,// gpio25
  inout  IO33,// gpio26
  inout  IO34,// gpio27
  inout  IO35,// gpio28
  inout  IO36,// gpio29
  inout  IO37,// gpio30
  inout  IO38,// gpio31
  input  IO39,// uart_rx
  output IO40,// uart_tx
  input  IO41,// sd_i
  output IO42,// sd_o
  output IO43,// sck
  output IO44,// ss_0
  output IO45,// ss_1
  output IO46,// ss_2
  output IO47,// ss_3
  output IO48,// pwm1
  output IO49,// pwm2
  input  IO50,// I2C0_scl_i
  output IO51,// I2C0_scl_o
  input  IO52,// I2C0_sda_i
  output IO53 // I2C0_sda_o
  
);

endmodule