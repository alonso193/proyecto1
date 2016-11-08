module cmd_PAD_card (input OutIn_control, ENB_control, data_in_parallelToSerial_PAD, clk_SD, IOin_SD, output data_out_serialToParallel, IOout_SD);
    //wire OutIn_control, ENB_control, data_in_parallelToSerial_PAD, clk_SD, IOin_SD;
    //reg data_out_serialToParallel, IOout_SD;
    FF_D flipflop1(clk_SD, data_in_parallelToSerial_PAD, outToBuffer);
    FF_D flipflop2(clk_SD, IOout_SD, data_out_serialToParallel);
    buffer_triestado buffer(outToBuffer, OutIn_control, IOout_SD);
endmodule // cmd_PAD_card

module control_PAD ();

endmodule // control_PAD

module FF_D (input clk, D, output Q);
    wire clk, D;
    reg Q;
    always @ ( posedge clk) begin
        Q = D;
    end
endmodule // FF_D

module buffer_triestado (input Dato, ENB, output out);
    wire Dato, ENB;
    reg out;
    always @ ( * ) begin
        if (ENB == 1) begin
            out = Dato;
        end else begin
            out = 1'bz;
        end
    end
endmodule // buffer_triestado
