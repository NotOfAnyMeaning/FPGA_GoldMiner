// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2025
// (c) Technion IIT, Department of Electrical Engineering 2025 



module	Item1_Bitmap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic Item1_bought,  //input that comes from the shop SM	

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
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hdb,8'hb6,8'hb6,8'h92,8'h92,8'h91,8'h6d,8'h6d,8'h6d,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h20,8'h20,8'h60,8'h60,8'h60,8'h60,8'h00,8'h90,8'h90,8'hb0,8'h24,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hb6,8'h92,8'h91,8'h6d,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h26,8'h66,8'h66,8'h66,8'h6e,8'h6f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h87,8'ha5,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'hc0,8'h20,8'hfc,8'hfc,8'hfc,8'hb4,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hdb,8'hb6,8'h91,8'h6d,8'h65,8'h25,8'h25,8'h25,8'h25,8'h25,8'h66,8'h66,8'h66,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha6,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h20,8'hd8,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h24,8'h6c,8'h90,8'hb4,8'hd4,8'h90,8'h00,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h86,8'hc1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h60,8'hb4,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6c,8'h24,8'hfc,8'hfc,8'hfc,8'hfc,8'hd8,8'h00,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h86,8'ha1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'h80,8'h90,8'hfc,8'hfc,8'hfc,8'h6c,8'hdb,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h90,8'hfc,8'h24,8'hd8,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'h6f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha5,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'ha0,8'h6c,8'hfc,8'hfc,8'hfc,8'h90,8'hb6,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h25,8'h90,8'hfc,8'hfc,8'h6c,8'hb0,8'hfc,8'hfc,8'hfc,8'hfc,8'h6c,8'h26,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha6,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'he0,8'he0,8'hc0,8'hc0,8'he0,8'he0,8'hc0,8'hc0,8'hc0,8'ha0,8'h64,8'hfc,8'hfc,8'hfc,8'hb4,8'h91,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hdb,8'h24,8'hfc,8'hf8,8'hf8,8'hb4,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'h25,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha6,8'hc1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h24,8'hfc,8'hfc,8'hfc,8'hd8,8'h6d,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hd8,8'hd8,8'hf8,8'hd8,8'h24,8'hfc,8'hfc,8'hfc,8'hfc,8'hd8,8'h00,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h86,8'ha1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h20,8'hd8,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hd8,8'hf8,8'hf8,8'hf8,8'h24,8'hd8,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha5,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'h20,8'hb9,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h90,8'hf8,8'hd8,8'hf8,8'h6c,8'hb4,8'hfc,8'hfc,8'hfc,8'hfc,8'h64,8'h66,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha5,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha5,8'haf,8'h21,8'hb4,8'hfc,8'hfc,8'hfc,8'h6c,8'hdb,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h6c,8'hf8,8'hd8,8'hf8,8'hb4,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'h90,8'h25,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha6,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'he0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc1,8'hae,8'h8f,8'h8f,8'h26,8'h90,8'hfc,8'hfc,8'hfc,8'h8c,8'hb6,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hd8,8'hd8,8'hf8,8'hd8,8'h24,8'hfc,8'hfc,8'hfc,8'hfc,8'hd8,8'h21,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'ha6,8'hc1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h66,8'h6c,8'hfc,8'hfc,8'hfc,8'h90,8'h92,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hb4,8'hf8,8'hd8,8'hf8,8'h24,8'hd8,8'hfc,8'hfc,8'hfc,8'hfc,8'h20,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h86,8'ha1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h66,8'h24,8'hfc,8'hfc,8'hfc,8'hb4,8'h6d,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h90,8'hf8,8'hd8,8'hfc,8'h6c,8'hb4,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'h6e,8'h8f,8'h8f,8'h8f,8'h86,8'ha1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha5,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h6f,8'h24,8'hfc,8'hfc,8'hfc,8'hd8,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h6c,8'hf8,8'hd8,8'hf8,8'hb4,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'h90,8'h26,8'h8f,8'h86,8'ha1,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc5,8'hae,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h20,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hd8,8'hf8,8'hf8,8'hd8,8'h24,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'h20,8'ha5,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h00,8'hd8,8'hfc,8'hfc,8'hfc,8'h24,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hb4,8'hf8,8'hf8,8'hf8,8'h6c,8'hd8,8'hfc,8'hfc,8'hfc,8'hfc,8'h20,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha5,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h01,8'hd8,8'hfc,8'hfc,8'hfc,8'h24,8'hdb,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h6c,8'hf8,8'hf8,8'hf8,8'h90,8'h90,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'ha0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha5,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h01,8'hb4,8'hfc,8'hfc,8'hfc,8'h6c,8'hdb,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'h24,8'hf8,8'hd8,8'hf8,8'hb4,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'h70,8'h60,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc1,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h21,8'hb4,8'hfc,8'hfc,8'hfc,8'h6c,8'hb6,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hd8,8'hf8,8'hd8,8'hd8,8'h24,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'h20,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h21,8'h90,8'hfc,8'hf8,8'hd4,8'h20,8'hb6,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb0,8'hf8,8'hd8,8'hf8,8'h6c,8'hd8,8'hfc,8'hfc,8'hfc,8'hfc,8'h20,8'ha0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h66,8'h66,8'h66,8'h26,8'h25,8'h25,8'h01,8'h00,8'h24,8'h6c,8'h00,8'h00,8'hb6,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb7,8'h6c,8'hf8,8'hd8,8'hf8,8'h90,8'h90,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'h80,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha6,8'h8f,8'h8f,8'h8f,8'h8f,8'h8f,8'h6f,8'h66,8'h66,8'h66,8'h66,8'h25,8'h25,8'h21,8'h21,8'h21,8'h21,8'h21,8'h25,8'h25,8'h25,8'h65,8'h21,8'h24,8'hb4,8'hd8,8'h24,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hd8,8'hd8,8'hd8,8'hb4,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'h90,8'h60,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'hc0,8'ha0,8'h80,8'h65,8'h25,8'h25,8'h25,8'h25,8'h21,8'h21,8'h21,8'h25,8'h25,8'h25,8'h25,8'h65,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h86,8'h8f,8'h6e,8'h25,8'h90,8'hf8,8'h90,8'h24,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'hb4,8'hf8,8'hd8,8'hd8,8'h24,8'hb4,8'hd8,8'hb4,8'hb4,8'h6c,8'h00,8'h60,8'h60,8'h60,8'h20,8'h20,8'h20,8'h21,8'h21,8'h25,8'h25,8'h65,8'h66,8'h66,8'h66,8'h66,8'h66,8'h6e,8'h6e,8'h6e,8'h8e,8'h8e,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h25,8'h00,8'h24,8'h90,8'h24,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h70,8'hfc,8'hf8,8'hb4,8'h00,8'h6c,8'h90,8'h90,8'h6c,8'h00,8'h25,8'h66,8'h66,8'h66,8'h6e,8'h6e,8'h6e,8'h6f,8'h6e,8'h6e,8'h6e,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h26,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h25,8'h65,8'h6d,8'h6d,8'h92,8'h92,8'hb6,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'hf8,8'h90,8'h24,8'hb4,8'hfc,8'hfc,8'hb0,8'h24,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h66,8'h25,8'h21,8'h25,8'h25,8'h25,8'h25,8'h65,8'h6d,8'h6d,8'h6d,8'h92,8'h92,8'hb6,8'hb6,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h00,8'h90,8'hb4,8'hb0,8'h6c,8'h00,8'h25,8'h25,8'h65,8'h6d,8'h6d,8'h92,8'h92,8'hb6,8'hb6,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'h6d,8'h92,8'hb6,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
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
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING)&&!Item1_bought ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
// && 
endmodule