/*-----------------------------------------------------------------------
				mix columns transformation
-----------------------------------------------------------------------*/
module Mix_Columns_Enc
	(
	input [127:0] i_Din, // Data input to be transformed
	output[127:0] o_Dout
	);
//-------------instantiation---------------	
assign o_Dout[127:096]= Map_One_Col(i_Din[127:096]);
assign o_Dout[095:064]= Map_One_Col(i_Din[095:064]);
assign o_Dout[063:032]= Map_One_Col(i_Din[063:032]);
assign o_Dout[031:000]= Map_One_Col(i_Din[031:000]);

/*-----------------------------------------------------------------------
			Function: one column mapping for MixColumns
-----------------------------------------------------------------------*/
function [31:0] Map_One_Col(input [31:0] i_Din);
reg [7:0] S0x2, S1x2, S2x2, S3x2;// intermediate Poly mult results
reg [7:0] S0x3, S1x3, S2x3, S3x3;
	begin
		S0x2=Poly_Mult_x2(i_Din[31:24]);   // X2
		S1x2=Poly_Mult_x2(i_Din[23:16]); 
		S2x2=Poly_Mult_x2(i_Din[15:08]); 
		S3x2=Poly_Mult_x2(i_Din[07:00]); 

		S0x3=Poly_Mult_x3(i_Din[31:24]);  //X3
		S1x3=Poly_Mult_x3(i_Din[23:16]); 
		S2x3=Poly_Mult_x3(i_Din[15:08]); 
		S3x3=Poly_Mult_x3(i_Din[07:00]); 

		Map_One_Col[31:24] = S0x2 ^ S1x3 ^ i_Din[15:8] ^ i_Din[7:0];// Sum terms over GF(2)     
		Map_One_Col[23:16] = i_Din[31:24] ^ S1x2 ^ S2x3 ^ i_Din[7:0];//    The poly used in the MIXCOLUMN is    (02  03  01  01)
		Map_One_Col[15:08] = i_Din[31:24] ^ i_Din[23:16] ^ S2x2 ^ S3x3;	//										(01  02  03  01)
		Map_One_Col[07:00] = S0x3 ^ i_Din[23:16] ^ i_Din[15:8] ^ S3x2;//										(01  01  02  03)
	end																//											(03  01  01  02)
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {02} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
-----------------------------------------------------------------------*/

function [7:0] Poly_Mult_x2 (input [7:0] i_Din);
	begin
		Poly_Mult_x2 = {i_Din[6:0],1'b0}^(8'h1b&{8{i_Din[7]}});
	end
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {03} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
-----------------------------------------------------------------------*/

function [7:0] Poly_Mult_x3 (input [7:0] i_Din);
	begin
		Poly_Mult_x3 =Poly_Mult_x2(i_Din)^i_Din;
	end
endfunction


endmodule


