 
module sram_32x1024
(
  input logic          clk_i,
  input logic 	       rst_ni,
  
  input logic 	       csb_i,
  input logic 	       web_i,
  input logic  [3:0]   wmask_i,
  input logic  [9:0]   addr_i,
  input logic  [31:0]  wdata_i,
  output logic [31:0]  rdata_o
);
 

////////////////////////////////////////
//				      //
//         ADDR BANK SELECTION        //
//				      //
////////////////////////////////////////

  logic [1:0] bank_sel;
  
  always_ff @(negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      bank_sel <= '0;
    end else begin
      bank_sel <= addr_i[9:8];
    end
  end

  logic [7:0] addr1;
  logic [7:0] addr2;
  logic [7:0] addr3;
  logic [7:0] addr4;
  
  logic csb1;
  logic csb2;
  logic csb3;
  logic csb4;
 
 
  always_comb begin
    {csb1, addr1} = (addr_i[9:8] == 2'b00) ? {csb_i, addr_i[7:0]} : {1'b1, 8'b0};
    {csb2, addr2} = (addr_i[9:8] == 2'b01) ? {csb_i, addr_i[7:0]} : {1'b1, 8'b0};
    {csb3, addr3} = (addr_i[9:8] == 2'b10) ? {csb_i, addr_i[7:0]} : {1'b1, 8'b0};
    {csb4, addr4} = (addr_i[9:8] == 2'b11) ? {csb_i, addr_i[7:0]} : {1'b1, 8'b0};
  end  
////////////////////////////////////////
//				      //
//         DATA BANK SELECTION        //
//				      //
////////////////////////////////////////

  logic [31:0] rdata1;
  logic [31:0] rdata2;
  logic [31:0] rdata3;
  logic [31:0] rdata4;
  
  always_comb begin
//     rdata_o = (addr_i[9:8] == 2'b00) ? rdata1 : (addr_i[9:8] == 2'b01) ? rdata2 :
// 	      (addr_i[9:8] == 2'b10) ? rdata3 : (addr_i[9:8] == 2'b11) ? rdata4 : 32'b0;
    if(bank_sel == 2'b01) begin
      rdata_o = rdata2;
    end else if(bank_sel == 2'b00) begin
      rdata_o = rdata1;
    end else if(bank_sel == 2'b10) begin
      rdata_o = rdata3;
    end else if(bank_sel == 2'b11) begin
      rdata_o = rdata4;
    end else begin
      rdata_o = '0;
    end
  end


  
  sky130_sram_1kbyte_1rw1r_32x256_8 sram1(
   `ifdef USE_POWER_PINS
     .vccd1	(),
     .vssd1	(),
   `endif
    // Port 0: RW
     .clk0	(clk_i),
     .csb0	(csb1),
     .web0	(web_i),
     .wmask0	(wmask_i),
     .addr0	(addr1),
     .din0	(wdata_i),
     .dout0	(rdata1),
    // Port 1: R
     .clk1	(1'b0),
     .csb1	(1'b1),
     .addr1	('0),
     .dout1	()
  );
  
  
  sky130_sram_1kbyte_1rw1r_32x256_8 sram2(
   `ifdef USE_POWER_PINS
     .vccd1	(),
     .vssd1	(),
   `endif
    // Port 0: RW
     .clk0	(clk_i),
     .csb0	(csb2),
     .web0	(web_i),
     .wmask0	(wmask_i),
     .addr0	(addr2),
     .din0	(wdata_i),
     .dout0	(rdata2),
    // Port 1: R
     .clk1	(1'b0),
     .csb1	(1'b1),
     .addr1	(),
     .dout1	()
  );  
  
  sky130_sram_1kbyte_1rw1r_32x256_8 sram3(
   `ifdef USE_POWER_PINS
     .vccd1	(),
     .vssd1	(),
   `endif
    // Port 0: RW
     .clk0	(clk_i),
     .csb0	(csb3),
     .web0	(web_i),
     .wmask0	(wmask_i),
     .addr0	(addr3),
     .din0	(wdata_i),
     .dout0	(rdata3),
    // Port 1: R
     .clk1	(1'b0),
     .csb1	(1'b1),
     .addr1	(),
     .dout1	()
  );
  
  sky130_sram_1kbyte_1rw1r_32x256_8 sram4(
   `ifdef USE_POWER_PINS
     .vccd1	(),
     .vssd1	(),
   `endif
    // Port 0: RW
     .clk0	(clk_i),
     .csb0	(csb4),
     .web0	(web_i),
     .wmask0	(wmask_i),
     .addr0	(addr4),
     .din0	(wdata_i),
     .dout0	(rdata4),
    // Port 1: R
     .clk1	(1'b0),
     .csb1	(1'b1),
     .addr1	(),
     .dout1	()
  );
 
endmodule