//-----------------------------------------------------
// PROYECTO 1  : SD HOST
// Archivo     : testfisico.v
// Descripcion : testbench para capa física de bloque de DATA
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------

`timescale 1ns / 1ps

//`include "DATA.v"
`include "probadorPhysical.v"
`include "DATA_PHYSICAL.v"




module testbench;


// Wires para probar data
//inputs
wire SD_CLK;
wire RESET_L;
wire strobe_IN_DATA_Phy;
wire ack_IN_DATA_Phy;
wire [15:0] timeout_Reg_DATA_Phy;
wire [3:0] blocks_DATA_Phy;
wire writeRead_DATA_Phy;
wire multiple_DATA_Phy;
wire idle_in_DATA_Phy;
wire transmission_complete_PS_Phy;
wire reception_complete_SP_Phy;
wire [31:0] data_read_SP_Phy;
wire [31:0] dataFromFIFO_FIFO_Phy;

//outputs
wire serial_Ready_Phy_DATA;
wire complete_Phy_DATA;
wire ack_OUT_Phy_DATA;
wire data_timeout_Phy_DATA;
wire reset_Wrapper_Phy_PS;
wire enable_pts_Wrapper_Phy_PS;
wire enable_stp_Wrapper_Phy_SP;
wire [31:0] dataParallel_Phy_PS;
wire pad_state_Phy_PAD;
wire pad_enable_Phy_PAD;
wire writeFIFO_enable_Phy_FIFO;
wire readFIFO_enable_Phy_FIFO;
wire [31:0] dataReadToFIFO_Phy_FIFO;
wire IO_enable_Phy_SD_CARD;
 
      
//probador para bloque de control de datos
probador DataTest(
    .SD_CLK(SD_CLK),
    .RESET_L(RESET_L),
    .strobe_IN_DATA_Phy(strobe_IN_DATA_Phy),
    .ack_IN_DATA_Phy(ack_IN_DATA_Phy),
    .timeout_Reg_DATA_Phy(timeout_Reg_DATA_Phy),
    .blocks_DATA_Phy(blocks_DATA_Phy),
    .writeRead_DATA_Phy(writeRead_DATA_Phy),
    .multiple_DATA_Phy(multiple_DATA_Phy),
    .idle_in_DATA_Phy(idle_in_DATA_Phy),
    .transmission_complete_PS_Phy(transmission_complete_PS_Phy),
    .reception_complete_SP_Phy(reception_complete_SP_Phy),
    .data_read_SP_Phy(data_read_SP_Phy),
    .dataFromFIFO_FIFO_Phy(dataFromFIFO_FIFO_Phy)
);

// Instanciar Unit Under Test (UUT) DATA_PHYSICAL
DATA_PHYSICAL DATAPhy(
	//inputs
    .SD_CLK(SD_CLK),
    .RESET_L(RESET_L),
    .strobe_IN_DATA_Phy(strobe_IN_DATA_Phy),
    .ack_IN_DATA_Phy(ack_IN_DATA_Phy),
    .timeout_Reg_DATA_Phy(timeout_Reg_DATA_Phy),
    .blocks_DATA_Phy(blocks_DATA_Phy),
    .writeRead_DATA_Phy(writeRead_DATA_Phy),
    .multiple_DATA_Phy(multiple_DATA_Phy),
    .idle_in_DATA_Phy(idle_in_DATA_Phy),
    .transmission_complete_PS_Phy(transmission_complete_PS_Phy),
    .reception_complete_SP_Phy(reception_complete_SP_Phy),
    .data_read_SP_Phy(data_read_SP_Phy),
    .dataFromFIFO_FIFO_Phy(dataFromFIFO_FIFO_Phy),

	//outputs
    .serial_Ready_Phy_DATA(serial_Ready_Phy_DATA),
    .complete_Phy_DATA(complete_Phy_DATA),
    .ack_OUT_Phy_DATA(ack_OUT_Phy_DATA),
    .data_timeout_Phy_DATA(data_timeout_Phy_DATA),
    .reset_Wrapper_Phy_PS(reset_Wrapper_Phy_PS),
    .enable_pts_Wrapper_Phy_PS(enable_pts_Wrapper_Phy_PS),
    .enable_stp_Wrapper_Phy_SP(enable_stp_Wrapper_Phy_SP),
    .dataParallel_Phy_PS(dataParallel_Phy_PS),
    .pad_state_Phy_PAD(pad_state_Phy_PAD),
    .pad_enable_Phy_PAD(pad_enable_Phy_PAD),
    .writeFIFO_enable_Phy_FIFO(writeFIFO_enable_Phy_FIFO),
    .readFIFO_enable_Phy_FIFO(readFIFO_enable_Phy_FIFO),
    .dataReadToFIFO_Phy_FIFO(dataReadToFIFO_Phy_FIFO),
    .IO_enable_Phy_SD_CARD(IO_enable_Phy_SD_CARD)
      
);

endmodule