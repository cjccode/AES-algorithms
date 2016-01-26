/*-----------------------------------------------------------------------
							AES test bench
-----------------------------------------------------------------------*/
`include "timescale.v"
module Tb_Aes;

reg	r_Clk_50M;
reg	r_Rst_n;

reg r_En;
reg [1:0] r_Key_Mode;
reg [255:0] r_Key;
reg r_Key_En;
reg r_Mode; //0:encryption 1:Decryption
reg [127:0] r_Din;
reg r_Din_En;

wire [127:0] w_Dout;
wire w_Dout_En;

parameter PERIOD = 20;	//50MHz
//----------AES instantiation--------	
Aes
Aes_0
	(
	.i_Clk(r_Clk_50M),
	.i_Rst_n(r_Rst_n),
	
	.i_En(r_En),
	.i_Key_Mode(r_Key_Mode),
	.i_Key(r_Key),
	.i_Key_En(r_Key_En),
	.i_Mode(r_Mode), //0:encryption 1:Decryption
	.i_Din(r_Din),
	.i_Din_En(r_Din_En),
	
	.o_Dout(w_Dout),
	.o_Dout_En(w_Dout_En)
	);
//---------clock generator----------------
initial	
	begin
		r_Clk_50M = 0;
		forever	#(PERIOD/2)	r_Clk_50M = ~r_Clk_50M;
	end
//---------------reset-------------------
task Task_Reset;
	begin
		r_Rst_n = 0;
		repeat(2) @(posedge r_Clk_50M);
		r_Rst_n = 1;
	end
endtask	
//----------------test case--------------	
reg [511:0] r_Test_Vec[2:0];
reg [511:0] r_Temp;
reg [127:0] r_Plain,r_Cipher;
integer i,j,Error_Count,Right_Count;
initial 
    begin
		$display("\n*****************************************************");
		$display("* AES Test bench ...");
		$display("*****************************************************\n");
		Error_Count=0;
		Right_Count=0;
		r_En<=1;
		r_Mode = 0; 
		r_Key_Mode<=0;
		r_Key_En = 0;
		r_Din_En =0;
		Task_Reset;
		//	                                           r_Key              				             plaintext					ciphertext
//r_Test_Vec[0]=512'h0000000000000000_0000000000000000_00000000000000000000000000000000_f34481ec3cc627bacd5dc3fb08f273e6_0336763e966d92595a567cc9ce537f5e;//128 bit
//r_Test_Vec[1]=512'h0000000000000000_0000000000000000_00000000000000000000000000000000_f34481ec3cc627bacd5dc3fb08f273e6_b234e51c9f51bf86784668bae8917dc4;//192 bit
//r_Test_Vec[2]=512'h0000000000000000_0000000000000000_00000000000000000000000000000000_f34481ec3cc627bacd5dc3fb08f273e6_bfe4717310dba3095e4048fc012e279e;//256 bit

r_Test_Vec[0]=512'h0123456789abcdef_0123456789abcdef_0123456789abcdef0123456789abcdef_f34481ec3cc627bacd5dc3fb08f273e6_3aed973e8e917bad98e2aff991ff463e;//128 bit
r_Test_Vec[1]=512'h0123456789abcdef_0123456789abcdef_0123456789abcdef0123456789abcdef_f34481ec3cc627bacd5dc3fb08f273e6_cf66a69d6ebaae56bcb144e09a86287d;//192 bit
r_Test_Vec[2]=512'h0123456789abcdef_0123456789abcdef_0123456789abcdef0123456789abcdef_f34481ec3cc627bacd5dc3fb08f273e6_cf13ba334db57bcdffff07af00ec7686;//256 bit
		for(i=0;i<3;i=i+1)
			begin
				if(i==0) $display("Keys Mode: 128 bits:");
				else if(i==1) $display("Keys Mode: 192 bits:");
				else $display("Keys Mode: 256 bits:");
				for(j=0;j<1;j=j+1)
					begin
					    r_Key_Mode<=i;
						r_Temp = r_Test_Vec[i];
						r_Key  = r_Temp[511:256];
						r_Plain =r_Temp[255:128];
						r_Cipher=r_Temp[127:0];
						
						@(posedge r_Clk_50M);
						#10 r_Key_En = 1;
						@(posedge r_Clk_50M);
						#10 r_Key_En = 0;
						repeat(8) @(posedge r_Clk_50M);

						#10 r_Mode <= 0; //encryption
							r_Din <= r_Plain;
							r_Din_En <= 1;
						@(posedge r_Clk_50M);
						#10 r_Din_En = 0;
						while(!w_Dout_En) @(posedge r_Clk_50M); 
						if(w_Dout != r_Cipher) Error_Count = Error_Count + 1;
						else Right_Count = Right_Count + 1;
						$display("(%0d): Encryption, %0d Right, %0d Errors, Expected: %x, Got: %x",Right_Count+Error_Count, Right_Count, Error_Count, r_Cipher, w_Dout);
						
						r_Cipher = w_Dout;
								

						@(posedge r_Clk_50M);//decryption
						#10 r_Mode <= 1; 
							r_Din <= r_Cipher;
							r_Din_En <= 1;
						@(posedge r_Clk_50M);
						#10 r_Din_En = 0;
						while(!w_Dout_En) @(posedge r_Clk_50M); 
						if(w_Dout != r_Plain) Error_Count = Error_Count + 1;
						else Right_Count = Right_Count + 1;
						$display("(%0d): Decryption, %0d Right, %0d Errors, Expected: %x, Got: %x",Right_Count+Error_Count, Right_Count, Error_Count, r_Plain, w_Dout);	
					end
			end
	end

endmodule
