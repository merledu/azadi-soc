
module uart_core (
    input  clk_i,
    input  rst_ni,
    
    input  ren,
    input  we,
    input  [31:0] wdata,
    output [31:0] rdata,
    input  [7:0]  addr,    
    output tx_o,
    input  rx_i,
    
    output intr_tx
);
    
    localparam ADDR_CTRL = 0;
    localparam ADDR_TX   = 4;
    localparam ADDR_RX   = 8;
    localparam RX_EN     = 12;
    localparam TX_EN     = 16;
    localparam RX_STATUS = 20;
    localparam RX_SC     = 24;
    
    reg [15:0] control;
    reg [7:0]  tx;
    wire [7:0] rx;
    reg  [7:0] rx_reg;
    reg        rx_en;
    reg        tx_en;
    reg        rx_status;
    reg        rx_clr;
    wire       rx_done;
    
    always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            control <= 16'b0;
            tx      <= 8'b0;
            rx_en   <= 1'b0;
            tx_en   <= 1'b0;
	    rx_clr  <= 1'b1;
        end else begin
          if(~ren & we) begin
            if(addr == ADDR_CTRL) begin
                control  <= wdata[15:0];
            end else if (addr == ADDR_TX) begin
                tx  <= wdata[7:0];
            end else if (addr == RX_EN) begin
                rx_en <= wdata[0];
            end else if(addr == TX_EN) begin
                tx_en <= wdata[0];
            end else if(addr == RX_SC) begin
	        rx_clr <= wdata[0];
	    end else begin
                control <= 16'b0;
                tx      <= 8'b0;
                rx_en   <= 1'b0;
                tx_en   <= 1'b0;
		rx_clr  <= 1'b1;
            end
        end 
    end     
  end
    
    
uart_tx u_tx (
   .clk_i       (clk_i),
   .rst_ni      (rst_ni),
   .tx_en       (tx_en),
   .i_TX_Byte   (tx), 
   .CLKS_PER_BIT(control),
   .o_TX_Serial (tx_o),
   .o_TX_Done   (intr_tx)
);
    
uart_rx u_rx(
  .clk_i        (clk_i),
  .rst_ni       (rst_ni),
  .i_Rx_Serial  (rx_en? rx_i: 1'b1),
  .o_Rx_DV      (rx_done),
  .CLKS_PER_BIT (control),
  .o_Rx_Byte    (rx)
);

always @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        rx_status <= 1'b0;
	rx_reg    <= 8'b0;
    end else begin
        
	if (rx_done) begin
	   rx_reg  <= rx;
	   rx_status <= 1'b1;	
	end else if(!rx_clr) begin
	   rx_status <= 1'b0;	
	end
    end
end
  
 assign rdata = (addr == 20)? rx_status : (addr == 8)? rx_reg : 0;   
      
   
endmodule
