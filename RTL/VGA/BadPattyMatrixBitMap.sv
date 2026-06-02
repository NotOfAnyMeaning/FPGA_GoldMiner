
//(c) Technion IIT, Department of Electrical Engineering 2025 



module	BadPattyMatrixBitMap
	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					input logic collision_Bubble_BadPatty,
					input logic [2:0]level_sel,
					input logic load_game,
					
					//this will be used to check wether there are healty burgers touching the rotten burger. 
					//the numbering system is the rotten burger is the center and the cells are numebred from 0 to 7, 
					//the top left cell is 0 and then clockwise.
					//each healthy burger touching a stage2 (the less rotten stage) rotten burger will be removed from the 
				   //healthy burgers mazemask and will be added to the rotten's
					
					input logic [2:0][7:0] rotten, 
					input logic is_exploding,
					input logic start_of_frame,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic add_points, 
					output	logic [10:0] bad_patty_explosion_mazeX,
					output	logic [10:0] bad_patty_explosion_mazeY,
					output   logic hit_bad_patty_stage_2,
					output 	logic ded_point_rotten
					
					
					
 );
 

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
 logic [10:0] offsetX_collision;
 logic [10:0] offsetY_collision;
 logic flag;
 logic is_exploding_d;

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits
 assign bad_patty_explosion_mazeX = offsetX_collision;
 assign bad_patty_explosion_mazeY = offsetY_collision;
 
 
 

 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the understanding 


logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]  MazeBitMapMask ;  

logic [0:2][0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [3:0]   MazeDefaultBitMapMask= 
{
	//LEVEL 1
	{
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000},
		{64'h00000000000000000}
	 },
	 //LEVEL 2
	 {
		{64'h00000200000000000},
		{64'h00000000020000200},
		{64'h02000200000000000},
		{64'h00000000000000000},
		{64'h00000000000200000},
		{64'h00200000020000200},
		{64'h00000000000002000},
		{64'h00002000000000000}
	},
	//LEVEL 3
	{ 
		{64'h00000200000000000},
		{64'h02000000000000200},
		{64'h02000200000000000},
		{64'h00000000000200000},
		{64'h00000000200000000},
		{64'h00200000000000200},
		{64'h00000200000020000},
		{64'h00002000000000000}
	}
};


 


 
logic [1:0] [0:TILE_HEIGHT_Y-1] [0:TILE_WIDTH_X-1] [7:0] object_colors = {
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'h70,8'hb9,8'h70,8'h70,8'h00,8'h71,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb9,8'hb9,8'hb9,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'h90,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hd9,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'hb9,8'hb9,8'h70,8'h90,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h70,8'hb9,8'hb9,8'h70,8'hb5,8'hb1,8'hb5,8'hb5,8'hb5,8'hb5,8'h90,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'h90,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'hb9,8'hb9,8'h70,8'hb5,8'hb5,8'hb5,8'hb5,8'h90,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hb9,8'hb9,8'hb9,8'hb9,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'h70,8'hb5,8'hb5,8'h70,8'hb9,8'hb9,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb9,8'h95,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb5,8'hb5,8'hb5,8'h90,8'h70,8'hb9,8'hb9,8'hb1,8'hb5,8'hb9,8'hb9,8'hb9,8'hb9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'hb5,8'hb5,8'hb9,8'hb9,8'hb9,8'hd9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h90,8'hb5,8'hb9,8'hb9,8'hb9,8'h6c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hd9,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hb9,8'hb9,8'hd9,8'h70,8'hb9,8'h70,8'hb9,8'hb9,8'h70,8'hb5,8'hb5,8'hb5,8'hb5,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb5,8'h70,8'hb1,8'hb5,8'hb5,8'h90,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'h64,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h6c,8'hb9,8'h6c,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'h70,8'h70,8'hfd,8'h64,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h64,8'h70,8'hb9,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h64,8'h64,8'h64,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h64,8'h64,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb9,8'h24,8'hd4,8'hfd,8'hfd,8'hfd,8'h64,8'hd4,8'h64,8'h64,8'h64,8'h64,8'h64,8'h84,8'hfd,8'hd4,8'hfd,8'hfd,8'h64,8'hb9,8'hb9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hd9,8'hb9,8'h24,8'hfd,8'hb0,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h84,8'h84,8'h64,8'hb0,8'h64,8'hfd,8'h64,8'hdd,8'hb9,8'hb9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h2c,8'h70,8'h70,8'hfd,8'hb5,8'hb5,8'hb5,8'h24,8'h91,8'h24,8'h64,8'h84,8'h84,8'h84,8'h24,8'hb1,8'hfd,8'hb5,8'hb9,8'hb9,8'hb9,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h2c,8'hb9,8'hd4,8'hb5,8'hb5,8'hb5,8'hb5,8'h00,8'hb5,8'hb5,8'hb5,8'hb5,8'hb5,8'h70,8'hb5,8'hfd,8'hb5,8'hb9,8'h70,8'h70,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'hb5,8'hb5,8'hb5,8'hb5,8'hb1,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h70,8'h70,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'hb9,8'h70,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
	},
	{{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'hff,8'h00,8'h24,8'h6c,8'h00,8'h00,8'hff,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h00,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h6c,8'h24,8'h00,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h04,8'h00,8'h24,8'h04,8'h24,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h04,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h6c,8'h70,8'h6c,8'h04,8'h04,8'h24,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h6c,8'h6c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h00,8'h70,8'h6c,8'h6c,8'h70,8'h6c,8'h6c,8'h6c,8'h04,8'h6c,8'h04,8'h00,8'h6c,8'h04,8'h70,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h04,8'h6c,8'h6c,8'h00,8'h00,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h2c,8'h00,8'h24,8'h6c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h70,8'h6c,8'h00,8'h70,8'h70,8'h6c,8'h24,8'h6c,8'h04,8'h70,8'h6c,8'h6c,8'h04,8'h04,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h70,8'h6c,8'h04,8'h04,8'h04,8'h04,8'h6c,8'h04,8'h24,8'h00,8'h24,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h04,8'h24,8'h04,8'h04,8'h2c,8'h2c,8'h2c,8'h6c,8'h6c,8'h6c,8'h6c,8'h00,8'h00,8'h2c,8'h6c,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h6c,8'h24,8'h6c,8'h24,8'h8c,8'h00,8'h00,8'h00,8'h24,8'h6c,8'h24,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h20,8'h24,8'h24,8'h00,8'h20,8'h24,8'h00,8'h00,8'h00,8'h6c,8'h20,8'h6c,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h00,8'h6c,8'h00,8'h24,8'h24,8'h00,8'h00,8'h6c,8'h6c,8'h70,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h24,8'h00,8'h04,8'h00,8'h04,8'h00,8'h6c,8'h6c,8'h6c,8'h6c,8'h00,8'h00,8'h6c,8'h00,8'h04,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h6c,8'h70,8'h2c,8'h6c,8'h2c,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
	}};

 
//
// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'hFF;
		offsetX_collision <= 0;
      offsetY_collision <= 0;
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;
		hit_bad_patty_stage_2 <= 0;
		is_exploding_d <= 0;
			
	end
	else begin
		hit_bad_patty_stage_2 <= 0;
		is_exploding_d <= is_exploding;
		ded_point_rotten <= 0;
		if((!is_exploding) && is_exploding_d) begin
			flag <= 0;
		end
		if(load_game == 1) begin
			MazeBitMapMask  <=  MazeDefaultBitMapMask ;
		end
		else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		add_points <= 0;
		if (collision_Bubble_BadPatty && (MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] != 4'h0)) begin
				flag <= 1;
				// HIT 1: If Object is Healthy (State 2) -> Change to Damaged (State 1)
				if (MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] == 4'h2) begin
					MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] <= 4'h01;
					hit_bad_patty_stage_2 <= 1;
					offsetX_collision <= offsetX_MSB;
					offsetY_collision <= offsetY_MSB;
					
					// No points added yet, just a state change
				end
				
				// HIT 2: If Object is Damaged (State 1) -> Destroy it (State 0)
				else if ((MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] == 4'h1) && (flag == 0)) begin
					MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB] <= 4'h00;
					ded_point_rotten <= 1;
				end
		end		
		
		//if rotten isn't 0 then there was a hit and there was at least 1 healthy burger. where there was one, replace with rotten.
		if(rotten[level_sel] != 0) begin
			
					if(rotten[level_sel][0]) begin
						MazeBitMapMask[level_sel][offsetY_collision-1][offsetX_collision-1] <= 4'h02;
					
					end
					if(rotten[level_sel][1]) begin
						MazeBitMapMask[level_sel][offsetY_collision-1][offsetX_collision]<= 4'h02;
						
					end
					if(rotten[level_sel][2]) begin
						MazeBitMapMask[level_sel][offsetY_collision-1][offsetX_collision+1]<= 4'h02;
						
					end
					if(rotten[level_sel][3]) begin
						MazeBitMapMask[level_sel][offsetY_collision][offsetX_collision+1]<= 4'h02;
						 
					end
					if(rotten[level_sel][4]) begin
						MazeBitMapMask[level_sel][offsetY_collision+1][offsetX_collision+1]<= 4'h02;
						
					end
					if(rotten[level_sel][5]) begin
						MazeBitMapMask[level_sel][offsetY_collision+1][offsetX_collision]<= 4'h02;
			
					end
					if(rotten[level_sel][6]) begin
						MazeBitMapMask[level_sel][offsetY_collision+1][offsetX_collision-1]<= 4'h02;
			
					end
					if(rotten[level_sel][7]) begin
						MazeBitMapMask[level_sel][offsetY_collision][offsetX_collision-1]<= 4'h02;
					
					end
		end	
		
		if (InsideRectangle == 1'b1 )	
			begin 
		   	case (MazeBitMapMask[level_sel][offsetY_MSB][offsetX_MSB])
					
					// State 2: Healthy 
					4'h2 : RGBout <= object_colors[1][offsetY_LSB][offsetX_LSB];
					
					// State 1: Damaged 
					4'h1 : RGBout <= object_colors[0][offsetY_LSB][offsetX_LSB];
					
					// State 0 Transparent
					default: RGBout <= TRANSPARENT_ENCODING; 
				endcase
			end 
		end 
	end
end
//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; 
endmodule

