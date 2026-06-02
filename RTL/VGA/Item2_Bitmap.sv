// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	Item2_Bitmap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic Item2_bought,  //input that comes from the shop SM	

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
//				   output   logic	[2:0] HitEdgeCode 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 
localparam  int OBJECT_NUMBER_OF_X_BITS = 6;  // uptated to match item , need to check


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

 //logic	[10:0] HitCodeX ;// offset of Hitcode 
 //logic	[10:0] HitCodeY ; 
//assign HitCodeX = offsetX >> ( OBJECT_NUMBER_OF_X_BITS - 4 );	// hitedge code MSB of the offset
//assign HitCodeY = offsetY >> ( OBJECT_NUMBER_OF_Y_BITS - 4 );	 	 

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

//localparam  int OBJECT_NUMBER_OF_Y_BITS =63;  
//localparam  int OBJECT_NUMBER_OF_X_BITS =127;  
 
 
logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h64,8'hb5,8'hb1,8'h6c,8'hd5,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hd5,8'hb5,8'h91,8'h8c,8'h8c,8'h8c,8'hac,8'hcc,8'hac,8'hac,8'h64,8'hf4,8'hd0,8'hac,8'hac,8'h8c,8'h8c,8'h8c,8'h64,8'h64,8'h6c,8'h64,8'h64,8'h64,8'h8c,8'h8c,8'h8c,8'h84,8'h64,8'h8c,8'hac,8'hac,8'hac,8'hd0,8'h64,8'hb5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h84,8'h84,8'hf4,8'hf4,8'hf0,8'hf0,8'hf0,8'hd0,8'hf4,8'hf4,8'hf4,8'hf0,8'hf0,8'hf4,8'hd0,8'hf4,8'hf4,8'hf4,8'hf8,8'hf8,8'hf4,8'hf4,8'hf4,8'h8c,8'hf9,8'hf4,8'hf4,8'hf4,8'hf4,8'hf0,8'hd0,8'hd0,8'hcc,8'hac,8'hcc,8'hd0,8'hd0,8'hd0,8'hd0,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf0,8'hf4,8'h64,8'hf4,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb5,8'h64,8'h8c,8'h64,8'hd0,8'h84,8'h84,8'h84,8'h64,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h64,8'h64,8'h64,8'h64,8'h64,8'h20,8'h8c,8'h64,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h24,8'h24,8'h24,8'h24,8'h64,8'h6c,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h8c,8'h64,8'hf4,8'hac,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h84,8'hf4,8'h64,8'h24,8'h24,8'h70,8'h6d,8'h91,8'h91,8'hd9,8'hfe,8'hd9,8'hf9,8'hb9,8'hd9,8'h91,8'h91,8'h91,8'h91,8'hb1,8'h91,8'h91,8'h70,8'h70,8'h6c,8'h6c,8'h6c,8'h95,8'hb5,8'h95,8'hb9,8'hb5,8'hb5,8'hb5,8'hb5,8'h91,8'h91,8'h90,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h8c,8'hac,8'hac,8'hac,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'hac,8'hf4,8'h64,8'hfe,8'hfe,8'hfd,8'hd9,8'hd9,8'hd9,8'hd9,8'hd9,8'hfd,8'hfe,8'hfe,8'hfe,8'hdd,8'hde,8'hd9,8'hde,8'hd9,8'hd9,8'hfe,8'hfa,8'hda,8'hd9,8'hb9,8'hd9,8'hfe,8'hd9,8'hda,8'hd9,8'hb5,8'hd9,8'hd9,8'hd9,8'hfe,8'hfa,8'hfd,8'hfe,8'hd9,8'hb5,8'h91,8'h24,8'h64,8'hac,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'hac,8'hf8,8'h8c,8'hd9,8'hfd,8'hdd,8'hfe,8'hf9,8'hfd,8'hd9,8'hd9,8'hb5,8'hfe,8'hfe,8'hd9,8'hf9,8'hfe,8'hfe,8'hfe,8'hfd,8'hda,8'hd9,8'hd9,8'hb5,8'hd9,8'hd5,8'hb9,8'hfd,8'hfe,8'hd9,8'hd9,8'hd9,8'hfa,8'hfe,8'hf9,8'hd9,8'hde,8'hfe,8'hfe,8'hfd,8'hfe,8'hde,8'h6c,8'h6c,8'hac,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hac,8'hf8,8'h90,8'hd5,8'hd9,8'hd9,8'hd9,8'hda,8'hd9,8'hd9,8'hd9,8'hd9,8'hfd,8'hfe,8'hfa,8'hda,8'hfe,8'hfd,8'hfe,8'hfe,8'hfe,8'hfa,8'hfd,8'hfd,8'hfe,8'hfe,8'hfe,8'hfd,8'hb9,8'hb5,8'hb5,8'hd5,8'hfd,8'hfe,8'hfe,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hd9,8'hde,8'h91,8'h8c,8'ha4,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hac,8'hf8,8'hb1,8'hde,8'hfa,8'hde,8'hd9,8'hdd,8'hd9,8'hd9,8'hf9,8'hd5,8'hfe,8'hfe,8'hfe,8'hdd,8'hfe,8'hd9,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hf9,8'hfd,8'hfe,8'hfe,8'hfe,8'hfa,8'hfe,8'hfe,8'hd9,8'hda,8'hfe,8'hfd,8'hfd,8'hfe,8'hfe,8'hfd,8'hd9,8'hfa,8'hfe,8'h6c,8'h90,8'hac,8'hd0,8'h84,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'hac,8'hf8,8'h90,8'hfd,8'hfd,8'hda,8'hba,8'hfa,8'hd9,8'hfe,8'h6c,8'hbd,8'hdd,8'hdd,8'hbd,8'hdd,8'hbd,8'hbd,8'hbd,8'hbd,8'hbd,8'hbd,8'hbd,8'h99,8'h99,8'h99,8'hbd,8'hdd,8'hdd,8'h99,8'h99,8'h99,8'h9d,8'h9d,8'h9d,8'hfe,8'hde,8'hfe,8'hfe,8'hd9,8'hd9,8'hb5,8'h91,8'h8c,8'hac,8'hd0,8'h84,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hac,8'hf8,8'h90,8'hfe,8'hd9,8'hd9,8'hd9,8'hda,8'hd9,8'hfe,8'h70,8'h74,8'h94,8'h94,8'h99,8'hdd,8'hdd,8'hdd,8'hdd,8'hdd,8'hdd,8'hb9,8'h70,8'h74,8'h9d,8'hdd,8'hdd,8'hdd,8'hdd,8'hdd,8'hbd,8'hbd,8'h95,8'h74,8'h9d,8'hda,8'hfe,8'hfe,8'hfe,8'hda,8'hfa,8'hd9,8'h71,8'h64,8'h84,8'hf4,8'hac,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hac,8'hf4,8'h8c,8'hfe,8'hdd,8'hfd,8'hda,8'hd9,8'hd9,8'hd9,8'h74,8'h99,8'h99,8'h30,8'h70,8'h70,8'hb9,8'hdd,8'hdd,8'hbd,8'h95,8'h98,8'h70,8'hb9,8'h74,8'h70,8'hbd,8'hdd,8'h70,8'h74,8'h70,8'h74,8'h9d,8'h99,8'hdd,8'hd9,8'hde,8'hfe,8'hd9,8'hb9,8'hda,8'hd9,8'h6c,8'h8c,8'hac,8'hd0,8'hac,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd9,8'h84,8'hcc,8'hf4,8'hd4,8'hfd,8'hfd,8'hfe,8'hf9,8'hb9,8'hd9,8'hfe,8'h2c,8'h78,8'hbd,8'h30,8'h70,8'h70,8'hbd,8'hdd,8'hdd,8'h95,8'hdd,8'hdd,8'hdd,8'hdd,8'h99,8'h70,8'h74,8'hdd,8'h30,8'h70,8'h70,8'h9d,8'h9d,8'h9d,8'hbd,8'hd9,8'hd9,8'hfe,8'hd9,8'hfe,8'hde,8'hd5,8'h6c,8'h6c,8'hac,8'hd0,8'hd0,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h8c,8'hf0,8'hf8,8'hf4,8'hdd,8'hd9,8'hd9,8'hd9,8'hb5,8'hb9,8'hd9,8'h2c,8'h98,8'h99,8'h30,8'h70,8'h70,8'h70,8'hdd,8'hdd,8'h95,8'h74,8'hdd,8'hdd,8'hbd,8'hbd,8'h95,8'h95,8'hdd,8'hbd,8'h74,8'h30,8'h70,8'h99,8'h9d,8'hbd,8'hda,8'hde,8'hfe,8'hfe,8'hfe,8'hd9,8'hfe,8'h6c,8'h20,8'hb0,8'hf8,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h8c,8'hac,8'hf8,8'h84,8'hfe,8'hfe,8'hfe,8'hda,8'hd9,8'hb5,8'hd9,8'h6c,8'hbd,8'h9d,8'h99,8'h70,8'h70,8'hbd,8'hdd,8'hfd,8'h95,8'h95,8'h70,8'h95,8'hb9,8'h71,8'h74,8'h70,8'hbd,8'hdd,8'h70,8'h94,8'h9d,8'h9d,8'h9d,8'hbd,8'hfe,8'hfe,8'hfe,8'hd9,8'hdd,8'hb9,8'hd9,8'h70,8'h64,8'h84,8'hac,8'hac,8'hd9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'h6c,8'hac,8'hf8,8'h64,8'hfe,8'hfe,8'hfd,8'hd9,8'hfe,8'hd9,8'hfe,8'h2c,8'hdd,8'h9d,8'hbd,8'hbd,8'hbd,8'hdd,8'hbd,8'hdd,8'hdd,8'h74,8'h95,8'h95,8'h95,8'h74,8'h2c,8'hbd,8'hbd,8'hdd,8'hdd,8'hdd,8'hdd,8'hdd,8'h9d,8'h9d,8'hfa,8'hd9,8'hfe,8'hd9,8'hfe,8'hd9,8'hfe,8'h71,8'h64,8'h84,8'hac,8'hac,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h90,8'hac,8'hf8,8'h8c,8'hde,8'hf9,8'hda,8'hf9,8'hdd,8'hd9,8'hfe,8'h6c,8'hbd,8'h94,8'h98,8'hdd,8'hbd,8'hbd,8'hdd,8'hdd,8'h95,8'h94,8'h94,8'h74,8'h70,8'h70,8'h30,8'h74,8'hdd,8'hdd,8'hdd,8'hdd,8'hbd,8'h94,8'h94,8'hdd,8'hde,8'hd9,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h90,8'h64,8'h84,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h8c,8'hf8,8'h8c,8'hfd,8'hfe,8'hfe,8'hfe,8'hfe,8'hd9,8'hfd,8'h6c,8'h70,8'h70,8'h95,8'h95,8'h70,8'h70,8'h6c,8'h70,8'h90,8'h94,8'h74,8'h70,8'h70,8'h94,8'h70,8'h70,8'h70,8'h70,8'h95,8'h70,8'h6c,8'h94,8'h94,8'h95,8'hd9,8'hfe,8'hfe,8'hf9,8'hd9,8'hd9,8'hfe,8'hb5,8'h6c,8'h8c,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h8c,8'hf4,8'hac,8'hd9,8'hfe,8'hd9,8'hda,8'hfa,8'hd9,8'hde,8'hfe,8'hfe,8'hfd,8'hfe,8'hfe,8'hd9,8'hfe,8'hdd,8'hfe,8'hfe,8'hfa,8'hd9,8'hf9,8'hd9,8'hb5,8'hda,8'hfd,8'hfe,8'hfe,8'hfe,8'hfd,8'hfe,8'hd9,8'hd9,8'hfe,8'hda,8'hfa,8'hfd,8'hd9,8'hd9,8'hfe,8'hd9,8'h91,8'h6c,8'h84,8'hd0,8'h84,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h8c,8'hf4,8'hd0,8'hfe,8'hfe,8'hfe,8'hf9,8'hd9,8'hd9,8'hfe,8'hfe,8'hfe,8'hda,8'hdd,8'hd9,8'hd9,8'hfe,8'hfa,8'hf9,8'hd9,8'hd9,8'hda,8'hfa,8'hda,8'hfe,8'hdd,8'hda,8'hfe,8'hd9,8'hfe,8'hd9,8'hfe,8'hfe,8'hfe,8'hfd,8'hd9,8'hd9,8'hd9,8'hd9,8'hd9,8'hfe,8'hfe,8'h90,8'h6c,8'hac,8'hd0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h64,8'hd0,8'hd0,8'hb4,8'hfd,8'hfe,8'hfe,8'hfe,8'hf9,8'hfe,8'hdd,8'hfe,8'hfd,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hde,8'hd9,8'hd9,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hde,8'hfe,8'hfe,8'hd9,8'hda,8'hd9,8'hfa,8'hfe,8'hfe,8'hd9,8'hb5,8'hd9,8'hdd,8'h91,8'h6c,8'h84,8'hd4,8'h84,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h64,8'hcc,8'hf4,8'h8c,8'hfe,8'hfe,8'hdd,8'hb9,8'hd9,8'hfe,8'hfd,8'hfe,8'hd9,8'hde,8'hda,8'hda,8'hda,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hd9,8'hfa,8'hfe,8'hfe,8'hfe,8'hda,8'hfe,8'hb5,8'hd9,8'hf9,8'hfa,8'hfe,8'hfd,8'hf9,8'hdd,8'hfd,8'hfe,8'h71,8'h64,8'h84,8'hf4,8'h8c,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h64,8'hac,8'hf8,8'hb0,8'hfd,8'hdd,8'hd9,8'hd9,8'hd9,8'hde,8'hfe,8'hfe,8'hd9,8'hd9,8'hda,8'hb5,8'hb5,8'hda,8'hda,8'hfa,8'hf9,8'hd9,8'hd9,8'hda,8'hfe,8'hdd,8'hde,8'hfe,8'hfe,8'hfa,8'hd5,8'hfe,8'hfe,8'hfe,8'hfe,8'hd9,8'hd9,8'hb9,8'hd9,8'hd9,8'hfd,8'hd9,8'h6c,8'h64,8'h8c,8'hd0,8'h8c,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h60,8'h84,8'h64,8'hf4,8'hf4,8'hd0,8'hac,8'hac,8'hd0,8'hd0,8'hd0,8'hac,8'h8c,8'h8c,8'h64,8'hac,8'hd0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hd0,8'h64,8'hf4,8'hf4,8'hd0,8'hd0,8'hd0,8'hd0,8'hd0,8'hac,8'h84,8'h64,8'h84,8'h84,8'hac,8'hd0,8'hd0,8'hd0,8'hd0,8'hac,8'hf4,8'h64,8'h8c,8'hac,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'h6c,8'h24,8'h20,8'hd0,8'hd0,8'hd0,8'hb0,8'hb0,8'hac,8'hac,8'hac,8'h8c,8'hac,8'hac,8'hac,8'hac,8'hb0,8'hd0,8'hf0,8'hd0,8'h71,8'h91,8'h91,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h95,8'hb0,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h8c,8'h8c,8'h84,8'h60,8'hb0,8'h20,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h20,8'h64,8'h64,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h64,8'h24,8'h6c,8'h20,8'h84,8'h64,8'h64,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h6c,8'h6c,8'h6c,8'h24,8'h20,8'h24,8'h24,8'h6c,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one encoding per edge:  hit_colors[2:0] =   
 
//logic [0:15] [0:15] [2:0] hit_colors = 
//		  {48'o4433333333333344,     
//			48'o4443333333333444,    
//			48'o1444333333334442, 
//			48'o1144433333344422,
//			48'o1114443333444222,
//			48'o1111444334442222,
//			48'o1111144444422222,
//			48'o1111114444222222,
//			48'o1111114444222222,
//			48'o1111144444422222,
//			48'o1111444004442222,
//			48'o1114440000444222,
//			48'o1144400000044422,
//			48'o1444000000004442,
//			48'o4440000000000444,
//			48'o4400000000000044};
 
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		//HitEdgeCode <= 3'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		//HitEdgeCode <= 3'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];
			//HitEdgeCode <= hit_colors[HitCodeY][HitCodeX];	//get hitting edge code from the colors table  
		
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING) && !Item2_bought) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
// 
endmodule