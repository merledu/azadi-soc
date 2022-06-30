
module generic_fifo #(
  parameter DWIDTH     = 8,
  parameter AWIDTH     = 8,
  parameter FDEPTH     = 256,
  parameter BYTE_WRITE = 0,
  parameter BYTE_READ  = 0
)(
  input logic  clk_i,
  input logic  rst_ni,
  
  input logic  re_i,
  input logic  we_i,
  input logic  clr_i,
  input logic  rst_i, 
  output logic buffer_full,
  
  input logic [31:0] 	     wdata_i,
   
  output logic [31:0]       rdata_o,
  
  output logic [AWIDTH:0] bsize_o,
  output logic [AWIDTH:0] r_size_o

);

  logic [AWIDTH:0] raddr;
  logic [AWIDTH:0] waddr;
  logic msb_comp;
  logic pointer_equal;
  logic buffer_empty;
 // logic buffer_overflow;
 
  logic [DWIDTH:0] buffer[0:FDEPTH];
  logic [FDEPTH-1:0] w_addr_dec;
  
  // write address
  
  if(BYTE_WRITE == 1) begin
    always_ff @ (posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
	waddr <= '0;
      end else begin
	if(clr_i) begin
	  waddr <= '0;
      end else if(we_i) begin
	waddr <= waddr + 1;
      end else begin
	waddr <= waddr;
      end
     end
    end
  end else begin
    always_ff @ (posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
	waddr <= '0;
      end else begin
	if(clr_i) begin
	  waddr <= '0;
      end else if(we_i) begin
	waddr <= waddr + 4;
      end else begin
	waddr <= waddr;
      end
     end
    end  
  end
  
  
  // read adderss
  if(BYTE_READ == 1) begin
    always_ff @ (posedge clk_i or negedge rst_ni) begin
      if(!rst_ni) begin
	raddr <= '0;
      end else begin 
	if(rst_i) begin
	  raddr <= '0;
	end else if (re_i & (~buffer_empty)) begin
	  raddr <= raddr + 1;
	end else begin
	  raddr <= raddr;
	end
      end
    end
  end else begin
    always_ff @ (posedge clk_i or negedge rst_ni) begin
      if(!rst_ni) begin
	raddr <= '0;
      end else begin 
	if(rst_i) begin
	  raddr <= '0;
	end else if (re_i & (~buffer_empty)) begin
	  raddr <= raddr + 4;
	end else begin
	  raddr <= raddr;
	end
      end
    end
  end

  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      buffer_full <= 1'b0;
    end else begin 
      if(clr_i) begin
	buffer_full <= 1'b0;
      end else if((waddr >= 8'hff) & we_i) begin
	buffer_full <= 1'b1;
      end else if(raddr > 8'h00) begin
	buffer_full <= 1'b0;
      end
    end
  end
  
  always_ff @ (posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      buffer_empty <= 1'b0;
    end else begin
      if(rst_i) begin
	buffer_empty <= 1'b0;
      end else if((raddr >= 8'hff) & re_i) begin
	buffer_empty <= 1'b1;
      end 
    end
  end
  
if(BYTE_WRITE == 1) begin

   always_ff @(posedge clk_i or negedge rst_ni) begin
     if (!rst_ni) begin
      for (int unsigned i = 0; i < FDEPTH; i++) begin
       buffer[i] <= '0;
      end
     end else if (clr_i) begin
      for (int unsigned i = 0; i < FDEPTH; i++) begin
       buffer[i] <= '0;
      end
     end else if(we_i) begin
       buffer[waddr] <= {wdata_i[7:0], 1'b1};
       buffer[FDEPTH]<= 9'b0;
     end
   end

end else begin

 always_ff @(posedge clk_i or negedge rst_ni) begin
   if (!rst_ni) begin
    for (int unsigned i = 0; i < FDEPTH; i++) begin
     buffer[i] <= '0;
    end
   end else if (clr_i) begin
    for (int unsigned i = 0; i < FDEPTH; i++) begin
     buffer[i] <= '0;
    end
   end else if(we_i) begin
     buffer[waddr]     <= {wdata_i[7:0],   1'b1};
     buffer[waddr + 1] <= {wdata_i[15:8],  1'b1};
     buffer[waddr + 2] <= {wdata_i[23:16], 1'b1};
     buffer[waddr + 3] <= {wdata_i[31:24], 1'b1};
     buffer[FDEPTH]<= 9'b0;
   end
 end
end
  
//  if(BYTE_WRITE == 1) begin
//  always_ff @(posedge clk_i or negedge rst_ni) begin
//   if(!rst_ni) begin
//   buffer <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//   end else if (clr_i) begin
//   buffer <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//   end else if(we_i) begin
//	buffer[waddr] <= {wdata_i[7:0], 1'b1};
//	buffer[9'd256]<= 9'b0;
//      end
//    end
//  end else begin
//    always_ff @(posedge clk_i or negedge rst_ni) begin
//     if(!rst_ni) begin
//       buffer <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//     end else if (clr_i) begin
//     buffer <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//     end else if(we_i) begin
//       buffer[waddr]     <= {wdata_i[7:0],   1'b1};
//       buffer[waddr + 1] <= {wdata_i[15:8],  1'b1};
//       buffer[waddr + 2] <= {wdata_i[23:16], 1'b1};
//       buffer[waddr + 3] <= {wdata_i[31:24], 1'b1};
//       buffer[9'd256]<= 9'b0;
//      end
//    end
//  end
  
  if(BYTE_READ == 1) begin
   always @(*) begin
     if(re_i && (raddr <= 9'h100)) begin
       rdata_o = {24'b0,buffer[raddr]};
     end /*else begin
       rdata_o = '0;
     end*/
   end
  end else begin
   always @(*) begin
     if(re_i && (raddr <= 9'h100)) begin
       rdata_o[7:0]   = buffer[raddr][8:1];
       rdata_o[15:8]  = buffer[raddr + 1][8:1];
       rdata_o[23:16] = buffer[raddr + 2][8:1];
       rdata_o[31:24] = buffer[raddr + 3][8:1];
     end /*else begin
       rdata_o = '0;
     end*/
   end
  end
  assign bsize_o =  waddr;
  assign r_size_o = raddr;

endmodule