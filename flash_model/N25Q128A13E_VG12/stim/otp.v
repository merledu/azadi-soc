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


    defparam Testbench.DUT.memory_file = "";




    reg [addrDim-1:0] A1='h00, //Beginning of OTP area.
                      A2='h40, //Last column of OTP area (control byte).
                      A3='h7F; //Out of OTP area.  
    integer i;


    initial begin


        tasks.init;

        // program OTP 
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A1);
        for (i=1; i<=4; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (out of OTP area)
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A3);
        tasks.send_data('hFF);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (limit of OTP area) 
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A2-1);
        for (i=1; i<=4; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (error because of lock bit) 
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A1);
        tasks.send_data('h00);
        tasks.close_comm;
        #100;


        // read OTP
        tasks.send_command('h4B);
        tasks.send_address(A1);
        tasks.send_dummy('hF0,15); //dummy byte
        tasks.read(5);
        tasks.close_comm;

        // read OTP (limit of OTP area)
        tasks.send_command('h4B);
        tasks.send_address(A2-1);
        tasks.send_dummy('hF0,15); //dummy byte
        tasks.read(4);
        tasks.close_comm;
    
    end



endmodule    
