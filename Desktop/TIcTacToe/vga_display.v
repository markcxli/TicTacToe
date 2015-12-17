`timescale 1ns / 1ps
module vga_display(Score_rst, rst, clk, R, G, B, HS, VS, R_control, G_control, B_control, up, down, left, right, enter, valueX, valueO);
	input Score_rst, rst;	// global reset
	input clk;	// 100MHz clk
	input up,down,left,right,enter;
	
	// color inputs for a given pixel
	input [2:0] R_control, G_control;
	input [1:0] B_control; 
	
	// color outputs to show on display (current pixel)
	output reg [2:0] R, G;
	output reg [1:0] B;
	
	// Synchronization signals
	output HS;
	output VS;
	
	output reg [3:0] valueX, valueO;
	//**************************************************************************************************************
	parameter S_IDLE = 0;	// 0000 - no button pushed
	parameter S_UP = 1;		// 0001 - the first button pushed	
	parameter S_DOWN = 2;	// 0010 - the second button pushed
	parameter S_LEFT = 4; 	// 0100 - and so on	
	parameter S_RIGHT = 8;	// 1000 - and so on

	reg [3:0] state, next_state;
	////////////////////////////////////////	

	reg [10:0] x, y;				//currentposition variables
	reg slow_clk;					// clock for position update,	
									// if it’s too fast, every push
									// of a button willmake your object fly away.
	reg fxs;
	reg fos;	
	wire fx0,fx1,fx2,fx3,fx4,fx5,fx6,fx7,fx8;
	wire fo0,fo1,fo2,fo3,fo4,fo5,fo6,fo7,fo8;
	wire G_O1,G_O2,G_O3,G_O4,G_O5,G_O6,G_O7,G_O8,G_O9;
	reg player;
	reg [3:0] position;
	reg [8:0] matrixX;
	reg [8:0] matrixO;
	reg chance1;
	reg chance2;
	reg chance3;
	reg schance1;
	reg schance2;
	reg schance3;
	reg Xwin,Owin,winCount,tieXO;
		
	wire enter_db;
	wire enter_d;
	wire enter_u;
	Debouncer Enter_Debounce (clk,enter,enter_db,enter_d,enter_u);
	
	initial begin					// initial position of the box	
		x = 0; y=0; 
		player = 0;
		position = 4'b0000; 
		matrixX = 9'b000000000; 
		matrixO = 9'b000000000;
		fxs = 0;
		fos = 0;
		Xwin = 0;
		Owin = 0;
		winCount = 0;
		chance1 = 0;
		chance2 = 0;
		chance3 = 0;
		valueX = 4'd0;
		valueO = 4'd0;
		tieXO = 0;
	end	

	////////////////////////////////////////////	
	// slow clock for position update - optional
	reg [23:0] slow_count;	
	initial begin
		slow_count = 0;
	end
	always @ (posedge clk)begin
		slow_count = slow_count + 1'b1;	
		slow_clk = slow_count[23];
	end	
	/////////////////////////////////////////

/*
	wire up_db;
	wire up_d;
	wire up_u;
	Debouncer Up_Debounce (slow_clk,up,up_db,up_d,up_u);

	wire down_db;
	wire down_d;
	wire down_u;
	Debouncer Down_Debounce (slow_clk,down,down_db,down_d,down_u);
	wire left_db;
	wire left_d;
	wire left_u;
	Debouncer Left_Debounce (slow_clk,left,left_db,left_d,left_u);
	wire right_db;
	wire right_d;
	wire right_u;
	Debouncer Right_Debounce (slow_clk,right,right_db,right_d,right_u);
	*/

	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));

	///////////////////////////////////////////
	// State Machine	
	always @ (posedge slow_clk)begin
		state = next_state;	
	end

	always @ (posedge slow_clk) begin	
		if (~(schance1&schance2&schance3)) begin
				//reset;
				schance1 = 1;
				schance2 = 1;
				schance3 = 1;
				x = 0;
				y = 0;
				position = 0;
				end
			else begin
				end
	
		if (rst) begin
			x = 0; 
			y = 0;
			if (position > 0)
				position = 0;
			else
				position = 0;
		end
		else begin
		end
		case (state)
			S_IDLE: next_state = {right,left,down,up}; // if input is 0000
			
			S_UP: begin	// if input is 0001
				if (y >= 11'd155) begin 
					y = y - 11'd155;	
					position = position - 4'b0011;
				end
				else begin
				end
				next_state = {right,left,down,up};
			end	
			
			S_DOWN: begin // if input is 0010
				if (y < 11'd310) begin
					position = position + 4'b0011;
					y = y + 11'd155;	
				end
				else begin
				end
				next_state = {right,left,down,up};
			end
			
			S_LEFT: begin	// if input is 0001
				position = position - 4'b0001;
				if (x >= 11'd208) begin
					x = x - 11'd208;	
				end
				else begin
				end
				next_state = {right,left,down,up};
			end
			
			S_RIGHT: begin	// if input is 0001
				if (x < 11'd416) begin
					position = position + 4'b0001;
					x = x + 11'd208;	
				end
				else begin
				end
				next_state = {right,left,down,up};
			end
			
			default: begin
				x = x;
				y = y;
				next_state = {right,left,down,up};
			end	
		endcase
	end
	wire fig_x, fig_o, frame, G_O, tie;
	wire hframe1, hframe2, hframe3, hframe4;
	wire vframe1, vframe2, vframe3, vframe4;
	wire fig_x1, fig_x2, fig_x3, fig_x4;
	wire fig_o1, fig_o2, fig_o3;
	wire tie1, tie2, tie3;
	
	assign hframe1 = ~blank & (hcount >= 0 & hcount <= 800 & vcount >= 0 & vcount <= 15);
	assign hframe2 = ~blank & (hcount >= 0 & hcount <= 800 & vcount >= 155 & vcount <= 170);
	assign hframe3 = ~blank & (hcount >= 0 & hcount <= 800 & vcount >= 310 & vcount <= 325);
	assign hframe4 = ~blank & (hcount >= 0 & hcount <= 800 & vcount >= 465 & vcount <= 480);	
	assign vframe1 = ~blank & (hcount >= 0 & hcount <= 17 & vcount >= 0 & vcount <= 480);
	assign vframe2 = ~blank & (hcount >= 207 & hcount <= 225 & vcount >= 0 & vcount <= 480);
	assign vframe3 = ~blank & (hcount >= 415 & hcount <= 432 & vcount >= 0 & vcount <= 480);
	assign vframe4 = ~blank & (hcount >= 622 & hcount <= 640 & vcount >= 0 & vcount <= 480);
	assign fig_x1 = ~blank & (((hcount >=x+42 & hcount <= x+62)|(hcount >= x+162 & hcount <= x+182)) & ((vcount >= y+15 & vcount <= y+35)|(vcount >= y+135 & vcount <= y+155)));
	assign fig_x2 = ~blank & (((hcount >=x+62 & hcount <= x+82)|(hcount >= x+142 & hcount <= x+162)) & ((vcount >= y+35 & vcount <= y+55)|(vcount >= y+115 & vcount <= y+135)));
	assign fig_x3 = ~blank & (((hcount >=x+82 & hcount <= x+102)|(hcount >= x+122 & hcount <= x+142)) & ((vcount >= y+55 & vcount <= y+75)|(vcount >= y+95 & vcount <= y+115)));
	assign fig_x4 = ~blank & ((hcount >=x+102 & hcount <= x+122) & (vcount >= y+75 & vcount <= y+95));
	assign fig_o1 = ~blank & ((hcount >=x+82 & hcount <= x+142) & ((vcount >= y+15 & vcount <= y+35)|(vcount >= y+135 & vcount <= y+155)));
	assign fig_o2 = ~blank & (((hcount >=x+62 & hcount <= x+82)|(hcount >= x+142 & hcount <= x+162)) & ((vcount >= y+35 & vcount <= y+55)|(vcount >= y+115 & vcount <= y+135)));
	assign fig_o3 = ~blank & (((hcount >=x+42 & hcount <= x+62)|(hcount >= x+162 & hcount <= x+182)) & (vcount >= y+55 & vcount <= y+115));
	assign G_O1 = (((hcount >=225 & hcount <= 255)|(hcount >= 342 & hcount <= 372)) & (vcount >= 170 & vcount <= 310));
	assign G_O2 = (((hcount >=285 & hcount <= 312)|(hcount >= 402 & hcount <= 422)|(hcount >= 442 & hcount <= 462)) & (vcount >= 234 & vcount <= 310));
	assign G_O3 = ((hcount >=542 & hcount <= 622) & ((vcount >= 240 & vcount <= 254)|(vcount >= 268 & vcount <= 282)|(vcount >= 296 & vcount <= 310)));
	assign G_O4 = ((hcount >=502 & hcount <= 522) & (vcount >= 240 & vcount <= 310));
	assign G_O5 = ((hcount >=462 & hcount <= 522) & (vcount >= 240 & vcount <= 254));
	assign G_O6 = ((hcount >=402 & hcount <= 422) & (vcount >= 198 & vcount <= 219));
	assign G_O7 = ((hcount >=542 & hcount <= 562) & (vcount >= 254 & vcount <= 268));
	assign G_O8 = ((hcount >=602 & hcount <= 622) & (vcount >= 282 & vcount <= 310));
	assign G_O9 = ((hcount >=225 & hcount <= 372) & (vcount >= 282 & vcount <= 310));
	assign tie1 = (((hcount >=155 & hcount <= 245)|(hcount >= 305 & hcount <= 335)|(hcount >= 395 & hcount <= 485)) & (vcount >= 155 & vcount <= 195));
	assign tie2 = (((hcount >=185 & hcount <= 215)|(hcount >= 305 & hcount <= 335)|(hcount >= 395 & hcount <= 415)) & (vcount >= 155 & vcount <= 355));
	assign tie3 = ((hcount >=395 & hcount <= 485) & ((vcount >= 245 & vcount <= 275)|(vcount >= 325 & vcount <= 355)));
	
	assign G_O = (G_O1|G_O2|G_O3|G_O4|G_O5|G_O6|G_O7|G_O8|G_O9);
	assign tie = (tie1|tie2|tie3);
	assign frame = (hframe1|hframe2|hframe3|hframe4|vframe1|vframe2|vframe3|vframe4);
	assign fig_x = (fig_x1|fig_x2|fig_x3|fig_x4);
	assign fig_o = (fig_o1|fig_o2|fig_o3);
	
	
	vga_bsprite_X X0(11'd0,11'd0,hcount,vcount,1'b0,fx0);
	vga_bsprite_X X1(11'd208,11'd0,hcount,vcount,1'b0,fx1);
	vga_bsprite_X X2(11'd416,11'd0,hcount,vcount,1'b0,fx2);
	vga_bsprite_X X3(11'd0,11'd155,hcount,vcount,1'b0,fx3);
	vga_bsprite_X X4(11'd208,11'd155,hcount,vcount,1'b0,fx4);
	vga_bsprite_X X5(11'd416,11'd155,hcount,vcount,1'b0,fx5);
	vga_bsprite_X X6(11'd0,11'd310,hcount,vcount,1'b0,fx6);
	vga_bsprite_X X7(11'd208,11'd310,hcount,vcount,1'b0,fx7);
	vga_bsprite_X X8(11'd416,11'd310,hcount,vcount,1'b0,fx8);
	vga_bsprite_O O0(11'd0,11'd0,hcount,vcount,1'b0,fo0);
	vga_bsprite_O O1(11'd208,11'd0,hcount,vcount,1'b0,fo1);
	vga_bsprite_O O2(11'd416,11'd0,hcount,vcount,1'b0,fo2);
	vga_bsprite_O O3(11'd0,11'd155,hcount,vcount,1'b0,fo3);
	vga_bsprite_O O4(11'd208,11'd155,hcount,vcount,1'b0,fo4);
	vga_bsprite_O O5(11'd416,11'd155,hcount,vcount,1'b0,fo5);
	vga_bsprite_O O6(11'd0,11'd310,hcount,vcount,1'b0,fo6);
	vga_bsprite_O O7(11'd208,11'd310,hcount,vcount,1'b0,fo7);
	vga_bsprite_O O8(11'd416,11'd310,hcount,vcount,1'b0,fo8);
	
	always @ (posedge clk) begin
	// if correct initialized
		if (~(chance1&chance2&chance3)) begin
			//reset;
			chance1 = 1;
			chance2 = 1;
			chance3 = 1;
			player = 0;
			matrixX = 0;
			matrixO = 0;
			winCount = 0;
			Xwin = 0;
			Owin = 0;
			end
		else begin
			end
		if (Score_rst) begin
			valueX = 0;
			valueO = 0;
			end
		else begin
			end
		if (rst) begin
			matrixX = 9'b000000000;
			matrixO = 9'b000000000;
			player = 0;
			Xwin = 0;
			Owin = 0;
			if (winCount)
			winCount = 0;
			else
			winCount = winCount;
			tieXO = 0;
			end
		else begin
			matrixX = matrixX;
			matrixO = matrixO;
			player = player;
			end

		fxs = ((fx0&matrixX[0])|(fx1&matrixX[1])|(fx2&matrixX[2])|(fx3&matrixX[3])|(fx4&matrixX[4])|(fx5&matrixX[5])|(fx6&matrixX[6])|(fx7&matrixX[7])|(fx8&matrixX[8]));
		fos = ((fo0&matrixO[0])|(fo1&matrixO[1])|(fo2&matrixO[2])|(fo3&matrixO[3])|(fo4&matrixO[4])|(fo5&matrixO[5])|(fo6&matrixO[6])|(fo7&matrixO[7])|(fo8&matrixO[8]));
		if (player) begin
			if (enter_d) begin
				case (position)
					0: begin									
						if (~matrixX[0]&~matrixO[0]) begin
							matrixX[0] = ~matrixX[0];
							end
						else begin
							matrixX[0] = matrixX[0];
							end
						player = ~player;
						end //0
					1: begin
						if (~matrixX[1]&~matrixO[1]) begin
							matrixX[1] = ~matrixX[1];
							end
						else begin
							matrixX[1] = matrixX[1];
							end
						player = ~player;
						end //1
					2: begin
						if (~matrixX[2]&~matrixO[2]) begin
							matrixX[2] = ~matrixX[2];
							end
						else begin
							matrixX[2] = matrixX[2];
							end
						player = ~player;
						end //2
					3: begin
						if (~matrixX[3]&~matrixO[3]) begin
							matrixX[3] = ~matrixX[3];
							end
						else begin
							matrixX[3] = matrixX[3];
							end
						player = ~player;
						end //3
					4: begin
						if (~matrixX[4]&~matrixO[4]) begin
							matrixX[4] = ~matrixX[4];
							end
						else begin
							matrixX[4] = matrixX[4];
							end
						player = ~player;
						end //4
					5: begin
						if (~matrixX[5]&~matrixO[5]) begin
							matrixX[5] = ~matrixX[5];
							end
						else begin
							matrixX[5] = matrixX[5];
							end
						player = ~player;
						end //5
					6: begin
						if (~matrixX[6]&~matrixO[6]) begin
							matrixX[6] = ~matrixX[6];
							end
						else begin
							matrixX[6] = matrixX[6];
							end
						player = ~player;
						end //6
					7: begin
						if (~matrixX[7]&~matrixO[7]) begin
							matrixX[7] = ~matrixX[7];
							end
						else begin
							matrixX[7] = matrixX[7];
							end
						player = ~player;
						end //7
					8: begin
						if (~matrixX[8]&~matrixO[8]) begin
							matrixX[8] = ~matrixX[8];
							end
						else begin
							matrixX[8] = matrixX[8];
							end
						player = ~player;
						end //8
					default: begin
						matrixX = 0;
						player = ~player;
						end //default
					endcase
				end//enter_d
			else begin
				matrixX = matrixX;
				end
			end // player
		else begin //else player
			if (enter_d) begin
				case (position)
					0: begin				
						if (~matrixO[0]&~matrixX[0]) begin
							matrixO[0] = ~matrixO[0];
							end
						else begin
							matrixO[0] = matrixO[0];
							end
						player = ~player;
						end //0
					1: begin
						if (~matrixO[1]&~matrixX[1]) begin
							matrixO[1] = ~matrixO[1];
							end
						else begin
							matrixO[1] = matrixO[1];
							end
						player = ~player;
						end //1
					2: begin
						if (~matrixO[2]&~matrixX[2]) begin
							matrixO[2] = ~matrixO[2];
							end
						else begin
							matrixO[2] = matrixO[2];
							end
						player = ~player;
						end //2
					3: begin
						if (~matrixO[3]&~matrixX[3]) begin
							matrixO[3] = ~matrixO[3];
							end
						else begin
							matrixO[3] = matrixO[3];
							end
						player = ~player;
						end //3
					4: begin
						if (~matrixO[4]&~matrixX[4]) begin
							matrixO[4] = ~matrixO[4];
							end
						else begin
							matrixO[4] = matrixO[4];
							end
						player = ~player;
						end //4
					5: begin
						if (~matrixO[5]&~matrixX[5]) begin
							matrixO[5] = ~matrixO[5];
							end
						else begin
							matrixO[5] = matrixO[5];
							end
						player = ~player;
						end //5
					6: begin
						if (~matrixO[6]&~matrixX[6]) begin
							matrixO[6] = ~matrixO[6];
							end
						else begin
							matrixO[6] = matrixO[6];
							end
						player = ~player;
						end //6
					7: begin
						if (~matrixO[7]&~matrixX[7]) begin
							matrixO[7] = ~matrixO[7];
							end
						else begin
							matrixO[7] = matrixO[7];
							end
						player = ~player;
						end //7
					8: begin
						if (~matrixO[8]&~matrixX[8]) begin
							matrixO[8] = ~matrixO[8];
							end
						else begin
							matrixO[8] = matrixO[8];
							end
						player = ~player;
						end //8
					default: begin
						matrixO = 0;
						player = ~player;
						end //default
					endcase
				end//enter
				else begin
					matrixO = matrixO;
					end
			end//else player
		if (fxs) begin
			R = 3'b100;
			G = 0;
			B = 2'b10;
			end
		else if (fos) begin
			R = 3'b100;
			G = 3'b100;
			B = 0;
			end
		else begin
			R = 0;
			G = 0;
			B = 0;
			end			//color boxes
		if (player) begin
			if (fig_x) begin
				R = 3'b111;
				G = 0;
				B = 2'b11;
				end
			else begin
				end
			end //player
		else begin
			if (fig_o) begin
				R = 3'b111;
				G = 3'b111;
				B = 0;
				end
			else begin
				end
			end //~player			
		if (frame) begin
			R = 3'b111;
			G = 3'b111;
			B = 3'b11;
			end	//frame
		else begin
			end	
		tieXO = ((matrixX[0]+matrixX[1]+matrixX[2]+matrixX[3]+matrixX[4]+matrixX[5]+matrixX[6]+matrixX[7]+matrixX[8]+matrixO[0]+matrixO[1]+matrixO[2]+matrixO[3]+matrixO[4]+matrixO[5]+matrixO[6]+matrixO[7]+matrixO[8])>= 9);
		if (tieXO) begin
			if (tie) begin
				R = 3'b000;
				G = 3'b111;
				B = 2'b10;
				end // tie
			else begin
				R = 3'b000;
				G = 3'b000;
				B = 2'b00;
				end // tie else
			end // tieXO
		else begin
			end // tieXO
		Xwin = ((matrixX[0]+matrixX[1]+matrixX[2]==3)|(matrixX[3]+matrixX[4]+matrixX[5]==3)|(matrixX[6]+matrixX[7]+matrixX[8]==3)|((matrixX[0]+matrixX[3]+matrixX[6])==3)|((matrixX[1]+matrixX[4]+matrixX[7])==3)|((matrixX[2]+matrixX[5]+matrixX[8])==3)|((matrixX[0]+matrixX[4]+matrixX[8])==3)|((matrixX[2]+matrixX[4]+matrixX[6])==3));
		Owin = ((matrixO[0]+matrixO[1]+matrixO[2]==3)|(matrixO[3]+matrixO[4]+matrixO[5]==3)|(matrixO[6]+matrixO[7]+matrixO[8]==3)|((matrixO[0]+matrixO[3]+matrixO[6])==3)|((matrixO[1]+matrixO[4]+matrixO[7])==3)|((matrixO[2]+matrixO[5]+matrixO[8])==3)|((matrixO[0]+matrixO[4]+matrixO[8])==3)|((matrixO[2]+matrixO[4]+matrixO[6])==3));
		if (Xwin) begin 
			if (~winCount) begin
				valueX=valueX+4'b0001;
				winCount = 1'b1;
				end
			else
				winCount = winCount;
			if (G_O|fx3) begin
				R = 3'b111;
				G = 3'b000;
				B = 2'b11;
				end
			else begin
				R = 3'b000;
				G = 3'b000;
				B = 2'b00;
				end
			end //Xwin
		else if (Owin) begin
			if (~winCount) begin
				valueO=valueO+4'b0001;
				winCount = 1'b1;
				end
			else
				winCount = winCount;
			if (G_O|fo3) begin
				R = 3'b111;
				G = 3'b111;
				B = 2'b00;
				end
			else begin
				R = 3'b000;
				G = 3'b000;
				B = 2'b00;
				end
			end//Owin
		else begin
			end //else Xwin Owin
	end//posedge clk
endmodule
