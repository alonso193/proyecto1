module fetch( 	input 			reset,
				input			clk,
				input 			start,
				input [63:0] 	address,
				input [31:0]	ram_data,
				output [95:0] 	address_descriptor,
				output [63:0]	address_to_fetch,
				output 			address_fetch_done,
				output 			start_confirmation);

// Codificacion de estados

parameter WAIT = 4'b001;
parameter FST_FETCH = 4'b0010;
parameter SND_FETCH = 4'b0100;
parameter TRD_FETCH = 4'b1000;

// Registros necesarios

reg [3:0] 	state;
reg [3:0]	next_state;
reg [95:0]	address_descriptor;
reg [63:0]	address_to_fetch;
reg			address_fetch_done;
reg			start_confirmation;

// Asignacion de vector de proximo estado

always @(posedge clk) begin
		if(reset) state <= WAIT;

		else state <= next_state;
end

// Logica de proximo estado

always @(*) begin
 case(state)
	WAIT: begin

				if(start == 1) begin
						next_state = FST_FETCH;
				end
				else begin
						next_state = next_state;
				end
	end

	FST_FETCH: begin
			next_state = SND_FETCH;
	end

	SND_FETCH: begin
			next_state = TRD_FETCH;
	end

	TRD_FETCH: begin
			next_state = WAIT;
	end

	default: begin
		next_state = WAIT;
	end
 endcase // end case(state)

end // end always @(*)

// Logica de estado presente

always @(*) begin

	case(state)
		WAIT: begin
			address_fetch_done = 1;
			address_to_fetch = address;
			address_descriptor = address_descriptor;
			start_confirmation = 0;
		end

		FST_FETCH: begin
			address_fetch_done = 0;
			address_to_fetch = address + 4;
			address_descriptor[31:0] = ram_data;
			start_confirmation = 0;
		end

		SND_FETCH: begin
			address_fetch_done = 0;
			address_to_fetch = address + 8;
			address_descriptor[63:32] = ram_data;
			start_confirmation = 1;

		end

		TRD_FETCH: begin
			address_fetch_done = 1;
			address_to_fetch = address;
			address_descriptor[95:64] = ram_data;
			start_confirmation = 0;

		end

		default: begin
			address_fetch_done = 1;
			address_to_fetch = address;
			address_descriptor = 0;
			start_confirmation = 0;

		end

	endcase // end logic for case(state)
end // end always @(*)

endmodule // end fetch
