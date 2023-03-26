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

//`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 
module Stimuli3 (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
//module Stimuli (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
    `include "include/DevParam.h"
   
   
    output S;
    output [`VoltageRange] Vcc;

    inout DQ0, DQ1; 

    inout Vpp_W_DQ2;

    `ifdef HOLD_pin
        inout HOLD_DQ3; 
    `endif
    

    `ifdef RESET_pin
       inout RESET_DQ3;
    `endif

      defparam Testbench.DUT3.memory_file = "mem_Q128_bottom.vmf";

    reg [addrDim-1:0] A0='h0, A1, A2='h08;


    initial begin
        
            A1='hFFFFFA;

        //tasks3.init;
        tasks3.asml_init;
//        tasks31.asml_init;
//        tasks32.asml_init;
//        tasks33.asml_init;
         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks3.send_command_asml('h70);
        tasks3.read(1); 
        tasks3.close_comm;
        #100;

        tasks3.send_power_loss_rescue_sequence_part1_quad(); //let's give one less clock cycle
        tasks3.close_comm;
        #10;
        tasks3.send_power_loss_rescue_sequence_part1_dual();
        tasks3.close_comm;
        #50;
        tasks3.send_power_loss_rescue_sequence_part1_extended();
        tasks3.close_comm;
        #50;
        tasks3.send_power_loss_rescue_sequence_part2();
        tasks3.close_comm;
        #2500;

         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks3.send_command_asml('h70);
        tasks3.read(1); 
        tasks3.close_comm;
        #2000;

         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks3.send_command_asml('h70);
        tasks3.read(1); 
        tasks3.close_comm;
        #100;


    end


endmodule    

