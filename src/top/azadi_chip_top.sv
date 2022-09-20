// Copyright MERL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module azadi_chip_top (
`ifdef USE_POWER_PINS
   inout vccd1,
   inout vssd1,
`endif
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        prog_i,

  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_oe,

  // uart-periph interface
  output logic        uart_txo,
  input  logic        uart_rxi,

  // PWM interface  
  output logic        pwm_o,
  output logic        pwm_o_2,
  output logic        pwm1_oe,
  output logic        pwm2_oe,

  // SPI interface
  output logic  [3:0] ss_o,
  output logic        sclk_o,
  output logic        sd_oe,
  output logic        sd_o,
  input  logic        sd_i
);

  logic [15:0] clks_per_bit;

  PAD100MTB PAD_1   (.BUMP( clk_i       ));
  PAD100MTB PAD_2   (.BUMP( rst_ni      ));
  PAD100MTB PAD_3   (.BUMP( prog_i      ));
  PAD100MTB PAD_4   (.BUMP( gpio_i[0]   ));
  PAD100MTB PAD_5   (.BUMP( gpio_i[1]   ));
  PAD100MTB PAD_6   (.BUMP( gpio_i[2]   ));
  PAD100MTB PAD_7   (.BUMP( gpio_i[3]   ));
  PAD100MTB PAD_8   (.BUMP( gpio_i[4]   ));
  PAD100MTB PAD_9   (.BUMP( gpio_i[5]   ));
  PAD100MTB PAD_10  (.BUMP( gpio_i[6]   ));
  PAD100MTB PAD_11  (.BUMP( gpio_i[7]   ));
  PAD100MTB PAD_12  (.BUMP( gpio_i[8]   ));
  PAD100MTB PAD_13  (.BUMP( gpio_i[9]   ));
  PAD100MTB PAD_14  (.BUMP( gpio_i[10]  ));
  PAD100MTB PAD_15  (.BUMP( gpio_i[11]  ));
  PAD100MTB PAD_16  (.BUMP( gpio_i[12]  ));
  PAD100MTB PAD_17  (.BUMP( gpio_i[13]  ));
  PAD100MTB PAD_18  (.BUMP( gpio_i[14]  ));
  PAD100MTB PAD_19  (.BUMP( gpio_i[15]  ));
  PAD100MTB PAD_20  (.BUMP( gpio_i[16]  ));
  PAD100MTB PAD_21  (.BUMP( gpio_i[17]  ));
  PAD100MTB PAD_22  (.BUMP( gpio_i[18]  ));
  PAD100MTB PAD_23  (.BUMP( gpio_i[19]  ));
  PAD100MTB PAD_24  (.BUMP( gpio_i[20]  ));
  PAD100MTB PAD_25  (.BUMP( gpio_i[21]  ));
  PAD100MTB PAD_26  (.BUMP( gpio_i[22]  ));
  PAD100MTB PAD_27  (.BUMP( gpio_i[23]  ));
  PAD100MTB PAD_28  (.BUMP( gpio_i[24]  ));
  PAD100MTB PAD_29  (.BUMP( gpio_i[25]  ));
  PAD100MTB PAD_30  (.BUMP( gpio_i[26]  ));
  PAD100MTB PAD_31  (.BUMP( gpio_i[27]  ));
  PAD100MTB PAD_32  (.BUMP( gpio_i[28]  ));
  PAD100MTB PAD_33  (.BUMP( gpio_i[29]  ));
  PAD100MTB PAD_34  (.BUMP( gpio_i[30]  ));
  PAD100MTB PAD_35  (.BUMP( gpio_i[31]  ));
  PAD100MTB PAD_36  (.BUMP( gpio_o[0]   ));
  PAD100MTB PAD_37  (.BUMP( gpio_o[1]   ));
  PAD100MTB PAD_38  (.BUMP( gpio_o[2]   ));
  PAD100MTB PAD_39  (.BUMP( gpio_o[3]   ));
  PAD100MTB PAD_40  (.BUMP( gpio_o[4]   ));
  PAD100MTB PAD_41  (.BUMP( gpio_o[5]   ));
  PAD100MTB PAD_42  (.BUMP( gpio_o[6]   ));
  PAD100MTB PAD_43  (.BUMP( gpio_o[7]   ));
  PAD100MTB PAD_44  (.BUMP( gpio_o[8]   ));
  PAD100MTB PAD_45  (.BUMP( gpio_o[9]   ));
  PAD100MTB PAD_46  (.BUMP( gpio_o[10]  ));
  PAD100MTB PAD_47  (.BUMP( gpio_o[11]  ));
  PAD100MTB PAD_48  (.BUMP( gpio_o[12]  ));
  PAD100MTB PAD_49  (.BUMP( gpio_o[13]  ));
  PAD100MTB PAD_50  (.BUMP( gpio_o[14]  ));
  PAD100MTB PAD_51  (.BUMP( gpio_o[15]  ));
  PAD100MTB PAD_52  (.BUMP( gpio_o[16]  ));
  PAD100MTB PAD_53  (.BUMP( gpio_o[17]  ));
  PAD100MTB PAD_54  (.BUMP( gpio_o[18]  ));
  PAD100MTB PAD_55  (.BUMP( gpio_o[19]  ));
  PAD100MTB PAD_56  (.BUMP( gpio_o[20]  ));
  PAD100MTB PAD_57  (.BUMP( gpio_o[21]  ));
  PAD100MTB PAD_58  (.BUMP( gpio_o[22]  ));
  PAD100MTB PAD_59  (.BUMP( gpio_o[23]  ));
  PAD100MTB PAD_60  (.BUMP( gpio_o[24]  ));
  PAD100MTB PAD_61  (.BUMP( gpio_o[25]  ));
  PAD100MTB PAD_62  (.BUMP( gpio_o[26]  ));
  PAD100MTB PAD_63  (.BUMP( gpio_o[27]  ));
  PAD100MTB PAD_64  (.BUMP( gpio_o[28]  ));
  PAD100MTB PAD_65  (.BUMP( gpio_o[29]  ));
  PAD100MTB PAD_66  (.BUMP( gpio_o[30]  ));
  PAD100MTB PAD_67  (.BUMP( gpio_o[31]  ));
  PAD100MTB PAD_68  (.BUMP( gpio_oe[0]  ));
  PAD100MTB PAD_69  (.BUMP( gpio_oe[1]  ));
  PAD100MTB PAD_70  (.BUMP( gpio_oe[2]  ));
  PAD100MTB PAD_71  (.BUMP( gpio_oe[3]  ));
  PAD100MTB PAD_72  (.BUMP( gpio_oe[4]  ));
  PAD100MTB PAD_73  (.BUMP( gpio_oe[5]  ));
  PAD100MTB PAD_74  (.BUMP( gpio_oe[6]  ));
  PAD100MTB PAD_75  (.BUMP( gpio_oe[7]  ));
  PAD100MTB PAD_76  (.BUMP( gpio_oe[8]  ));
  PAD100MTB PAD_77  (.BUMP( gpio_oe[9]  ));
  PAD100MTB PAD_78  (.BUMP( gpio_oe[10] ));
  PAD100MTB PAD_79  (.BUMP( gpio_oe[11] ));
  PAD100MTB PAD_80  (.BUMP( gpio_oe[12] ));
  PAD100MTB PAD_81  (.BUMP( gpio_oe[13] ));
  PAD100MTB PAD_82  (.BUMP( gpio_oe[14] ));
  PAD100MTB PAD_83  (.BUMP( gpio_oe[15] ));
  PAD100MTB PAD_84  (.BUMP( gpio_oe[16] ));
  PAD100MTB PAD_85  (.BUMP( gpio_oe[17] ));
  PAD100MTB PAD_86  (.BUMP( gpio_oe[18] ));
  PAD100MTB PAD_87  (.BUMP( gpio_oe[19] ));
  PAD100MTB PAD_88  (.BUMP( gpio_oe[20] ));
  PAD100MTB PAD_89  (.BUMP( gpio_oe[21] ));
  PAD100MTB PAD_90  (.BUMP( gpio_oe[22] ));
  PAD100MTB PAD_91  (.BUMP( gpio_oe[23] ));
  PAD100MTB PAD_92  (.BUMP( gpio_oe[24] ));
  PAD100MTB PAD_93  (.BUMP( gpio_oe[25] ));
  PAD100MTB PAD_94  (.BUMP( gpio_oe[26] ));
  PAD100MTB PAD_95  (.BUMP( gpio_oe[27] ));
  PAD100MTB PAD_96  (.BUMP( gpio_oe[28] ));
  PAD100MTB PAD_97  (.BUMP( gpio_oe[29] ));
  PAD100MTB PAD_98  (.BUMP( gpio_oe[30] ));
  PAD100MTB PAD_99  (.BUMP( gpio_oe[31] ));
  PAD100MTB PAD_100 (.BUMP( uart_txo    ));
  PAD100MTB PAD_101 (.BUMP( uart_rxi    ));
  PAD100MTB PAD_102 (.BUMP( pwm_o       ));
  PAD100MTB PAD_103 (.BUMP( pwm_o_2     ));
  PAD100MTB PAD_104 (.BUMP( pwm1_oe     ));
  PAD100MTB PAD_105 (.BUMP( pwm2_oe     ));
  PAD100MTB PAD_106 (.BUMP( ss_o[0]     ));
  PAD100MTB PAD_107 (.BUMP( ss_o[1]     ));
  PAD100MTB PAD_108 (.BUMP( ss_o[2]     ));
  PAD100MTB PAD_109 (.BUMP( ss_o[3]     ));
  PAD100MTB PAD_110 (.BUMP( sclk_o      ));
  PAD100MTB PAD_111 (.BUMP( sd_oe       ));
  PAD100MTB PAD_112 (.BUMP( sd_o        ));
  PAD100MTB PAD_113 (.BUMP( sd_i        ));

  azadi_soc_top azadi_soc_top_i(
  `ifdef USE_POWER_PINS
     .vccd1	( vccd1 ),
     .vssd1	( vssd1 ),
  `endif
    .clk_i	      ( clk_i        ),
    .rst_ni	      ( rst_ni       ),
    .prog		      ( prog_i       ),
    .clks_per_bit	( clks_per_bit ),
    .gpio_i	      ( gpio_i       ),
    .gpio_o	      ( gpio_o       ),
    .gpio_oe	    ( gpio_oe      ),
    // uart-periph interface
    .uart_tx	    ( uart_tx      ),
    .uart_rx	    ( uart_rx      ),
    // PWM interface  
    .pwm_o	      ( pwm_o        ),
    .pwm_o_2	    ( pwm_o_2      ),
    .pwm1_oe	    ( pwm1_oe      ),
    .pwm2_oe	    ( pwm2_oe      ),
    // SPI interface
    .ss_o		      ( ss_o         ),
    .sclk_o	      ( sclk_        ),
    .sd_o		      ( sd_o         ),
    .sd_oe	      ( sd_oe        ),
    .sd_i		      ( sd_i         )
  );

endmodule
