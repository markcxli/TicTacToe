
//////////////////////////////////////////////////////////////////////////////////
module Binary_to_4Displays(big_bin,clk,sevenPlus,AN);
input clk;
input [15:0] big_bin;
output [7:0] sevenPlus;
output [3:0] AN;

wire [3:0] small_bin;
reg slow_clk;

	reg [15:0] slow_count;	
	initial begin
		slow_count = 0;
	end
	always @ (posedge clk)begin
		slow_count = slow_count + 1'b1;	
		slow_clk = slow_count[15];
	end	

seven_alternate sevenAlter(big_bin, small_bin, AN, slow_clk);
Binary_to_7LED_DEC B2D (small_bin,sevenPlus);
endmodule
