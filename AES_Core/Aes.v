/*--------------------------------------------------------
					AES Top Core
----------------------------------------------------------*/
`include "timescale.v"
module Aes
	(
	input i_Clk,
	input i_Rst_n,
	
	input i_En,
	input [1:0] i_Key_Mode,
	input [255:0] i_Key,
	input i_Key_En,
	input i_Mode, //0:encryption 1:Decryption
	input [127:0] i_Din,
	input i_Din_En,
	
	output reg [127:0] o_Dout,
	output reg o_Dout_En
	);
/*~~~~~~~~~~~~~~~~~~~~~~~Keys Expansion~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
//-------keys expansion parameter define--------
reg [3:0] r_Key_Round_No;
reg [127:0] r_Round_key[15:0];
reg [255:0] r_Exp_Key;

wire [127:0] w_Round_key0,w_Round_key1;
wire [255:0] w_Exp_key0,w_Exp_key1;
//----------keys expansion instantiation--------
Key_Expansion
Key_Expansion_0
	(
	.i_Round_Times(r_Key_Round_No),
	.i_Key_Mode(i_Key_Mode),
	.i_Exp_Key(r_Exp_Key),
	
	.o_Round_key(w_Round_key0),
	.o_Exp_key(w_Exp_key0)
	);
Key_Expansion

Key_Expansion_1
	(
	.i_Round_Times(r_Key_Round_No+4'd1),
	.i_Key_Mode(i_Key_Mode),
	.i_Exp_Key(w_Exp_key0),
	
	.o_Round_key(w_Round_key1),
	.o_Exp_key(w_Exp_key1)
	);

//-----------Keys expansion Control--------------
always @(posedge i_Clk,negedge i_Rst_n)
	begin
		if(!i_Rst_n)
			begin
				r_Key_Round_No<=15;
				r_Exp_Key<=0;
			end
	    else 
			begin
				if(i_Key_En)//trigger
					begin
						r_Key_Round_No<=0;
						r_Exp_Key<=i_Key;
					end
				else if(r_Key_Round_No<15)
					begin
						if(r_Key_Round_No==14) r_Key_Round_No<=r_Key_Round_No+4'd1;//if(r_Key_Round_No=14),r_Key_Round_No+4'd2=16>15
						else r_Key_Round_No<=r_Key_Round_No+4'd2;
						
						r_Round_key[r_Key_Round_No]<=w_Round_key0;
						r_Round_key[r_Key_Round_No+4'd1]<=w_Round_key1;
						r_Exp_Key<=w_Exp_key1;
					end
				else
					begin
						r_Key_Round_No<=15;
						r_Exp_Key<=0;
					end
			end
	end
/*~~~~~~~~~~~~~~~~~~~~AES Encryption and Decryption~~~~~~~~~~~~~~~~~*/
//-----------parameter define-----------
reg [3:0] r_Round_No_0,r_Round_No_1,r_Round_No_2,r_Round_No_3,r_Round_No_4;
wire [127:0] w_Enc_Dout0,w_Enc_Dout1,w_Enc_Dout2,w_Enc_Dout3,w_Enc_Dout4;
wire [127:0] w_Dec_Dout0,w_Dec_Dout1,w_Dec_Dout2,w_Dec_Dout3,w_Dec_Dout4;
reg [127:0] r_Din;
localparam ENCRYPT=0;
localparam DECRYPT=1;
always @(i_Mode,r_Round_No_0)
	begin
		case(i_Mode)
			ENCRYPT:
				begin
					r_Round_No_1=r_Round_No_0+4'h1;
					r_Round_No_2=r_Round_No_0+4'h2;
					r_Round_No_3=r_Round_No_0+4'h3;
					r_Round_No_4=r_Round_No_0+4'h4;
				end
			DECRYPT:
				begin
					r_Round_No_1=r_Round_No_0-4'h1;
					r_Round_No_2=r_Round_No_0-4'h2;
					r_Round_No_3=r_Round_No_0-4'h3;
					r_Round_No_4=r_Round_No_0-4'h4;
				end
		endcase
	end

//---------encrypt instantiation-------
One_Round_Enc  
One_Round_Enc_0
	(
	.i_Round_Times(r_Round_No_0),
	.i_Key_Mode(i_Key_Mode),
	.i_Round_key(r_Round_key[r_Round_No_0]),
	.i_Din(r_Din),
	.o_Dout(w_Enc_Dout0)
	);
One_Round_Enc  
One_Round_Enc_1
	(
	.i_Round_Times(r_Round_No_1),
	.i_Key_Mode(i_Key_Mode),
	.i_Round_key(r_Round_key[r_Round_No_1]),
	.i_Din(w_Enc_Dout0),
	.o_Dout(w_Enc_Dout1)
	);
One_Round_Enc  
One_Round_Enc_2
	(
	.i_Round_Times(r_Round_No_2),
	.i_Key_Mode(i_Key_Mode),
	.i_Round_key(r_Round_key[r_Round_No_2]),
	.i_Din(w_Enc_Dout1),
	.o_Dout(w_Enc_Dout2)
	);
One_Round_Enc  
One_Round_Enc_3
	(
	.i_Round_Times(r_Round_No_3),
	.i_Key_Mode(i_Key_Mode),
	.i_Round_key(r_Round_key[r_Round_No_3]),
	.i_Din(w_Enc_Dout2),
	.o_Dout(w_Enc_Dout3)
	);
One_Round_Enc  
One_Round_Enc_4
	(
	.i_Round_Times(r_Round_No_4),
	.i_Key_Mode(i_Key_Mode),
	.i_Round_key(r_Round_key[r_Round_No_4]),
	.i_Din(w_Enc_Dout3),
	.o_Dout(w_Enc_Dout4)
	);	

//---------decrypt instantiation---------
One_Round_Dec  
One_Round_Dec_0
	(
	.i_Round_Times(r_Round_No_0),
	.i_Round_key(r_Round_key[r_Round_No_0]),
	.i_Din(r_Din),
	.o_Dout(w_Dec_Dout0)
	);
One_Round_Dec  
One_Round_Dec_1
	(
	.i_Round_Times(r_Round_No_1),
	.i_Round_key(r_Round_key[r_Round_No_1]),
	.i_Din(w_Dec_Dout0),
	.o_Dout(w_Dec_Dout1)
	);
One_Round_Dec  
One_Round_Dec_2
	(
	.i_Round_Times(r_Round_No_2),
	.i_Round_key(r_Round_key[r_Round_No_2]),
	.i_Din(w_Dec_Dout1),
	.o_Dout(w_Dec_Dout2)
	);
One_Round_Dec  
One_Round_Dec_3
	(
	.i_Round_Times(r_Round_No_3),
	.i_Round_key(r_Round_key[r_Round_No_3]),
	.i_Din(w_Dec_Dout2),
	.o_Dout(w_Dec_Dout3)
	);
One_Round_Dec  
One_Round_Dec_4
	(
	.i_Round_Times(r_Round_No_4),
	.i_Round_key(r_Round_key[r_Round_No_4]),
	.i_Din(w_Dec_Dout3),
	.o_Dout(w_Dec_Dout4)
	);		
//----------AES control---------
reg [1:0] r_Reuse_No;
reg r_Dout_En;//output data enable buffer
always @(posedge i_Clk,negedge i_Rst_n)
	begin
		if(!i_Rst_n)
			begin
				r_Dout_En<=0;
				r_Reuse_No<=2;	
				r_Round_No_0<=0;
				r_Din<=0;
			end
		else if(i_En)
			begin
				if(i_Din_En) 
					begin
						case(i_Mode)
							ENCRYPT:
								begin
									r_Round_No_0<=1;
									r_Din<=r_Round_key[0] ^ i_Din;// first add round key transformation
									r_Reuse_No<=0;
								end
							DECRYPT:
								begin
									if(i_Key_Mode==0) 
										begin
											r_Round_No_0<=9;
											r_Din<=r_Round_key[10] ^ i_Din;// first add round key transformation
										end
									else if(i_Key_Mode==1) 
										begin
											r_Round_No_0<=11;
											r_Din<=r_Round_key[12] ^ i_Din;
										end
									else  
										begin
											r_Round_No_0<=13;
											r_Din<=r_Round_key[14] ^ i_Din;
										end
									r_Reuse_No<=0;
								end
						endcase
					end
				else if(r_Reuse_No<2)
					begin
						case(i_Mode)
							ENCRYPT:
								begin
									r_Round_No_0<=r_Round_No_0+4'd5;
									r_Din<=w_Enc_Dout4;
								end
							DECRYPT:
								begin
									r_Round_No_0<=r_Round_No_0-4'd5;
									r_Din<=w_Dec_Dout4;
								end
						endcase
						r_Reuse_No<=r_Reuse_No+2'd1;
						if(r_Reuse_No==1) r_Dout_En<=1;//output  enable
						else r_Dout_En<=0;
					end
				else
					begin
					    r_Dout_En<=0;
						r_Reuse_No<=2;	
						r_Round_No_0<=0;
						r_Din<=0;
					end
			end
	end
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~output control~~~~~~~~~~~~~~~~~~~~~~~*/
always @(posedge i_Clk,negedge i_Rst_n)
	begin
		if(!i_Rst_n)
			begin
				o_Dout<=0;
				o_Dout_En<=0;	
			end
	    else if(i_En)
			begin
				if(i_Key_Mode==0) o_Dout<=r_Din;
				else if(i_Key_Mode==1) o_Dout <= i_Mode==ENCRYPT ? w_Enc_Dout1 : w_Dec_Dout1;
				else o_Dout <= i_Mode==ENCRYPT ? w_Enc_Dout3 : w_Dec_Dout3;
	
				o_Dout_En<=r_Dout_En;	
			end
	end
endmodule
