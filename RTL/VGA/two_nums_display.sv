//this moudle can get a binary number with up to 10 bits and outputs up to 4 decimal numbers
module two_nums_display (
    input       logic        resetN,
    input       logic        clk,
    input       logic [6:0]  binary_num,
    input       logic signed [10:0] pixelX,
    input       logic signed [10:0] pixelY,
	 input		 logic Item_bought,

    //outputs for units
    output      logic [7:0]  RGBout_box_units,
    output      logic        drawingRequest_box_units,
    output      logic        digit_units_DR,
    output      logic [7:0]  RGBout_digit_units,
    
    //outputs for tens
    output      logic [7:0]  RGBout_box_tens,
    output      logic        drawingRequest_box_tens,
    output      logic        digit_tens_DR,
    output      logic [7:0]  RGBout_digit_tens
    
    
);

    //wires to compute the digits
    logic [3:0] units;
    logic [3:0] tens;
    

    //outputs of square objects (offset wires)
    logic [10:0] offsetX_units;
    logic [10:0] offsetY_units;
    
    logic [10:0] offsetX_tens;
    logic [10:0] offsetY_tens;
    //
	 logic digit_units_DR_raw;
	 logic digit_tens_DR_raw;
	 
   

    //position of units display
    parameter int topLeftX_units = 0;
    parameter int topLeftY_units = 0;
    
    //position of tens display
    parameter int topLeftX_tens = 0;
    parameter int topLeftY_tens = 0;
    
  
    
    
//---------------UNITS----------------------------------------- 
    
    square_object #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16)) //defines the parameters for this instance 
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
    

    NumbersBitMap_bob #(.digit_color(8'hB6)) //defines the color of the number
	 NumbersBitMap_units(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_units),
        .offsetY (offsetY_units),
        .InsideRectangle (drawingRequest_box_units),
        .digit (units),
        //outputs
        .drawingRequest (digit_units_DR_raw),
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

    NumbersBitMap_bob #(.digit_color(8'hB6))
	 NumbersBitMap_tens(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_tens),
        .offsetY (offsetY_tens),
        .InsideRectangle (drawingRequest_box_tens),
        .digit (tens),
        //outputs
        .drawingRequest (digit_tens_DR_raw),
        .RGBout (RGBout_digit_tens)
    );
        


    always_comb begin
        units = binary_num % 10;
        tens = (binary_num / 10) % 10;
        
    end
assign digit_units_DR = ( Item_bought ) ? 1'b0 : digit_units_DR_raw;
assign digit_tens_DR = ( Item_bought ) ? 1'b0 : digit_tens_DR_raw;


endmodule