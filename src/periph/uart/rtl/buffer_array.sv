
module buffer_array #(
  parameter int BUFFER_DEPTH = 256,
  parameter int BUFFER_WIDTH = 8,
  parameter int ADDR_WIDTH   = 8
) (
  input logic clk_i,
  input logic rst_ni,

  input logic re_i,
  input logic we_i,
  input logic clr_i,
  input logic [ADDR_WIDTH-1:0]   waddr_i,
  input logic [ADDR_WIDTH:0]     raddr_i,
  input logic [BUFFER_WIDTH-1:0] wdata_i,
  output logic [BUFFER_WIDTH:0]  rdata_o

);

  logic [BUFFER_WIDTH:0] buffer[0:BUFFER_DEPTH-1];
  logic [BUFFER_DEPTH-1:0] w_addr_dec;

  always_comb begin : we_a_decoder
   for (int unsigned i = 0; i < BUFFER_DEPTH; i++) begin
     w_addr_dec[i] = (waddr_i == 8'(i)) ?  we_i : 1'b0;
   end
  end


  for (genvar i = 0; i < BUFFER_DEPTH; i++) begin : g_rf_flops
   always_ff @(posedge clk_i or negedge rst_ni) begin
     if (!rst_ni) begin
       buffer[i] <= '0;
     end else if (clr_i) begin
       buffer[i] <= '0;
     end else if(w_addr_dec[i]) begin
       buffer[i] <= {wdata_i, 1'b1};
     end
   end
  end

  assign rdata_o = (raddr_i <= 9'hff) ? buffer[raddr_i[7:0]] : '0;


endmodule