`timescale 1 ns/1 ps

module main();

  // Testbench uses a 25 MHz clock (same as Go Board)
  // Want to interface to 115200 baud UART
  // 25000000 / 115200 = 217 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_BIT_PERIOD      = 8600;
  parameter FILENAME= "/home/merl/github_repos/azadi/tools/program.hex";
  wire [15:0] c_CLKS_PER_BIT = 16'd87;
  reg r_Clock = 0;
  reg r_Reset = 0;
  reg r_RX_Serial = 1;

  reg [31:0] INSTR[99:0];
  integer instr_count = 0;
      
      initial begin
        $readmemh(FILENAME,INSTR);
      end
azadi_soc_top Azadi 
(
  .clock (r_Clock),
  .Reset_ni (r_Reset),
  .uart_rx_i (r_RX_Serial),
  .gpio_i(4'b0000),
  .gpio_o()
);

  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
      

      // Send Start Bit
      r_RX_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
      
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_RX_Serial <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
      
      // Send Stop Bit
      r_RX_Serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE

  
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

  
  // Main Testing:
  initial
    begin
      @(posedge r_Clock);
      r_Reset=1;
      #500
      r_Reset=0;
      // Send a command to the UART (exercise Rx)
    while(instr_count<99 && INSTR[instr_count]!=32'h00000FFF)begin
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count][7:0]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count][15:8]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count][23:16]);
        @(posedge r_Clock);
        UART_WRITE_BYTE(INSTR[instr_count][31:24]);
        @(posedge r_Clock);
        instr_count = instr_count + 1'b1;

    end      
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'hff);
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h0f);
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h00);
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h00);
      // Check that the correct command was received

      $display("Executed");
            repeat (6) begin
			 repeat (1000) @(posedge r_Clock);
			 $display("+1000 cycles");
		end

    $finish();
    end
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule

