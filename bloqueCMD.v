//el siguiente módulo se encarga de la transferencia de comandos del sdHost a la sdCard y de la sdCard hacia el sdHost
module CMD (input clk_host, reset_host, new_command, IOin_SD, clk_SD, input [31:0]cmd_argument, input [5:0]cmd_index, output IOout_SD, CMD_COMPLETE);

endmodule // CMD

module cmd_control (clk_host, reset_host, new_command, cmd_argument, cmd_index, strobe_in, cmd_in, response, CMD_COMPLETE, strobe_out, idle_out, cmd_out);
    //señales provenientes del host
    input clk_host, reset_host;
    //señales provenientes de los registros
    input new_command;
    input [31:0]cmd_argument;
    input  [5:0]cmd_index;
    //señales provenientes de la capa fisica
    input strobe_in;
    input [135:0]cmd_in;
    //salidas hacia los registros
    output reg [127:0]response;
    output reg CMD_COMPLETE;
    //salidas hacia capa fisica
    output reg strobe_out;
    output reg idle_out;
    output reg [39:0]cmd_out;
    always @ ( * ) begin
        if (reset_host == 1) begin
            response = 0;
            CMD_COMPLETE = 0;
            strobe_out = 0;
            idle_out = 0;
            cmd_out = 0;
        end else begin
            if (new_command == 1) begin
                strobe_out = 1;
                
            end else begin

            end
        end
    end


endmodule // cmd_control
