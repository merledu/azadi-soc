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



    reg [addrDim-1:0] A1='h01FFFC, //Near the end of the page.
                      A2='h01FF00, //At the beggining of same page. 
                      B1='h003300,
                      S0='h080000; //sector 8

    integer i;


    initial begin

        
        tasks.init;
        
        // dual program
        $display("\n --- Dual program");
        tasks.write_enable;
        tasks.send_command('hA2);
        tasks.send_address(B1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(B1);
        tasks.read(9);
        tasks.close_comm;



        //-----------------------
        // dual extended program
        //-----------------------
        // dual extended program
        $display("\n --- Dual extended program");
        tasks.write_enable;
        tasks.send_command('hD2);
        tasks.send_address_dual(B1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hD1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(B1);
        tasks.read(9);
        tasks.close_comm;

        
        //---------------
        // quad program
        //---------------
        
        // quad program
        $display("\n --- Quad program");
        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_quad('hF1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(9);
        tasks.close_comm;
        

        //---------------
        // quad extended program
        //---------------
        
        // quad extended program
        $display("\n --- Quad extended program");
        tasks.write_enable;
        tasks.send_command('h12);
        tasks.send_address_quad(A1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_quad('hF1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(9);
        tasks.close_comm;

        //---------------
        // page program
        //---------------

        // page program 
        $display("\n --- Page program with suspend");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #100;
        $display("\n --- program suspend");

        tasks.send_command('h75);
        tasks.close_comm;
        #200;

        $display("\n --- program resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        tasks.send_address(A2);
        tasks.read(5);
        tasks.close_comm;

        
         // page program 
        $display("\n --- Page program with suspend 2");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #100;
        $display("\n --- program suspend");

        tasks.send_command('h75);
        tasks.close_comm;
        #200;
        
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;

        tasks.send_command('h03);
        tasks.send_address(B1);
        tasks.read(5);
        tasks.close_comm;

        $display("\n --- program resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        tasks.send_address(A2);
        tasks.read(5);
        tasks.close_comm;

         // page program 
        $display("\n --- Page program with suspend 3");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #100;
        $display("\n --- program suspend");

        tasks.send_command('h75);
        tasks.close_comm;
        #200;
        
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);
        

        $display("\n --- program resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        tasks.send_address(A2);
        tasks.read(5);
        tasks.close_comm;

         // page program 
        $display("\n --- Page program with suspend 3");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;


        #100;
        $display("\n --- program suspend");
        tasks.send_command('h75);
        tasks.close_comm;
        #200;
        $display("\n --- New Page Program during program suspend");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);
        

        $display("\n --- program resume");
        tasks.send_command('h7A);
        tasks.close_comm;
        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        tasks.send_address(A2);
        tasks.read(5);
        tasks.close_comm;

         // page program 
        $display("\n --- Page program with suspend 4");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;

        #100;
        $display("\n --- program suspend");

        tasks.send_command('h75);
        tasks.close_comm;
        #200;
        
        $display("\n --- Sector erase during program suspend");


         // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(S0); 
        tasks.close_comm;
        #(erase_delay+100);        
        
        $display("\n --- program resume");
        tasks.send_command('h7A);
        tasks.close_comm;
        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        tasks.send_address(A2);
        tasks.read(5);
        tasks.close_comm;
         

       // dual program suspended
        $display("\n --- Dual program suspended");
        tasks.write_enable;
        tasks.send_command('hA2);
        tasks.send_address(B1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #500;

        $display("\n --- program suspend");

        tasks.send_command('h75);
        tasks.close_comm;

        #200;
 
        $display("\n --- program resume");
        tasks.send_command('h7A);
        tasks.close_comm;

        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(B1);
        tasks.read(9);
        tasks.close_comm;


 
    end


endmodule    
