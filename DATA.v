//-----------------------------------------------------
// Proyecto 1  : DISEÑO DE UN CONTROLADOR DE SD HOST
// Archivo     : DATA.v
// Descripcion : Control de datos del SD Host 
//  La función de este bloque es servir de interface entre los registros
//  la interfaz de DMA, y la capa física donde se pasan las tramas de bits
//  directamente.
//
// Grupo 02
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------

/* PINOUT del módulo*

Para nombrar señales se usa la convención señal_procedencia_destino
_____________________________________________________________________________________
Nombre de Señal        : Entradas : Salidas : procedencia : destino

CLK                           x        -         Host          DATA
RESET_L                       x        -         Host          DATA
writeRead_Regs_DATA           x        -         Regs          DATA
blockCount_Regs_DATA [3:0]    x        -         Regs          DATA
multipleData_Regs_DATA        x        -         Regs          DATA        
timeout_Enable_Regs_DATA      x        -         Regs          DATA 
timeout_Reg_Regs_DATA [15:0]  x        -         Regs          DATA 
new_DAT_DMA_DATA              x        -         DMA           DATA 
serial_Ready_Phy_DATA         x        -         DATA_PHYSICAL DATA 
timeout_Phy_DATA              x        -         DATA_PHYSICAL DATA 
complete_Phy_DATA             x        -         DATA_PHYSICAL DATA 
ack_IN_Phy_DATA               x        -         DATA_PHYSICAL DATA 
fifo_OK_FIFO_DATA             x        -         FIFO          DATA 
transfer_complete_DATA_DMA    -        x         DATA          DMA 
strobe_OUT_DATA_Phy           -        x         DATA          DATA_PHYSICAL     
ack_OUT_DATA_Phy              -        x         DATA          DATA_PHYSICAL
blocks_DATA_Phy [3:0]         -        x         DATA          DATA_PHYSICAL
timeout_value_DATA_Phy [15:0] -        x         DATA          DATA_PHYSICAL
writeReadPhysical_DATA_Phy    -        x         DATA          DATA_PHYSICAL
multiple_DATA_Phy             -        x         DATA          DATA_PHYSICAL
idle_out_DATA_Phy             -        x         DATA          DATA_PHYSICAL

---
nota: DATA_PHYSICAL corresponde al módulo que representa la capa física de este SD HOST.
*/

`timescale 1ns / 1ps




module DATA(
    input wire CLK,
    input wire RESET_L,
    input wire writeRead_Regs_DATA,
    input wire [3:0] blockCount_Regs_DATA,
    input wire multipleData_Regs_DATA,
    input wire timeout_Enable_Regs_DATA, 
    input wire [15:0] timeout_Reg_Regs_DATA, 
    input wire new_DAT_DMA_DATA,
    input wire serial_Ready_Phy_DATA, 
    input wire timeout_Phy_DATA, 
    input wire complete_Phy_DATA, 
    input wire ack_IN_Phy_DATA, 
    input wire fifo_OK_FIFO_DATA,
    output reg transfer_complete_DATA_DMA,
    output reg strobe_OUT_DATA_Phy,
    output reg ack_OUT_DATA_Phy,
    output reg [3:0] blocks_DATA_Phy,
    output reg [15:0] timeout_value_DATA_Phy,
    output reg writeReadPhysical_DATA_Phy,
    output reg multiple_DATA_Phy,
    output reg idle_out_DATA_Phy
);


//Definición y condificación de estados one-hot
parameter RESET                  = 6'b000001;
parameter IDLE                   = 6'b000010; 
parameter SETTING_OUTPUTS        = 6'b000100;
parameter CHECK_FIFO             = 6'b001000;
parameter TRANSMIT               = 6'b010000;
parameter ACK                    = 6'b100000;

reg STATE;
reg NEXT_STATE;

//NEXT_STATE logic (always_ff)
always @ (posedge CLK)
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
        //------------------------------------------
        RESET:
            begin
            //ponga todas las salidas a 0
            transfer_complete_DATA_DMA = 0;
            strobe_OUT_DATA_Phy        = 0;
            ack_OUT_DATA_Phy           = 0;
            blocks_DATA_Phy            = 4'b0000;
            timeout_value_DATA_Phy     = 0;
            writeReadPhysical_DATA_Phy = 0;
            multiple_DATA_Phy          = 0;
            idle_out_DATA_Phy          = 0;
            //avanza automaticamente a IDLE
            NEXT_STATE = IDLE;
            end
        //------------------------------------------
        IDLE:
            begin
            //se afirma idle_out_DATA_Phy y se pasa a SETTING_OUTPUTS si new_DAT_DMA_DATA es 1
            idle_out_DATA_Phy = 1;

            if (new_DAT_DMA_DATA)
                begin
                    NEXT_STATE = SETTING_OUTPUTS;
                end
            else
                begin
                    NEXT_STATE = IDLE;
                end 
            end
        //------------------------------------------
        SETTING_OUTPUTS:
            begin
            //cambiar Salidas
            blocks_DATA_Phy = blockCount_Regs_DATA;
            timeout_value_DATA_Phy = timeout_Reg_Regs_DATA;
            writeReadPhysical_DATA_Phy = writeRead_Regs_DATA;
            multiple_DATA_Phy = multipleData_Regs_DATA;
            
            //revisar serial_Ready_Phy_DATA para pasar a revisar el buffer
            if (serial_Ready_Phy_DATA)
                begin
                    NEXT_STATE = CHECK_FIFO;
                end
            else
                begin
                    NEXT_STATE = SETTING_OUTPUTS;
                end
            end
        //------------------------------------------
        CHECK_FIFO:
            begin
            //salidas se mantienen igual que el estado anterior
            blocks_DATA_Phy = blockCount_Regs_DATA;
            timeout_value_DATA_Phy = timeout_Reg_Regs_DATA;
            writeReadPhysical_DATA_Phy = writeRead_Regs_DATA;
            multiple_DATA_Phy = multipleData_Regs_DATA;

            // revisar fifo_OK_FIFO_DATA
            if (fifo_OK_FIFO_DATA)
                begin
                    NEXT_STATE = TRANSMIT;
                end
            else
                begin
                    NEXT_STATE = CHECK_FIFO;
                end
            end
        //------------------------------------------
        TRANSMIT:
            begin
            //afirma la señal strobe_OUT_DATA_Phy
            strobe_OUT_DATA_Phy = 1;
            // se espera a que termine la transmisión de la capa física, lo cual
            // se indica con la señal complete_Phy_DATA = 1
            if (complete_Phy_DATA)
                begin
                    NEXT_STATE = ACK;
                end
            else
                begin
                    NEXT_STATE = TRANSMIT;
                end
            end
        //-------------------------------------------
        ACK:
            begin
            //afirmar ack_OUT_DATA_Phy
            ack_OUT_DATA_Phy = 1;
            // si la capa física me confirma el acknowledge, continúo a IDLE
            if (ack_IN_Phy_DATA)
                begin
                    NEXT_STATE = IDLE;
                end
            else
                begin
                    NEXT_STATE = ACK;
                end
            end 
        default:
            begin
            NEXT_STATE = RESET;
            end 
    endcase
end //always
//-----------------------------------

endmodule // DATA