//modulo de PAD que se comunicará con la SD y con los serializadores y paralelizadores de la capa fisica del CMD
module cmd_PAD_card (input ENB_control, data_in_parallelToSerial_PAD, clk_SD, IOin_SD, output data_out_serialToParallel, IOout_SD);
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
