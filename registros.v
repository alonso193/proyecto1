module registers(clk, r/w, addr, data_in, data_out)
 
  parameter data_witdh = 32;
   parameter addr_witdh = 8;
   parameter reg_witdh = 28;
   
  
   input clk;
   input r/w;
   input [addr_witdh-1: 0] addr;
   input [data_witdh-1: 0] data_in;
   input [data_witdh-1: 0] data_out;
   
   input [31: 0] 	  register_0;
   input [31: 0] 	  register_1;
   input [31: 0] 	  register_2;
   input [31: 0] 	  register_3;
   input [31: 0] 	  register_4;
   input [31: 0] 	  register_5;
   input [31: 0] 	  register_6;
   input [31: 0] 	  register_7;
   input [31: 0] 	  register_8;
   input [31: 0] 	  register_9;
   input [31: 0] 	  register_10;
   input [31: 0] 	  register_11;
   input [31: 0] 	  register_12;
   input [31: 0] 	  register_13;
   input [31: 0] 	  register_14;
   input [31: 0] 	  register_15;
   input [31: 0] 	  register_16;
   input [31: 0] 	  register_17;
   input [31: 0] 	  register_18;
   input [31: 0] 	  register_19;
   input [31: 0] 	  register_20;
   input [31: 0] 	  register_21;
   input [31: 0] 	  register_22;
   input [31: 0] 	  register_23;
   input [31: 0] 	  register_24;
   input [31: 0] 	  register_25;
   input [31: 0] 	  register_26;
   input [31: 0] 	  register_27;
   input [31: 0] 	  register_27;
   
   input [8: 0] 	  address;
   input [1: 0] 	  bits_mux;
   input [1: 0] 	  enable_mux;

   input [7: 0] 	  data_1;
   input [7: 0] 	  data_2;
   input [7: 0] 	  data_3;
   input [7: 0] 	  data_4;
   input [7: 0] 	  out;

   input 		  bits_mux2;
   

   reg [data_witdh-1: 0]  regs [0: reg_witdh-1];
   
   assign address = [0: 4] addr;
   assign bits_mux = [6: 5] addr;
   assign enable_mux = [7] addr;
   
	      
 
  // Lectura y escritura
  always @(posedge clk) begin
    if (r/w == 1)
      data_out <= regs[address];
    else
      regs[address] <= data_in;
  end

  // Multiplexar el dato de salida

   always @(posedge clk) begin
      if (enable_mux == 0) begin
	 assign data_1_mux1 = [7: 0] data_out;
	 assign data_2_mux1 = [15: 8] data_out;
	 assign data_3_mux1 = [23: 16] data_out;
	 assign data_4_mux1 = [31: 23] data_out;
	 
	 if (bits_mux == 00) begin
	    out_8 = data_1_mux1;
	 end
	 
	 else if (bits_mux == 00) begin
	    out_8 = data_2_mux1;
	 end
	 
	 else if (bits_mux == 00) begin
	    out_8 = data_3_mux1;
	 end
	 
	 else begin
	    out_8 = data_4_mux1; 
	 end
      end	
	 
      else //if (enable_mux == 1) begin
	 assign data_1_mux2 = [15: 0] data_out;
	 assign data_2_mux2 = [31: 16] data_out;
	 
	 assign bit_mux2 = [0] bit_mux;
	 assign bit_mux2 = [0] bit_mux;
	 
	 if (bits_mux2 == 0) begin
	    out_16 = data_1_mux2;
	 end
	 
	 else if (bits_mux2 == 0) begin
	    out_16 = data_2_mux2;
	 end
	 
      end
   end 


endmodule 
