
module arduino_to_LED (
	input MAX10_CLK1_50,
	input [3:0] P,
	output reg [9:0] LEDR
	);
	reg high;
	
	always @(posedge MAX10_CLK1_50) begin
		LEDR[3:0] <= P;
		LEDR[7:4] <= P;
	end


endmodule