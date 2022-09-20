
module serial2word #(
  parameter AddrWidth = 24,
  parameter DataWidth = 32,
  parameter BitPerSec = 1024
)(
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 rx_i,
  output logic                 start,
  output logic                 stop,
  output logic                 valid_o,
  output logic [AddrWidht-1:0] addr_o,
  output logic [DataWidth-1:0] wdata_o
);

  // This module will take data from UART on rx_i pin and store the resultant byte into FIFO.
  // Once the FIFO is full that means the data is ready to transmit as a word.

  // local parameters
  localparam EndingIstruction = 32'h0000_0FFF; 

  // Local Signals
  logic [3:0]  cntr;
  logic        wvalid;
  logic [7:0]  w_byte;
  logic [31:0] four_bytes;

  // Using the Azadi UART-RX module
  uart_rx u_uart_rx(
    .clk_i        ( clk_i     ),
    .rst_ni       ( rst_ni    ),
    .i_Rx_Serial  ( rx_i      ),
    .CLKS_PER_BIT ( BitPerSec ),
    .sbit_o       ( start     ),
    .o_Rx_DV      ( wvalid    ),
    .o_Rx_Byte    ( w_byte    )
  );

  //////////////
  // Sift Reg
  //////////////
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cntr       <= '0;
      addr_o     <= '0;
      four_bytes <= '0;
    end else begin
      if (wvalid) begin
        four_bytes <= {four_bytes[23:0], w_byte};
        cntr       <= &cntr ? '0 : {cntr[2:0], wvalid};
        addr_o     <= &cntr ? addr_o + 4 : addr_o;
      end
    end
  end
  
  assign valid_o = &cntr ? 1'b1 : 1'b0;
  assign wdata_o = four_bytes;
  assign stop    = (four_bytes == EndingIstruction) ? 1'b1 : 1'b0;

endmodule : serial2word
