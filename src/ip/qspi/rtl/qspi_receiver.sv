`timescale 1ns/1ps
module qspi_receiver(
  input logic clk_i,
  input logic rst_ni,
    
  input logic [3:0] s_in_i,
  input logic       enb_i,
  output logic [31:0] p_out_o
);

  logic [31:0] shift_reg;
  
  always_ff @(negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      shift_reg <= '0;
    end else begin
      if(enb_i) begin
        shift_reg <=  {shift_reg[27:0], s_in_i};
      end 
    end
  end
    
  assign p_out_o = shift_reg;

endmodule
