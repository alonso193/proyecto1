//-----------------------------------------------------
// PROYECTO 1  : SD HOST
// Archivo     : probadorPhysical.v
// Descripcion : generador de estimulos para el bloque de capa fisica de DATA
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------


module probador(
    output reg SD_CLK,
    output reg RESET_L,
    output reg strobe_IN_DATA_Phy,
    output reg ack_IN_DATA_Phy,
    output reg [15:0] timeout_Reg_DATA_Phy,
    output reg [3:0] blocks_DATA_Phy,
    output reg writeRead_DATA_Phy,
    output reg multiple_DATA_Phy,
    output reg idle_in_DATA_Phy,
    output reg transmission_complete_PS_Phy,
    output reg reception_complete_SP_Phy,
    output reg [31:0] data_read_SP_Phy,
    output reg [31:0] dataFromFIFO_FIFO_Phy

);

// Generar CLK
always
begin
    #10 SD_CLK= ! SD_CLK;
end
//Generar pruebas
 initial begin
		//dumps
		$dumpfile("PhysicalTest.vcd");
		$dumpvars(0,testbench);
                // Initialize Inputs
                
                SD_CLK                       = 0; 
                writeRead_DATA_Phy           = 1;
                strobe_IN_DATA_Phy           = 1;          
                ack_IN_DATA_Phy              = 0;
                timeout_Reg_DATA_Phy         = 16'd100;
                blocks_DATA_Phy              = 4'b1111;
                multiple_DATA_Phy            = 0;
                idle_in_DATA_Phy             = 0;
                transmission_complete_PS_Phy = 0;
                reception_complete_SP_Phy    = 0;
                data_read_SP_Phy             = 32'hCAFECAFE;
                dataFromFIFO_FIFO_Phy        = 32'hCAFECAFE;

                //pulso de RESET_L
                #50
                RESET_L = 1;
                #10
                RESET_L = 0;
                #30
                RESET_L = 1;
                //Aqui ya pasa a IDLE
                $display("Aqui ya pasa a IDLE");
                //pasamos a fifo read
 
                //pasamos al estado LOAD write
                $display("Aqui ya pasa a load write, luego a send y wait response");
                #100
                reception_complete_SP_Phy = 1;
                #30
                ack_IN_DATA_Phy = 1;
                $display("manda el ack y devuelta a IDLE");





                
                #200
                $display("-----FIN------");
		$finish(2);
        end
endmodule
