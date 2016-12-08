//-----------------------------------------------------
// PROYECTO 1  : SD HOST
// Archivo     : probador.v
// Descripcion : generador de estimulos para el bloque de datos
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------


module probador # (parameter N = 32)
(

    output reg CLK,
    output reg RESET_L,
    output reg writeRead_Regs_DATA,
    output reg [3:0] blockCount_Regs_DATA,
    output reg multipleData_Regs_DATA,
    output reg timeout_Enable_Regs_DATA, 
    output reg [15:0] timeout_Reg_Regs_DATA, 
    output reg new_DAT_DMA_DATA,
    output reg serial_Ready_Phy_DATA, 
    output reg timeout_Phy_DATA, 
    output reg complete_Phy_DATA, 
    output reg ack_IN_Phy_DATA, 
    output reg fifo_OK_FIFO_DATA
);

// Generar CLK
always
begin
    #5 CLK= ! CLK;
end
//Generar pruebas
 initial begin
		//dumps
		$dumpfile("testDATA.vcd");
		$dumpvars(0,testbench);
                // Initialize Inputs
                oCLK = 0;            //definir CLK y pulso de RESET_L


                #50
                RESET_L = 1;
                #20
                RESET_L = 0;
                #30
                RESET_L = 1;
               
                $display("-----FIN------");
		$finish(2);
        end
endmodule
