/*-----------------------------------------------------------------------
				mix columns transformation
-----------------------------------------------------------------------*/
module Mix_Columns_Dec
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

reg [7:0] S0xe, S1xe, S2xe, S3xe;// intermediate Poly mult results
reg [7:0] S0x9, S1x9, S2x9, S3x9;
reg [7:0] S0xd, S1xd, S2xd, S3xd;// intermediate Poly mult results
reg [7:0] S0xb, S1xb, S2xb, S3xb;

	begin
		S0xe=Poly_Mult_xe(i_Din[31:24]);   // X2
		S1xe=Poly_Mult_xe(i_Din[23:16]); 
		S2xe=Poly_Mult_xe(i_Din[15:08]); 
		S3xe=Poly_Mult_xe(i_Din[07:00]); 

		S0x9=Poly_Mult_x9(i_Din[31:24]);  //X3
		S1x9=Poly_Mult_x9(i_Din[23:16]); 
		S2x9=Poly_Mult_x9(i_Din[15:08]); 
		S3x9=Poly_Mult_x9(i_Din[07:00]); 
		
		S0xd=Poly_Mult_xd(i_Din[31:24]);   // X2
		S1xd=Poly_Mult_xd(i_Din[23:16]); 
		S2xd=Poly_Mult_xd(i_Din[15:08]); 
		S3xd=Poly_Mult_xd(i_Din[07:00]); 

		S0xb=Poly_Mult_xb(i_Din[31:24]);  //X3
		S1xb=Poly_Mult_xb(i_Din[23:16]); 
		S2xb=Poly_Mult_xb(i_Din[15:08]); 
		S3xb=Poly_Mult_xb(i_Din[07:00]); 

		Map_One_Col[31:24] = S0xe ^ S1xb ^ S2xd ^ S3x9;// Sum terms over GF(2)
		Map_One_Col[23:16] = S0x9 ^ S1xe ^ S2xb ^ S3xd;
		Map_One_Col[15:08] = S0xd ^ S1x9 ^ S2xe ^ S3xb;
		Map_One_Col[07:00] = S0xb ^ S1xd ^ S2x9 ^ S3xe;
	end
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
		Function: multiplies input poly by {04=02*02} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
				
				(a*x^4) mod m = ((a*x^2)* x^2 ) mod m 
				              = ( (a*x^2) mod m)*(x^2 mod m) ) mod m 
							  = (Poly_Mult_x^2(a))*(x^2) ) mod m 
							  = Poly_Mult_x2( Poly_Mult_x^2(a) )
-----------------------------------------------------------------------*/
function [7:0] Poly_Mult_x4 (input [7:0] i_Din);
reg [7:0] Mult_x2;
	begin
	   Mult_x2 =  Poly_Mult_x2(i_Din);
	   Poly_Mult_x4 = Poly_Mult_x2(Mult_x2);
	end
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {08=02*04} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
-----------------------------------------------------------------------*/

function [7:0] Poly_Mult_x8 (input [7:0] i_Din);
reg [7:0] Mult_x4;
	begin
		Mult_x4 = Poly_Mult_x4(i_Din);
		Poly_Mult_x8 =Poly_Mult_x2( Mult_x4 );
	end
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {0e=08+04+02} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
				(a*(x^2+x^4)mod m = ( (a*x^2) mod m ) + ( (a*x^4) mod m )
							  = Poly_Mult_x2(a)	+ Poly_Mult_x4(a)		
-----------------------------------------------------------------------*/
function [7:0] Poly_Mult_xe (input [7:0] i_Din);
	begin
		Poly_Mult_xe = Poly_Mult_x8(i_Din) ^ Poly_Mult_x4(i_Din) ^ Poly_Mult_x2(i_Din);
	end
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {09=08+01} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
				(a*(x^2+x^4)mod m = ( (a*x^2) mod m ) + ( (a*x^4) mod m )
							  = Poly_Mult_x2(a)	+ Poly_Mult_x4(a)		
-----------------------------------------------------------------------*/
function [7:0] Poly_Mult_x9 (input [7:0] i_Din);
	begin
		Poly_Mult_x9 =  Poly_Mult_x8(i_Din) ^ i_Din;
	end
endfunction
/*-----------------------------------------------------------------------
		Function: multiplies input poly by {0d=08+04+01} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
				(a*(x^2+x^4)mod m = ( (a*x^2) mod m ) + ( (a*x^4) mod m )
							  = Poly_Mult_x2(a)	+ Poly_Mult_x4(a)		
-----------------------------------------------------------------------*/
function [7:0] Poly_Mult_xd (input [7:0] i_Din);
	begin
		Poly_Mult_xd =  Poly_Mult_x8(i_Din) ^ Poly_Mult_x4(i_Din) ^ i_Din;
	end
endfunction

/*-----------------------------------------------------------------------
		Function: multiplies input poly by {0b=08+02+01} over GF(2^8) and reduces
				mod m(x) = x^8 + x^4 + x^3 + x + 1
				(a*(x^2+x^4)mod m = ( (a*x^2) mod m ) + ( (a*x^4) mod m )
							  = Poly_Mult_x2(a)	+ Poly_Mult_x4(a)		
-----------------------------------------------------------------------*/
function [7:0] Poly_Mult_xb (input [7:0] i_Din);
	begin
		Poly_Mult_xb =  Poly_Mult_x8(i_Din) ^ Poly_Mult_x2(i_Din) ^ i_Din;
	end
endfunction

endmodule


