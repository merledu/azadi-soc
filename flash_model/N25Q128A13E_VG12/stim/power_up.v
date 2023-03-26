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
// For all the M25Pxxx devices
//-----------------------------

`timescale 1ns / 1ns


`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file


      defparam Testbench.DUT.memory_file = "mem_Q128_bottom.vmf";



    
    reg [addrDim-1:0] A='h0, B='h10;
    
    reg [`VoltageRange] V0='d0, V1=Vcc_wi, V2=Vcc_min;

    reg [15:0] regData='b1111111111011111;

    //---------------------------------------------------
    // NB: these stimuli have been simulated with the 
    // following timing constants:
    //  write_access_power_up_delay = 100000;
    //  read_access_power_up_delay = 10000;
    //  T = 20; (clock period)
    //----------------------------------------------------



    initial begin

          tasks.set_Vpp_W('d0);
        
        tasks.set_HOLD(1);
        
        //-------------------------
        // Fast POR not selected 
        //-------------------------

        $display("\n ---PollingAccessOn=1 && ReadAccessOn=0 && WriteAccessOn=0");
        
        tasks.Vcc_waveform(V0,10,V1,10,V2,10);
        $display("\n ---Polling WIP=1 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #full_access_power_up_delay;
        
        $display("\n ---PollingAccessOn=1 && ReadAccessOn=1 && WriteAccessOn=1");

        $display("\n ---Read Status Register WIP=0 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;


        $display("\n ---read");
        tasks.send_command('h03);
        tasks.send_address(A);
        tasks.read(1);
        tasks.close_comm;
        

        $display("\n ---program");
        tasks.write_enable;
        $display("\n ---Read Status Register WIP=0 WEL=1");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;

        tasks.send_command('h02);
        tasks.send_address(B);
        tasks.send_data('hC1);
        tasks.close_comm;

        $display("\n ---Read Status Register WIP=1 WEL=1");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #program_delay;
        
        $display("\n ---Read Status Register WIP=0 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;


        //-------------------------
        // Fast POR selected 
        //-------------------------
            // write non volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        tasks.send_data(regData[7:0]);
        tasks.send_data(regData[15:8]);
        tasks.close_comm;
        #(write_NVCR_delay+100);  


        $display("\n ---PollingAccessOn=1 && ReadAccessOn=0 && WriteAccessOn=0");
        
        tasks.Vcc_waveform(V0,10,V1,10,V2,10);
        $display("\n ---Polling WIP=1 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #read_access_power_up_delay;
        
        $display("\n ---PollingAccessOn=1 && ReadAccessOn=1 && WriteAccessOn=0");

        $display("\n ---Read Status Register WIP=0 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;

        $display("\n ---read");
        tasks.send_command('h03);
        tasks.send_address(A);
        tasks.read(1);
        tasks.close_comm;
        
        $display("\n --- program WREN issued");
        tasks.write_enable;
        
        $display("\n ---Read Status Register WIP=1 WEL=1");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        
        # write_access_power_up_delay;
        
        $display("\n ---Read Status Register WIP=0 WEL=1");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        
        tasks.send_command('h02);
        tasks.send_address(B);
        tasks.send_data('hC1);
        tasks.close_comm;

        $display("\n ---Read Status Register WIP=1 WEL=1");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #program_delay;
        
        $display("\n ---Read Status Register WIP=0 WEL=0");
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;

    end


endmodule    
