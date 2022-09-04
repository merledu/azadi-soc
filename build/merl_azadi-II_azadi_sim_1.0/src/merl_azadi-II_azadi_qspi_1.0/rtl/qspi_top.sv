module qspi_top(
  input logic clk_i,
  input logic rst_ni,

  input  tlul_pkg::tlul_h2d_t tl_i,
  output tlul_pkg::tlul_d2h_t tl_o,

  input  logic [3:0] qspi_i,
  output logic [3:0] qspi_o,
  output logic [3:0] qspi_oe,
  output logic       qspi_csb,
  output logic       qspi_clk
);

  logic [23:0] addr;
  logic        req;
  logic [31:0] data;
  logic        valid;
  logic        we;
  qspi_xip u_qspi(
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .addr_i   ((addr <<2) ),
    .req_i    (req),
    .rdata_o  (data),
    .rvalid_o (valid),
    .qspi_i   (qspi_i),
    .qspi_o   (qspi_o),
    .qspi_oe  (qspi_oe),
    .qspi_csb (qspi_csb),
    .qspi_clk (qspi_clk)
  );

  tlul_sram_adapter #(
    .SramAw       (24),
    .SramDw       (32), 
    .Outstanding  (2),  
    .ByteAccess   (1),
    .ErrOnWrite   (0),  // 1: Writes not allowed, automatically error
    .ErrOnRead    (0)   // 1: Reads not allowed, automatically error  

  ) qspi_tl_intf (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .tl_i      (tl_i),
    .tl_o      (tl_o), 
    .req_o     (req),
    .gnt_i     (valid),
    .we_o      (),
    .addr_o    (addr),
    .wdata_o   (),
    .wmask_o   (),
    .rdata_i   (data),
    .rvalid_i  (valid),
    .rerror_i  (2'b0)
  );
endmodule
