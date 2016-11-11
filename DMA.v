
module DMA(

clock      , // clock
reset      , // Active high, syn reset
req_0      , // Request 0
req_1      , // Request 1
gnt_0      , // Grant 0
gnt_1
);
 input   clock,reset,req_0,req_1;
 output  gnt_0,gnt_1;
 wire    clock,reset,req_0,req_1;
 reg     gnt_0,gnt_1;
 parameter SIZE = 3           ;
 parameter IDLE  = 3'b001,GNT0 = 3'b010,GNT1 = 3'b100 ;
 reg   [SIZE-1:0]          state        ;// Seq part of the FSM
 wire  [SIZE-1:0]          next_state   ;// combo part of FSM




    assign next_state = fsm_function(state, req_0, req_1);


    function [SIZE-1:0] fsm_function;
    
    input  [SIZE-1:0]  state ;
    input    req_0 ;
    input    req_1 ;



    case(state)
     IDLE : if (req_0 == 1'b1) begin
                  fsm_function = GNT0;
                end else if (req_1 == 1'b1) begin
                  fsm_function= GNT1;
                end else begin
                  fsm_function = IDLE;
                end
     GNT0 : if (req_0 == 1'b1) begin
                  fsm_function = GNT0;
                end else begin
                  fsm_function = IDLE;
                end
     GNT1 : if (req_1 == 1'b1) begin
                  fsm_function = GNT1;
            end else begin
                  fsm_function = IDLE;
                end
     default : fsm_function = IDLE;
    endcase
 endfunction





endmodule
