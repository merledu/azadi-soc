module rom #(
  parameter  int Width       = 32,
  parameter  int Depth       = 8 // 1kB default
) (
  input  logic             clk_i,
  input  logic             req_i,
  input  logic [Depth-1:0] addr_i,
  output logic [Width-1:0] rdata_o
);
  localparam actual_depth = 256;
  logic [Width-1:0] mem [0:actual_depth-1];

  always_ff @(posedge clk_i) begin
    if (req_i) begin
      rdata_o <= mem[addr_i];
    end
  end
endmodule
