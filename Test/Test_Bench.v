/*----------------------------------------------------------
                
				AES module test bench
				                     ----designed by Leo Tu
									     2015.5.20 11:08:29
										 
------------------------------------------------------------*/


`include "timescale.v"

module     tb_aes_module;

//---------define interface ports-----------//
reg  clk;
reg  rst_n;
reg  i_empty_fifo;
reg  i_full_fifo;
reg [33:0] i_data_in;


wire  o_rd_in;
wire  o_wr_out;
wire  o_error;
wire [33:0] o_data_out;

parameter  PERIOD = 20;	//50MHz

//------------AES top instantiation-----------//
top_aes_128  top_aes_128(
                        .clk(clk),
					    .rst_n(rst_n),
					    .o_rd_in(o_rd_in),
					    .i_data_in(i_data_in),
					    .i_empty_fifo(i_empty_fifo),
					    .o_error(o_error),
					    .i_full_fifo(i_full_fifo),
					    .o_data_out(o_data_out),
					    .o_wr_out(o_wr_out));

//-------------clock generator----------------//
initial	
  begin
    clk = 0;
	forever	#(PERIOD/2)	clk = ~clk;
  end
//-------------reset and initialization--------//
task set_reset;
	begin
		rst_n = 0;
		i_empty_fifo = 1;
		i_full_fifo = 1;
		repeat(2) @(posedge clk);
		rst_n = 1;
	end
endtask
//----------------test case-----------------//
reg [33:0] sim_fifo_1[24:0];
reg [33:0] sim_fifo_2[26:0];
reg [33:0] sim_fifo_3[28:0];
reg [33:0] r_data;
integer i,j,k,number,r_error;
initial 
  begin
    $display("\n*****************************************************");
	$display("* AES Module Test Bench ...");
	$display("*****************************************************\n");
	r_error = 0;
	i_empty_fifo = 0;
	i_full_fifo = 0;
	number = 0;
	set_reset;

    sim_fifo_1[0]= {2'b01,32'h00002a19};
    sim_fifo_1[1]= {2'b00,32'h00000000};
    sim_fifo_1[2]= {2'b00,32'hffffffff};
    sim_fifo_1[3]= {2'b00,32'h00000000};
    sim_fifo_1[4]= {2'b00,32'hffffffff};// 4 bags of keys
    sim_fifo_1[5]= {2'b00,32'h0000ffff};
    sim_fifo_1[6]= {2'b00,32'hffff0000};
    sim_fifo_1[7]= {2'b00,32'h0000ffff};
    sim_fifo_1[8]= {2'b00,32'hffff0000};// 4 bags of IV
    sim_fifo_1[9]= {2'b00,32'h01234567};
    sim_fifo_1[10]= {2'b00,32'h89abcdef};
    sim_fifo_1[11]= {2'b00,32'h01234567};
    sim_fifo_1[12]= {2'b00,32'h89abcdef};
    sim_fifo_1[13]= {2'b00,32'h02468ace};
    sim_fifo_1[14]= {2'b00,32'h13579bdf};
    sim_fifo_1[15]= {2'b00,32'h02468ace};
    sim_fifo_1[16]= {2'b00,32'h13579bdf};//
    sim_fifo_1[17]= {2'b00,32'hf0f0f0f0};
    sim_fifo_1[18]= {2'b00,32'h0f0f0f0f};
    sim_fifo_1[19]= {2'b00,32'hf0f0f0f0};
    sim_fifo_1[20]= {2'b00,32'h0f0f0f0f};
    sim_fifo_1[21]= {2'b00,32'h0000ffff};
    sim_fifo_1[22]= {2'b00,32'hffff0000};
    sim_fifo_1[23]= {2'b00,32'h0000ffff};
    sim_fifo_1[24]= {2'b10,32'hffff0000};//16 bags of data


    sim_fifo_2[0]= {2'b01,32'h0000281b};
    sim_fifo_2[1]= {2'b00,32'hffffffff};
    sim_fifo_2[2]= {2'b00,32'h00000000};
    sim_fifo_2[3]= {2'b00,32'hffffffff};
    sim_fifo_2[4]= {2'b00,32'h00000000};
    sim_fifo_2[5]= {2'b00,32'hffffffff};
    sim_fifo_2[6]= {2'b00,32'h00000000};// 6 bags of keys
    sim_fifo_2[7]= {2'b00,32'h0000ffff};
    sim_fifo_2[8]= {2'b00,32'hffff0000};
    sim_fifo_2[9]= {2'b00,32'h0000ffff};
    sim_fifo_2[10]= {2'b00,32'hffff0000};// 4 bags of IV
    sim_fifo_2[11]= {2'b00,32'h01234567};
    sim_fifo_2[12]= {2'b00,32'h89abcdef};
    sim_fifo_2[13]= {2'b00,32'h01234567};
    sim_fifo_2[14]= {2'b00,32'h89abcdef};
    sim_fifo_2[15]= {2'b00,32'h02468ace};
    sim_fifo_2[16]= {2'b00,32'h13579bdf};
    sim_fifo_2[17]= {2'b00,32'h02468ace};
    sim_fifo_2[18]= {2'b00,32'h13579bdf};
    sim_fifo_2[19]= {2'b00,32'hf0f0f0f0};//
    sim_fifo_2[20]= {2'b00,32'h0f0f0f0f};
    sim_fifo_2[21]= {2'b00,32'hf0f0f0f0};
    sim_fifo_2[22]= {2'b00,32'h0f0f0f0f};
    sim_fifo_2[23]= {2'b00,32'h0000ffff};
    sim_fifo_2[24]= {2'b00,32'hffff0000};
    sim_fifo_2[25]= {2'b00,32'h0000ffff};
    sim_fifo_2[26]= {2'b10,32'hffff0000};//16 bags of data
  
  
    sim_fifo_3[0]= {2'b01,32'h0000271d};
    sim_fifo_3[1]= {2'b00,32'h0f0f0f0f};
    sim_fifo_3[2]= {2'b00,32'hf0f0f0f0};
    sim_fifo_3[3]= {2'b00,32'h0f0f0f0f};
    sim_fifo_3[4]= {2'b00,32'hf0f0f0f0};
    sim_fifo_3[5]= {2'b00,32'h01234567};
    sim_fifo_3[6]= {2'b00,32'h76543210};
    sim_fifo_3[7]= {2'b00,32'h89abcdef};
    sim_fifo_3[8]= {2'b00,32'hfedcba98};// 8 bags of keys
    sim_fifo_3[9]= {2'b00,32'h0000ffff};
    sim_fifo_3[10]= {2'b00,32'hffff0000};
    sim_fifo_3[11]= {2'b00,32'h0000ffff};
    sim_fifo_3[12]= {2'b00,32'hffff0000};// 4 bags of IV
    sim_fifo_3[13]= {2'b00,32'h01234567};
    sim_fifo_3[14]= {2'b00,32'h89abcdef};
    sim_fifo_3[15]= {2'b00,32'h01234567};
    sim_fifo_3[16]= {2'b00,32'h89abcdef};
    sim_fifo_3[17]= {2'b00,32'h02468ace};
    sim_fifo_3[18]= {2'b00,32'h13579bdf};
    sim_fifo_3[19]= {2'b00,32'h02468ace};
    sim_fifo_3[20]= {2'b00,32'h13579bdf};
    sim_fifo_3[21]= {2'b00,32'hf0f0f0f0};//
    sim_fifo_3[22]= {2'b00,32'h0f0f0f0f};
    sim_fifo_3[23]= {2'b00,32'hf0f0f0f0};
    sim_fifo_3[24]= {2'b00,32'h0f0f0f0f};
    sim_fifo_3[25]= {2'b00,32'h0000ffff};
    sim_fifo_3[26]= {2'b00,32'hffff0000};
    sim_fifo_3[27]= {2'b00,32'h0000ffff};
    sim_fifo_3[28]= {2'b10,32'hffff0000};//16 bags of data
  
    for(i=0;i<3;i=i+1)
	  begin
	    for(j=0;j<((i*2)+25);j=j+1)
	      begin
		    @(posedge clk);
			i_empty_fifo = 0;
		    i_full_fifo = 0;
		    if(i==0) i_data_in = sim_fifo_1[j];
		    else if(i==1) i_data_in = sim_fifo_2[j];
			     else i_data_in = sim_fifo_3[j];
            if(o_error) r_error = r_error + 1;
			if((number==0)&&(o_wr_out)) $display("Keys Mode:128 bits:");
	        else if((number==16)&&(o_wr_out)) $display("Keys Mode:192 bits:");
	             else if((number==32)&&(o_wr_out)) $display("Keys Mode:256 bits:");
		    if(o_wr_out) begin 
		        r_data = o_data_out;
		        number = number + 1;
		        $display("(%0d): Encryption or Decryption,  %0d Errors, Got: %x",i, r_error, r_data);
			end
			if(j==28) begin
				for(k=0;k<8;k=k+1)
				  begin
				    @(posedge clk);
					if(k==0) i_empty_fifo = 1;
					if(o_wr_out) begin 
		                r_data = o_data_out;
		                number = number + 1;
		                $display("(%0d): Encryption or Decryption,  %0d Errors, Got: %x",i, r_error, r_data);
				    end
				  end
			end
		  end
      end

	#200 $stop;
	
  end

  
endmodule