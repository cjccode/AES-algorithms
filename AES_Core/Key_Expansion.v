/*-----------------------------------------------------------------------
				Key Expansion transformation
-----------------------------------------------------------------------*/
module Key_Expansion
	(
	input [255:0] i_Exp_Key,
	input [3:0] i_Round_Times,
	input [1:0] i_Key_Mode,
	
	output reg [127:0] o_Round_key,
	output reg [255:0] o_Exp_key
	);

wire [31:0] w_Rcon0,w_Rcon1,w_Rcon2,w_Rot_Word, w_Sub_Word;	

assign w_Rcon0= i_Round_Times == 4'h1 ? 32'h01_000000://128bit key Rcon Transform	
				i_Round_Times == 4'h2 ? 32'h02_000000://10 round times
				i_Round_Times == 4'h3 ? 32'h04_000000:
				i_Round_Times == 4'h4 ? 32'h08_000000:
				i_Round_Times == 4'h5 ? 32'h10_000000:
				i_Round_Times == 4'h6 ? 32'h20_000000:
				i_Round_Times == 4'h7 ? 32'h40_000000:
				i_Round_Times == 4'h8 ? 32'h80_000000:
				i_Round_Times == 4'h9 ? 32'h1b_000000:32'h36_000000;
				
assign w_Rcon1= i_Round_Times == 4'h1 ? 32'h01_000000://192bit key Rcon Transform	
				i_Round_Times == 4'h2 ? 32'h02_000000://12 round times
				i_Round_Times == 4'h3 ? 32'h02_000000:
				i_Round_Times == 4'h4 ? 32'h04_000000:
				i_Round_Times == 4'h5 ? 32'h08_000000:
				i_Round_Times == 4'h6 ? 32'h08_000000:
				i_Round_Times == 4'h7 ? 32'h10_000000:	
				i_Round_Times == 4'h8 ? 32'h20_000000:
				i_Round_Times == 4'h9 ? 32'h20_000000:
				i_Round_Times == 4'ha ? 32'h40_000000:
				i_Round_Times == 4'hb ? 32'h80_000000:	32'h80_000000;

				
assign w_Rcon2= i_Round_Times == 4'h1 ? 32'h01_000000://256bit key Rcon Transform	
				i_Round_Times == 4'h2 ? 32'h02_000000://14 round times
				i_Round_Times == 4'h3 ? 32'h02_000000:
				i_Round_Times == 4'h4 ? 32'h04_000000:
				i_Round_Times == 4'h5 ? 32'h04_000000:
				i_Round_Times == 4'h6 ? 32'h08_000000:
				i_Round_Times == 4'h7 ? 32'h08_000000:	
				i_Round_Times == 4'h8 ? 32'h10_000000:
				i_Round_Times == 4'h9 ? 32'h10_000000:
				i_Round_Times == 4'ha ? 32'h20_000000:
				i_Round_Times == 4'hb ? 32'h20_000000:	
				i_Round_Times == 4'hc ? 32'h40_000000:
				i_Round_Times == 4'hd ? 32'h40_000000:32'h80_000000;					
				
				
assign w_Rot_Word = {i_Exp_Key[23:0], i_Exp_Key[31:24]};//RotWord Transform	

S_Box_Enc 	S_Box_Enc_0(.i_Din(w_Rot_Word[31:24]),.o_Dout(w_Sub_Word[31:24]));//Sbox Transform	
S_Box_Enc 	S_Box_Enc_1(.i_Din(w_Rot_Word[23:16]),.o_Dout(w_Sub_Word[23:16]));
S_Box_Enc 	S_Box_Enc_2(.i_Din(w_Rot_Word[15:08]),.o_Dout(w_Sub_Word[15:08]));
S_Box_Enc 	S_Box_Enc_3(.i_Din(w_Rot_Word[07:00]),.o_Dout(w_Sub_Word[07:00]));

reg [255:0] r_Exp_Key;
always @(i_Exp_Key,i_Round_Times,i_Key_Mode,w_Rcon0,w_Rcon1,w_Rcon2,w_Sub_Word,o_Round_key)
	begin
		o_Round_key =0;
		o_Exp_key = 0;
		r_Exp_Key=0;
		case(i_Key_Mode)
			2'b00://key :128 bit 
				begin
					o_Round_key[127:096]=i_Round_Times ?     w_Sub_Word^w_Rcon0^(i_Exp_Key[127:096]) : i_Exp_Key[127:096];//w0 
					o_Round_key[095:064]=i_Round_Times ? (o_Round_key[127:096])^(i_Exp_Key[095:064]) : i_Exp_Key[095:064];//w1
					o_Round_key[063:032]=i_Round_Times ? (o_Round_key[095:064])^(i_Exp_Key[063:032]) : i_Exp_Key[063:032];//w2
					o_Round_key[031:000]=i_Round_Times ? (o_Round_key[063:032])^(i_Exp_Key[031:000]) : i_Exp_Key[031:000];//w3
					o_Exp_key=o_Round_key;
				end
			2'b01://key :192 bit
				begin
					r_Exp_Key[191:160]=w_Sub_Word^w_Rcon1^(i_Exp_Key[191:160])  ;//w0 
					r_Exp_Key[159:128]=(r_Exp_Key[191:160])^(i_Exp_Key[159:128]) ;//w1
					r_Exp_Key[127:096]=(r_Exp_Key[159:128])^(i_Exp_Key[127:096]) ;//w2
					r_Exp_Key[095:064]=(r_Exp_Key[127:096])^(i_Exp_Key[095:064]) ;//w3
					r_Exp_Key[063:032]=(r_Exp_Key[095:064])^(i_Exp_Key[063:032]) ;//w4
					r_Exp_Key[031:000]=(r_Exp_Key[063:032])^(i_Exp_Key[031:000]) ;//w5
					case(i_Round_Times)
						4'h0,4'h3,4'h6,4'h9,4'hc:
							begin
								o_Round_key[127:096]=i_Exp_Key[191:160];
								o_Round_key[095:064]=i_Exp_Key[159:128];
								o_Round_key[063:032]=i_Exp_Key[127:096];
								o_Round_key[031:000]=i_Exp_Key[095:064];
								o_Exp_key=i_Exp_Key;
							end
						4'h1,4'h4,4'h7,4'ha:
							begin
								o_Round_key[127:096]=i_Exp_Key[063:032];
								o_Round_key[095:064]=i_Exp_Key[031:000];
								o_Round_key[063:032]=r_Exp_Key[191:160];
								o_Round_key[031:000]=r_Exp_Key[159:128];
								o_Exp_key=r_Exp_Key;
							end
						default:
							begin
								o_Round_key[127:096]=i_Exp_Key[127:096];
								o_Round_key[095:064]=i_Exp_Key[095:064];
								o_Round_key[063:032]=i_Exp_Key[063:032];
								o_Round_key[031:000]=i_Exp_Key[031:000];
								o_Exp_key=r_Exp_Key;
							end
					endcase
				end
			default: //key :256 bit       
				begin
					r_Exp_Key[255:224]=w_Sub_Word^w_Rcon2 ^ (i_Exp_Key[255:224]) ;//w0 
					r_Exp_Key[223:192]=(r_Exp_Key[255:224])^(i_Exp_Key[223:192]) ;//w1
					r_Exp_Key[191:160]=(r_Exp_Key[223:192])^(i_Exp_Key[191:160]) ;//w2
					r_Exp_Key[159:128]=(r_Exp_Key[191:160])^(i_Exp_Key[159:128]) ;//w3
					r_Exp_Key[127:096]=(r_Exp_Key[159:128])^(i_Exp_Key[127:096]) ;//w4
					r_Exp_Key[095:064]=(r_Exp_Key[127:096])^(i_Exp_Key[095:064]) ;//w5
					r_Exp_Key[063:032]=(r_Exp_Key[095:064])^(i_Exp_Key[063:032]) ;//w6
					r_Exp_Key[031:000]=(r_Exp_Key[063:032])^(i_Exp_Key[031:000]) ;//w7
					case(i_Round_Times)
						4'h0,4'h2,4'h4,4'h6,4'h8,4'ha,4'hc,4'he:
							begin
								o_Round_key[127:096]=i_Exp_Key[255:224];
								o_Round_key[095:064]=i_Exp_Key[223:192];
								o_Round_key[063:032]=i_Exp_Key[191:160];
								o_Round_key[031:000]=i_Exp_Key[159:128];
								o_Exp_key=i_Exp_Key;
							end
						default:
							begin
								o_Round_key[127:096]=i_Exp_Key[127:096];
								o_Round_key[095:064]=i_Exp_Key[095:064];
								o_Round_key[063:032]=i_Exp_Key[063:032];
								o_Round_key[031:000]=i_Exp_Key[031:000];
								o_Exp_key=r_Exp_Key;
							end
					endcase
				end
		endcase
	end

endmodule