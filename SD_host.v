`include "REG.v"
`include "CMD.v"
`include "BloqueDATA.v"
`include "modules/DMA.v"


module SD_host (clk_host,
				reset_host,
				io_enable_cmd,
				CMD_PIN_IN,
				CMD_PIN_OUT,
				clk_SD,
				data_in_register,
				data_out_register,
				req_register,
				ack_register,
				addres_register,
				rw_register,
				DATA_PIN_IN,
				DATA_PIN_OUT,
				IO_enable_Phy_SD_CARD,
				pad_enable_Phy_PAD,
				pad_state_Phy_PAD,
				cmd_reg_write,
				cmd_reg_read,
				Continue,
				descriptor_table,
				TRAN,
				STOP);

    //señales del host

    input wire clk_host, reset_host;
    input wire DATA_PIN_IN;
    output wire DATA_PIN_OUT;
    output wire IO_enable_Phy_SD_CARD;

    //outputs para el estado del PAD
    output wire pad_enable_Phy_PAD;
    output wire pad_state_Phy_PAD;

    //señales del CMD

    input wire CMD_PIN_IN;
    output wire io_enable_cmd, CMD_PIN_OUT;

    //señales del register

    input wire [31:0]data_in_register;
    output wire [31:0] data_out_register;
    input wire req_register;
    input wire ack_register;
    input wire [4:0]addres_register;
    input wire rw_register;

	// señales de DMA
	input wire cmd_reg_write;
	input wire cmd_reg_read;
	input wire Continue;
	input wire [6:0][85:0] descriptor_table;
	input wire TRAN;
	input wire STOP;

    //señales compartidas del SD

    input wire clk_SD;

    //cables de conexion entre DMA y CMD

    wire new_command;

    //cables de conexion entre REG y CMD
    wire [31:0]cmd_argument;
    wire [5:0]cmd_index;
    wire [127:0]response;
    wire cmd_complete, cmd_index_error;
    assign cmd_argument = bloque_registers.Argument;
    assign cmd_index = bloque_registers.cmd_index;
    assign bloque_registers.cmd_complete = cmd_complete;
    assign bloque_registers.cmd_index_error = cmd_index_error;

    //wires entre REGS y DATA
    wire [15:0] timeout_Reg_Regs_DATA;
    wire writeRead_Regs_DATA;
    wire [3:0] blockCount_Regs_DATA;
    wire multipleData_Regs_DATA;
    wire timeout_enable_Regs_DATA;

	//wires entre DMA y DATA
	wire   transfer_complete_DATA_DMA;

    assign timeout_Reg_Regs_DATA = bloque_registers.Timeout_Reg;
    assign writeRead_Regs_DATA = bloque_registers.writeRead;
    assign blockCount_Regs_DATA = bloque_registers.block_count;
    assign multipleData_Regs_DATA = bloque_registers.multipleData;
    assign timeout_enable_Regs_DATA = bloque_registers.timeout_enable;

    // wire entre DMA y FIFO

	wire FIFO_EMPTY_DMA;
	wire FIFO_FULL_DMA;
	wire [63:0] system_address;
	wire writing_mem; // 1 if dir = 0 and TFC = 0
	wire reading_mem; //
	wire reading_fifo;
	wire writing_fifo;
	wire [5:0] next_descriptor_index;
	reg [5:0] descriptor_index;

	always @(posedge clk_host) begin
		descriptor_index <= next_descriptor_index;
	end



	DMA bloqueDMA(reset,
				  clk_host,
				  transfer_complete_DATA_DMA,
				  cmd_reg_write,
				  cmd_reg_read,
				  Continue,
				  TRAN,
				  STOP,
				  FIFO_EMPTY_DMA,
				  FIFO_FULL_DMA,
				  descriptor_table [0][85:22], // data_address
				  descriptor_table [0][20:5], // length
				  descriptor_index,
				  descriptor_table [0][4], //act1
				  descriptor_table [0][3], //act2
				  descriptor_table [0][2], // END
				  descriptor_table [0][1], // valid
				  descriptor_table [0][0], // dir
				  new_command, // To CMD block
				  system_address,
				  writing_mem, // 1 if dir = 0 and TFC = 0
	              reading_mem, //
	              reading_fifo,
	              writing_fifo,
	   		      next_descriptor_index);




    CMD bloque_CMD(clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
    REG bloque_registers(clk_host, rw_register, addres_register, data_in_register, data_out_register);

    //Bloque de DATA
    BloqueDATA Data_Control(
    .CLK(clk_host),
    .SD_CLK(clk_SD),
    .RESET_L(reset_host),
    .timeout_Reg_Regs_DATA(timeout_Reg_Regs_DATA),
    .writeRead_Regs_DATA(writeRead_Regs_DATA),
    .blockCount_Regs_DATA(blockCount_Regs_DATA),
    .multipleData_Regs_DATA(multipleData_Regs_DATA),
    .timeout_enable_Regs_DATA(timeout_enable_Regs_DATA),
    //.FIFO_OK_FIFO_DATA(),
    //.[31:0] dataFromFIFO_FIFO_Phy(),
    //.New_DAT_DMA_DATA(),
    //.DATA_PIN_IN(DATA_PIN_IN),
    //.writeFIFO_enable_Phy_FIFO(),
    //.readFIFO_enable_Phy_FIFO(),
    //.[31:0] dataReadToFIFO_Phy_FIFO(),
    .transfer_complete_DATA_DMA(transfer_complete_DATA_DMA),
    .IO_enable_Phy_SD_CARD(IO_enable_Phy_SD_CARD),
    .DATA_PIN_OUT(DATA_PIN_OUT),
    .pad_state_Phy_PAD(pad_state_Phy_PAD),
    .pad_enable_Phy_PAD(pad_enable_Phy_PAD)
    );

endmodule // SD_host
