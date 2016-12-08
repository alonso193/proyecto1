//-----------------------------------------------------
// Proyecto 1  : DISEÑO DE UN CONTROLADOR DE SD HOST
// Archivo     : BloqueDATA.v
// Descripcion : CONTROLADOR de datos del SD Host.
//  La función de este bloque es servir de interfaz entre la tajeta SD y el buffer FIFO.
//
//
// Grupo 02
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------


/*

PINOUT DEL BLOQUE DE DATA
_____________________________________________________________________________________
    Nombre de Señal                  : Entradas : Salidas : procedencia : destino
    CLK                                   x          -           HOST      DATA
    SD_CLK                                x          -           HOST      DATA
    RESET_L                               x          -           HOST      DATA
    timeout_Reg_DATA                      x          -           Reg       DATA
    writeRead_Reg_DATA                    x          -           Reg       DATA
    blockCount_Reg_DATA                   x          -           Reg       DATA
    multipleData_Reg_DATA                 x          -           Reg       DATA
    timeout_enable_Reg_DATA               x          -           Reg       DATA
    FIFO_OK_FIFO_DATA                     x          -           FIFO      DATA
    New_DAT_DMA_DATA                      x          -           DMA       DATA
    DATA_PIN_IN                           x          -           SD_CARD   DATA
    writeFIFO_enable_DATA_FIFO            -          x           DATA      FIFO
    readFIFO_enable_DATA_FIFO             -          x           DATA      FIFO
    transfer_complete_DATA_DMA            -          x           DATA      DMA
    IO_enable_DATA_SD_CARD                -          x           DATA      SD_CARD
    DATA_PIN_OUT                          -          x           DATA      SD_CARD
_____________________________________________________________________________________

*/

//Define
`define PALABRA 32

//Módulos utilizados
`include "DATA.v"
`include "DATA_PHYSICAL.v"

module BloqueDATA(
    input wire CLK,
    input wire SD_CLK,
    input wire RESET_L,
    input wire [15:0] timeout_Reg_Regs_DATA,
    input wire writeRead_Regs_DATA,
    input wire [3:0] blockCount_Regs_DATA,
    input wire multipleData_Regs_DATA,
    input wire timeout_enable_Regs_DATA,
    input wire FIFO_OK_FIFO_DATA,
    input wire [31:0] dataFromFIFO_FIFO_Phy,
    input wire New_DAT_DMA_DATA,
    input wire DATA_PIN_IN,
    output wire writeFIFO_enable_Phy_FIFO,
    output wire readFIFO_enable_Phy_FIFO,
    output wire [31:0] dataReadToFIFO_Phy_FIFO,
    output wire transfer_complete_DATA_DMA,
    output wire IO_enable_Phy_SD_CARD,
    output wire DATA_PIN_OUT,
    output wire pad_state_Phy_PAD,
    output wire pad_enable_Phy_PAD
);

//wires entre DATA y DATA_PHYSICAL
wire serial_Ready_Phy_DATA;
wire timeout_Phy_DATA;
wire complete_Phy_DATA;
wire ack_IN_Phy_DATA;
wire strobe_OUT;
wire strobe_OUT_DATA_Phy;
wire ack_OUT_DATA_Phy;
wire [3:0] blocks_DATA_Phy;
wire [15:0] timeout_value_DATA_Phy;
wire writeReadPhysical_DATA_Phy;
wire multiple_DATA_Phy;
wire idle_out_DATA_Phy;

//wires a SP o PS converter
//SP
wire reception_complete_SP_Phy;
wire [31:0] data_read_SP_Phy;
wire enable_stp_Wrapper_Phy_SP;
//PS
wire transmission_complete_PS_Phy;
wire reset_Wrapper_Phy_PS;
wire enable_pts_Wrapper_Phy_PS;
wire [31:0] dataParallel_Phy_PS;


//CONTROLADOR de DATOS
DATA ControlDatos(
    .CLK(CLK),
    .RESET_L(RESET_L),
    .writeRead_Regs_DATA(writeRead_Regs_DATA),
    .blockCount_Regs_DATA(blockCount_Regs_DATA),
    .multipleData_Regs_DATA(multipleData_Regs_DATA),
    .timeout_Enable_Regs_DATA(timeout_enable_Regs_DATA),
    .timeout_Reg_Regs_DATA(timeout_Reg_Regs_DATA),
    .new_DAT_DMA_DATA(New_DAT_DMA_DATA),
    .serial_Ready_Phy_DATA(serial_Ready_Phy_DATA),
    .timeout_Phy_DATA(timeout_Phy_DATA),
    .complete_Phy_DATA(complete_Phy_DATA),
    .ack_IN_Phy_DATA(ack_IN_Phy_DATA),
    .fifo_OK_FIFO_DATA(FIFO_OK_FIFO_DATA),
    .transfer_complete_DATA_DMA(transfer_complete_DATA_DMA),
    .strobe_OUT_DATA_Phy(strobe_OUT_DATA_Phy),
    .ack_OUT_DATA_Phy(ack_OUT_DATA_Phy),
    .blocks_DATA_Phy(blocks_DATA_Phy),
    .timeout_value_DATA_Phy(timeout_value_DATA_Phy),
    .writeReadPhysical_DATA_Phy(writeReadPhysical_DATA_Phy),
    .multiple_DATA_Phy(multiple_DATA_Phy),
    .idle_out_DATA_Phy(idle_out_DATA_Phy)
);

//Capa física de control de datos
DATA_PHYSICAL CapaFisica(
    .SD_CLK(SD_CLK),
    .RESET_L(RESET_L),
    .strobe_IN_DATA_Phy(strobe_OUT_DATA_Phy),
    .ack_IN_DATA_Phy(ack_OUT_DATA_Phy),
    .timeout_Reg_DATA_Phy(timeout_value_DATA_Phy),
    .blocks_DATA_Phy(blocks_DATA_Phy),
    .writeRead_DATA_Phy(writeReadPhysical_DATA_Phy),
    .multiple_DATA_Phy(multiple_DATA_Phy),
    .idle_in_DATA_Phy(idle_out_DATA_Phy),
    .transmission_complete_PS_Phy(transmission_complete_PS_Phy),
    .reception_complete_SP_Phy(reception_complete_SP_Phy),
    .data_read_SP_Phy(data_read_SP_Phy),
    .dataFromFIFO_FIFO_Phy(dataFromFIFO_FIFO_Phy),
    .serial_Ready_Phy_DATA(serial_Ready_Phy_DATA),
    .complete_Phy_DATA(complete_Phy_DATA),
    .ack_OUT_Phy_DATA(ack_IN_Phy_DATA),
    .data_timeout_Phy_DATA(timeout_Phy_DATA),
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

//convertidor Paralelo a Serial
PARALLEL_TO_SERIAL convert_paralelo_serial(
    .enable_pts(enable_pts_Wrapper_Phy_PS), 
    .reset_pts(reset_Wrapper_Phy_PS), 
    .SD_CLK(SD_CLK), 
    .signal_in(dataParallel_Phy_PS), 
    .signal_out(DATA_PIN_OUT), 
    .parallel_complete(transmission_complete_PS_Phy)
);

//convertidor serial a paralelo
SERIAL_TO_PARALLEL #(32) convert_serial_paralelo(
    .serial_in(DATA_PIN_IN),
    .enable_stp(enable_stp_Wrapper_Phy_SP),
    .SD_CLK(SD_CLK),
    .RESET_L(RESET_L),
    .reception_complete(reception_complete_SP_Phy),
    .parallel_out(data_read_SP_Phy)
);


endmodule // BloqueDATA

/*
----------------------------------------
MODULOS adicionales para el BloqueDATA
----------------------------------------


*/
module PARALLEL_TO_SERIAL (
    input wire enable_pts, 
    input wire reset_pts, 
    input wire SD_CLK, 
    input wire [31:0] signal_in, 
    output reg signal_out, 
    output reg parallel_complete
    );
    
    //registros y wires internos
    reg [8:0]contador = 0;

    always @ ( posedge SD_CLK ) begin
        if (reset_pts == 1) begin
            signal_out <= 0;
            contador <= 0;
            parallel_complete <= 0;
        end else begin
            if (enable_pts == 1) begin
                if (contador == 32) begin
                    parallel_complete <= 1;
                    contador <= 0;
                end else begin
                    parallel_complete <= 0;
                    signal_out = signal_in[31 - contador];
                    contador <= contador + 1;
                end
            end else begin
                signal_out <= 0;
            end
        end
    end
endmodule // PARALLEL_TO_SERIAL


module SERIAL_TO_PARALLEL # (parameter SIZE = `PALABRA)
(
    input wire serial_in,
    input wire enable_stp,
    input wire SD_CLK,
    input wire RESET_L,
    output reg reception_complete,
    output reg [SIZE - 1:0] parallel_out
);

reg [8:0] contador;
always @ (posedge SD_CLK or negedge RESET_L)
begin
    if (~RESET_L)
        begin
            parallel_out <= 0;
            reception_complete <= 0;
            contador <= 0;
        end
    else
        begin
            if (enable_stp)
                begin
                    if (contador == SIZE)
                        begin
                            reception_complete <= 1;
                            contador <= 0;
                        end
                    else
                        begin
                            reception_complete <= 0;
                            parallel_out <= {serial_in, parallel_out[SIZE-1:1]};
                            contador <= contador + 1;
                        end
                end
            else
                begin
                    parallel_out <= 0;
                end
        end
end //always

endmodule // CONVERT_SERIAL_TO_PARALLEL