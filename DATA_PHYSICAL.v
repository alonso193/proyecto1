//-----------------------------------------------------
// Proyecto 1  : DISEÑO DE UN CONTROLADOR DE SD HOST
// Archivo     : DATA_PHYSICAL.v
// Descripcion : Control de capa física de datos del SD Host.
//  La función de este bloque es servir de interfaz entre la tajeta SD, la capa física y el buffer FIFO.
//  Se comunica con el bloque de Registros y los convertidores Serial a Paralelo, Paralelo a Serial y el bloque
//  PAD.
//
// Grupo 02
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------

/*
=================================================
CAPA FÍSICA DEL MODULO DE CONTROL DE DATOS
=================================================

Este módulo por aparte se especializa en manejar tramas de datos directamente
con la tarjeta SD y sus pines físicos.  Su arquitectura es muy similar a la de
la capa física del bloque CMD, con la diferencia de que a DATA_PHYSICAL le toca
interactuar directamente con el buffer FIFO.

PINOUT del módulo:

Para nombrar señales se usa la convención señal_procedencia_destino

---
notas:
 1- entiéndase PS como el módulo Parallel to Serial y SP como el módulo Serial to Parallel.
 2- SD_CLK opera a 25MHz

_____________________________________________________________________________________
Nombre de Señal              : Entradas : Salidas : procedencia : destino

SD_CLK                             x       -         SD_CARD       DATA_PHYSICAL
RESET_L                            x       -         Host          DATA_PHYSICAL
strobe_IN_DATA_Phy                 x       -         DATA          DATA_PHYSICAL
ack_IN_DATA_Phy                    x       -         DATA          DATA_PHYSICAL
timeout_Reg_DATA_Phy [15:0]        x       -         DATA          DATA_PHYSICAL
blocks_DATA_Phy [3:0]              x       -         DATA          DATA_PHYSICAL
writeRead_DATA_Phy                 x       -         DATA          DATA_PHYSICAL
multiple_DATA_Phy                  x       -         DATA          DATA_PHYSICAL
idle_in_DATA_Phy                   x       -         DATA          DATA_PHYSICAL
transmission_complete_PS_Phy       x       -         PS            DATA_PHYSICAL
reception_complete_SP_Phy          x       -         SP            DATA_PHYSICAL
data_read_SP_Phy [31:0]            x       -         SP            DATA_PHYSICAL
dataFromFIFO_FIFO_Phy [31:0]       x       -         FIFO          DATA_PHYSICAL
serial_Ready_Phy_DATA              -       x         DATA_PHYSICAL DATA
complete_Phy_DATA                  -       x         DATA_PHYSICAL DATA
ack_OUT_Phy_DATA                   -       x         DATA_PHYSICAL DATA
data_timeout_Phy_DATA              -       x         DATA_PHYSICAL DATA y Regs
reset_Wrapper_Phy_PS               -       x         DATA_PHYSICAL PS y SP
enable_pts_Wrapper_Phy_PS          -       x         DATA_PHYSICAL PS
enable_stp_Wrapper_Phy_SP          -       x         DATA_PHYSICAL SP
dataParallel_Phy_PS [31:0]         -       x         DATA_PHYSICAL PS
pad_state_Phy_PAD                  -       x         DATA_PHYSICAL PAD
pad_enable_Phy_PAD                 -       x         DATA_PHYSICAL PAD
writeFIFO_enable_Phy_FIFO          -       x         DATA_PHYSICAL FIFO
readFIFO_enable_Phy_FIFO           -       x         DATA_PHYSICAL FIFO
dataReadToFIFO_Phy_FIFO [31:0]     -       x         DATA_PHYSICAL FIFO
DAT_pin_IN_SDCard_Phy              x       -         SD_CARD       DATA_PHYSICAL <<< es un pin de entrada/salida que no se usa
DAT_pin_OUT_Phy_SDCard             -       x         DATA_PHYSICAL SD_CARD           en la implementacion final
DAT_pin_OUT_Enable_Phy_SDCard      -       x         DATA_PHYSICAL SD_CARD
_____________________________________________________________________________________

*/


module DATA_PHYSICAL(
    input wire SD_CLK,
    input wire RESET_L,
    input wire strobe_IN_DATA_Phy,
    input wire ack_IN_DATA_Phy,
    input wire [15:0] timeout_Reg_DATA_Phy,
    input wire [3:0] blocks_DATA_Phy,
    input wire writeRead_DATA_Phy,
    input wire multiple_DATA_Phy,
    input wire idle_in_DATA_Phy,
    input wire transmission_complete_PS_Phy,
    input wire reception_complete_SP_Phy,
    input wire [31:0] data_read_SP_Phy,
    input wire [31:0] dataFromFIFO_FIFO_Phy,
    output reg serial_Ready_Phy_DATA,
    output reg complete_Phy_DATA,
    output reg ack_OUT_Phy_DATA,
    output reg data_timeout_Phy_DATA,
    output reg reset_Wrapper_Phy_PS,
    output reg enable_pts_Wrapper_Phy_PS,
    output reg enable_stp_Wrapper_Phy_SP,
    output reg [31:0] dataParallel_Phy_PS,
    output reg pad_state_Phy_PAD,
    output reg pad_enable_Phy_PAD,
    output reg writeFIFO_enable_Phy_FIFO,
    output reg readFIFO_enable_Phy_FIFO,
    output reg [31:0] dataReadToFIFO_Phy_FIFO,
    output reg IO_enable_Phy_SD_CARD
);

//Definición y condificación de estados one-hot
parameter RESET                  = 11'b00000000001;
parameter IDLE                   = 11'b00000000010;
parameter FIFO_READ              = 11'b00000000100;
parameter LOAD_WRITE             = 11'b00000001000;
parameter SEND                   = 11'b00000010000;
parameter WAIT_RESPONSE          = 11'b00000100000;
parameter READ                   = 11'b00001000000;
parameter READ_FIFO_WRITE        = 11'b00010000000;
parameter READ_WRAPPER_RESET     = 11'b00100000000;
parameter WAIT_ACK               = 11'b01000000000;
parameter SEND_ACK               = 11'b10000000000;

//registros internos de interés
reg [15:0] timeout_input;
reg [3:0] blocks;
reg STATE;
reg NEXT_STATE;


//Inicializar, en el estado IDLE, los contadores para timeout_Reg_DATA_Phy y bloques
//timeout_input es el contador para el timeout_Reg_DATA_Phy;
//blocks es el contador para blocks_DATA_Phy;

//NEXT_STATE logic (always_ff)
always @ (posedge SD_CLK)
begin
    if (!RESET_L)
        begin
        STATE <= RESET;
        end
    else
        begin
            STATE <= NEXT_STATE;
        end
end
//--------------------------------

//CURRENT_STATE logic (always comb)
always @ (*)
begin
    case (STATE)
        RESET:
            begin
            //se ponen todas las salidas a 0 excepto reset_Wrapper_Phy_PS
            serial_Ready_Phy_DATA       = 0;
            complete_Phy_DATA           = 0;
            ack_OUT_Phy_DATA            = 0;
            data_timeout_Phy_DATA       = 0;
            reset_Wrapper_Phy_PS        = 1;  //solo esta en 1 porque el wrapper se resetea en 0
            enable_pts_Wrapper_Phy_PS   = 0;
            enable_stp_Wrapper_Phy_SP   = 0;
            dataParallel_Phy_PS         = 32'b0;
            pad_state_Phy_PAD           = 0;
            pad_enable_Phy_PAD          = 0;
            writeFIFO_enable_Phy_FIFO   = 0;
            readFIFO_enable_Phy_FIFO    = 0;
            dataReadToFIFO_Phy_FIFO     = 32'b0;
            IO_enable_Phy_SD_CARD        = 0   //por default el host recibe datos desde la tarjeta SD

            //avanza automaticamente a IDLE
            NEXT_STATE = IDLE;
            end
        //------------------------------
        IDLE:
            begin
            // estado por defecto en caso de interrupcion
            // afirma la salida serial_Ready_Phy_DATA
            serial_Ready_Phy_DATA = 1;
            //reiniciar blocks_DATA_Phy y timeout_Reg_DATA_Phy
            blocks = 4'b0;
            timeout_input = 16'b0;

            if (strobe_IN_DATA_Phy && writeRead_DATA_Phy)
                begin
                    NEXT_STATE = FIFO_READ;
                end
            else
                begin
                    NEXT_STATE = READ;
                end
            end
        //-------------------------------
        FIFO_READ:
            begin
            //se afirma writeFIFO_enable_Phy_FIFO
            writeFIFO_enable_Phy_FIFO = 1;
            dataParallel_Phy_PS = dataFromFIFO_FIFO_Phy;

            //se avanza al estado LOAD_WRITE
            NEXT_STATE = LOAD_WRITE;
            end
        //--------------------------------
        LOAD_WRITE:
            begin
            //se carga al convertidor PS los datos que venían del FIFO mediante la
            //combinación de señales:
            enable_pts_Wrapper_Phy_PS = 1;
            IO_enable_Phy_SD_CARD = 0;
            pad_state_Phy_PAD = 1;
            pad_enable_Phy_PAD = 1;

            //se avanza al estado SEND
            NEXT_STATE = SEND;
            end
        //---------------------------------
        SEND:
            begin
            //avisar al hardware que se entregarán datos
            IO_enable_Phy_SD_CARD = 1;
            //se avanza al estado WAIT_RESPONSE
            NEXT_STATE = WAIT_RESPONSE;
            end
        //---------------------------------
        WAIT_RESPONSE:
            begin
            //desabilitar convertidor PS
            enable_pts_Wrapper_Phy_PS = 0;
            //habilitar el convertidor SP
            enable_stp_Wrapper_Phy_SP = 1;
            //preparar el PAD para su uso
            pad_state_Phy_PAD = 0;
            //comienza la cuenta de timeout_input y genera interrupcion si se pasa
            timeout_input = timeout_input + 1;
            if (timeout_input == timeout_Reg_DATA_Phy)
                begin
                    data_timeout_Phy_DATA = 1;
                end
            else
                begin
                    data_timeout_Phy_DATA = 0;
                end

            if (reception_complete_SP_Phy)
                begin
                    //se incrementa en 1 los bloques transmitidos
                    blocks = blocks + 1;
                    //y se decide el estado
                    if (!multiple_DATA_Phy || (blocks==blocks_DATA_Phy))
                        begin
                            NEXT_STATE = WAIT_ACK;
                        end
                    else
                        begin
                            //continúa la transmisión del siguiente bloque
                            NEXT_STATE = FIFO_READ;
                        end
                end
            else
                begin
                    NEXT_STATE = WAIT_RESPONSE;
                end
            end
        //-----------------------------------
        READ:
            begin
            //se afirma la señal pad_enable_Phy_PAD
            pad_enable_Phy_PAD = 1;
            //pad_state_Phy_PAD se pone en bajo para usarlo como entrada
            pad_state_Phy_PAD = 0;
            //habilitar convertidad SP
            enable_stp_Wrapper_Phy_SP = 1;
            //se realiza una cuenta de timeout
            timeout_input = timeout_input + 1;
            //genera interrupcion si se pasa
            if (timeout_input == timeout_Reg_DATA_Phy)
                begin
                    data_timeout_Phy_DATA = 1;
                end
            else
                begin
                    data_timeout_Phy_DATA = 0;
                end

            //revisar si la transmisión está completa
            if (reception_complete_SP_Phy)
                begin
                    //se incrementa en 1 los bloques transmitidos
                    blocks = blocks + 1;
                    NEXT_STATE = READ_FIFO_WRITE;
                end
            else
                begin
                    NEXT_STATE = READ;
                end
            end
        //------------------------------------
        READ_FIFO_WRITE:
            begin
            //afirma la señal readFIFO_enable_Phy_FIFO
            readFIFO_enable_Phy_FIFO = 1;
            //se coloca la salida dataReadToFIFO_Phy_FIFO en data_read_SP_Phy
            dataReadToFIFO_Phy_FIFO = data_read_SP_Phy;
            //se desabilita el convertidor SP
            enable_stp_Wrapper_Phy_SP = 0;
            if ((blocks == blocks_DATA_Phy) || !multiple_DATA_Phy)
                begin
                    NEXT_STATE = WAIT_ACK;
                end
            else
                begin
                    NEXT_STATE = READ_WRAPPER_RESET;
                end
            end
        //------------------------------------
        READ_WRAPPER_RESET:
            begin
            //reiniciar los wrappers
            reset_Wrapper_Phy_PS = 1;
            NEXT_STATE = READ;
            end
        //------------------------------------
        WAIT_ACK:
            begin
            //afirma la señal complete_Phy_DATA para indicar que se terminó la transacción de DATA
            complete_Phy_DATA = 1;
            if (ack_IN_DATA_Phy)
                begin
                    NEXT_STATE = SEND_ACK;
                end
            else
                begin
                    NEXT_STATE = WAIT_ACK;
                end
            end
        //-------------------------------------
        SEND_ACK:
            begin
                //afirma la señal ack_OUT_Phy_DATA para reconocer que se recibió ack_IN_DATA_Phy por parte del CONTROLADOR DATA
                ack_OUT_Phy_DATA = 1;
                NEXT_STATE = IDLE;
            end
        //-------------------------------------
        default:
            begin
            NEXT_STATE = IDLE;  //estado por defecto
            end
    endcase
end //always



endmodule // DATA_PHYSICAL
