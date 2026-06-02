// JellyfishBitMap 
// A single level bitmap. displaying Jellyfish on the screen
// Updated Feb 2025 

module JellyfishBitMap ( 
    input logic clk,
    input logic resetN,
    input logic [10:0] offsetX, // offset from top left position 
    input logic [10:0] offsetY,
    input logic InsideRectangle, // input that the pixel is within a bracket 
    input logic collision_Bubble_Burger,
	 input logic [2:0] level_sel,
	 input logic item_bought, // if item was bought remove the jellyfish from the map
	 input logic load_game,

    output logic drawingRequest, // output that the pixel should be displayed 
    output logic [7:0] RGBout, // rgb value from the bitmap 
	 output logic ded_points
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; // RGB value in the bitmap representing a transparent pixel 

localparam int TILE_NUMBER_OF_X_BITS = 6; // 
localparam int TILE_NUMBER_OF_Y_BITS = 6; // 

localparam int TEXTURE_SIZE_X = 32;
localparam int TEXTURE_SIZE_Y = 32;


localparam int MAZE_NUMBER_OF__X_BITS = 4; // 2^4 = 16 // the maze of the objects 
localparam int MAZE_NUMBER_OF__Y_BITS = 3; // 2^3 = 8 

//-----

localparam int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS;
localparam int TILE_HEIGHT_Y = 1 << TILE_NUMBER_OF_Y_BITS;
localparam int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS;
localparam int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS;

logic [10:0] offsetX_LSB;
logic [10:0] offsetY_LSB; 
logic [10:0] offsetX_MSB;
logic [10:0] offsetY_MSB;

assign offsetX_LSB = offsetX[(TILE_NUMBER_OF_X_BITS-1):0]; // get lower bits 
assign offsetY_LSB = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0]; // get lower bits 
assign offsetX_MSB = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1):TILE_NUMBER_OF_X_BITS]; // get higher bits 
assign offsetY_MSB = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1):TILE_NUMBER_OF_Y_BITS]; // get higher bits 

logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0] MazeBitMapMask;  

logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0] MazeDefaultBitMapMask = // default table to load on reset 
{	
	{  //the first level
		 {64'h0010000000010000},
		 {64'h0100000100000000},
		 {64'h0000000000000000},
		 {64'h0000000001000010},
		 {64'h0001000000000000},
		 {64'h0000000000000000},
		 {64'h0000000001000000},
		 {64'h0000000000000000}
	 },
	 {		//the second level
		 {64'h0010100000010000},
		 {64'h0100000110001100},
		 {64'h0000010000000000},
		 {64'h0010000000010000},
		 {64'h0000100000100000},
		 {64'h0100000000000000},
		 {64'h0000000001100010},
		 {64'h0000000000000000}
	},
	{		//the third level
	    {64'h0010001000010000},
		 {64'h0100100110000010},
		 {64'h0001101000001000},
		 {64'h0000000010000100},
		 {64'h0001001100100000},
		 {64'h0010000001100010},
		 {64'h0010000001100100},
		 {64'h0000000000000000}
	}
};

logic [0:TEXTURE_SIZE_Y-1] [0:TEXTURE_SIZE_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hff,8'hf7,8'hf7,8'hfb,8'hff,8'hff,8'hff,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hf2,8'hf2,8'hf2,8'hf7,8'hfb,8'hfb,8'hff,8'hfb,8'hf7,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hf6,8'hf2,8'hf2,8'hfb,8'hfb,8'hfb,8'hf2,8'hf2,8'hf2,8'hf6,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hf7,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hf2,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hf6,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf6,8'hf7,8'hf7,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hf6,8'hf6,8'hf7,8'hff,8'hff,8'hff,8'hf2,8'hf2,8'hf2,8'he5,8'he1,8'he1,8'hf2,8'hf2,8'he1,8'he1,8'he1,8'hf7,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hf7,8'hfb,8'hff,8'hff,8'hf6,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf6,8'hff,8'hf2,8'hf2,8'hf2,8'he1,8'he1,8'hee,8'he5,8'he1,8'he1,8'he1,8'he1,8'he5,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hfb,8'hf2,8'hf2,8'hf2,8'hee,8'he1,8'he5,8'he1,8'he1,8'he1,8'he1,8'he1,8'he1,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'he1,8'he1,8'he1,8'he1,8'he1,8'he1,8'hee,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf7,8'hf2,8'hf2,8'hf2,8'hf2,8'hfb,8'hf2,8'hf2,8'hf2,8'he1,8'hf2,8'he1,8'he1,8'he1,8'he1,8'he1,8'he1,8'hf2,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hf2,8'hfb,8'hff,8'hff,8'hff,8'hfb,8'hf2,8'hf2,8'hf2,8'hee,8'hf2,8'he1,8'he1,8'he1,8'he1,8'he1,8'he1,8'hf2,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hfb,8'hf2,8'hf2,8'hf2,8'hf2,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'he1,8'he1,8'he1,8'he1,8'he1,8'he5,8'hfb,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hf2,8'hf2,8'hf2,8'hf2,8'hf7,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'he1,8'he1,8'he1,8'he1,8'hf2,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf7,8'hf7,8'hf7,8'hf7,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hee,8'hf2,8'hf2,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hf6,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hff,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hf2,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfb,8'hfb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

 

//
// pipeline (ff) to get the pixel color from the array   

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin
        RGBout <= 8'hFF;
        MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //  copy default table 
    end
    else begin
	 if(load_game == 1) begin
			MazeBitMapMask  <=  MazeDefaultBitMapMask ;
		end
		else begin
        RGBout <= TRANSPARENT_ENCODING ; // default 
		  ded_points <= 0;
		  //the following condition checks if a collision was registered 
        if (collision_Bubble_Burger && MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB]) begin
            MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] <= 4'h00;   
				ded_points <= 1;
			end
        
        if (InsideRectangle == 1'b1 )   
            //if item 1 was bought then remove jellyfish otherwise check mask as usual
				if ( item_bought ) begin 
					RGBout <= TRANSPARENT_ENCODING;
				end 	
				else begin 
                case (MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB])
                     4'h0 : RGBout <= TRANSPARENT_ENCODING ;
                     default: RGBout <= object_colors[offsetY_LSB>>1][offsetX_LSB>>1]; 
                endcase
            end 
		end 
	end
end
//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmap    
endmodule