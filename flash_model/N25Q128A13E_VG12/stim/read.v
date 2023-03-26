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

        tasks.init;

        //----------------
        //  Standard read
        //----------------
        $display("\n ----- Read.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A0);
        tasks.read(4);
        tasks.close_comm;
        #100;

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(8);
        tasks.close_comm;
        #100;


        
            //----------------
            //  Dual read
            //----------------
            $display("\n ----- Dual Read.");

            // dual read from memory file
            tasks.send_command('h3B);
            tasks.send_address(A2);
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(3);
            tasks.close_comm;
            #100;

            //----------------
            //  Fast read
            //----------------
            $display("\n ----- Fast Read.");
            
            // fast read from memory file
            tasks.send_command('h0B);
            tasks.send_address(A0);
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read(4);
            tasks.close_comm;
            #100;


            //----------------
            //   Dual I/O read
            //----------------
            $display("\n ----- Dual I/O read");
            
            //  Dual I/O read from memory file
            tasks.send_command('hBB);
            tasks.send_address_dual(A1);
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(8);
            tasks.close_comm;
            #100;


            //----------------
            // Quad read
            //----------------
            $display("\n ----- Quad Fast Read.");
            
            // fast read from memory file
            tasks.send_command('h6B);
            tasks.send_address(A2);
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_quad(4);
            tasks.close_comm;
            #100;

            //----------------
            //   Quad I/O read
            //----------------
            $display("\n -----  Quad I/O read");
            
            //  Quad I/O read from memory file
            tasks.send_command('hEB);
            tasks.send_address_quad(A1);
            tasks.send_dummy('h200,15); //dummy byte
            tasks.read_quad(8);
            tasks.close_comm;
            #100;

        //----------------
        //  Read ID
        //----------------
        $display("\n ----- Read ID.");
        
        // read ID
        tasks.send_command('h9F);
        tasks.read(24);
        tasks.close_comm;
        #100;


        //------------------------
        //  Multiple I/O Read ID
        //------------------------

          // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable;
        tasks.send_command('h61);
        tasks.send_data('b00001100);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // Multiple I/O Read ID
        $display("\n -----  Multiple I/O Read ID.");
        tasks.send_command_quad('hAF);
        tasks.read_quad(10); 
        tasks.close_comm;
        #100;
 
    end


endmodule    
