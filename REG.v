module REG(clk, rw, addr, data_in, data_out);
  
  parameter data_witdh = 32;
  parameter addr_witdh = 5;
  parameter reg_witdh = 29;
   
   input clk;
   wire  clk;
   
   input rw;
   wire  rw;
   
   input req;
   wire  req;
   
   output ack;
   reg 	  ack;
   
   input [addr_witdh-1: 0] addr;
   wire 		   addr;
   
   input [data_witdh-1: 0] data_in;
   wire 		   data_in;
   
   output [data_witdh-1: 0] data_out;
   reg 			    data_out;

   /*input cmd_complete;
    input cmd_index_error;
    always @(cmd_complete) begin
    
    */
   
   
   //0
   output [15: 0] 	    SDMA_System_Address_Low;
   wire [15: 0] 	    SDMA_System_Address_Low;
   output [15: 0] 	    SDMA_System_Address_High;
   wire [15: 0] 	    SDMA_System_Address_High;
   
   //1
   output [15: 0] 	    Block_Size;
   wire [15: 0] 	    Block_Size;
   output [15: 0] 	    Block_Count;
   wire [15: 0] 	    Block_Count;
   
   //2
   output [15: 0] 	    Argument0;
   wire [15: 0] 	    Argument0;
   output [15: 0] 	    Argument1;
   wire [15: 0] 	    Argument1;
   
   output [31:0] 	    Argument; 		    
   wire [31:0] 		    Argument;
   assign        	    Argument[15:0] = Argument0;
   assign 		    Argument[31:16] = Argument1;
   
   //3
   output [15: 0] 	    Transfer_Mode;
   wire [15: 0] 	    Transfer_Mode;
   output [15: 0] 	    Command;
   wire [15: 0] 	    Command;
   wire [5:0] 		    cmd_index; //CMD
   assign cmd_index[5:0] = Command[13:8];
   
   //4-5-6-7
   output [15: 0] 	    Response0; //read only
   output [15: 0] 	    Response1;
   output [15: 0] 	    Response2; 
   output [15: 0] 	    Response3;
   output [15: 0] 	    Response4;
   output [15: 0] 	    Response5;
   output [15: 0] 	    Response6;
   output [15: 0] 	    Response7;
   wire [15: 0] 	    Response0; 
   wire [15: 0] 	    Response1;
   wire [15: 0] 	    Response2; 
   wire [15: 0] 	    Response3;
   wire [15: 0] 	    Response4;
   wire [15: 0] 	    Response5;
   wire [15: 0] 	    Response6;
   wire [15: 0] 	    Response7;
   
   //8
   output [15: 0] 	    Buffer_Data_Port0;
   wire [15: 0] 	    Buffer_Data_Port0;
   output [15: 0] 	    Buffer_Data_Port1;
   wire [15: 0] 	    Buffer_Data_Port1;
   
   //9
   output [15: 0] 	    Present_State1; // read only
   wire [15: 0] 	    Present_State1;
   output [15: 0] 	    Present_State2; 
   wire [15: 0] 	    Present_State2;
   
   //10
   output [7: 0] 	    Host_Control;
   output [7: 0] 	    Power_Control;
   wire [7: 0] 		    Host_Control;
   wire [7: 0] 		    Power_Control;
   output [7: 0] 	    Block_Gap_Control;
   output [7: 0] 	    Wakeup_Control;
   wire [7: 0] 		    Block_Gap_Control;
   wire [7: 0] 		    Wakeup_Control;
   
   //11
   output [15: 0] 	    Clock_Control;
   wire [15: 0] 	    Clock_Control;
   output [7: 0] 	    Timeout_Control;
   output [7: 0] 	    Software_Reset;
   wire [7: 0] 		    Timeout_Control;
   wire [7: 0] 		    Software_Reset;
   
   //12
   output [15: 0] 	    Normal_Interrupt_Status;
   wire [15: 0] 	    Normal_Interrupt_Status;
   output [15: 0] 	    Error_Interrupt_Status;
   wire [15: 0] 	    Error_Interrupt_Status;
   
   //13
   output [15: 0] 	    Normal_Interrupt_Status_Enable;
   wire [15: 0] 	    Normal_Interrupt_Status_Enable;
   output [15: 0] 	    Error_Interrupt_Status_Enable;
   wire [15: 0] 	    Error_Interrupt_Status_Enable;
   
   //14
   output [15: 0] 	    Normal_Interrupt_Signal_Enable;
   wire [15: 0] 	    Normal_Interrupt_Signal_Enable;
   output [15: 0] 	    Error_Interrupt_Signal_Enable;
   wire [15: 0] 	    Error_Interrupt_Signal_Enable;
   
   //15
   output [15: 0] 	    Auto_CMD12_Error_Status;
   wire [15: 0] 	    Auto_CMD12_Error_Status;
   //--
   
   //16
   output [15: 0] 	    Capabilities1; //*
   wire [15: 0] 	    Capabilities1; //*
   output [15: 0] 	    Capabilities2; //*
   wire [15: 0] 	    Capabilities2; //*
   
   //17
   output [15: 0] 	    Capabilities_Reserved_1; //*
   wire [15: 0] 	    Capabilities_Reserved_1; //*
   output [15: 0] 	    Capabilities_Reserved_2; //*
   wire [15: 0] 	    Capabilities_Reserved_2; //*
   
   //18
   output [15: 0] 	    Maximum_Current_Capabilities1; //*
   wire [15: 0] 	    Maximum_Current_Capabilities1; //*
   output [15: 0] 	    Maximum_Current_Capabilities2; //*
   wire [15: 0] 	    Maximum_Current_Capabilities2; //*
   
   //19
   output [15: 0] 	    Maximum_Current_Capabilities_Reserved_1; //*
   output [15: 0] 	    Maximum_Current_Capabilities_Reserved_2; //*
   wire [15: 0] 	    Maximum_Current_Capabilities_Reserved_1; //*
   wire [15: 0] 	    Maximum_Current_Capabilities_Reserved_2; //*
   
   //20
   output [15: 0] 	    Force_Event_for_Auto_CMD12_Error_Status;
   output [15: 0] 	    Force_Event_for_Error_Interrupt_Status;
   wire [15: 0] 	    Force_Event_for_Auto_CMD12_Error_Status;
   wire [15: 0] 	    Force_Event_for_Error_Interrupt_Status;
   
   //21
   output [7: 0] 	    ADMA_Error_Status;//*
   wire [7: 0] 		    ADMA_Error_Status;//*
   
   //22-23
   output [15: 0] 	    ADMA_System_Address_15;
   output [15: 0] 	    ADMA_System_Address_31;
   output [15: 0] 	    ADMA_System_Address_47;
   output [15: 0] 	    ADMA_System_Address_63;
   wire [15: 0] 	    ADMA_System_Address_15;
   wire [15: 0] 	    ADMA_System_Address_31;
   wire [15: 0] 	    ADMA_System_Address_47;
   wire [15: 0] 	    ADMA_System_Address_63;
   
   //27
   output [15: 0] 	    Host_Controller_Version;
   output [15: 0] 	    Slot_Interrupt_Status;
   wire [15: 0] 	    Host_Controller_Version;
   wire [15: 0] 	    Slot_Interrupt_Status;

   //24
   output [15:0] 	    Timeout_Reg; 	    
   wire [15:0] 		    Timeout_Reg;
   
   output [15:0] 	    data;
   wire 		    writeRead;
   wire 		    multipleData;
   wire 		    timeout_enable;   
   
   
   reg [data_witdh-1: 0]    regs [0: reg_witdh-1];
   
   assign SDMA_System_Address_Low[15:0] = regs[5'b00000][15:0];
   assign SDMA_System_Address_High[15:0] = regs[5'b00000][31:16];
   
   assign Block_Size[15:0] = regs[5'b00001][15:0];
   assign Block_Count[15:0] = regs[5'b00001][31:16];
   wire [3:0] 		    blockCount; //DATA
   assign blockCount = Block_Count[3:0];
   
   assign Argument0[15:0] = regs[ 5'b00010][15: 0];
   assign Argument1[15:0] = regs[ 5'b00010][31: 16];
   
   assign Transfer_Mode[15:0] = regs[5'b00011];
   assign Command[15:0] = regs[5'b00011][31: 16];
   
   assign Response0[15:0] = regs[5'b00100][15:0];
   assign Response1[15:0] = regs[5'b00100][31: 16];
   
   assign Response2[15:0] = regs[5'b00101][15:0];
   assign Response3[15:0] = regs[5'b00101][31: 16];
   
   assign Response4[15:0] = regs[5'b00110][15:0];
   assign Response5[15:0] = regs[5'b00110][31: 16];
   
   assign Response6[15:0] = regs[5'b00111][15:0];
   assign Response7[15:0] = regs[5'b00111][31: 16];
   
   assign Buffer_Data_Port0[15:0] = regs[5'b01000][15:0];
   assign Buffer_Data_Port1[15:0] = regs[5'b01000][31: 16];
   
   assign Present_State1[15:0] = regs[5'b01001][15:0];
   assign Present_State2[15:0] = regs[5'b01001][31: 16];
   
   assign Host_Control[7:0] = regs[5'b01010][7:0];
   assign Power_Control[7:0] = regs[5'b01010][15:8];
   assign Block_Gap_Control[7:0] = regs[5'b01010][23:16];
   assign Wakeup_Control[7:0] = regs[5'b01010][31:24];
   
   assign Clock_Control[15:0] = regs[5'b01011][15:0];
   assign Timeout_Control[7:0] = regs[5'b01011][23:16];
   assign Software_Reset[7:0] = regs[5'b01011][31:24];
   
   assign Normal_Interrupt_Status[15:0] = regs[5'b01100][15:0];
   assign Error_Interrupt_Status[15:0] = regs[5'b01100][31: 16];
   
   assign Normal_Interrupt_Status_Enable[15:0] = regs[5'b01101][15:0];
   assign Error_Interrupt_Status_Enable[15:0] = regs[5'b01101][31: 16];
   
   assign Normal_Interrupt_Signal_Enable[15:0] = regs[5'b01110][15:0];
   assign Error_Interrupt_Signal_Enable[15:0] = regs[5'b01110][31: 16];
   
   assign Auto_CMD12_Error_Status[15:0] = regs[5'b01111][15:0];
   //assign 0 = [31: 16] regs[addr];
   
   assign Capabilities1[15:0] = regs[5'b10000][15:0];
   assign Capabilities2[15:0] = regs[5'b10000][31: 16];
   
   assign Capabilities_Reserved_1[15:0] = regs[5'b10001][15:0];
   assign Capabilities_Reserved_2[15:0] = regs[5'b10001][31: 16];
   
   assign Maximum_Current_Capabilities1[15:0] = regs[5'b10010][15:0];
   assign Maximum_Current_Capabilities2[15:0] = regs[5'b10010][31: 16];
   
   assign Maximum_Current_Capabilities_Reserved_1[15:0] = regs[5'b10011][15:0];
   assign Maximum_Current_Capabilities_Reserved_2[15:0] = regs[5'b10011][31: 16];
   
   assign Force_Event_for_Auto_CMD12_Error_Status[15:0] = regs[5'b10100][15:0];
   assign Force_Event_for_Error_Interrupt_Status[15:0] = regs[5'b10100][31: 16];
   
   assign ADMA_Error_Status[7:0] = regs[5'b10101][7:0];
   
   
   assign ADMA_System_Address_15[15:0] = regs[5'b10110][15:0];
   assign ADMA_System_Address_31[15:0] = regs[5'b10110][31: 16];
   
   assign ADMA_System_Address_47[15:0] = regs[5'b10111][15:0];
   assign ADMA_System_Address_63[15:0] = regs[5'b10111][31: 16];
   
   assign Slot_Interrupt_Status[15: 0] = regs[5'b10011][15: 0];
   assign Host_Controller_Version[15: 0] = regs[5'b10011][31: 16];

   assign Timeout_Reg[15: 0] = regs[5'b11000][15: 0];
   assign data[15: 0] = regs[5'b11000][31: 16];

  
  // assign timeout_Reg[14:0] = Timeout[14:0]; //DATA
   assign timeout_enable = data[0];
   assign writeRead = data[1];
   assign multipleData = data[2];

   
   
   
   // Lectura y escritura desde CPU (se estan leyendo y escribiendo 32)
   always @(posedge clk) begin
      if(req == 1) begin      
	 if (rw == 1) begin //lectura
	    data_out <= regs[addr];
	    ack <= 1;
	 end
	 else begin
	    regs[addr] <= data_in;
	    ack <= 1;
	 end
      end
      else begin
	 data_out <= data_out;
	 ack <= 0;
      end
   end 
   
endmodule 

