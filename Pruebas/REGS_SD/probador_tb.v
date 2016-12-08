`include "REG.v"
`include "probador_regs.v"
module testbench;

	parameter data_witdh = 32;
	parameter addr_witdh = 5;
	parameter reg_witdh = 28;
   
   
   wire clk;
   
   wire rw;
   
   wire req;
   
   wire ack;
   
   wire [addr_witdh-1: 0]addr;
   
   wire [data_witdh-1: 0]data_in;

   wire [data_witdh-1: 0]data_out;
   
   wire reset;
   
   initial begin
	$dumpfile("registers.vcd");
	$dumpvars(0, testbench);
	end

REG b1 (clk, rw, addr, data_in, data_out, ack, req, reset);
probador p1 (clk, rw, addr, data_in, data_out, ack, req, reset);

endmodule

//iverilog -o reg.vvp probador_tb.v