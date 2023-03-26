module serial2word #(
  parameter AddrWidth = 24,
  parameter DataWidth = 32,
  parameter ClocksPerBit = 16'd2604
)(
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 rx_i,
  input  logic                 lsb_i,
  output logic                 start,
  output logic                 stop,
  output logic                 valid_o,
  output logic [AddrWidth-1:0] addr_o,
  output logic [DataWidth-1:0] wdata_o
);

  // This module will take data from UART on rx_i pin and store the resultant byte into FIFO.
  // Once the FIFO is full that means the data is ready to transmit as a word.

  // local parameters
  localparam EndingIstruction = 32'hFFFF_FFFF; 

  // Local Signals
  logic [3:0]  cntr;
  logic        delay;
  logic        wvalid;
  logic [23:0] addr_d1;
  logic [23:0] addr_d2;
  logic [7:0]  w_byte;
  logic [31:0] four_bytes;

  // Using the Azadi UART-RX module
  puart_rx u_uart_rx(
    .clk_i        ( clk_i     ),
    .rst_ni       ( rst_ni    ),
    .i_Rx_Serial  ( rx_i      ),
    .CLKS_PER_BIT ( ClocksPerBit ),
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
      delay      <= '0;
      addr_o     <= 24'hff0004;
      four_bytes <= '0;
      addr_d1 <= 24'hff0004;
      addr_d2 <= 24'hff0004;
    end else begin
      addr_d1 <= &cntr ? addr_d1 + 4 : addr_d1;
      addr_d2 <= addr_d1;
      addr_o  <= addr_d2;
      cntr   <= &cntr ? '0 : cntr;
      delay  <= &cntr ?  1 : 0;
      if (wvalid && !stop) begin
        if(lsb_i) begin
          four_bytes <= {w_byte, four_bytes[31:8]};
        end else begin
          four_bytes <= {four_bytes[23:0], w_byte};
        end
        cntr       <= {cntr[2:0], wvalid};
      end
    end
  end

  assign valid_o = ((&cntr || delay ) && ~stop) ? 1'b1 : 1'b0;
  assign wdata_o = four_bytes;
  assign stop    = (four_bytes == EndingIstruction) ? 1'b1 : 1'b0;

endmodule : serial2word
