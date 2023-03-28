// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Designer  : Zeeshan Rafique <zeeshanrafique23@gmail.com>
// Date,Time : 03/10/2022, 06:50 PM

module azadi_chip_top(
  inout wire [53:0] IO_PAD
);
  logic [53:0] io_in;
  logic [53:0] io_out;
  logic [53:0] io_oeb;
  logic [53:0] io_ren;

  azadi_pin_top u_azadi_pin_top(
    .io_in_i  ( io_in  ),
    .io_out_o ( io_out ),
    .io_oeb_o ( io_oeb ),
    .io_ren_o ( io_ren )
  );

  /*
           PDUW16SDGZ_G [PULL-UP]                                 |           PDDW16SDGZ_G [PULL-DOWN]
  ---------------------------------------------------------------------------------------------------------------------------
                          VCC ___                                 |                    _     /|
                               |                                  |                 C |_|___/ |_________
                   _           R                                  |                         \ |    |    |
              REN |_|--------o|:                                  |                          \|    |    |
                               |                                  |                     _          |    |      _
                   _     /|    |                                  |                REN |_|-------o|:    |-----|_| PAD
                C |_|___/ |____|_____                             |                                |    |
                        \ |         |                             |                                R    |
                         \|         |      _                      |                                |    |
                                    |-----|_| PAD                 |                             G ---   |
                   _    |\          |                             |                    _    |\     -    |
                I |_|___| \_________|                             |                 I |_|___| \_________|
                        | /                                       |                         | /
                        |/o                                       |                         |/o
                   _      |                                       |                    _      |
              OEN |_|-----'                                       |               OEN |_|-----'
  ---------------------------------------------------------------------------------------------------------------------------
  */

  // GPIOs[23:0]
  /* PULL-UP  */ PDUW16SDGZ_G GPIO0     (.I(io_out[0]),  .OEN(io_oeb[0]),  .REN(io_ren[0]),  .PAD(IO_PAD[0]),  .C(io_in[0]));  // Muxed with UART_RX_0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO1     (.I(io_out[1]),  .OEN(io_oeb[1]),  .REN(io_ren[1]),  .PAD(IO_PAD[1]),  .C(io_in[1]));  // Muxed with UART_TX_0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO2     (.I(io_out[2]),  .OEN(io_oeb[2]),  .REN(io_ren[2]),  .PAD(IO_PAD[2]),  .C(io_in[2]));  // Muxed with SPI_OUT_0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO3     (.I(io_out[3]),  .OEN(io_oeb[3]),  .REN(io_ren[3]),  .PAD(IO_PAD[3]),  .C(io_in[3]));  // Muxed with SPI_IN_0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO4     (.I(io_out[4]),  .OEN(io_oeb[4]),  .REN(io_ren[4]),  .PAD(IO_PAD[4]),  .C(io_in[4]));  // Muxed with SCLK 0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO5     (.I(io_out[5]),  .OEN(io_oeb[5]),  .REN(io_ren[5]),  .PAD(IO_PAD[5]),  .C(io_in[5]));  // Muxed with CSB 0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO6     (.I(io_out[6]),  .OEN(io_oeb[6]),  .REN(io_ren[6]),  .PAD(IO_PAD[6]),  .C(io_in[6]));  // Muxed with SPI OUT 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO7     (.I(io_out[7]),  .OEN(io_oeb[7]),  .REN(io_ren[7]),  .PAD(IO_PAD[7]),  .C(io_in[7]));  // Muxed with SPI IN 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO8     (.I(io_out[8]),  .OEN(io_oeb[8]),  .REN(io_ren[8]),  .PAD(IO_PAD[8]),  .C(io_in[8]));  // Muxed with SCLK 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO9     (.I(io_out[9]),  .OEN(io_oeb[9]),  .REN(io_ren[9]),  .PAD(IO_PAD[9]),  .C(io_in[9]));  // Muxed with CSB 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO10    (.I(io_out[10]), .OEN(io_oeb[10]), .REN(io_ren[10]), .PAD(IO_PAD[10]), .C(io_in[10])); // Muxed with PWM 0 - Chan 0
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO11    (.I(io_out[11]), .OEN(io_oeb[11]), .REN(io_ren[11]), .PAD(IO_PAD[11]), .C(io_in[11])); // Muxed with PWM 0 - Chan 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO12    (.I(io_out[12]), .OEN(io_oeb[12]), .REN(io_ren[12]), .PAD(IO_PAD[12]), .C(io_in[12])); // Muxed with PWM 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO13    (.I(io_out[13]), .OEN(io_oeb[13]), .REN(io_ren[13]), .PAD(IO_PAD[13]), .C(io_in[13])); // Muxed with PWM 1
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO14    (.I(io_out[14]), .OEN(io_oeb[14]), .REN(io_ren[14]), .PAD(IO_PAD[14]), .C(io_in[14])); // Muxed with PWM 2
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO15    (.I(io_out[15]), .OEN(io_oeb[15]), .REN(io_ren[15]), .PAD(IO_PAD[15]), .C(io_in[15])); // Muxed with PWM 2
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO16    (.I(io_out[16]), .OEN(io_oeb[16]), .REN(io_ren[16]), .PAD(IO_PAD[16]), .C(io_in[16])); // Muxed with PWM 3
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO17    (.I(io_out[17]), .OEN(io_oeb[17]), .REN(io_ren[17]), .PAD(IO_PAD[17]), .C(io_in[17])); // Muxed with PWM 3
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO18    (.I(io_out[18]), .OEN(io_oeb[18]), .REN(io_ren[18]), .PAD(IO_PAD[18]), .C(io_in[18])); // Dedicated GPIO-18
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO19    (.I(io_out[19]), .OEN(io_oeb[19]), .REN(io_ren[19]), .PAD(IO_PAD[19]), .C(io_in[19])); // Dedicated GPIO-19
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO20    (.I(io_out[20]), .OEN(io_oeb[20]), .REN(io_ren[20]), .PAD(IO_PAD[20]), .C(io_in[20])); // Dedicated GPIO-20
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO21    (.I(io_out[21]), .OEN(io_oeb[21]), .REN(io_ren[21]), .PAD(IO_PAD[21]), .C(io_in[21])); // Dedicated GPIO-21
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO22    (.I(io_out[22]), .OEN(io_oeb[22]), .REN(io_ren[22]), .PAD(IO_PAD[22]), .C(io_in[22])); // Dedicated GPIO-22
  /* PULL-DOWN*/ PDDW16SDGZ_G GPIO23    (.I(io_out[23]), .OEN(io_oeb[23]), .REN(io_ren[23]), .PAD(IO_PAD[23]), .C(io_in[23])); // Dedicated GPIO-23

  // House Keeping SPI ie. Programming SPI slave (FTDI)
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_OUT_S (.I(io_out[24]), .OEN(io_oeb[24]), .REN(io_ren[24]), .PAD(IO_PAD[24]), .C(io_in[24])); // Dedicated SPI_OUT_S
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_IN_S  (.I(io_out[25]), .OEN(io_oeb[25]), .REN(io_ren[25]), .PAD(IO_PAD[25]), .C(io_in[25])); // Dedicated SPI_IN_S
  /* PULL-DOWN*/ PDDW16SDGZ_G SCLK_S    (.I(io_out[26]), .OEN(io_oeb[26]), .REN(io_ren[26]), .PAD(IO_PAD[26]), .C(io_in[26])); // Dedicated SCLK_S
  /* PULL-DOWN*/ PDDW16SDGZ_G CSB_S     (.I(io_out[27]), .OEN(io_oeb[27]), .REN(io_ren[27]), .PAD(IO_PAD[27]), .C(io_in[27])); // Dedicated CSB_S

  // UART-3 (FTDI)
  /* PULL-DOWN*/ PDDW16SDGZ_G UART_TX_3 (.I(io_out[28]), .OEN(io_oeb[28]), .REN(io_ren[28]), .PAD(IO_PAD[28]), .C(io_in[28])); // Dedicated UART_TX_3
  /* PULL-UP  */ PDUW16SDGZ_G UART_RX_3 (.I(io_out[29]), .OEN(io_oeb[29]), .REN(io_ren[29]), .PAD(IO_PAD[29]), .C(io_in[29])); // Dedicated UART_RX_3

  // UART-1
  /* PULL-DOWN*/ PDDW16SDGZ_G UART_TX_1 (.I(io_out[30]), .OEN(io_oeb[30]), .REN(io_ren[30]), .PAD(IO_PAD[30]), .C(io_in[30])); // Dedicated UART_TX_1
  /* PULL-UP  */ PDUW16SDGZ_G UART_RX_1 (.I(io_out[31]), .OEN(io_oeb[31]), .REN(io_ren[31]), .PAD(IO_PAD[31]), .C(io_in[31])); // Dedicated UART_RX_1MAIN_IO_PORTS

  // UART-2
  /* PULL-DOWN*/ PDDW16SDGZ_G UART_TX_2 (.I(io_out[32]), .OEN(io_oeb[32]), .REN(io_ren[32]), .PAD(IO_PAD[32]), .C(io_in[32])); // Dedicated UART_TX_2
  /* PULL-UP  */ PDUW16SDGZ_G UART_RX_2 (.I(io_out[33]), .OEN(io_oeb[33]), .REN(io_ren[33]), .PAD(IO_PAD[33]), .C(io_in[33])); // Dedicated UART_RX_1MAIN_IO_PORTS

  // SPI-2 Master
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_OUT_2 (.I(io_out[34]), .OEN(io_oeb[34]), .REN(io_ren[34]), .PAD(IO_PAD[34]), .C(io_in[34])); // Dedicated SPI_OUT_2
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_IN_2  (.I(io_out[35]), .OEN(io_oeb[35]), .REN(io_ren[35]), .PAD(IO_PAD[35]), .C(io_in[35])); // Dedicated SPI_IN_2
  /* PULL-DOWN*/ PDDW16SDGZ_G SCLK_2    (.I(io_out[36]), .OEN(io_oeb[36]), .REN(io_ren[36]), .PAD(IO_PAD[36]), .C(io_in[36])); // Dedicated SCLK_2
  /* PULL-DOWN*/ PDDW16SDGZ_G CSB_2     (.I(io_out[37]), .OEN(io_oeb[37]), .REN(io_ren[37]), .PAD(IO_PAD[37]), .C(io_in[37])); // Dedicated CSB_2

  // SPI-3 Master
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_OUT_3 (.I(io_out[38]), .OEN(io_oeb[38]), .REN(io_ren[38]), .PAD(IO_PAD[38]), .C(io_in[38])); // Dedicated SPI_OUT_3
  /* PULL-DOWN*/ PDDW16SDGZ_G SPI_IN_3  (.I(io_out[39]), .OEN(io_oeb[39]), .REN(io_ren[39]), .PAD(IO_PAD[39]), .C(io_in[39])); // Dedicated SPI_IN_3
  /* PULL-DOWN*/ PDDW16SDGZ_G SCLK_3    (.I(io_out[40]), .OEN(io_oeb[40]), .REN(io_ren[40]), .PAD(IO_PAD[40]), .C(io_in[40])); // Dedicated SCLK_3
  /* PULL-DOWN*/ PDDW16SDGZ_G CSB_3     (.I(io_out[41]), .OEN(io_oeb[41]), .REN(io_ren[41]), .PAD(IO_PAD[41]), .C(io_in[41])); // Dedicated CSB_3

  // QSPI Master
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_CLK  (.I(io_out[42]), .OEN(io_oeb[42]), .REN(io_ren[42]), .PAD(IO_PAD[42]), .C(io_in[42])); // Dedicated QSPI_CLK
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_CSB  (.I(io_out[43]), .OEN(io_oeb[43]), .REN(io_ren[43]), .PAD(IO_PAD[43]), .C(io_in[43])); // Dedicated QSPI_CSB
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_D0   (.I(io_out[44]), .OEN(io_oeb[44]), .REN(io_ren[44]), .PAD(IO_PAD[44]), .C(io_in[44])); // Dedicated QSPI_D0
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_D1   (.I(io_out[45]), .OEN(io_oeb[45]), .REN(io_ren[45]), .PAD(IO_PAD[45]), .C(io_in[45])); // Dedicated QSPI_D1
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_D2   (.I(io_out[46]), .OEN(io_oeb[46]), .REN(io_ren[46]), .PAD(IO_PAD[46]), .C(io_in[46])); // Dedicated QSPI_D2
  /* PULL-DOWN*/ PDDW16SDGZ_G QSPI_D3   (.I(io_out[47]), .OEN(io_oeb[47]), .REN(io_ren[47]), .PAD(IO_PAD[47]), .C(io_in[47])); // Dedicated QSPI_D3

  /* PULL-DOWN*/ PDDW16SDGZ_G LED_ALIVE (.I(io_out[48]), .OEN(io_oeb[48]), .REN(io_ren[48]), .PAD(IO_PAD[48]), .C(io_in[48])); // Dedicated LED-Alive
  /* PULL-DOWN*/ PDDW16SDGZ_G BOOT_SEL  (.I(io_out[49]), .OEN(io_oeb[49]), .REN(io_ren[49]), .PAD(IO_PAD[49]), .C(io_in[49])); // Dedicated Boot-Sel
  /* PULL-DOWN*/ PDDW16SDGZ_G RST_NI    (.I(io_out[50]), .OEN(io_oeb[50]), .REN(io_ren[50]), .PAD(IO_PAD[50]), .C(io_in[50])); // Dedicated Reset

  /* PULL-DOWN*/ PDDW16SDGZ_G MIAN_CLK  (.I(io_out[51]), .OEN(io_oeb[51]), .REN(io_ren[51]), .PAD(IO_PAD[51]), .C(io_in[51])); // Dedicated Main Clock

  /* PULL-DOWN*/ PDDW16SDGZ_G PLL_LOCK  (.I(io_out[52]), .OEN(io_oeb[52]), .REN(io_ren[52]), .PAD(IO_PAD[52]), .C(io_in[52])); // Dedicated PLL-lock
  /* PULL-DOWN*/ PDDW16SDGZ_G P_ON_RST  (.I(io_out[53]), .OEN(io_oeb[53]), .REN(io_ren[53]), .PAD(IO_PAD[53]), .C(io_in[53])); // Dedicated PowerOnReset

endmodule: azadi_chip_top
