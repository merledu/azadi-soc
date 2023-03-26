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


//-----------------------------
// For the N25Qxxx device
//-----------------------------

`timescale 1ns / 1ns


`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file

    defparam Testbench.DUT.memory_file = "";

    reg [15:0] regData='b1111111111111111;

    reg [addrDim-1:0] A0='h0, A1, A2='h08,B1='h003300;

    reg [15:0] R;

    integer i;

    initial begin

        if ((devName=="N25Q256A33E") ||(devName=="N25Q256A31E"))
            A1='hFFFFFA;
        else if ((devName=="N25Q032A13E") ||(devName=="N25Q032A11E"))
            A1='h3FFFFA;


        tasks.init;
        
        
        $display("\n---------------------------------");
        $display("\n--- PLRS in between two SR reads "); 
        $display("\n---------------------------------");

        $display("\n--- STATUS REGISTER READ"); 
        tasks.send_command('h05);
        tasks.read(2); 
        tasks.close_comm;


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

        $display("\n--- STATUS REGISTER READ"); 
        tasks.send_command('h05);
        tasks.read(2); 
        tasks.close_comm;
        #100;

    end  


    endmodule


