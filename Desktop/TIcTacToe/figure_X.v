`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    17:17:19 04/14/2013 
// Design Name: 	VGA sprites controller
// Module Name:    vga_bsprite 
// Project Name:  vga_display
// Target Devices: xc6slx16
// Tool versions: ISE 13.3
// Description: This project calls memory sprites to show on the screen
//
// Dependencies: game_over_mem, vga_controller
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_bsprite_X(x, y, hc, vc, blank, fig_x);
	input [10:0] x, y;	// Coordinates of where the image will be placed
	input [10:0] hc, vc;	// Coordinates of the current pixel
	input blank;
	output reg fig_x;
	
//	reg [9:0] x, y;
	reg fig_x1,fig_x2,fig_x3,fig_x4;
	
	always @ (*) begin
//		if (hc >= x0 & hc < x1)		// make sure thath x1-x0 = image_width
////			x = hc-x0;	// offset the coordinates
//			x= 150;
//		else
//			x = 0;
//			
//		if (vc >= y0 & vc < y1)		// make sure that y1-y0 = image_height
////			y = vc - y0;	//offset the coordinates
//			y = 100;
//		else
//			y = 0;
	fig_x1 = (((hc >=x+42 & hc <= x+62)|(hc >= x+162 & hc <= x+182)) & ((vc >= y+15 & vc <= y+35)|(vc >= y+135 & vc <= y+155)));
	fig_x2 = (((hc >=x+62 & hc <= x+82)|(hc >= x+142 & hc <= x+162)) & ((vc >= y+35 & vc <= y+55)|(vc >= y+115 & vc <= y+135)));
	fig_x3 = (((hc >=x+82 & hc <= x+102)|(hc >= x+122 & hc <= x+142)) & ((vc >= y+55 & vc <= y+75)|(vc >= y+95 & vc <= y+115)));
	fig_x4 = ((hc >=x+102 & hc <= x+122) & (vc >= y+75 & vc <= y+95));
	fig_x = ~blank & (fig_x1|fig_x2|fig_x3|fig_x4);

	end
endmodule
