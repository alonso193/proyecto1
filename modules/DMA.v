// *****************************
// Luis F. Mora
// B24449
// Circuitos Digitales II
// Prof. Enrique Coen
// *****************************

module DMA(input reset,
           input clk,
           input TFC, // Senal del fifo (cuando system_address = data_address + length)
           input cmd_reg_write, // Senal de inicio
           input cmd_reg_read, // Senal de inicio
           input Continue, // Senal de reanudacion
           input TRAN, // Parte del descriptor address
           input STOP, // Interrupt signal
           input empty, // fifo empty
           input full, // fifo full
           input [63:0] data_address, // Posicion donde empieza el dato (Address Field del Address Descriptor)
           input [15:0] length, // Tamano del dato en bytes (Length del Address Descriptor)
		   input [5:0] descriptor_index, // Descriptor table de 64 entradas -> 6 bits de indexacion
		   input  act1, // Attribute[4]
		   input  act2, // Attribute[3]
		   input  END, // Attribute [2]
		   input  valid, // Attribute[1]
		   input  dir, // Attribute[0] 1: from memory to SD / 0: from SD to memory
           output start_transfer,
           output [63:0] system_address, // 4 bytes currently being transfered
           output writing_mem, // 1 if dir = 0 and TFC = 0
           output reading_mem, //
           output reading_fifo,
           output writing_fifo,
		   output [5:0] next_descriptor_index);

 parameter ST_STOP  = 2'b00,
           ST_FDS   = 2'b01,
           ST_CADR  = 2'b10,
           ST_TFR   = 2'b11;

reg   [1:0]          state;          // Estado presente

reg                  reading_fifo;
reg                  writing_fifo;
reg                  reading_mem;
reg                  writing_mem;    // 1 if dir = 0 and TFC = 0
reg                  start_transfer;


reg  [1:0]          next_state; // Proximo estado
reg  [63:0]         system_address; //
reg  [5:0]			next_descriptor_index;


 // Asignar proximo estado

 always  @ (posedge clk)
  begin
  state <= next_state;
  end

 // Logica de transicion de estados

always @(*) begin

   case(state)

	ST_STOP : begin                                                      // ADMA2 stays in this state in following cases:
            if(reset) next_state = ST_STOP;                              // After reset
               else if(cmd_reg_write || Continue) next_state = ST_FDS;   // All descriptor data transfers are completed
          end                                                            // If a new DMA operation is started by writing Command register, go to
                                                                         //  ST_FDS state.

     ST_FDS :   begin                                    // DMA fetches a descriptor line: if (!Act2&&!Act1) NOP: go to next
                    if(!valid) next_state = ST_FDS;      // descriptor line. If descriptor line valid = 0 to go next descriptor line
                    else next_state = ST_CADR;           // Next descriptor line = descriptor_index
                end
     ST_CADR :  begin                                             // Link operation loads another Descriptor address to ADMA System Address
                if(TRAN) next_state = ST_TFR;                // register. In other operations, ADMA System Address register is
                       else next_state = ST_CADR ;
                if(!END&&!TRAN) next_state = ST_FDS  ;      // incremented to point next descriptor line. If TRAN=0, go to ST_TFR state.
                end                                               //  data_address = system_address

ST_TFR : begin                                                            // Data transfer of one descriptor line is executed between system memory
                      if(!TFC) next_state = ST_TFR;                       // and SD card. If data transfer continues (End=0) go to ST_TFR. goto_address++
                      else if(TFC&&(END||STOP)) next_state = ST_STOP;     // If data transfer is complete (End = 1) got to ST_STOP.
                       else if(TFC&&(!END||!STOP)) next_state = ST_FDS;   // Stop signal is generated through interrupts
              end

    default : next_state = ST_STOP;
    endcase
end // always(*)

// Logica de las salidas

always @(*) begin
           case(state)
                      ST_STOP: begin
                               start_transfer = 0;
                               system_address = data_address; // 4 bytes currently being transfered
                               writing_mem  = 0;   // 1 if dir = 0 and TFC = 0
                               reading_mem  = 0;   //
                               reading_fifo = 0;
                               writing_fifo = 0;
                      end

                      ST_FDS: begin

                               start_transfer = 0;
                               writing_mem =  0 ;   // 1 if dir = 0 and TFC = 0
                               reading_mem  = 0;   //
                               reading_fifo = 0;
                               writing_fifo = 0;
                               if(!valid) next_descriptor_index = descriptor_index + 1;
                      end

                      ST_CADR: begin
                               start_transfer = 0;
                	           system_address  = data_address + 1; // 4 bytes currently being transfered
                               writing_mem  = 0;    // 1 if dir = 0 and TFC = 0
                               reading_mem  = 0;   //
                               reading_fifo = 0;
                               writing_fifo = 0;
                      end
                      ST_TFR: begin
                               start_transfer = 1;
                               system_address =  system_address; // 4 bytes currently being transfered
                               writing_mem = !dir;    // 1 if dir = 0 and TFC = 0
                               reading_mem = dir;    //
                               reading_fifo = !dir; // FIXME no lo tengo muy claro
                               writing_fifo = dir;  // FIXME no lo tengo muy claro
                      end

					  default: begin
					  start_transfer = 0;
					  system_address = data_address; // 4 bytes currently being transfered
					  writing_mem  = 0;   // 1 if dir = 0 and TFC = 0
					  reading_mem  = 0;   //
					  reading_fifo = 0;
					  writing_fifo = 0;
			 end

           endcase

end // always @(*)



endmodule
