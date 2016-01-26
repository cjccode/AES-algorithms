/*---------------------------------------------------------------------------------
                
		The controller of output which belongs to AES module 
				                                           ----designed by Leo Tu
									                           2015.5.20 11:03:34
															   
-----------------------------------------------------------------------------------*/


module ctl_out(clk,
               rst_n,
			   i_done,
               i_full_fifo,
			   i_data_out_aes,
			   o_wr_out,
			   o_data_out,
			   fifo_state,
			   data_chain,
			   done_data,
			   data_len
			   );
 
//----------define the input ports-----------//
input clk;
input rst_n;
input i_full_fifo;
input i_done;
input [7:0] data_len;
input [127:0] i_data_out_aes; 

//----------define the output ports----------//
output fifo_state;
output done_data;
output [127:0] data_chain;

output reg o_wr_out;
output reg [33:0] o_data_out;

//----------define all parameters and registers----------//
reg cstate;
reg nstate;
reg [2:0] cnt_flag;
reg [7:0] cnt_data;
reg [31:0] data_buff[3:1];

parameter s0 = 1'd0,s1 = 1'd1;

//-----------------FSM------------------------------------//
always@(negedge clk or negedge rst_n) begin
    if(!rst_n) cstate <= s0;
	else cstate <= nstate;
end

always@(i_full_fifo, cstate, cnt_flag, i_done) begin
    if(!i_full_fifo) begin
	    case(cstate)
		  s0:begin
		       if(i_done) nstate = s1;
			   else nstate = s0;
			 end
		  s1:begin
			   if(cnt_data == data_len) begin 
			       if(cnt_flag <= 3'd3) nstate = s1;
				   else nstate = s0;
			   end
			   else nstate = s1;
			 end
		  default: nstate = s0;
	    endcase
	end
end

always@(negedge clk or negedge rst_n) begin 
    if(!rst_n) begin
	    o_wr_out <= 1'b0;
		cnt_data <= 8'd0;
		cnt_flag <= 3'd0;
		data_buff[1] <= 32'd0;
		data_buff[2] <= 32'd0;
		data_buff[3] <= 32'd0;
		o_data_out <= 34'd0;
	end
	else begin
	       if(i_full_fifo) begin
			   o_wr_out <= 1'b0;
		   end
		   else begin
		          case(nstate)
				    s0:begin
						 o_wr_out <= 1'b0;
						 cnt_flag <=3'd0;
						 cnt_data <= 8'd0;
						 o_data_out <= 34'd0;
				       end
					s1:begin 
						 o_wr_out <= 1'b1;
						 if(cnt_data == data_len) begin          //   When the last bag is coming,  //
							 if(cnt_flag <= 3'b010) begin        //   we need the state stay in this part,  //
							     cnt_flag <= cnt_flag + 3'd1;    //   so we should set the counter zero until last clock.//
								 o_data_out <= {2'b00,data_buff[cnt_flag]};
							 end
							 else begin
							        if(cnt_flag == 3'b011) begin 
									    cnt_flag <= cnt_flag + 3'd1;
									    o_data_out <= {2'b10,data_buff[cnt_flag]};
									end
								  end
					     end
						 else begin
								if(cnt_data == 8'd0) begin
								    {data_buff[3],data_buff[2],data_buff[1],o_data_out[31:0]} <= i_data_out_aes;
							        o_data_out[33:32] <= 2'b01;
									cnt_flag <= 3'd1;
									cnt_data <= cnt_data + 8'd4;
								end
								else begin
								       if(i_done) begin
									       {data_buff[3],data_buff[2],data_buff[1],o_data_out[31:0]} <= i_data_out_aes;
							               o_data_out[33:32] <= 2'b00;
									       cnt_flag <= 3'd1;
									       cnt_data <= cnt_data + 8'd4;
								       end
								       else begin
							                  cnt_flag <= cnt_flag + 3'd1;
								              o_data_out <= {2'b00,data_buff[cnt_flag]};
									        end
								
							         end
							  end
					   end
					default:;
				  endcase
				end
		 end
end

assign fifo_state = i_full_fifo;
assign done_data = i_done;
assign data_chain = i_data_out_aes;

endmodule