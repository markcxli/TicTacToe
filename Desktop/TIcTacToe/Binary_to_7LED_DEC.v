`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:15:40 12/01/2015 
// Design Name: 
// Module Name:    Binary_to_7LED_DEC 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Binary_to_7LED_DEC(bin,sevenPlus);
input [3:0] bin;
output reg [7:0] sevenPlus;
reg [6:0] seven; //Assume MSB is A, and LSB is G	
initial	begin//Initial block, used for correct simulations	
	seven=0;
	sevenPlus=0;
end
always @ (*) begin
	case(bin)	
		0:	seven = 7'b0000001;
		1:	seven = 7'b1001111;
		2: seven = 7'b0010010;
		3: seven = 7'b0000110;
		4: seven = 7'b1001100;
		5: seven = 7'b0100100;
		6: seven = 7'b0100000;
		7: seven = 7'b0001111;
		8: seven = 7'b0000000;
		9: seven = 7'b0001100;
		14: seven = 7'b0001000;
		15: seven = 7'b1100000;
		//remember 0 means ‘‘light-up’’
		default: seven = 7'b1111111;//Something here	
	endcase
	sevenPlus = {seven,1'b1};
	end
endmodule
