//this is a top module 

module top(
	input MAX10_CLK1_50,
	input SCL,
	inout SDA,
	input FINISH,
	//input FIN,
	output[9:0] LEDR,
	output[7:0] SEG0,
	output[7:0] SEG1,
	output[7:0] SEG2,
	output[7:0] SEG3,
	output[7:0] SEG4,
	output[7:0] SEG5,
	
		//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N
	
	
);

	wire [7:0] DOUT_L, DOUT_L2, DOUT_L3, DOUT_H;
	wire [7:0] hex1, hex2, hex3;
	

//=======================================================
//  REG/WIRE declarations
//=======================================================
	//data to pass into SDRAM
	reg [127:0] data;
	reg     [4:0]   state           = 5'b00001;
	reg     [4:0]   next_state      = 5'b00010;

	wire   [21:0]   address         = 22'b1;
	wire            reset           = 1'b0;

	wire            write_command;
	reg             read_command;
	wire            write_finished;
	wire            read_finished;
	reg   [127:0]   write_data;
	wire  [127:0]   read_data;
	wire FIN;

	reg             write_request;
	reg             read_request;
	
//==================================================
	//assign write_data[7:0] = 8'h23;
	//assign write_data[127:8] = 120'b0;
//==================================================
	
	
	I2C_slave s(MAX10_CLK1_50, SCL, SDA, HIGHBYTE, DOUT_L, DOUT_L2, DOUT_L3, DOUT_H, FIN);
	display_output d(hex1, hex2, hex3, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5);
	
	
	assign LEDR[9] = ~FINISH;
	//assign the finish signal to the write command
	assign write_command = FIN;
	
	always@(*) begin
		if(FIN) begin
			write_data[7:0] = #1 DOUT_L;
			write_data[15:8] = #1 DOUT_L2;
			write_data[23:16] = #1 DOUT_L3;
			write_data[31:24] = #1 DOUT_H;
			write_data[127:32] = 96'b0;
		end
	end
	
	assign LEDR[7:0] = data[7:0];
	assign hex1 = data[15:8];
	assign hex2 = data[23:16];
	assign hex3 = data[31:24];
	
	//assign LEDR[7:0] = write_data[7:0];
	//assign hex1 = write_data[15:8];
	//assign hex2 = write_data[23:16];
	//assign hex3 = write_data[31:24];
	
	
	always @(posedge MAX10_CLK1_50)
begin
    state <= #1 next_state;
end

	//if write finished, active read request
	reg active = 0;
	integer count = 0;
	parameter countnum = 10;
	
	always @(posedge MAX10_CLK1_50) begin
		if(count < countnum) read_command <= 1'b1;
		else read_command <= 1'b0;
	end
	
	always @(posedge MAX10_CLK1_50) begin
		if(count < countnum) count = count + 1;
		else count = 0;
	end
	
	
	always @(state or write_command or read_command or write_finished or read_finished)
begin
    case(state)
        5'b00001:
            if(write_command)
                next_state  <= 5'b00010;
            else if(read_command)
                next_state  <= 5'b01000;
            else
                next_state  <= 5'b00001;
                
        5'b00010:
            if(write_finished)
                next_state  <= 5'b00100;
            else
                next_state  <= 5'b00010;
        5'b00100:
            next_state      <= 5'b00001;
            
        5'b01000:
            if(read_finished)
                next_state  <= 5'b10000;
            else
                next_state  <= 5'b01000;
        5'b10000:
            next_state      <= 5'b00001;
    endcase
end

always @(state)
begin
    case(state)
        5'b00001:
        begin
            write_request   <= #1 1'b0;
            read_request    <= #1 1'b0;
        end
        
        5'b00010:
        begin
            write_request   <= #1 1'b1;
            read_request    <= #1 1'b0;
        end
        5'b00100:
        begin
            write_request   <= #1 1'b0;
            read_request    <= #1 1'b0;
        end
        
        5'b01000:
        begin
            write_request   <= #1 1'b0;
            read_request    <= #1 1'b1;
        end
        5'b10000:
        begin
            write_request   <= #1 1'b0;
            read_request    <= #1 1'b0;
            data            <= #1 read_data;
        end
    endcase
end
	
	
	sdram_controller sdram_controller(
	.iclk(MAX10_CLK1_50),
    .ireset(reset),
    
    .iwrite_req(write_request),
    .iwrite_address(address),
    .iwrite_data(write_data),
    .owrite_ack(write_finished),
    
    .iread_req(read_request),
    .iread_address(address),
    .oread_data(read_data),
    .oread_ack(read_finished),
    
	//////////// SDRAM //////////
	.DRAM_ADDR(DRAM_ADDR),
    .DRAM_BA(DRAM_BA),
    .DRAM_CAS_N(DRAM_CAS_N),
    .DRAM_CKE(DRAM_CKE),
    .DRAM_CLK(DRAM_CLK),
    .DRAM_CS_N(DRAM_CS_N),
    .DRAM_DQ(DRAM_DQ),
    .DRAM_LDQM(DRAM_LDQM),
    .DRAM_RAS_N(DRAM_RAS_N),
    .DRAM_UDQM(DRAM_UDQM),
    .DRAM_WE_N(DRAM_WE_N)
);

endmodule
