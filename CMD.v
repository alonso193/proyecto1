

module CMD (clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, CMD_PIN_OUT, CMD_PIN_IN, clk_SD);
    //entradas del CMD
    input wire clk_host, reset_host, new_command, CMD_PIN_IN, clk_SD;
    input wire [31:0]cmd_argument;
    input wire [5:0]cmd_index;
    //salidas del CMD
    output reg cmd_complete, cmd_index_error, CMD_PIN_OUT;
    //wires necesarios para conectar los sub-módulos
    //wire serial_ready, ack_in, strobe_in;
    //wire [135:0]cmd_in;
    //wire timeout;
    //wire [127:0]response;

    cmd_control cmd_control1();
    control_capa_fisica control_capa_fisica1();
    parallel_to_serial parallel_to_serial1();
    serial_to_parallel serial_to_parallel1();
endmodule // CMD


module cmd_control (clk_host,reset_host, new_command, cmd_argument, cmd_index, ack_in, strobe_in, cmd_in, response, cmd_complete, cmd_index_error, strobe_out, ack_out, idle_out, cmd_out);
    //declaración de entradas y salidas

    //provenientes del host
    input wire clk_host;
    input wire reset_host;
    input wire new_command;
    input wire [31:0]cmd_argument;
    input wire [5:0]cmd_index;

    //provenientes de la capa física
    input wire ack_in;
    input wire strobe_in;
    input wire [135:0]cmd_in;
    output reg [127:0]response;
    output reg cmd_complete;
    output reg cmd_index_error;
    output reg strobe_out;
    output reg ack_out;
    output reg idle_out;
    output reg [39:0]cmd_out;
    //asignación de los diferentes estados que tendrá la máquina de estados
    parameter RESET = 0;
    parameter IDLE = 1;
    parameter SETTING_OUTPUTS = 2;
    parameter PROCESSING = 3;
    reg [1:0]estado = 0;

    always @ ( * ) begin
        case (estado)
            RESET: begin
                response = 0;
                cmd_complete = 0;
                cmd_index_error = 0;
                strobe_out = 0;
                ack_out = 0;
                idle_out = 0;
                cmd_out = 0;
                estado = IDLE;
            end
            IDLE: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (new_command == 1) begin
                        estado = SETTING_OUTPUTS;
                    end else begin
                        idle_out = 1;
                        estado = IDLE;
                    end
                end
            end
            SETTING_OUTPUTS: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    strobe_out = 1;
                    cmd_out [39] = 0;
                    cmd_out [38] = 1;
                    cmd_out [37:32] = cmd_index;
                    cmd_out [31:0] = cmd_argument;
                    estado = PROCESSING;
                end
            end
            PROCESSING: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (strobe_in == 1) begin
                        cmd_complete = 1;
                        ack_out = 1;
                        if ((cmd_out[0] != 1) || (cmd_in[134] != 0)) begin
                            cmd_index_error = 1;
                        end else begin
                            cmd_index_error = 0;
                        end
                        response = cmd_in[135:8];
                        if (ack_in == 1) begin
                            estado = IDLE;
                        end else begin
                            estado = PROCESSING;
                        end
                    end else begin
                        estado = PROCESSING;
                    end
                end
            end
            default: begin
                estado = IDLE;
            end
        endcase
    end
endmodule // cmd_control

module control_capa_fisica (strobe_in, ack_in, idle_in, pad_response, reception_complete, transmission_complete, ack_out, strobe_out, response, cmd_timeout, load_send, enable_stp, enable_pts, reset_stp, reset_pts, reset_host, clk_SD);
    input wire strobe_in, ack_in, idle_in, reset_host, clk_SD;
    input wire [135:0]pad_response;
    input wire reception_complete, transmission_complete;
    output reg ack_out, strobe_out;
    output reg [135:0]response;
    output reg cmd_timeout, load_send, enable_stp, enable_pts, reset_stp, reset_pts;
    parameter RESET = 0;
    parameter IDLE = 1;
    parameter SEND_COMMAND = 2;
    parameter WAIT_RESPONSE = 3;
    parameter SEND_RESPONSE = 4;
    parameter WAIT_ACK = 5;
    parameter SEND_ACK = 6;
    reg [2:0] estado = 0;
    reg [5:0]cuenta_wait_response = 0;

    always @ ( * ) begin
        case (estado)
            RESET: begin
                ack_out = 0;
                strobe_out = 0;
                response = 0;
                cmd_timeout = 0;
                load_send = 0;
                enable_stp = 0;
                enable_pts = 0;
                reset_stp = 0;
                reset_pts = 0;
                estado = IDLE;
            end
            IDLE: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    reset_stp = 1;
                    reset_pts = 1;
                    if (strobe_in == 1) begin
                        estado = SEND_COMMAND;
                    end else begin
                        estado = IDLE;
                    end
                end
            end
            SEND_COMMAND: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (idle_in == 1) begin
                        estado = IDLE;
                    end else begin
                        enable_pts = 1;
                        load_send = 1;
                        if (transmission_complete == 1) begin
                            estado = WAIT_RESPONSE;
                        end else begin
                            estado = SEND_COMMAND;
                        end
                    end
                end
            end
            WAIT_RESPONSE: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (idle_in == 1) begin
                        estado = IDLE;
                    end else begin
                        if (cuenta_wait_response == 63) begin
                            estado = reset_host;
                        end else begin
                            enable_stp = 1;
                            load_send = 0;
                            if (reception_complete == 1) begin
                                estado = SEND_RESPONSE;
                            end else begin
                                estado = WAIT_RESPONSE;
                            end
                        end
                    end
                end
            end
            SEND_RESPONSE: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (idle_in == 1) begin
                        estado = IDLE;
                    end else begin
                        response = pad_response;
                        strobe_out = 1;
                        estado = WAIT_ACK;
                    end
                end
            end
            WAIT_ACK: begin
                if (reset_host == 1) begin
                    estado = RESET;
                end else begin
                    if (idle_in == 1) begin
                        estado = IDLE;
                    end else begin
                        if (ack_in == 1) begin
                            estado = SEND_ACK;
                        end else begin
                            ack_out = 0;
                            strobe_out = 0;
                            response = 0;
                            cmd_timeout = 0;
                            load_send = 0;
                            enable_stp = 0;
                            enable_pts = 0;
                            reset_stp = 0;
                            reset_pts = 0;
                            estado = WAIT_ACK;
                        end
                    end
                end
            end
            SEND_ACK: begin
                ack_out = 1;
                estado = IDLE;
            end
            default: begin
                estado = IDLE;
            end
        endcase
    end
endmodule // control_capa_fisica

module parallel_to_serial (enable_pts, reset_pts, clk_SD, signal_in, signal_out, parallel_complete);
    output reg signal_out, parallel_complete;
    input wire [39:0]signal_in;
    input wire clk_SD;
    input wire reset_pts, enable_pts;
    reg [8:0]contador = 0;
    always @ ( posedge clk_SD ) begin
        if (reset_pts == 1) begin
            signal_out <= 0;
            contador <= 0;
            parallel_complete <= 0;
        end else begin
            if (enable_pts == 1) begin
                if (contador == 40) begin
                    parallel_complete <= 1;
                    contador <= 0;
                end else begin
                    parallel_complete <= 0;
                    signal_out = signal_in[39 - contador];
                    contador <= contador + 1;
                end
            end else begin
                signal_out <= 0;
            end
        end
    end
endmodule // parallel_to_serial

module serial_to_parallel (command, signal_in, enable_stp, reset_stp, clk_SD, signal_out, serial_complete);
    input  wire [39:0]command;
    input wire signal_in, enable_stp, reset_stp, clk_SD;
    output reg [135:0]signal_out;
    output reg serial_complete;
    reg [8:0]contador = 0;
    reg responsonse_width = 0;
    always @ ( * ) begin
        if (command[37:32] == 12) begin
            responsonse_width = 136;
        end else begin
            responsonse_width = 40;
        end
    end
    always @ ( posedge clk_SD ) begin
        if (reset_stp) begin
            signal_out <= 0;
            contador <= 0;
            serial_complete <= 0;
        end else begin
            if (enable_stp == 1) begin
                if (contador == responsonse_width) begin
                    serial_complete <= 1;
                    contador <= 0;
                end else begin
                    serial_complete <= 0;
                    signal_out[(responsonse_width - 1) - contador] <= signal_in;
                    contador <= contador + 1;
                end
            end else begin
                signal_out <= 0;
            end
        end
    end
endmodule // serial_to_parallel
