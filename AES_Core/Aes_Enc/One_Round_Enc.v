/*-----------------------------------------------------------------------
				one iteration transformation
-----------------------------------------------------------------------*/
module One_Round_Enc
	(
	input [3:0] i_Round_Times,
	input [1:0] i_Key_Mode,
	input [127:0] i_Round_key,
	input [127:0] i_Din,
	
	output [127:0] o_Dout
	);
wire [127:0] w_Sub_Bytes_Dout,w_Shift_Rows_Dout,w_Mix_Columns_Dout;
//-----------instantiation--------------
Sub_Bytes_Enc
Sub_Bytes_Enc_0
	(
	.i_Din(i_Din),
	.o_Dout(w_Sub_Bytes_Dout)
	); 
Shift_Rows_Enc
Shift_Rows_Enc_0
	(
	.i_Din(w_Sub_Bytes_Dout),
	.o_Dout(w_Shift_Rows_Dout)
	); 
Mix_Columns_Enc
Mix_Columns_Enc_0
	(
	.i_Din(w_Shift_Rows_Dout),
	.o_Dout(w_Mix_Columns_Dout)
	);  
assign o_Dout =( ((i_Key_Mode==0) && (i_Round_Times ==10)) || ((i_Key_Mode==1) && (i_Round_Times ==12))
				|| ((i_Key_Mode==2) && (i_Round_Times ==14)) )? w_Shift_Rows_Dout^i_Round_key:
				w_Mix_Columns_Dout^i_Round_key;// add round key
endmodule








