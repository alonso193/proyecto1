
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
 parameter SIZE = 3
         ;
 parameter ST_STOP  = 2'b00,ST_FDS = 2'b01,ST_CADR = 2'b10, ST_TFR = 2'b11;

 reg   [SIZE-1:0]          state        ;// Seq part of the FSM
 wire  [SIZE-1:0]          next_state   ;// combo part of FSM




    assign next_state = fsm_function(state, req_0, req_1);


    function [SIZE-1:0] fsm_function;

    input  [SIZE-1:0]  state ;
    input    req_0 ;
    input    req_1 ;



    case(state)
     ST_STOP : if (req_0 == 1'b1) begin  /* ADMA2 stays in this state in following cases:
                                         (1) After Power on reset or software reset.
                                         (2) All descriptor data transfers are completed
                                         If a new ADMA2 operation is started by writing Command register, go to
                                         ST_FDS state. */
                  fsm_function = ST_STOP;
                end else if (req_1 == 1'b1) begin
                  fsm_function= ST_FDS;
                end else begin
                  fsm_function = ST_CADR;
                end
     ST_FDS : if (req_0 == 1'b1) begin /* ADMA2 fetches a descriptor line and set parameters in internal registers.
                                          Next go to ST_CADR state.*/
                  fsm_function = ST_TFR;
                end else begin
                  fsm_function = ST_STOP;
                end
     ST_CADR : if (req_1 == 1'b1) begin  /* Link operation loads another Descriptor address to ADMA System Address
                                            register. In other operations, ADMA System Address register is
                                            incremented to point next descriptor line. If End=0, go to ST_TFR state.
                                            ADMA2 shall not be stopped at this state even if some errors occur.  */
                  fsm_function = ST_CADR;
            end else begin
                  fsm_function = ST_TFR;
                end
    ST_TFR : if(req_0 == 1'b1) begin   /* Data transfer of one descriptor line is executed between system memory
                                          and SD card. If data transfer continues (End=0) go to ST_FDS state. If data
                                          transfer completes, go to ST_STOP state. */
                fsm_function = ST_STOP;
                end else begin
                  fsm_function = ST_TFR;
                end
    //  default : fsm_function = IDLE;
    endcase
 endfunction





endmodule
