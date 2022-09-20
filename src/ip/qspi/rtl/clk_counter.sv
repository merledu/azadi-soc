`timescale 1ns/1ps

module clk_counter (
  input logic clk_i,
  input logic rst_ni,

  input logic enable_i,
  input logic clear_i,
  input logic [5:0] max_count_i,

  output logic [5:0] clk_count_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      clk_count_o <= '0;
    end else begin
      if(enable_i) begin
        clk_count_o <= clk_count_o + 6'b1;
      end else if (clear_i) begin
        clk_count_o <= '0;
      end
    end
  end
endmodule
