`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:23:32 12/13/2015 
// Design Name: 
// Module Name:    TicTacToe 
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
module TicTacToe(
input rst,Score_rst,
input clk,
input up,down,left,right,enter,
input [2:0] R_control, G_control,
input [1:0] B_control,
output [2:0] R, G,
output [1:0] B,
output HS,VS,
output [7:0] sevenPlus,
output [3:0] AN
    );
wire [3:0] valueX;
wire [3:0] valueO;
vga_display VD(Score_rst, rst, clk, R, G, B, HS, VS, R_control, G_control, B_control, up, down, left, right, enter, valueX, valueO);
wire [15:0] big_bin;
assign big_bin = {4'b1110, valueX, 4'b1111, valueO};
Binary_to_4Displays B24D(big_bin,clk,sevenPlus,AN);

endmodule
