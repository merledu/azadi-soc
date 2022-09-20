
module sram #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 8) (
        input logic                  clock,
        input logic                  reset,
        input logic                  readEnable,
        input logic [ADDR_WIDTH-1:0] Address,
        output logic [DATA_WIDTH-1:0]readData,
        input logic                  writeEnable,
        input logic [DATA_WIDTH-1:0] writeData
);

localparam MEM_DEPTH = 256;
reg  [DATA_WIDTH-1:0]     sram[0:MEM_DEPTH-1];
always@(posedge clock) begin
if(!reset && writeEnable) sram[Address] <= writeData;
else if(!reset && readEnable) readData <= sram[Address];
else readData <= 'b0;
end
endmodule