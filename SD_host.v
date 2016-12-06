`include "REG.v"
`include "CMD.v"

module SD_host (clk_host, reset_host, io_enable_cmd, CMD_PIN_IN, CMD_PIN_OUT, clk_SD, data_in_register, data_out_register, req_register, ack_register, addres_register, rw_register);
    //señales del host
    input wire clk_host, reset_host;

    //señales del CMD
    input wire CMD_PIN_IN;
    output io_enable_cmd, CMD_PIN_OUT;

    //señales del register
    input wire [31:0]data_in_register;
    output [31:0]data_out_register;
    input wire req_register;
    input wire ack_register;
    input wire [4:0]addres_register;
    input wire rw_register;

    //señales compartidas del SD
    input clk_SD;

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


    CMD bloque_CMD(lk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
    REG bloque_registers(clk_host, rw_register, addres_register, data_in_register, data_out_register);

endmodule // SD_host
