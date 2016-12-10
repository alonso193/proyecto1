// *****************************
// Luis F. Mora
// B24449
// Circuitos Digitales II
// Prof. Enrique Coen
// *****************************

module probador_dma(output reg reset,
				 	output reg clk, // Señales de entrada del DMA
				 	output reg TFC, // Senal del fifo (cuando system_address = data_address + length)
 	        	 	output reg cmd_reg_write, // Senal de inicio
				 	output reg cmd_reg_read, // Senal de inicio
				 	output reg Continue, // Senal de reanudacion
				 	output reg TRAN, // Parte del descriptor address
				 	output reg STOP, // Interrupt signal
				 	output reg empty, // fifo empty
				 	output reg full, // fifo full
				 	output reg [63:0] data_address, // Posicion donde empieza el dato (Address Field del Address Descriptor)
				 	output reg [15:0] length, // Tamano del dato en bytes (Length del Address Descriptor)
				 	output reg [5:0] descriptor_index, // Descriptor table de 64 entradas -> 6 bits de indexacion
				 	output reg  act1, // Attribute[4]
				 	output reg  act2, // Attribute[3]
				 	output reg  END, // Attribute [2]
				 	output reg  valid, // Attribute[1]
				 	output reg  dir);


always begin // Señal de reloj del host
	#5 clk =! clk;
end


initial begin

	$dumpfile("testDMA.vcd");
	$dumpvars(0,probador_dma);

		// Inicializar variables
			reset = 1;
			clk = 0;
			TFC = 0;
	        cmd_reg_write = 0; // luego se activa para iniciar el DMAC
			cmd_reg_read = 0;  // Senal de inicio
			Continue = 0;  // Senal de reanudacion / no aplica en este caso porque no se van a considerar interrupciones del cpu
			TRAN = 0;  // Parte del descriptor address
			STOP = 0; // Siempre va a estar en cero porque no vamos a considerar interrupciones del cpu
			empty = 1; // Asumir que el fifo esta vacio
			full = 0;  // Asumir que el fifo esta lleno
			data_address = 0; // Posicion donde empieza el dato (Address Field del Address Descriptor)
			length = 10; // Tamano del dato en bytes
			descriptor_index = 0; // Leer la primera posicion del descritor table
			act1 = 0;  // Attribute[4]
			act2 = 1;  // Attribute[3] Asumir que se debe dar una transferencia
			END = 1;   // Attribute [2] Asumir que solo se va a procesar una hilera del descriptor table
		 	valid = 1;  // Attribute[1] Asumir que la hilera del descriptor table es valida
			dir = 1; // Transmitir de memoria a SD

			//Reset off

			#50
			reset = 0;

			// Pasar a ST_FDS

			#50
			cmd_reg_write = 1;
			
			$display("Fin del DMA test");
	$finish(2);







end
endmodule
