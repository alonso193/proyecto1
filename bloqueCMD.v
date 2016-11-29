//el siguiente módulo se encarga de la transferencia de comandos del sdHost a la sdCard y de la sdCard hacia el sdHost
module CMD (input clk_host, reset_host, new_command, IOin_SD, clk_SD, input [31:0]cmd_argument, input [5:0]cmd_index, output IOout_SD, CMD_COMPLETE, output [127:0]response);

endmodule // CMD

module senales_cmd_control (clk_host, reset_host, new_command, ack_in, cmd_argument, cmd_index, strobe_in, cmd_in, response, CMD_COMPLETE, strobe_out, idle_out, cmd_out);
    //señales provenientes del host
    output reg clk_host, reset_host;

    //señales provenientes de los registros
    output reg new_command;
    output reg ack_in;

    output reg [31:0]cmd_argument;
    output reg [5:0]cmd_index;

    //señales provenientes de la capa fisica
    output reg strobe_in;
    output reg [135:0]cmd_in;

    //salidas hacia los registros
    input  [127:0]response;
    input  CMD_COMPLETE;

    //salidas hacia capa fisica
    input  strobe_out;
    input  idle_out;
    input  [39:0]cmd_out;

    always begin
        #1 clk_host = ~clk_host;
    end

    initial begin
        $dumpfile("prueba_cmd_control.vcd");
        $dumpvars;
        clk_host = 0;
        reset_host = 1;
        new_command = 0;
        ack_in = 1;
        cmd_argument = 4294967295;
        cmd_index = 63;
        strobe_in = 0;
        cmd_in = 0;
        #5 reset_host = 0;
        #15 new_command = 1; ack_in = 1;
        #1 ack_in = 0;
        #10 cmd_argument = 1; cmd_index = 3;
        #40 strobe_in = 1; ack_in = 1;
        #40 $finish;
    end

endmodule // señales_cmd_control

module testbench_cmd_control ();
    wire clk_host, reset_host, new_command, ack_in, strobe_in, CMD_COMPLETE, strobe_out, idle_out;
    wire [31:0]cmd_argument;
    wire [5:0]cmd_index;
    wire [135:0]cmd_in;
    wire [127:0]response;
    wire [39:0]cmd_out;

    cmd_control c1(clk_host, reset_host, new_command, ack_in, ack_out, cmd_argument, cmd_index, strobe_in, cmd_in, response, CMD_COMPLETE, strobe_out, idle_out, cmd_out);
    senales_cmd_control s1(clk_host, reset_host, new_command, ack_in, cmd_argument, cmd_index, strobe_in, cmd_in, response, CMD_COMPLETE, strobe_out, idle_out, cmd_out);
endmodule // testbench_cmd_control

module cmd_control (clk_host, reset_host, new_command, ack_in, ack_out, cmd_argument, cmd_index, strobe_in, cmd_in, response, CMD_COMPLETE, strobe_out, idle_out, cmd_out);

    //señales provenientes del host
    input clk_host, reset_host;

    //señales provenientes de los registros
    input new_command;
    input ack_in;
    input [31:0]cmd_argument;
    input  [5:0]cmd_index;

    //señales provenientes de la capa fisica
    input strobe_in;
    input [135:0]cmd_in;

    //salidas hacia los registros
    output reg [127:0]response;
    output reg CMD_COMPLETE;

    //salidas hacia capa fisica
    output reg ack_out;
    output reg strobe_out;
    output reg idle_out;
    output reg [39:0]cmd_out;

    //estado de IDLE
    always @ ( * ) begin
        if (reset_host == 1) begin
            response <= 0;
            ack_out = 0;
            CMD_COMPLETE <= 0;
            strobe_out <= 0;
            idle_out <= 0;
            cmd_out <= 0;
        end else begin
            //si se requiere de un nuevo comando se pasa al estado de setting outputs
            //poniendo las salidas en sus valores correspondientes
            if (new_command == 1 && ack_in == 1) begin
                strobe_out <= 1;
                cmd_out[31:0] <= cmd_argument;
                cmd_out[37:32] <= cmd_index;
                cmd_out[38] <= 1;
                cmd_out[39] <= 0;
            if (strobe_in == 1) begin
                ack_out <= 1;
                CMD_COMPLETE <= 1;
            end else begin
                ack_out <= 0;
                CMD_COMPLETE = 0;
            end
            //para cuando se necesite procesar la respuesta el new command ya estará en bajo
            //por lo que se pasa al siguiente estado preguntado si la capa fisica termino su labor
            end else begin
                //se pregunta si se terminó para indicarselo a los registros
                if (strobe_in == 1) begin
                    ack_out <= 1;
                    CMD_COMPLETE <= 1;
                end else begin
                    ack_out <= 0;
                    CMD_COMPLETE = 0;
                end
            end
        end
    end
endmodule // cmd_control


module control_capa_fisica (strobe_in, idle_in, reset_host, pad_response, reception_complete, enable_stp, enable_pts, transmission_complete, load_send, reset_stp, reset_pts /*,PAD_enable*/, clk_SD, IOin_SD, IOout_SD);
    input strobe_in, idle_in, reset_host, reception_complete, clk_SD, IOin_SD, transmission_complete;
    input [135:0]pad_response;
    output reg enable_stp, load_send, enable_pts, reset_stp, reset_pts, IOout_SD;
    output reg [135:0]response;
    initial begin
        enable_stp <= 0;
        load_send <= 0;
        enable_pts <= 0;
        reset_stp <= 0;
        reset_pts <= 0;
        IOout_SD <= 0;
        response <= 0;
    end
    always @ ( * ) begin
        if (strobe_in == 1) begin

        end else begin
            reset_pts <= 1;
            reset_stp <= 1;
        end
    end
endmodule // control_capa_fisica

//modulo de PAD que se comunicará con la SD y con los serializadores y paralelizadores de la capa fisica del CMD
module cmd_PAD_card (input ENB_control, data_in_parallelToSerial_PAD, clk_SD, IOin_SD, output data_out_serialToParallel, IOout_SD);
    //lo que hace es traspasar del host al SD o viceversa
    flipflopD f1(ENB_control, clk_SD, data_in_parallelToSerial_PAD, IOout_SD);
    flipflopD f2(ENB_control, clk_SD, IOin_SD,data_out_serialToParallel);
endmodule // cmd_PAD_card

//flipflop de tipo D
module flipflopD (input ENB, clk, D, output Q);
    reg Q;
    always @ ( posedge clk ) begin
        if (ENB == 1) begin
            Q = D;
        end else begin
            Q = 1'bz;
        end
    end
endmodule // flipflopD

//flipflopD_neg
module flipflopD_neg (input ENB, clk, D, output Q);
    reg Q;
    always @ ( posedge clk ) begin
        if (ENB == 0) begin
            Q = D;
        end else begin
            Q = 1'bz;
        end
    end
endmodule // flipflopD

module serial_to_parallel ();

endmodule // serial_to_parallel
