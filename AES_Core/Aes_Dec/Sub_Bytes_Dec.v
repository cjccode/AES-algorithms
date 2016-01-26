/*-----------------------------------------------------------------------
				Subbytes is to The S box transform
-----------------------------------------------------------------------*/
module Sub_Bytes_Dec
	(
	input  [127:0] i_Din,// Data input
	output [127:0] o_Dout
	); 
//--------------------examplify modules-------------------------	
S_Box_Dec 	S_Box_Dec_00(.i_Din(i_Din[07:00]),.o_Dout(o_Dout[07:00]));
S_Box_Dec 	S_Box_Dec_01(.i_Din(i_Din[15:08]),.o_Dout(o_Dout[15:08]));
S_Box_Dec 	S_Box_Dec_02(.i_Din(i_Din[23:16]),.o_Dout(o_Dout[23:16]));
S_Box_Dec 	S_Box_Dec_03(.i_Din(i_Din[31:24]),.o_Dout(o_Dout[31:24]));
S_Box_Dec 	S_Box_Dec_04(.i_Din(i_Din[39:32]),.o_Dout(o_Dout[39:32]));
S_Box_Dec 	S_Box_Dec_05(.i_Din(i_Din[47:40]),.o_Dout(o_Dout[47:40]));
S_Box_Dec	S_Box_Dec_06(.i_Din(i_Din[55:48]),.o_Dout(o_Dout[55:48]));
S_Box_Dec 	S_Box_Dec_07(.i_Din(i_Din[63:56]),.o_Dout(o_Dout[63:56]));
S_Box_Dec 	S_Box_Dec_08(.i_Din(i_Din[71:64]),.o_Dout(o_Dout[71:64]));
S_Box_Dec 	S_Box_Dec_09(.i_Din(i_Din[79:72]),.o_Dout(o_Dout[79:72]));
S_Box_Dec 	S_Box_Dec_10(.i_Din(i_Din[87:80]),.o_Dout(o_Dout[87:80]));
S_Box_Dec 	S_Box_Dec_11(.i_Din(i_Din[95:88]),.o_Dout(o_Dout[95:88]));
S_Box_Dec 	S_Box_Dec_12(.i_Din(i_Din[103:096]),.o_Dout(o_Dout[103:096]));
S_Box_Dec 	S_Box_Dec_13(.i_Din(i_Din[111:104]),.o_Dout(o_Dout[111:104]));
S_Box_Dec 	S_Box_Dec_14(.i_Din(i_Din[119:112]),.o_Dout(o_Dout[119:112]));
S_Box_Dec 	S_Box_Dec_15(.i_Din(i_Din[127:120]),.o_Dout(o_Dout[127:120]));
endmodule
