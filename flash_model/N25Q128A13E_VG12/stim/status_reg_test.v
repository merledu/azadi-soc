`timescale 1ns / 1ns


`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file



    defparam Testbench.DUT.memory_file = "";


    reg [addrDim-1:0] A1='h010000; //sector 1
    reg [addrDim-1:0] A2='h040000; //sector 4
    
    reg [dataDim-1:0] regData = 'h0;

    integer i;



    initial begin

        tasks.init;


        // write status register 
        $display("\n--- Write status register");
        tasks.write_enable;
        tasks.send_command('h01);
        //regData[6:2] = 'b01011; // (BP3,TB,BP2,BP1,BP0)=(0,1,0,1,1) - lock sector 0 to 3
        regData[1:0] = 'b11; // (BP3,TB,BP2,BP1,BP0)=(0,1,0,1,1) - lock sector 0 to 3
        tasks.send_data(regData); 
        tasks.close_comm;
        #(write_SR_delay+100);  

    end

    endmodule
