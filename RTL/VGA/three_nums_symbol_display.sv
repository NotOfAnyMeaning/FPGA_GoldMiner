//this moudle can get a binary number with up to 10 bits and outputs up to 4 decimal numbers
module three_nums_symbol_display (
    input       logic        resetN,
    input       logic        clk,
    input       logic [6:0]  binary_num,
    input       logic signed [10:0] pixelX,
    input       logic signed [10:0] pixelY,
	 

    //outputs for units
    output      logic [7:0]  RGBout_box_units,
    output      logic        drawingRequest_box_units,
    output      logic        digit_units_DR,
    output      logic [7:0]  RGBout_digit_units,
    
    //outputs for tens
    output      logic [7:0]  RGBout_box_tens,
    output      logic        drawingRequest_box_tens,
    output      logic        digit_tens_DR,
    output      logic [7:0]  RGBout_digit_tens,
    //outputs for hundreds
    output      logic [7:0]  RGBout_box_hundrends,
    output      logic        drawingRequest_box_hundrends,
    output      logic        digit_hundrends_DR,
    output      logic [7:0]  RGBout_digit_hundrends,
	 // outputs for backslash
	 output      logic [7:0]  RGBout_box_slash,
    output      logic        drawingRequest_box_slash,
    output      logic        slash_DR,
    output      logic [7:0]  RGBout_slash
    
);

    //wires to compute the digits
    logic [3:0] units;
    logic [3:0] tens;
	 logic [3:0] hundrends;
    

    //outputs of square objects (offset wires)
    logic [10:0] offsetX_units;
    logic [10:0] offsetY_units;
    
    logic [10:0] offsetX_tens;
    logic [10:0] offsetY_tens;
    //
	 
	 logic [10:0] offsetX_hundrends;
    logic [10:0] offsetY_hundrends;
	 
	 logic [10:0] offsetX_slash;
    logic [10:0] offsetY_slash;
   

    //position of units display
    parameter int topLeftX_units = 0;
    parameter int topLeftY_units = 0;
    
    //position of tens display
    parameter int topLeftX_tens = 0;
    parameter int topLeftY_tens = 0;
    
	 //position of hundrends display
    parameter int topLeftX_hundrends = 0;
    parameter int topLeftY_hundrends = 0;
  
    //position of slash display
    parameter int topLeftX_slash = 0;
    parameter int topLeftY_slash = 0;
    
//---------------UNITS----------------------------------------- 
    
    square_object #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16) ) //defines the parameters for this instance 
	 square_objects_units(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .pixelX (pixelX),
        .pixelY (pixelY),
        .topLeftX (topLeftX_units), //parameter
        .topLeftY (topLeftY_units), //parameter
        
        //outputs
        .offsetX (offsetX_units),
        .offsetY (offsetY_units),
        .drawingRequest (drawingRequest_box_units),
        .RGBout (RGBout_box_units)
    );
    

    NumbersBitMap_bob  //defines the color of the number
	 NumbersBitMap_units(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_units),
        .offsetY (offsetY_units),
        .InsideRectangle (drawingRequest_box_units),
        .digit (units),
        //outputs
        .drawingRequest (digit_units_DR),
        .RGBout (RGBout_digit_units)
    );


//---------------TENS-----------------------------------------      
    square_object #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16))   
	 square_objects_tens(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .pixelX (pixelX),
        .pixelY (pixelY),
        .topLeftX (topLeftX_tens), //parameter
        .topLeftY (topLeftY_tens), //parameter

        
        //outputs
        .offsetX (offsetX_tens),
        .offsetY (offsetY_tens),
        .drawingRequest (drawingRequest_box_tens),
        .RGBout (RGBout_box_tens)
    );

    NumbersBitMap_bob 
	 NumbersBitMap_tens(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_tens),
        .offsetY (offsetY_tens),
        .InsideRectangle (drawingRequest_box_tens),
        .digit (tens),
		  
        //outputs
        .drawingRequest (digit_tens_DR),
        .RGBout (RGBout_digit_tens)
    );
        
//---------------HUNDRENDS-----------------------------------------     
    square_object   #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16))    square_objects_hundrends(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .pixelX (pixelX),
        .pixelY (pixelY),
        .topLeftX (topLeftX_hundrends), //parameter
        .topLeftY (topLeftY_hundrends), //parameter
        
        //outputs
        .offsetX (offsetX_hundrends),
        .offsetY (offsetY_hundrends),
        .drawingRequest (drawingRequest_box_hundrends),
        .RGBout (RGBout_box_hundrends)
    );

    NumbersBitMap_bob       NumbersBitMap_hundrends(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_hundrends),
        .offsetY (offsetY_hundrends),
        .InsideRectangle (drawingRequest_box_hundrends),
        .digit (hundrends),
		  
        //outputs
        .drawingRequest (digit_hundrends_DR),
        .RGBout (RGBout_digit_hundrends)
    );

//---------------SLASH----------------------------------------- 
       square_object   #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16))    square_objects_slash(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .pixelX (pixelX),
        .pixelY (pixelY),
        .topLeftX (topLeftX_slash), //parameter
        .topLeftY (topLeftY_slash), //parameter
        
        //outputs
        .offsetX (offsetX_slash),
        .offsetY (offsetY_slash),
        .drawingRequest (drawingRequest_box_slash),
        .RGBout (RGBout_box_slash)
    );

    NumbersBitMap_bob       NumbersBitMap_slash(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_slash),
        .offsetY (offsetY_slash),
        .InsideRectangle (drawingRequest_box_slash),
        .digit (7'd10),
		  
        //outputs
        .drawingRequest (slash_DR),
        .RGBout (RGBout_slash)
    );
    always_comb begin
        units = binary_num % 10;
        tens = (binary_num / 10) % 10;
        hundrends = (binary_num / 100) % 10;
    end



endmodule