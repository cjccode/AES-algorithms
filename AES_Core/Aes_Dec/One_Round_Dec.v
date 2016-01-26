/*-----------------------------------------------------------------------
				one iteration transformation
-----------------------------------------------------------------------*/
module One_Round_Dec
	(
	input [3:0] i_Round_Times,
	input [127:0] i_Round_key,
	input [127:0] i_Din,
	
	output [127:0] o_Dout
	);
wire [127:0]w_Shift_Rows_Dout,w_Sub_Bytes_Dout,w_Add_Round_Key,w_Mix_Columns_Dout;
//-----------instantiation--------------
Shift_Rows_Dec
Shift_Rows_Dec_0
	(
	.i_Din(i_Din),
	.o_Dout(w_Shift_Rows_Dout)
	); 
Sub_Bytes_Dec
Sub_Bytes_Dec_0
	(
	.i_Din(w_Shift_Rows_Dout),
	.o_Dout(w_Sub_Bytes_Dout)
	); 
	
assign w_Add_Round_Key = w_Sub_Bytes_Dout^i_Round_key;
							
Mix_Columns_Dec
Mix_Columns_Dec_0
	(
	.i_Din(w_Add_Round_Key),
	.o_Dout(w_Mix_Columns_Dout)
	);  
assign o_Dout =(i_Round_Times==0) ? w_Add_Round_Key : w_Mix_Columns_Dout;

endmodule








