module sram_fifo#(
    parameter int Depth = 9,
    parameter int Width = 128
)(i_clk,i_rst,read_en,write_en,data_in,data_out,addr);
  input logic i_clk,i_rst;
  input logic read_en,write_en;
  input logic [Width-1:0] data_in;
  output logic [Width-1:0] data_out;
  input logic [Depth-1:0] addr;

  reg [Width-1:0] mem_space[Depth-1:0];

  always@(posedge i_clk or posedge i_rst)
    begin
      if(i_rst)
        data_out<=0;

      else if( write_en && !read_en)
        mem_space[addr]<=data_in;

      else if(read_en && !write_en)
       data_out<=data_in;
      else
        data_out<=0;

    end

endmodule