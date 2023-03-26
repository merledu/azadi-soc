
module sram #(
  parameter int unsigned DW = 32, 
  parameter int unsigned AW = 8
) (
  input  logic          clk,
  input  logic          csb,
  input  logic          wenb,
  input  logic [3:0]    wmask,
  input  logic [AW-1:0] addr,
  input  logic [DW-1:0] wdata,
  output logic [DW-1:0] rdata
);

  localparam MEM_DEPTH = 2 ** AW;

  logic [DW-1:0] mem [0:MEM_DEPTH-1];

  always@(posedge clk) begin
    if (!csb) begin
      // Writing to SRAM
      if (!wenb) begin
        if (wmask[0]) begin
          mem[addr][7:0] <= wdata[7:0];
        end
        if (wmask[1]) begin
          mem[addr][15:8] <= wdata[15:8];
        end
        if (wmask[2]) begin
          mem[addr][23:16] <= wdata[23:16];
        end 
        if (wmask[3]) begin
          mem[addr][31:24] <= wdata[31:24];
        end
      end else begin
        // Reading from SRAM
        rdata <= mem[addr];
      end
    end
  end
endmodule
