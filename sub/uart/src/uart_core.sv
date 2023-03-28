
module uart_core (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        ren,
    input  logic        we,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic [7:0]  addr,
    output logic        tx_o,
    output logic        tx_oe,
    input  logic        rx_i,

    output logic        intr_tx,
    output logic        intr_rx
);

  // Registers base address    
  localparam ADDR_CPB      = 0; // write
  localparam ADDR_TX        = 4; // write
  localparam ADDR_RX        = 8; // read
  localparam RX_EN          = 12; // write
  localparam TX_EN          = 16; // write
  localparam RX_STATUS      = 20; // read
  localparam RX_BYTE        = 56;
  localparam RX_SC          = 24; // write
  localparam TX_FIFO_EN     = 28; // write
  localparam TX_FIFO_CLEAR  = 32; // write
  localparam TX_FIFO_RESET  = 36; // write
  localparam RX_TIMEOUT     = 40; // write
  localparam RX_FIFO_RST    = 44; // write
  localparam RX_FIFO_CLR    = 48; // write
  localparam RX_BUFFER_SIZE = 52; // write

  // buffer width
  localparam BUFFER_WIDTH = 8;

  logic [15:0]              clks_per_bit;
  logic [BUFFER_WIDTH-1:0]  tx, rx, rx_val;
  logic                     rx_byte_enb;
  logic                     rx_en;
  logic                     tx_en;
  logic                     rx_status;
  logic                     rx_clr;
  logic                     rx_done;
  logic                     rx_timer_intr;
  logic 	                  rx_intr;
  logic 	                  rx_sbit;
  logic 	                  rx_fifo_rst;
  logic 	                  rx_fifo_clr;
  logic                     rx_fifo_empty;
  logic                     rx_fifo_full;
  logic [31:0]              rx_timeout;
  logic 	                  addr_rx_fifo;
  logic                     addr_tx_fifo;
  logic  [BUFFER_WIDTH-1:0] tx_fifo_data;
  logic                     tx_fifo_init;
  logic 	                  tx_fifo_op;
  logic 	                  tx_fifo_re;
  logic 	                  tx_fifo_we;
  logic 	                  tx_en_sel;
  logic  [BUFFER_WIDTH-1:0] tx_data_sel;
  logic                     tx_done;
  logic 	                  tx_fifo_clear;
  logic 	                  tx_fifo_reset;
  logic                     tx_fifo_empty;
  logic                     tx_fifo_full;
  logic  [BUFFER_WIDTH-1:0] rx_buffer_size;
  logic                     tx_done_delay1;
  logic                     tx_done_delay2;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      clks_per_bit           <= 16'b0;
      tx                <= 8'b0;
      rx_en             <= 1'b0;
      tx_en             <= 1'b0;
      tx_oe             <= 1'b0;
	    rx_clr            <= 1'b1;
      rx_byte_enb       <= 1'b0;
	    tx_fifo_init      <= 1'b0;
	    tx_fifo_op        <= 1'b0;
	    tx_fifo_clear     <= 1'b0;
	    tx_fifo_reset     <= 1'b0;
      tx_done_delay1    <= 1'b0;
      tx_done_delay2    <= 1'b0;
    end else begin
      tx_done_delay1 <= tx_done;
      tx_done_delay2 <= tx_done_delay1;
      if (~ren & we) begin
        if(addr == ADDR_CPB) begin
          clks_per_bit  <= wdata[15:0];
        end else
        if (addr == RX_EN) begin
          rx_en <= wdata[0];
        end else
        if(addr == TX_EN) begin
          tx_en <= wdata[0];
          tx_oe <= wdata[0];
        end else
        if(addr == RX_SC) begin
	        rx_clr <= wdata[0];
	      end else
        if(addr == TX_FIFO_EN) begin
	        tx_fifo_init <= wdata[0];
	      end else
        if(addr == TX_FIFO_CLEAR) begin
	        tx_fifo_clear <= wdata[0];
	      end else
        if(addr == TX_FIFO_RESET) begin
	        tx_fifo_reset <= wdata[0];
	      end else
        if(addr == RX_TIMEOUT) begin
	        rx_timeout <= wdata;
	      end else
        if(addr == RX_FIFO_RST) begin
	        rx_fifo_rst <= wdata[0];
	      end else
        if(addr == RX_FIFO_CLR) begin
	        rx_fifo_clr <= wdata[0];
        end else if(addr == RX_BYTE) begin
          rx_byte_enb <= wdata[0];
        end
	    end else begin
        if(intr_tx) begin
          tx_oe <= 1'b0;
        end
        tx_en         <= 1'b0;
	      tx_fifo_clear <= 1'b0;
	      tx_fifo_reset <= 1'b0;
	      tx_fifo_init  <= 1'b0;
        rx_fifo_clr   <= 1'b0;
	    end
	  end
  end
  
  assign addr_tx_fifo = (addr == ADDR_TX) ? 1'b1: 1'b0;
  assign tx_fifo_re   = (tx_done & ~tx_fifo_empty) | tx_fifo_init;
  assign tx_fifo_we   = addr_tx_fifo & we;
  assign tx_en_sel    = tx_en | (~tx_fifo_empty & tx_done_delay2);
  assign addr_rx_fifo = (addr == ADDR_RX) ? 1'b1: 1'b0;

  fifo_gen #(
    .DATA_WIDTH ( 8 ),
    .ADDR_WIDTH ( 8 )
  )u_write_buffer(
    .clk_i         ( clk_i         ),
    .rst_ni        ( rst_ni        ),
    .rd_i          ( tx_fifo_re    ), 
    .wr_i          ( tx_fifo_we    ),
    .wdata_i       ( wdata[7:0]    ),
    .clr_i         ( tx_fifo_clear ),
    .empty_o       (               ), 
    .empty_delay_o ( tx_fifo_empty ),
    .full_o        (               ),
    .rdata_o       ( tx_fifo_data  ),
    .size_o        (               )
  );

  uart_tx u_tx (
    .clk_i       ( clk_i        ),
    .rst_ni      ( rst_ni       ),
    .tx_en       ( tx_en_sel    ),
    .i_TX_Byte   ( tx_fifo_data ), 
    .CLKS_PER_BIT( clks_per_bit ),
    .o_TX_Serial ( tx_o         ),
    .o_TX_Done   ( tx_done      )
  );

  fifo_gen #(
    .DATA_WIDTH ( 8 ),
    .ADDR_WIDTH ( 8 )
  )u_read_buffer(
    .clk_i         ( clk_i              ),
    .rst_ni        ( rst_ni             ),
    .rd_i          ( addr_rx_fifo & ren ), 
    .wr_i          ( rx_done            ),
    .wdata_i       ( rx                 ),
    .clr_i         ( rx_fifo_clr        ),
    .empty_o       (                    ), 
    .empty_delay_o ( rx_fifo_empty      ),
    .full_o        (                    ),
    .rdata_o       ( rx_val             ),
    .size_o        ( rx_buffer_size     )
  );

  uart_rx u_rx(
    .clk_i        ( clk_i              ),
    .rst_ni       ( rst_ni             ),
    .i_Rx_Serial  ( rx_en ? rx_i: 1'b1 ),
    .o_Rx_DV      ( rx_done            ),
    .sbit_o       ( rx_sbit            ),
    .CLKS_PER_BIT ( clks_per_bit       ),
    .o_Rx_Byte    ( rx                 )
  );

  uart_timer rx_timer(
    .clk_i	      ( clk_i                ),
    .rst_ni	      ( rst_ni               ),
    .ten_i	      ( rx_en & ~rx_byte_enb ),
    .rx_start_i	  ( rx_sbit              ),
    .wdata_i	    ( rx_timeout           ),
    .rx_timeout_o	( rx_timer_intr        )
  );

  assign intr_rx = rx_timer_intr | (rx_done & rx_byte_enb);
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      rx_status <= 1'b0;
    end else begin
  	  if (intr_rx) begin
  	    rx_status <= 1'b1;	
  	  end else if(!rx_clr) begin
  	    rx_status <= 1'b0;	
  	  end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      intr_tx <= 1'b0;
    end else if(tx_done & (tx_fifo_empty)) begin
      intr_tx <= 1'b1;
    end else begin
      intr_tx <= 1'b0;
   end
  end

  assign rdata = (addr == 20)? rx_status : (addr == ADDR_RX)? rx_val : ((addr == RX_BUFFER_SIZE)&ren) ? rx_buffer_size : 0;
endmodule
