`timescale 1ns/1ps

module qspi_transmitter (

    input logic clk_i,
    input logic rst_ni,
    
    input logic [31:0] p_data_i,
    input logic        t_enb_i,
    input logic        t_load_i,
    output logic [3:0] s_out_o
);

  logic [3:0]  shift_out;
  logic [31:0] temp_reg;
  always_ff @(negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      temp_reg  <= 32'h0000_0000;
    end else begin
      if(t_load_i) begin
        temp_reg <= p_data_i;
      end else if(t_enb_i)  begin
        temp_reg     <= {temp_reg[27:0], 4'b0};
      end
    end
  end
    
  always_comb begin
    s_out_o[0] = temp_reg[28];
    s_out_o[1] = temp_reg[29];
    s_out_o[2] = temp_reg[30];
    s_out_o[3] = temp_reg[31];  
  end

endmodule
