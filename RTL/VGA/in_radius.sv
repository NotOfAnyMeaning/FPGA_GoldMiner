module 	in_radius(
					input 	logic signed	[10:0] pixelX,//  current VGA pixel 
					input 	logic signed	[10:0] pixelY,			 
					input		logic signed	[10:0] bubble_TLX,
					input		logic signed	[10:0] bubble_TLY,
					input		logic scale_factor,
					output	logic	[1:0] is_in_radius
);
	parameter signed R_power = 3000;
	parameter signed second_R_power = 6000;
	parameter signed third_R_power = 20000;
//	parameter signed bubble_width = 32;
//	parameter signed bubble_height = 32;
	int bubble_width = 32;
	int bubble_height = 32;
	logic signed [10:0] delta_x; //the distance in x
	logic signed [10:0] delta_y; //the distance in y 
	logic signed [21:0] delta_x_power; //the distance in x squered 
	logic signed [21:0] delta_y_power; //the distance in y squered 
	logic signed [10:0] x_bubble_center; 
	logic signed [10:0] y_bubble_center;
	
	
	
	
	
	
	always_comb begin
		bubble_width = 32<<scale_factor;
		bubble_height = 32<<scale_factor;
		
		//the >>> is used to keep the signed property, 
		//>> fills the places of the moved bits with 0's, 
		//>>> keeps the sign bit

		x_bubble_center = bubble_TLX + (bubble_width >>> 1);
		y_bubble_center = bubble_TLY + (bubble_height >>> 1);
		delta_x = pixelX-x_bubble_center;
		delta_y = pixelY-y_bubble_center;
		delta_x_power = delta_x*delta_x;
		delta_y_power = delta_y*delta_y;
		if (delta_x_power + delta_y_power <= R_power) begin
			is_in_radius = 2'b01;
			
		end
		else if (delta_x_power + delta_y_power <= second_R_power)begin
			is_in_radius = 2'b10;
		end
		else if (delta_x_power + delta_y_power <= third_R_power) begin
		is_in_radius = 2'b11;
		end
		else begin
			is_in_radius = 2'b00;
		end
	end
endmodule 