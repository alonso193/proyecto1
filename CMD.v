module probador ();
        wire [31:0]cmd_argument;
        wire [5:0]cmd_index;
        wire [127:0]response;
        CMD cmd1(clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
        testbench t1(clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
endmodule // probador

module testbench (clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
    output reg clk_host, reset_host, new_command;
    output reg [31:0]cmd_argument;
    output reg [5:0]cmd_index;
    input cmd_complete, cmd_index_error;
    input [127:0]response;
    input CMD_PIN_OUT, IO_enable_pin;
    output reg CMD_PIN_IN;
    output reg clk_SD;

    always begin
        #1 clk_host = ~clk_host;
    end
    always begin
        #5 clk_SD = ~clk_SD;
    end

    initial begin
        $dumpfile("prueba.vcd");
        $dumpvars;
        clk_host = 1;
        clk_SD = 1;
        new_command = 0;
        cmd_argument = 44;
        cmd_index = 15;
        #5 new_command = 1;
        #50 $finish;
    end
endmodule // testbench

module CMD (clk_host, reset_host, new_command, cmd_argument, cmd_index, cmd_complete, cmd_index_error, response, CMD_PIN_OUT, IO_enable_pin, CMD_PIN_IN, clk_SD);
    //entradas del CMD
    input wire clk_host, reset_host, new_command, CMD_PIN_IN, clk_SD;
    input wire [31:0]cmd_argument;
    input wire [5:0]cmd_index;
    //salidas del CMD
    output cmd_complete, cmd_index_error, CMD_PIN_OUT, IO_enable_pin;
    output [127:0]response;
    //wires necesarios para conectar los sub-módulos
    wire ack_physic_to_control;
    wire ack_control_to_physical;
    wire strobe_physic_to_control;
    wire strobe_control_to_physical;
    wire idle_control_to_physical;
    wire [39:0]cmd_out_control_to_pts;
    wire [135:0]response_to_cmd_in;
    wire [135:0]pad_response;
    wire end_serializer;
    wire end_parallel;
    wire physic_enable_stp, physic_enable_pts, physic_reset_stp, physic_reset_pts;

    cmd_control cmd_control1(clk_host, reset_host, new_command, cmd_argument, cmd_index, ack_physic_to_control, strobe_physic_to_control, response_to_cmd_in, response, cmd_complete, cmd_index_error, strobe_control_to_physical, ack_control_to_physical, idle_control_to_physical, cmd_out_control_to_pts);
    control_capa_fisica control_capa_fisica1(strobe_control_to_physical, ack_control_to_physical, idle_control_to_physical, pad_response, end_serializer, end_parallel, ack_physic_to_control, strobe_physic_to_control, response_to_cmd_in, IO_enable_pin, physic_enable_stp, physic_enable_pts, physic_reset_stp, physic_reset_pts, reset_host, clk_SD);
    parallel_to_serial parallel_to_serial1(physic_enable_pts, physic_reset_pts, clk_SD, cmd_out_control_to_pts, CMD_PIN_OUT, end_parallel);
    serial_to_parallel serial_to_parallel1(cmd_out_control_to_pts, CMD_PIN_IN, physic_enable_stp, physic_reset_stp, clk_SD, pad_response, end_serializer);
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

module control_capa_fisica (strobe_in, ack_in, idle_in, pad_response, reception_complete, transmission_complete, ack_out, strobe_out, response, load_send, enable_stp, enable_pts, reset_stp, reset_pts, reset_host, clk_SD);
    input wire strobe_in, ack_in, idle_in, reset_host, clk_SD;
    input wire [135:0]pad_response;
    input wire reception_complete, transmission_complete;
    output reg ack_out, strobe_out;
    output reg [135:0]response;
    output reg load_send, enable_stp, enable_pts, reset_stp, reset_pts;
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
