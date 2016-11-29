module transfer(input 			reset,
				input 			clk,
				input 			start,
				input 			direction,
				input 			fifo_empty,
				input 			fifo_full,
				input [63:0] 	address_init,
				input [15:0] 	length,
				input [31:0]	data_from_ram,
				input [31:0]	data_from_fifo,
				output 			ram_read,
				output			ram_write,
				output 			fifo_read,
				output 			fifo_write,
				output [31:0]	data_to_ram,
				output [31:0] 	data_to_fifo,
				output [63:0]	ram_adress);

	wire clk;

	reg 	not_half_clk;
	reg 	half_clk;

	parameter IDLE 	     = 5'b00001;
	parameter FIFO_RAM   = 5'b00010;
	parameter RAM_FIFO   = 5'b00100;
	parameter WAIT_READ  = 5'b01000;
	parameter WAIT_WRITE = 5'b10000;


	reg        TFC;
	reg        ram_read;
	reg        ram_write;
	reg        fifo_read;
	reg        fifo_write;
	reg 	   data_to_ram;
	reg 	   data_to_fifo;
	reg [63:0] ram_adress;
	reg [4:0]  state;
	reg [4:0]  next_state;

	// Internal variables for sum

	wire [63:0] lenght_64;
	wire [63:0] sum_result;

	assign length_64 = length<<2;
	assign sum_result = address_init + length_64;

	// Logica secuencial

	always @(posedge clk) begin
			state <= next_state;
	end

	// Logica de proximo estado

	always @(*) begin

			case(state)
				IDLE: begin
					if(start == 1) begin
							if(direction == 0) begin
									next_state = FIFO_RAM;
							end

							else begin
									next_state = RAM_FIFO;
							end
					end
				end

				FIFO_RAM: begin
					if(TFC == 1) begin
							next_state = IDLE;
					end

					else begin
							if(fifo_empty == 1) begin
									next_state = WAIT_READ;
							end

							else begin
									next_state = FIFO_RAM;
							end
					end
				end

				RAM_FIFO: begin
					if(TFC == 1)begin
						next_state = IDLE;
					end

					else begin
						if(fifo_full == 1) begin
							next_state = WAIT_WRITE;
						end
						else begin
							next_state = RAM_FIFO;
						end
					end
				end

				WAIT_READ: begin
					if(fifo_empty == 1) begin
							next_state = WAIT_READ;
					end

					else begin
							next_state = FIFO_RAM;
					end
				end

				WAIT_WRITE: begin
					if(fifo_full == 1) begin
							next_state = WAIT_WRITE;
					end

					else begin
							next_state = RAM_FIFO;
					end
				end

				default: begin
					next_state = IDLE;
				end


			endcase // case(state)
	end // always (*)

	always @(*) begin

		not_half_clk = !half_clk;

		case(state)
			IDLE:begin
				ram_read     = 1;
				ram_write    = 0;
				fifo_read    = 0;
				fifo_write   = 0;
				data_to_ram  = 0;
				data_to_fifo = 0;
				ram_adress = address_init;
			end

			FIFO_RAM:begin
				ram_read     = 0;
				ram_write    = 1;
				fifo_read    = 1;
				fifo_write   = 0;
				data_to_fifo = 0;
				data_to_ram  = data_from_fifo;
				if(ram_adress == sum_result) begin
					TFC = 1;
				end
				else begin
					TFC = 0;
				end
				ram_adress = ram_adress + 4;
			end

			RAM_FIFO:begin
				ram_read   = 1;
				ram_write  = 0;
				fifo_read  = 0;
				fifo_write = 1;
				data_to_ram = 0;
				data_to_fifo = data_from_ram;
				if(ram_adress == sum_result) begin
					TFC = 1;
				end
				else begin
					TFC = 0;
				end
				ram_adress = ram_adress + 4;
			end

			WAIT_READ:begin
				ram_read     = 0;
				ram_write    = 0;
				fifo_read    = 0;
				fifo_write   = 0;
				data_to_fifo = 0;
				TFC          = 0;
				data_to_ram = data_to_ram;
				ram_adress = ram_adress;
			end

			WAIT_WRITE:begin
				ram_read    = 0;
				ram_write   = 0;
				fifo_read   = 0;
				fifo_write  = 0;
				TFC         = 0;
				data_to_ram = 0;
				data_to_fifo = data_to_fifo;
				ram_adress = ram_adress;

			end

			default:begin
				ram_read     = 0;
				ram_write    = 0;
				fifo_read    = 0;
				fifo_write   = 0;
				data_to_ram  = 0;
				data_to_fifo = 0;
				TFC          = 1; 
				ram_adress = address_init;
			end
		endcase // case(state)
	end // always(*)

	always @(posedge clk) begin
		if(state == IDLE) begin
				half_clk = start;
		end
		else begin
				half_clk = half_clk + 1;
		end
	end

endmodule // transfer
