module vga_bsprite_O(x, y, hc, vc, blank, fig_o);
	input [10:0] x, y;	// Coordinates of where the image will be placed
	input [10:0] hc, vc;	// Coordinates of the current pixel
	input blank;
	output reg fig_o;
	
//	reg [9:0] x, y;
	reg fig_o1,fig_o2,fig_o3;
	
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
	fig_o1 = ~blank & ((hc >=x+82 & hc <= x+142) & ((vc >= y+15 & vc <= y+35)|(vc >= y+135 & vc <= y+155)));
	fig_o2 = ~blank & (((hc >=x+62 & hc <= x+82)|(hc >= x+142 & hc <= x+162)) & ((vc >= y+35 & vc <= y+55)|(vc >= y+115 & vc <= y+135)));
	fig_o3 = ~blank & (((hc >=x+42 & hc <= x+62)|(hc >= x+162 & hc <= x+182)) & (vc >= y+55 & vc <= y+115));
	fig_o = (fig_o1|fig_o2|fig_o3);

	end
endmodule
