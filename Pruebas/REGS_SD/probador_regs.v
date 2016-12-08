module probador(clk, rw, addr, data_in, data_out, ack, req, reset);

//Salidas y entradas	
	
  parameter data_witdh = 32;
  parameter addr_witdh = 5;
  parameter reg_witdh = 28;

   output clk;
   
   output rw;
   reg rw;
   
   output req;
   reg req;
   
   input ack;
   wire ack;
   
   output [addr_witdh-1: 0] addr;
   reg addr;
   
   output [data_witdh-1: 0] data_in;
   reg data_in;
   
   input [data_witdh-1: 0] data_out;
   wire data_out;
   
   output reset;
   reg reset = 1;

//Valores iniciales para las entradas 
	

//Cambio en las entradas según temporizador (en segundos)
	initial begin
		
	
		//Prueba ascendente
		$display("Inicia prueba");
		#1 reset = 0;
		addr = 5'b00000;
		req = 1'b1;
		rw = 1'b0; 
		data_in = 32'h00000001;
		#6 rw = 1'b1;
		#1 addr = 5'b00100;
		req = 1'b1;
		rw = 1'b0; 
		data_in = 32'h01010001;
		#6 rw = 1'b1;
		#1 req =1'b0;
		#1 addr = 5'b10110;
		req = 1'b1;
		rw = 1'b0; 
		data_in = 32'h11011010;
		#6 rw = 1'b1;
		#11 $finish;
	
	end
	
//Pulso de reloj cada segundo
	reg clk = 0;
	always #1 clk = !clk;

	
//contador c1 (Q, RCO, CLK, ENB, MODO, D, reset);

//Vista en pantalla
	initial
		$monitor("ack: %b", ack);
	
endmodule