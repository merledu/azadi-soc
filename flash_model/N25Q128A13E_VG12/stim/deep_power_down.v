//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  N25Q128A13E
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-




`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file
  

      defparam Testbench.DUT.memory_file =  "mem_Q128_bottom.vmf";


    reg [addrDim-1:0] A='h0, B='h10;
    
    reg [`VoltageRange] V0='d0, V1=Vcc_wi, V2=Vcc_min;



    initial begin

        tasks.init;
       
       `ifdef PowDown
        tasks.send_command('hB9);
        tasks.close_comm;
        #deep_power_down_delay;

        tasks.send_command('h03);
        tasks.send_address('h00);
        tasks.read(1);
        tasks.close_comm;

        tasks.send_command('hAB);
        tasks.close_comm;
        #release_power_down_delay;

        `endif

    end


endmodule    
