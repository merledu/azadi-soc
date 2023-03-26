
module sram_fifo #(
  parameter AWIDTH = 4
)(
  input logic clk_i,
  input logic cen_i,
  input logic wen_i,

  input  logic [AWIDTH-1:0] addr_i,
  input  logic [7:0]        wdata_i,
  output logic [7:0]        rdata_o
);

  logic [7:0] mem_array [2**AWIDTH-1:0];

  always_ff @(posedge clk_i) begin
    if(!cen_i && !wen_i) begin
      mem_array[addr_i] <= wdata_i;
    end
  end

  always_ff @(posedge clk_i) begin
    if(!cen_i && wen_i) begin
      rdata_o <= mem_array[addr_i];
    end
  end

endmodule