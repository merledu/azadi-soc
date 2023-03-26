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


    reg [addrDim-1:0] S0='h080000; //sector 8
    reg [addrDim-1:0] S1='h08FFFE; //sector 8 last columns
    reg [addrDim-1:0] SS0='h07F000; //sector 7, last subsector (subsector begin) 
    reg [addrDim-1:0] SS1='h07FFFE; //sector 7, last subsector (subsector end)
    reg [addrDim-1:0] addr='hFFFFFA; //location programmed in memory file

    initial begin



        tasks.init;
        

         // read flag status register 
        tasks.send_command('h70);
        tasks.read(2); 
        tasks.close_comm;
        #100;

         // clear flag status register 
        tasks.send_command('h50);
        tasks.close_comm;
        #clear_FSR_delay;


          // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable;
        tasks.send_command('h61);
        regData[7:0] = 'b00100111; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read non volatile configuration register 
        tasks.send_command_quad('h65);
        tasks.read(2); 
        tasks.close_comm;
        #100;
     

        //---------------
        // Sector erase 
        //---------------

        $display("\n---- Sector erase");

        // sector erase 
        tasks.write_enable_quad;
        tasks.send_command_quad('hD8);
        tasks.send_address_quad(S0); 
        tasks.close_comm;
        #(erase_delay+100);


        // read SR 
        tasks.send_command_quad('h05);
        tasks.read(2);
        tasks.close_comm;
        


    end  


    endmodule
