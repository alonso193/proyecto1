// *****************************
// Luis F. Mora
// B24449
// Circuitos Digitales II
// Prof. Enrique Coen
// *****************************

`timescale 1ns / 1ps

`include "probador_dma.v"
`include "DMA.v"


module testbech;

// Wires hacia el DMA

wire reset;
wire clk; // Señales de entrada del DMA
wire TFC; // Senal del fifo (cuando system_address = data_address + length)
wire cmd_reg_write; // Senal de inicio
wire cmd_reg_read; // Senal de inicio
wire Continue; // Senal de reanudacion
wire TRAN; // Parte del descriptor address
wire STOP; // Interrupt signal
wire empty; // ;fifo empty
wire full; // fifo full
wire [63:0] data_address; // Posicion donde empieza el dato (Address Field del Address Descriptor)
wire [15:0] length; // Tamano del dato en bytes (Length del Address Descriptor)
wire [5:0] descriptor_index; // Descriptor table de 64 entradas -> 6 bits de indexacion
wire  act1; // Attribute[4]
wire  act2; // Attribute[3]
wire  END; // Attribute [2]
wire  valid; // Attribute[1]
wire  dir;

// Salidas de DMA

wire start_transfer;
wire [63:0] system_address; // 4 bytes currently being transfered
wire writing_mem; // 1 if dir = 0 and TFC = 0
wire reading_mem; //
wire reading_fifo;
wire writing_fifo;
wire [5:0] next_descriptor_index;

probador_dma DMAtest(reset, clk, TFC, cmd_reg_write, cmd_reg_read, Continue, TRAN, STOP, empty, full, data_address,
					 length, descriptor_index, act1, act2, END, valid, dir);
					 
DMA DMAC(reset, clk, TFC, cmd_reg_write, cmd_reg_read, Continue);

// DMA DMA(reset, clk, TFC, cmd_reg_write, cmd_reg_read, Continue, TRAN, STOP, empty, full, data_address,
// 		 length, descriptor_index, act1, act2, END, valid, dir, start_transfer, system_address, writing_mem,
// 		 reading_mem, reading_fifo, writing_fifo, next_descriptor_index);

endmodule
