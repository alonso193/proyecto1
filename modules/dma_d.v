`include "fetch.v"
`include "transfer.v"

module dma( input 	[63:0] starting_address,
			input 	reset,
			input 	stop,
			input 	clk,
			input 	[31:0] data_from_ram,
			input 	[31:0] data_from_fifo,
			input 	fifo_full,
			input 	fifo_empty,
			input 	command_reg_write,
			input	command_reg_continue,
			input 	direction, // 1 es de ram a fifo
			output 	[31:0]	data_to_ram,
			output 	[31:0]	data_to_fifo,
			output 	[63:0]	ram_address,
			output	ram_write,
			output 	ram_read,
			output 	fifo_write,
			output 	fifo_read,
			output 	start_transfer);

	wire [95:0] fetch_address_descriptor;
	reg	 [95:0]	address_descriptor;

	wire		reset;
	wire		clk;
	wire		stop;

	reg [5:0]	state;

	// Codificacion de estados

	parameter ST_STOP 		= 6'b000001;
	parameter ST_FDS_START 	= 6'b010000;
	parameter ST_FDS 		= 6'b000010;
	parameter ST_CACDR 		= 6'b000100;
	parameter ST_TFR_START  = 6'b100000;
	parameter ST_TFR 		= 6'b001000;

	wire [63:0] address;
	wire [15:0] length;
	wire 		ACT1;
	wire 		ACT2;
	wire 		INT;
	wire 		END;
	wire 		VALID;

	assign address = address_descriptor[95:32];
	assign length  = address_descriptor[31:16];
	assign ACT1    = address_descriptor[5];
	assign ACT2    = address_descriptor[4];
	assign INT 	   = address_descriptor[2];
	assign END 	   = address_descriptor[1];
	assign VALID   = address_descriptor[0];

	assign NOP  = (~ACT2) & (~ACT1);
	assign RSV  = (~ACT2) & (ACT1);
	assign TRAN = (ACT2) & (~ACT1);
	assign LINK = (ACT2) & (ACT1);

	// Read write flags

	reg		ram_read;
	reg 	ram_write;
	reg		fifo_read;
	reg 	fifo_write;
	wire 	ram_read_transfer;
	wire 	ram_write_transfer;
	wire 	fifo_read_transfer;
	wire 	fifo_write_transfer;

	// Internal variables

	wire 		TFC;
	reg  [5:0]	next_state;
	reg  [63:0]	ram_fetch_address;
	wire 		address_fetch_done;
	reg 		begin_fetch;
	reg  [63:0]	next_ram_address;
	reg			start_transfer;
	wire [63:0] ram_address_transfer;
	wire [63:0] ram_address_fetch;
	reg  [63:0]	ram_address;
	reg  [32:0]	counter; // counter for triggering signals
	wire		start_confirmation;
	reg 		zero = 0;

	// Parte secuencial

	always @(posedge clk) begin
		if(reset) begin
			state <= ST_STOP;
			ram_address = 0 ;
		end
		else begin
			state <= next_state;
		end
	end


	// Transiciones de estado

	always @(*) begin
		if(reset) begin
			state       = ST_STOP;
		end
		else begin
			case(state)
				ST_STOP:begin
					if(command_reg_write == 1 || command_reg_continue == 1) begin
						next_state = ST_FDS_START;
					end
					else begin
						next_state = ST_STOP;
					end
				end

				ST_FDS_START:begin
					next_state = ST_FDS;
				end

				ST_FDS:begin
					if(VALID == 0) begin
						next_state = ST_FDS;
					end
					else begin
						if(address_fetch_done == 1) begin
							next_state = ST_CACDR;
						end
						else begin
							next_state = ST_FDS;
						end
					end
				end

				ST_CACDR:begin
					if(TRAN == 1) begin
						next_state = ST_TFR_START;
					end
					else begin
						if(END == 1) begin
							next_state = ST_STOP;
						end
						else begin
							next_state = ST_FDS_START;
						end
					end
				end

				ST_TFR_START:begin
					next_state = ST_TFR;
				end

				ST_TFR:begin
					if(TFC == 0) begin
						next_state = ST_TFR;
					end
					else begin
						if(END == 1 || stop == 1) begin
							next_state = ST_STOP;
						end
						else begin
							next_state = ST_FDS_START;
						end
					end
				end

				default:begin
					next_state = ST_STOP;
				end
			endcase
		end
	end // always @(*)

	// Output Logic

	always @(*) begin
		case(state)
			ST_STOP:begin
				ram_read           = 0;
				ram_write          = 0;
				fifo_read 		   = 0;
				fifo_write         = 0;
				ram_fetch_address  = starting_address;
				begin_fetch        = 0;
				start_transfer 	   = 0;
				counter			   = 0;
				address_descriptor = 0;
				next_ram_address   = 0;
			end

			ST_FDS:begin
			begin_fetch 			= 0;
				start_transfer 		= 0;
				ram_write 			= 0;
				ram_read 			= 1; // habilitar lectura de ram
				fifo_read 			= 0;
				fifo_write 			= 0;
				ram_address 			= ram_address_fetch;
				address_descriptor  = fetch_address_descriptor;
			end

			ST_CACDR:begin
				begin_fetch 	= 0;
				start_transfer 	= 0;
				address_descriptor = address_descriptor;
				ram_address = next_ram_address;
				if(LINK == 1) begin
					next_ram_address = address; // read descriptor for new address
				end
				else begin
					next_ram_address = ram_address + 12; // address descriptor has 96 bits
				end
			end

			ST_TFR:begin
				start_transfer = 0;
				if(start_transfer == 1)begin
					zero = 1;
				end
				ram_read 				= ram_read_transfer;
				ram_write 				= ram_write_transfer;
				fifo_read 				= fifo_read_transfer;
				fifo_write			 	= fifo_write_transfer;
				address_descriptor 		= address_descriptor;
			end

			ST_FDS_START:begin
				begin_fetch        = 1;
				address_descriptor = fetch_address_descriptor;
				start_transfer     = 0;
				ram_write          = 0;
				ram_read           = 1; // habilitar lectura de ram
				fifo_read 		   = 0;
				fifo_write 		   = 0;
				ram_address		   = next_ram_address;
				ram_fetch_address  = next_ram_address;
			end

			ST_TFR_START:begin
				ram_read 			= ram_read_transfer;
				ram_write 			= ram_write_transfer;
				fifo_read 			= fifo_read_transfer;
				fifo_write 			= fifo_write_transfer;
				address_descriptor 	= address_descriptor;
				begin_fetch 		= 0;
				start_transfer 		= 1; // transfer the data
				ram_address 		= ram_address_transfer;
			end

			default:begin
				ram_read = 0;
				ram_write = 0;
				fifo_read = 0;
				fifo_write = 0;
				ram_fetch_address = starting_address;
				begin_fetch = 0;
				start_transfer = 0;
			end
		endcase
	end // always @(*)

	// Modulos fetch y transfer

	fetch fetch(.reset(reset),
				.clk(clk),
				.start((begin_fetch & clk)),
				.address(ram_fetch_address),
				.ram_data(data_from_ram),
				.address_descriptor(fetch_address_descriptor),
				.address_to_fetch(ram_address_fetch),
				.address_fetch_done(address_fetch_done),
				.start_confirmation(start_confirmation));

	transfer transfer(.reset(reset),
					  .clk(clk),
					  .start((start_transfer & clk)),
					  .direction(direction),
					  .fifo_empty(fifo_empty),
					  .fifo_full(fifo_full),
					  .address_init(address),
					  .length(length),
					  .data_from_ram(data_from_ram),
					  .data_from_fifo(data_from_fifo),
					  .ram_read(ram_read_transfer),
					  .ram_write(ram_write_transfer),
					  .fifo_read(fifo_read_transfer),
					  .fifo_write(fifo_write_transfer),
					  .data_to_ram(data_to_ram),
					  .data_to_fifo(data_to_fifo),
					  .ram_adress(ram_address_transfer)); 

endmodule // dma
