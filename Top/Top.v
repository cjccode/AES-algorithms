/*-----------------------------------------------------------------------
                
		The top module which belongs to AES module 
				                                  ----designed by Leo Tu
									                  2015.5.20 11:05:03
													  
-------------------------------------------------------------------------*/


module  top_aes_128(
                    clk,
					rst_n,
					o_rd_in,
					i_data_in,
					i_empty_fifo,
					o_error,
					i_full_fifo,
					o_data_out,
					o_wr_out
					);
input clk;
input rst_n;
input i_empty_fifo;
input i_full_fifo;
input [33:0] i_data_in;

output o_rd_in;
output o_wr_out;
output o_error;
output [33:0] o_data_out;

wire o_load_data;
wire o_load_key;
wire o_mode;
wire o_en_clk;
wire [4:0] o_key_mode;
wire [15:0] data_len;
wire [127:0] o_data_in_aes;
wire [255:0] o_key_aes;

wire i_done;
wire [127:0] i_data_out_aes; 

wire fifo_state;
wire done_data;
wire [127:0] data_chain;

//-----------call up the former modules---------------
ctl_in  ctl_in(
                 .clk(clk),
                 .rst_n(rst_n),
                 .i_data_in(i_data_in),
			  .i_empty_fifo(i_empty_fifo),
                 .o_rd_in(o_rd_in),
			  .o_data_in_aes(o_data_in_aes),
			  .o_load_data(o_load_data),
			  .o_key_aes(o_key_aes),
			  .o_key_mode(o_key_mode),
			  .o_load_key(o_load_key),
			  .o_en_clk(o_en_clk),
			  .o_mode(o_mode),
			  .o_error(o_error),
			  .fifo_state(fifo_state),
			  .done_data(done_data),
			  .data_chain(data_chain),
			  .data_len(data_len)
			  );

ctl_out  ctl_out(
                   .clk(clk),
                   .rst_n(rst_n),
			    .i_done(i_done),
                   .i_full_fifo(i_full_fifo),
			    .i_data_out_aes(i_data_out_aes),
			    .o_wr_out(o_wr_out),
			    .o_data_out(o_data_out),
			    .fifo_state(fifo_state),
			    .data_chain(data_chain),
			    .done_data(done_data),
			    .data_len(data_len)
			    );	

Aes  aes(
          .i_Clk(clk),
		.i_Rst_n(rst_n),
		.i_Din_En(o_load_data),
		.i_Key(o_key_aes),
		.i_Din(o_data_in_aes),
		.i_Key_Mode(o_key_mode),
		.i_Key_En(o_load_key),
		.i_Mode(o_mode),
		.i_En(o_en_clk),
		.o_Dout_En(i_done),
		.o_Dout(i_data_out_aes)
		);				
endmodule