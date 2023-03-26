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
    
    defparam Testbench.DUT.memory_file = "mem_Q032.vmf";

    // transactions handles


    //reg [addrDim-1:0] A1='h01FFFC, //Near the end of the page.
    //                  A2='h01FF00, //At the beggining of same page. 
    //                  B1='h003300;
    integer i;

    reg [addrDim-1:0] A0='h0, A1='h0, A2='h08;
    reg [15:0] regData='b1111111111111111;

    initial begin

        tasks.init;

          // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable;
        tasks.send_command('h61);
        regData[7:0] = 'b0100_1111; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read volatile configuration register 
        tasks.send_command_quad_diffTiming('h85);
        tasks.read_quad(1); 
        tasks.close_comm;
        #100;


        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        //tasks.send_command_quad_diffTiming('h81);
        tasks.send_command_quad('h81);
        //regData[7:5] = 'b10; 
        regData[3] = 'b0; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command_quad('h85);
        tasks.read_quad(1); 
        tasks.close_comm;

        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h81);
        regData[7:4] = 'b1001; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

        // read
        $display("\n --- Read");
        tasks.send_command_quad('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address_quad(A0);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_quad(A2);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(3);
        tasks.close_comm;
        #2000

        $display("\n --- Power Loss Rescue Sequence Part 1");
        tasks.send_power_loss_rescue_sequence_part1_quad(); //let's give one less clock cycle
        tasks.close_comm;
        #10;
        tasks.send_power_loss_rescue_sequence_part1_dual();
        tasks.close_comm;
        #50;
        tasks.send_power_loss_rescue_sequence_part1_extended();
        tasks.close_comm;
        #50;
        $display("\n --- Power Loss Rescue Sequence Part 2");
        tasks.send_power_loss_rescue_sequence_part2();
        tasks.close_comm;
        #2000

        //----------------
        //  Standard read
        //----------------
        $display("\n ----- Read Post PLRS.");

        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
         tasks.send_address(A0);
        `endif
        tasks.read(4);
        tasks.close_comm;
        #100;

        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(8);
        tasks.close_comm;
        #100;
 

          // write volatile enhanced configuration register 
        $display("\n--- We are configuring device to quad protocol and enabling XIP");
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable;
        tasks.send_command('h61);
        regData[7:0] = 'b0100_1110; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read volatile configuration register 
//        tasks.send_command_quad_diffTiming('h85);
//        tasks.read_quad(1); 
//        tasks.close_comm;
        #100;


        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        //tasks.send_command_quad_diffTiming('h81);
        tasks.send_command_quad('h81);
        //regData[7:5] = 'b10; 
        regData[7:4] = 'b0000; 
        regData[3] = 'b0; 
        regData[0] = 'b1; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command_quad('h85);
        tasks.read_quad(1); 
        tasks.close_comm;

        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h81);
        regData[7:4] = 'b1001; 
        regData[0] = 'b1; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

        // read
        $display("\n --- We should be in quad protocol now. Doing Reads");
        $display("\n --- and turning on XIP");
        $display("\n --- Read");
        tasks.send_command_quad('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address_quad(A0);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_quad(A2);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n --- Next set of Reads will disable XIP");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_quad(A2);
        `endif
//        tasks.send_dummy_quad('h00,15); //dummy byte
//        tasks.read_quad(3);
//        tasks.close_comm;
//        #100;

        
        tasks.send_dummy_quad('hffffffff,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;

        // Configuring for Dual again
          // write volatile enhanced configuration register 
        $display("\n--- Configuring for DUAL again");
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h61);
        regData[7:0] = 'b1000_1110; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  


        $display("\n--- Write volatile configuration register");
        tasks.write_enable_dual;
        //tasks.send_command_dual_diffTiming('h81);
        tasks.send_command_dual('h81);
        //regData[7:5] = 'b10; 
        regData[7:4] = 'b0000; 
        regData[3] = 'b0; 
        regData[0] = 'b1; 
        tasks.send_data_dual(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command_dual('h85);
        tasks.read_dual(1); 
        tasks.close_comm;

        $display("\n--- Write volatile configuration register");
        tasks.write_enable_dual;
        tasks.send_command_dual('h81);
        regData[7:4] = 'b1001; 
        regData[0] = 'b1; 
        tasks.send_data_dual(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

        // read
        $display("\n We do reads in dual mode and turn XIP on.");
        $display("\n --- Read");
        tasks.send_command_dual('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address_dual(A0);
        `endif
        tasks.send_dummy_dual('h00,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_dual(A2);
        `endif
        tasks.send_dummy_dual('h00,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        #100;
        
        $display("\n We do reads in dual mode and but turn-off the XIP.");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_dual(A2);
        `endif
        tasks.send_dummy_dual('hffffffff,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;

        $display("\n--- Configuring for EXTENDED ");
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable_dual;
        tasks.send_command_dual('h61);
        regData[7:0] = 'b1100_1110; 
        tasks.send_data_dual(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        //tasks.send_command_diffTiming('h81);
        tasks.send_command('h81);
        //regData[7:5] = 'b10; 
        regData[7:4] = 'b1001; 
        regData[3] = 'b0; 
        regData[0] = 'b1; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(1); 
        tasks.close_comm;


        $display("\n We do reads in dual mode and turn XIP on.");
        $display("\n --- Read");
        tasks.send_command('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address(A0);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address(A2);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;
        
        $display("\n We do reads in dual mode and but turn-off the XIP.");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address(A2);
        `endif
        tasks.send_dummy('hffffffff,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        tasks.send_command('h0B);
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address(A2);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;

        $display("\n --- Power Loss Rescue Sequence Part 1");
        tasks.send_power_loss_rescue_sequence_part1_quad(); //let's give one less clock cycle
        tasks.close_comm;
        #10;
        tasks.send_power_loss_rescue_sequence_part1_dual();
        tasks.close_comm;
        #50;
        tasks.send_power_loss_rescue_sequence_part1_extended();
        tasks.close_comm;
        #50;
        $display("\n --- Power Loss Rescue Sequence Part 2");
        tasks.send_power_loss_rescue_sequence_part2();
        tasks.close_comm;
        #2000;

        $display("\n ----- Read Post 2nd PLRS.");

        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
         tasks.send_address(A0);
        `endif
        tasks.read(4);
        tasks.close_comm;
        #100;

        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(8);
        tasks.close_comm;
        #100;
 

          // write volatile enhanced configuration register 
        $display("\n--- We are configuring device to quad protocol and enabling XIP");
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable;
        tasks.send_command('h61);
        regData[7:0] = 'b0100_1110; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read volatile configuration register 
//        tasks.send_command_quad_diffTiming('h85);
//        tasks.read_quad(1); 
//        tasks.close_comm;
        #100;


        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        //tasks.send_command_quad_diffTiming('h81);
        tasks.send_command_quad('h81);
        //regData[7:5] = 'b10; 
        regData[7:4] = 'b0000; 
        regData[3] = 'b0; 
        regData[0] = 'b1; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command_quad('h85);
        tasks.read_quad(1); 
        tasks.close_comm;

        $display("\n--- Write volatile configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h81);
        regData[7:4] = 'b1001; 
        regData[0] = 'b1; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

        // read
        $display("\n --- We should be in quad protocol now. Doing Reads");
        $display("\n --- and turning on XIP");
        $display("\n --- Read");
        tasks.send_command_quad('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address_quad(A0);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(9);
        tasks.close_comm;
        #100;

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_quad(A2);
        `endif
        tasks.send_dummy_quad('h00,15); //dummy byte
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n --- Next set of Reads will disable XIP");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address_quad(A2);
        `endif
//        tasks.send_dummy_quad('h00,15); //dummy byte
//        tasks.read_quad(3);
//        tasks.close_comm;
//        #100;

        
        tasks.send_dummy_quad('hffffffff,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;
    end


endmodule    

