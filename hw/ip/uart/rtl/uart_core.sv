
module uart_core (
    input  logic clk_i,
    input  logic rst_ni,
    
    input  logic ren,
    input  logic we,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic [7:0]  addr,    
    output logic tx_o,
    input  logic rx_i,
    
    output logic intr_rx,
    output logic intr_tx
);
    localparam ADDR_CTRL = 0; // write
    localparam ADDR_TX   = 4; // write
    localparam ADDR_RX   = 8; // read
    localparam RX_EN     = 12; // write
    localparam TX_EN     = 16; // write
    localparam RX_STATUS = 20; // read
    localparam RX_SC     = 24; // write
    localparam TX_FIFO_EN = 28; // write
    localparam TX_FIFO_CLEAR = 32; // write
    localparam TX_FIFO_RESET = 36; // write
    localparam RX_TIMEOUT    = 40; // write
    localparam RX_FIFO_RST   = 44; // write
    localparam RX_FIFO_CLR   = 48; // write
    localparam RX_BUFFER_SIZE = 52; // write
    
    logic [15:0] control;
    logic [7:0]  tx;
    logic [7:0]  rx;
    logic [31:0]  rx_val;
    logic        rx_en;
    logic        tx_en;
    logic        rx_status;
    logic        rx_clr;
    logic        rx_done;
    logic 	 rx_sbit;
    logic 	 rx_fifo_rst;
    logic 	 rx_fifo_clr;
    logic [31:0] rx_timeout;
    logic 	 addr_rx_fifo;
    logic        addr_tx_fifo;
    logic  [31:0] tx_fifo_data;
    logic        tx_fifo_init;
    logic 	 tx_fifo_op;
    logic 	 tx_fifo_re;
    logic 	 tx_fifo_we;
    logic 	 tx_en_sel;
    logic  [7:0] tx_data_sel;
    logic        tx_done;
    logic 	 tx_fifo_clear;
    logic 	 tx_fifo_reset;
    logic  [8:0] rx_buffer_size;
    logic  [8:0] fifo_read_size;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            control <= 16'b0;
            tx      <= 8'b0;
            rx_en   <= 1'b0;
            tx_en   <= 1'b0;
	    rx_clr  <= 1'b1;
	    tx_fifo_init <= 1'b0;
	    tx_fifo_op   <= 1'b0;
	    tx_fifo_clear   <= 1'b0;
	    tx_fifo_reset   <= 1'b0;
	    rx_fifo_clr     <= 1'b0;
	    rx_fifo_rst     <= 1'b0;
        end else begin
          if(~ren & we) begin
            if(addr == ADDR_CTRL) begin
                control  <= wdata[15:0];
            end else if (addr == RX_EN) begin
                rx_en <= wdata[0];
            end else if(addr == TX_EN) begin
                tx_en <= wdata[0];
            end else if(addr == RX_SC) begin
	        rx_clr <= wdata[0];
	    end else if(addr == TX_FIFO_EN) begin
	        tx_fifo_init <= wdata[0];
	    end else if(addr == TX_FIFO_CLEAR) begin
	        tx_fifo_clear <= wdata[0];
	    end else if(addr == TX_FIFO_RESET) begin
	        tx_fifo_reset <= wdata[0];
	    end else if(addr == RX_TIMEOUT) begin
	        rx_timeout <= wdata;
	    end else if(addr == RX_FIFO_RST) begin
	        rx_fifo_rst <= wdata[0];
	    end else if(addr == RX_FIFO_CLR) begin
	        rx_fifo_clr <= wdata[0];
	    end
	  end else begin
	    rx_fifo_clr     <= 1'b0;
	    rx_fifo_rst     <= 1'b0;
	    tx_fifo_clear   <= 1'b0;
	    tx_fifo_reset   <= 1'b0;
	    tx_fifo_init <= 1'b0;
	  end
	end     
      end
  
  assign addr_tx_fifo = (addr == ADDR_TX) ? 1'b1: 1'b0;
  assign tx_fifo_re   = ((tx_done & tx_fifo_data[0]) & (fifo_read_size < 256)) | tx_fifo_init ;
  assign tx_fifo_we   = addr_tx_fifo & we;
  assign tx_en_sel    = tx_en & tx_fifo_data[0];
  
  assign addr_rx_fifo = (addr == ADDR_RX) ? 1'b1: 1'b0;
  //assign rx_timeout   = (addr == RX_TIMEOUT) & we ? wdata : '0;
  
 logic test;
generic_fifo #(
  .DWIDTH	(8),
  .AWIDTH	(8),
  .FDEPTH	(64),
  .BYTE_WRITE   (0),
  .BYTE_READ    (1)
) write_fifo (
  .clk_i	(clk_i),
  .rst_ni	(rst_ni),
  
  .re_i		(tx_fifo_re),
  .we_i		(tx_fifo_we),
  .clr_i	(tx_fifo_clear),
  .rst_i	(tx_fifo_reset),
  .wdata_i	(wdata),
  
  .buffer_full	(),
  .rdata_o	(tx_fifo_data),
  .bsize_o	(),
  .r_size_o     (fifo_read_size)
);
    
uart_tx u_tx (
   .clk_i       (clk_i),
   .rst_ni      (rst_ni),
   .tx_en       (tx_en_sel),
   .i_TX_Byte   (tx_fifo_data[8:1]), 
   .CLKS_PER_BIT(control),
   .o_TX_Serial (tx_o),
   .o_TX_Done   (tx_done)
);


generic_fifo #(
  .DWIDTH	(8),
  .AWIDTH	(8),
  .FDEPTH	(256),
  .BYTE_WRITE   (1),
  .BYTE_READ    (0)
) read_fifo (
  .clk_i	(clk_i),
  .rst_ni	(rst_ni),
  
  .re_i		(addr_rx_fifo & ren),
  .we_i		(rx_done),
  .clr_i	(rx_fifo_clr),
  .rst_i	(rx_fifo_rst),
  .wdata_i	(rx),
  
  .buffer_full	(),
  .rdata_o	(rx_val),
  .bsize_o	(rx_buffer_size),
  .r_size_o     ()
);
    
uart_rx u_rx(
  .clk_i        (clk_i),
  .rst_ni       (rst_ni),
  .i_Rx_Serial  (rx_en? rx_i: 1'b1),
  .o_Rx_DV      (rx_done),
  .sbit_o       (rx_sbit),
  .CLKS_PER_BIT (control),
  .o_Rx_Byte    (rx)
);


rx_timer rx_time(
  .clk_i	(clk_i),
  .rst_ni	(rst_ni),
  
  .ten_i	(rx_en),
  .rx_start_i	(rx_sbit),
  .wdata_i	(rx_timeout),
  
  .rx_timeout_o	(intr_rx)

);

// assign test = intr_rx & uart_init_rx;

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
  end else if(tx_done & (~tx_fifo_data[0])) begin
    intr_tx <= 1'b1;
  end else begin
    intr_tx <= 1'b0;
  end
 end
  
 assign rdata = (addr == 20)? rx_status : (addr == ADDR_RX)? rx_val : ((addr == RX_BUFFER_SIZE)) ? rx_buffer_size : 0;   
      
   
endmodule
