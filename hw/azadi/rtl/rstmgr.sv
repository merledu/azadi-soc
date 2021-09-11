
// basic reset managemnet logic for azadi

module rstmgr(

    input clk_i, //system clock
    input rst_ni, // system reset
    input prog_rst_ni,
   // input wire prog_i,
    output logic  sys_rst_ni // reset for system except debug module
);

  logic rst_d, rst_q;
  logic rst_fd, rst_fq; // follower flip flop
  //logic prog_reg;
  
  always_comb begin
    if(!rst_ni) begin
      rst_d = 1'b0;
    end else begin
    /*if(!prog_reg) begin
      rst_d = 1'b0;
    end else */if(!prog_rst_ni) begin
      rst_d = 1'b0;
    end else begin
      rst_d = 1'b1;
    end 
    end
  end
  

 /* always_ff @(posedge clk_i or negedge rst_ni) begin
  	if(!rst_ni) begin
	  prog_reg <= 1'b0;		
	end else begin 
	if(!prog_rst_ni)begin
	  prog_reg <= 1'b1;
	end else begin
	  prog_reg <= 1'b0;
	end
        end
  end*/
  always_ff @(posedge clk_i or negedge rst_ni) begin
	if(!rst_ni) begin
	  rst_q <= 1'b0;
	end else begin
	  rst_q <= rst_d;
	end
    
  end

  assign rst_fd = rst_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    	if(!rst_ni) begin
	  rst_fq <= 1'b0;
	end else begin
	  rst_fq <= rst_fd;
	end
  end

  assign sys_rst_ni = rst_fq;

endmodule
