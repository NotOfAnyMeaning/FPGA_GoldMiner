//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2025 


module	square_object_hand	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,//  current VGA pixel 
					input 	logic signed	[10:0] pixelY,

					input		logic [2:0]  curr_select_shop,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
					
);

parameter  int OBJECT_WIDTH_X = 100;
parameter  int OBJECT_HEIGHT_Y = 100;
parameter  logic [7:0] OBJECT_COLOR = 8'h03 ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 

//params for positions based on items
parameter int ITEM1_X = 260;
parameter int ITEM1_Y = 250;
parameter int ITEM2_X = 390;
parameter int ITEM2_Y = 250;
parameter int ITEM3_X = 300;
parameter int ITEM3_Y = 350;
parameter int EXIT_X = 450;
parameter int EXIT_Y = 320;


logic signed [10:0] topLeftX;//position on the screen 
logic	signed [10:0] topLeftY;   // can be negative , if the object is partliy outside 
 
int rightX ; //coordinates of the sides  
int bottomY ;
logic insideBracket ; 

//determining the positions of the cursor based on the current item in shop
always_comb begin
    topLeftX = ITEM1_X;
    topLeftY = ITEM1_Y;

    case (curr_select_shop)
        1: begin
            topLeftX = ITEM1_X; 
            topLeftY = ITEM1_Y;
        end
        2: begin
            topLeftX = ITEM2_X; 
            topLeftY = ITEM2_Y;
        end
        3: begin
            topLeftX = ITEM3_X; 
            topLeftY = ITEM3_Y;
        end
		  4: begin
				topLeftX = EXIT_X;
				topLeftY = EXIT_Y;
			end	
        default: begin
            topLeftX = ITEM1_X;
            topLeftY = ITEM1_Y;
        end
    endcase
end
//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign rightX	= (topLeftX + OBJECT_WIDTH_X);
assign bottomY	= (topLeftY + OBJECT_HEIGHT_Y);
assign	insideBracket  = 	 ( (pixelX  >= topLeftX) &&  (pixelX < rightX) // math is made with SIGNED variables  
						   && (pixelY  >= topLeftY) &&  (pixelY < bottomY) )  ; // as the top left position can be negative
		
//////////--------------------------------------------------------------------------------------------------------------=


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
		// DEFUALT outputs
	      RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
			drawingRequest <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
	
 
		if (insideBracket) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - topLeftX); //calculate relative offsets from top left corner allways a positive number 
			offsetY	<= (pixelY - topLeftY);
		end 
		

		
	end
end 
endmodule 