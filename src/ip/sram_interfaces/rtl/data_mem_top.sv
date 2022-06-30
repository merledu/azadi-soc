module data_mem_top
(
  input logic clk_i,
  input logic rst_ni,

// tl-ul insterface
  input tlul_pkg::tl_h2d_t tl_d_i,
  output tlul_pkg::tl_d2h_t tl_d_o,
  
// sram interface
  output  logic        csb,
  output  logic [11:0] addr_o,
  output  logic [31:0] wdata_o,
  output  logic [3:0]  wmask_o,
  output  logic        we_o,
  input   logic [31:0] rdata_i
);

  logic        tl_req;
  logic [31:0] tl_wmask;
  logic        we_i;
  logic        rvalid_o;
  
  logic        data_csbD;
  logic [11:0] data_addrD;
  logic [3:0]  data_wmaskD;
  logic        data_weD;
  logic [31:0] data_wdataD;

  assign data_wmaskD[0] = (tl_wmask[7:0]   != 8'b0) ? 1'b1: 1'b0;
  assign data_wmaskD[1] = (tl_wmask[15:8]  != 8'b0) ? 1'b1: 1'b0;
  assign data_wmaskD[2] = (tl_wmask[23:16] != 8'b0) ? 1'b1: 1'b0;
  assign data_wmaskD[3] = (tl_wmask[31:24] != 8'b0) ? 1'b1: 1'b0; 
  
  assign data_weD    = ~we_i;
  assign data_csbD   = ~tl_req;
  
  always_ff @(negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      addr_o =  '0;
      csb    =  '1;
      wmask_o=  '0;
      we_o   =  '0;
      wdata_o=  '0;
    end else begin
      addr_o =  data_addrD;
      csb    =  data_csbD;
      wmask_o=  data_wmaskD;
      we_o   =  data_weD;
      wdata_o=  data_wdataD;
    end
  
  end
  
  tlul_sram_adapter #(
    .SramAw       (12),
    .SramDw       (32), 
    .Outstanding  (4),  
    .ByteAccess   (1),
    .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
    .ErrOnRead    (0) 

  ) data_mem (
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .tl_i     (tl_d_i),
    .tl_o     (tl_d_o), 
    .req_o    (tl_req),
    .gnt_i    (1'b1),
    .we_o     (we_i),
    .addr_o   (data_addrD),
    .wdata_o  (data_wdataD),
    .wmask_o  (tl_wmask),
    .rdata_i  (rdata_i), 
    .rvalid_i (rvalid_o),
    .rerror_i (2'b0)

  );


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_o <= 1'b0;
    end else if (we_i) begin
      rvalid_o <= 1'b0;
    end else begin 
      rvalid_o <= tl_req;
    end
  end

endmodule
