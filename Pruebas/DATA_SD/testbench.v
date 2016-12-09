//-----------------------------------------------------
// PROYECTO 1  : SD HOST
// Archivo     : testbench.v
// Descripcion : testbench para bloque de datos
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------

`timescale 1ns / 1ps

`include "DATA.v"
`include "probador.v"
//`include "DATA_PHYSICAL.v"




module testbench;


// Wires para probar data
wire CLK;
wire RESET_L;
wire writeRead_Regs_DATA;
wire [3:0] blockCount_Regs_DATA;
wire multipleData_Regs_DATA;
wire timeout_Enable_Regs_DATA; 
wire [15:0] timeout_Reg_Regs_DATA; 
wire new_DAT_DMA_DATA;
wire serial_Ready_Phy_DATA; 
wire timeout_Phy_DATA; 
wire complete_Phy_DATA; 
wire ack_IN_Phy_DATA; 
wire fifo_OK_FIFO_DATA;

//salidas de DATA
wire transfer_complete_DATA_DMA;
wire strobe_OUT_DATA_Phy;
wire ack_OUT_DATA_Phy;
wire [3:0] blocks_DATA_Phy;
wire [15:0] timeout_value_DATA_Phy;
wire writeReadPhysical_DATA_Phy;
wire multiple_DATA_Phy;
wire idle_out_DATA_Phy;  
      
//probador para bloque de control de datos
probador DataTest(
    .CLK(CLK),
    .RESET_L(RESET_L),
    .writeRead_Regs_DATA(writeRead_Regs_DATA),
    .blockCount_Regs_DATA(blockCount_Regs_DATA),
    .multipleData_Regs_DATA(multipleData_Regs_DATA),
    .timeout_Enable_Regs_DATA(timeout_Enable_Regs_DATA), 
    .timeout_Reg_Regs_DATA(timeout_Reg_Regs_DATA), 
    .new_DAT_DMA_DATA(new_DAT_DMA_DATA),
    .serial_Ready_Phy_DATA(serial_Ready_Phy_DATA), 
    .timeout_Phy_DATA(timeout_Phy_DATA), 
    .complete_Phy_DATA(complete_Phy_DATA), 
    .ack_IN_Phy_DATA(ack_IN_Phy_DATA), 
    .fifo_OK_FIFO_DATA(fifo_OK_FIFO_DATA)

);

// Instanciar Unit Under Test (UUT) DATA
DATA DATA_CONTROL(
	//inputs
    .CLK(CLK),
    .RESET_L(RESET_L),
    .writeRead_Regs_DATA(writeRead_Regs_DATA),
    .blockCount_Regs_DATA(blockCount_Regs_DATA),
    .multipleData_Regs_DATA(multipleData_Regs_DATA),
    .timeout_Enable_Regs_DATA(timeout_Enable_Regs_DATA), 
    .timeout_Reg_Regs_DATA(timeout_Reg_Regs_DATA), 
    .new_DAT_DMA_DATA(new_DAT_DMA_DATA),
    .serial_Ready_Phy_DATA(serial_Ready_Phy_DATA), 
    .timeout_Phy_DATA(timeout_Phy_DATA), 
    .complete_Phy_DATA(complete_Phy_DATA), 
    .ack_IN_Phy_DATA(ack_IN_Phy_DATA), 
    .fifo_OK_FIFO_DATA(fifo_OK_FIFO_DATA),
	//outputs
    .transfer_complete_DATA_DMA(transfer_complete_DATA_DMA),
    .strobe_OUT_DATA_Phy(strobe_OUT_DATA_Phy),
    .ack_OUT_DATA_Phy(ack_OUT_DATA_Phy),
    .blocks_DATA_Phy(blocks_DATA_Phy),
    .timeout_value_DATA_Phy(timeout_value_DATA_Phy),
    .writeReadPhysical_DATA_Phy(writeReadPhysical_DATA_Phy),
    .multiple_DATA_Phy(multiple_DATA_Phy),
    .idle_out_DATA_Phy(idle_out_DATA_Phy)        
);

endmodule