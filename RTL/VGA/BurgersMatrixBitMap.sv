
//(c) Technion IIT, Department of Electrical Engineering 2025 



module	BurgersMatrixBitMap
	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic random_burger,
					input logic collision_Bubble_Burger,
					input logic [2:0]level_sel,
					input logic load_game,
					input	logic [10:0] bad_patty_explosion_mazeX, //the mazeX of the bad_patty that was hit
					input	logic [10:0] bad_patty_explosion_mazeY, //the mazeY of the bad_patty that was hit
					input	logic hit_bad_patty_stage_2,
					input logic start_of_frame,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic add_points, 
					output   logic [2:0][7:0] rotten //rotten is used to inform the bad patty module 
																//whether and where there was a healty burger touching a rotten 
																//burger that was hit
					
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 


localparam  int TILE_NUMBER_OF_X_BITS = 5;  // 2^5 = 32  
localparam  int TILE_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 

localparam  int MAZE_NUMBER_OF__X_BITS = 4;  // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 3;  // 2^3 = 8 

//-----

localparam  int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS ;
localparam  int TILE_HEIGHT_Y = 1 <<  TILE_NUMBER_OF_Y_BITS ;
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;


 logic [10:0] offsetX_LSB;
 logic [10:0] offsetY_LSB; 
 logic [10:0] offsetX_MSB;
 logic [10:0] offsetY_MSB;
 logic hit_bad_patty_stage_2_d;
 

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 

 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 


logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  MazeBitMapMask ;  

logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]   MazeDefaultBitMapMask= 
{
	//LEVEL 1
	{
		{64'h00100110000100000},
		{64'h01110000100011000},
		{64'h10000001001000000},
		{64'h00101100011000110},
		{64'h00001100010100000},
		{64'h00100000001000000},
		{64'h01001100011000100},
		{64'h00000000000010000}
	 },
	 //LEVEL 2
	 {
		{64'h00000011000000000},
		{64'h00010000001000010},
		{64'h00100001000000100},
		{64'h10001010100010000},
		{64'h00000101010011100},
		{64'h00110000100001100},
		{64'h00001000100100000},
		{64'h10000000000000001}
	},
	//LEVEL 3
	{ 
		{64'h00000000000110000},
		{64'h00010000001000010},
		{64'h00100001000000100},
		{64'h00000010100010000},
		{64'h00100100010001000},
		{64'h00010000100000000},
		{64'h00000000100100000},
		{64'h10001000000000001}
	}
};


 


 
logic [0:TILE_HEIGHT_Y-1] [0:TILE_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf9,8'hf9,8'hf5,8'hf5,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf9,8'hfd,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf9,8'hf9,8'hf5,8'hf5,8'hf4,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf9,8'hf9,8'hfd,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf9,8'hf9,8'hf5,8'hf5,8'hf5,8'hf9,8'hf9,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf4,8'hf9,8'hf9,8'hf5,8'h20,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf9,8'hf9,8'hf9,8'hf9,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf9,8'hf9,8'hf5,8'hf9,8'hf9,8'hf9,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf4,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf9,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hf4,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf9,8'hf9,8'hf5,8'hf9,8'hf9,8'hf5,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h00,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf8,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h84,8'h8c,8'h8c,8'h8c,8'hb1,8'h00,8'h00,8'h00,8'h00,8'h6d,8'hfe,8'hfe,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h00,8'h00,8'h8c,8'h8d,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h00,8'h8c,8'h8c,8'h84,8'h8c,8'h8c,8'hb1,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hcc,8'hfd,8'h84,8'h8c,8'h24,8'hac,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h00,8'hfd,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hfd,8'hfc,8'hfd,8'hfc,8'hfd,8'hfd,8'hfd,8'h00,8'h8c,8'h24,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h00,8'h00,8'hfc,8'hfd,8'hfd,8'hfd,8'hfc,8'hfd,8'hb0,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hcc,8'hac,8'hac,8'hcc,8'hcc,8'hf4,8'hf4,8'hd0,8'hfd,8'hfd,8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hf9,8'hd0,8'hac,8'hac,8'hac,8'hf4,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'hd0,8'hf5,8'hfc,8'hfc,8'hfc,8'hfd,8'hfc,8'hfd,8'hac,8'hcc,8'h8c,8'h8c,8'h8c,8'h8c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'hf4,8'hfd,8'hfd,8'hfe,8'hac,8'h8c,8'h8c,8'h8c,8'h00,8'h8c,8'h8c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf9,8'hf5,8'hf9,8'h00,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h84,8'hf4,8'h84,8'h8c,8'h8c,8'h8c,8'h00,8'h00,8'hf9,8'hf5,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf9,8'hf5,8'hf5,8'hf4,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf4,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf9,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hf4,8'hf5,8'hf9,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hf5,8'hf4,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
		RGBout <=	8'hFF;
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //  copy default tabel
		rotten <= 0;
			
	end
	else begin
		hit_bad_patty_stage_2_d <= hit_bad_patty_stage_2;
		if(load_game == 1) begin
			MazeBitMapMask  <=  MazeDefaultBitMapMask ;
			rotten <= 0;
		end
		else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		add_points <= 0;
		if(start_of_frame) begin
			rotten <= 0;
		end 
		if (collision_Bubble_Burger && MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB]) begin
			MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] <= 4'h00;  // clear entry 
			add_points <= 1; 
		end
		else if (hit_bad_patty_stage_2 && (!hit_bad_patty_stage_2_d)) begin
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX-1] != 0) begin //top left
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX-1] <= 4'h00;
				rotten[level_sel][0] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX] != 0) begin //top
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX]<= 4'h00;
				rotten[level_sel][1] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX+1] != 0) begin //top right
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY-1][bad_patty_explosion_mazeX+1]<= 4'h00;
				rotten[level_sel][2] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY][bad_patty_explosion_mazeX+1] != 0) begin //right
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY][bad_patty_explosion_mazeX+1]<= 4'h00;
				rotten[level_sel][3] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX+1] != 0) begin //bottom right
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX+1]<= 4'h00;
				rotten[level_sel][4] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX] != 0) begin //bottom
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX]<= 4'h00;
				rotten[level_sel][5] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX-1] != 0) begin //bottom left
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY+1][bad_patty_explosion_mazeX-1]<= 4'h00;
				rotten[level_sel][6] <= 1;
			end
			if(MazeBitMapMask[level_sel][bad_patty_explosion_mazeY][bad_patty_explosion_mazeX-1] != 0) begin //left
				MazeBitMapMask[level_sel][bad_patty_explosion_mazeY][bad_patty_explosion_mazeX-1]<= 4'h00;
				rotten[level_sel][7] <= 1;
			end
		end
		
		if (InsideRectangle == 1'b1 )	
			begin 
		   	case (MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB])
					 4'h0 : RGBout <= TRANSPARENT_ENCODING ;
					 4'h1 : RGBout <= object_colors[offsetY_LSB][offsetX_LSB]; 
					 default:  RGBout <= TRANSPARENT_ENCODING ; 
				endcase
			end 
		end 
	end
end
//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

