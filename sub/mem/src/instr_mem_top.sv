
module instr_mem_top
(
  input logic clk_i,
  input logic rst_ni,
  
  input  tlul_pkg::tlul_h2d_t tl_i,
  output tlul_pkg::tlul_d2h_t tl_o,
  
  // iccm controller interface 
  input  [12:0] iccm_ctrl_addr,
  input  [31:0] iccm_ctrl_wdata,
  input  logic  iccm_ctrl_we,
  input  logic  iccm_wsel,
    
  // sram interface 
  output  logic        csb,
  output  logic [12:0] addr_o,
  output  logic [31:0] wdata_o,
  output  logic [3:0]  wmask_o,
  output  logic        we_o,
  input   logic [31:0] rdata_i
);

logic        rvalid;
logic        tl_we;
logic [31:0] tl_wmask;
logic [31:0] tl_wdata;
logic [12:0] tl_addr;
logic        tl_req;
logic [3:0]  mask_sel;

assign mask_sel[0] = (tl_wmask[7:0]   != 8'b0) ? 1'b1: 1'b0;
assign mask_sel[1] = (tl_wmask[15:8]  != 8'b0) ? 1'b1: 1'b0;
assign mask_sel[2] = (tl_wmask[23:16] != 8'b0) ? 1'b1: 1'b0;
assign mask_sel[3] = (tl_wmask[31:24] != 8'b0) ? 1'b1: 1'b0;

assign csb     = ~(iccm_wsel ? tl_req : iccm_ctrl_we);
assign addr_o  = (iccm_wsel) ? tl_addr  : iccm_ctrl_addr;
assign wdata_o = (iccm_wsel) ? tl_wdata : iccm_ctrl_wdata;
assign we_o    = ~((iccm_wsel) ? tl_we  : iccm_ctrl_we);
assign wmask_o = (iccm_wsel) ? mask_sel : 4'b1111;


 tlul_sram_adapter #(
  .SramAw       (13),
  .SramDw       (32), 
  .Outstanding  (2),  
  .ByteAccess   (1),
  .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
  .ErrOnRead    (0)   // 1: Reads not allowed, automatically error  

) inst_mem (
  .clk_i     (clk_i),
  .rst_ni    (rst_ni),
  .tl_i      (tl_i),
  .tl_o      (tl_o), 
  .req_o     (tl_req),
  .gnt_i     (1'b1),
  .we_o      (tl_we),
  .addr_o    (tl_addr),
  .wdata_o   (tl_wdata),
  .wmask_o   (tl_wmask),
  .rdata_i   (rdata_i),
  .rvalid_i  (rvalid),
  .rerror_i  (2'b0)
);

 always_ff @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    rvalid <= 1'b0;
  end else if (iccm_ctrl_we | tl_we) begin
    rvalid <= 1'b0;
  end else begin 
    rvalid <= tl_req;
  end
 end

endmodule
