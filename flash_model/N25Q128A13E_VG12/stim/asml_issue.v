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



`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 

      defparam Testbench.DUT.memory_file = "mem_Q128_bottom.vmf";

    reg [addrDim-1:0] A0='h0, A1, A2='h08;


    initial begin
        
            A1='hFFFFFA;

        //tasks.init;
        tasks.asml_init;
         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks.send_command_asml('h70);
        tasks.read(1); 
        tasks.close_comm;
        #100;

        tasks.send_power_loss_rescue_sequence_part1_quad(); //let's give one less clock cycle
        tasks.close_comm;
        #10;
        tasks.send_power_loss_rescue_sequence_part1_dual();
        tasks.close_comm;
        #50;
        tasks.send_power_loss_rescue_sequence_part1_extended();
        tasks.close_comm;
        #50;
        tasks.send_power_loss_rescue_sequence_part2();
        tasks.close_comm;
        #2500;

         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks.send_command_asml('h70);
        tasks.read(1); 
        tasks.close_comm;
        #2000;

         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks.send_command_asml('h70);
        tasks.read(1); 
        tasks.close_comm;
        #100;


    end


endmodule    
