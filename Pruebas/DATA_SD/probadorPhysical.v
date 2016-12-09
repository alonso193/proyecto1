//-----------------------------------------------------
// PROYECTO 1  : SD HOST
// Archivo     : probador.v
// Descripcion : generador de estimulos para el bloque de datos
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------


module probador(
    //señales para DATA_control
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
    //señales para DATA_PHYSICAL
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
                
                CLK = 0;            
                new_DAT_DMA_DATA              = 0;
                serial_Ready_Phy_DATA         = 0;
                blockCount_Regs_DATA          = 4'b1111;  //procesar 15 bloques
                timeout_Reg_Regs_DATA         = 16'd100;  //ciclos para timeout
                writeRead_Regs_DATA           = 1;        // Escritura (leer del FIFO para pasar a SD)
                multipleData_Regs_DATA        = 0;        //no es operacion multi trama
                fifo_OK_FIFO_DATA             = 0;        //FIFO en espera
                complete_Phy_DATA             = 0;
                ack_IN_Phy_DATA               = 0;

                //pulso de RESET_L
                #50
                RESET_L = 1;
                #10
                RESET_L = 0;
                #30
                RESET_L = 1;
                //Aqui ya pasa a IDLE
                $display("Aqui ya pasa a IDLE");
                //pasamos a setting outputs
                #50
                new_DAT_DMA_DATA = 1;
                $display("Aqui ya pasa a SETTING OUTPUTS");
                #100
                serial_Ready_Phy_DATA = 1;
                //pasamos a checkear el FIFO
                $display("Aqui ya pasa a Check FIFO");
                //nos quedamos 50 ciclos en Check FIFO
                #50
                fifo_OK_FIFO_DATA = 1;
                //pasamos al estado transmit
                $display("Aqui ya pasa a transmit");
                #50
                //esperamos 50 ciclo en transmit y pasamos a ACK
                complete_Phy_DATA = 1;

                //aqui terminamos la transmicion mandando un ACK out a capa física 
                //y esperando un ACK in
                #30
                ack_IN_Phy_DATA = 1;
                new_DAT_DMA_DATA = 0;
                $display("De vuelta a IDLE");

                
                #200
                $display("-----FIN------");
		$finish(2);
        end
endmodule
