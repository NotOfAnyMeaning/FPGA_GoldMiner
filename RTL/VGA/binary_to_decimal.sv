//this moudle can get a binary number with up to 10 bits and outputs up to 4 decimal numbers
module binary_to_decimal (
    input       logic        resetN,
    input       logic        clk,
    input       logic [9:0]  binary_num,
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
    
    //outputs for thousands
    output      logic [7:0]  RGBout_box_thousands,
    output      logic        drawingRequest_box_thousands,
    output      logic        digit_thousands_DR,
    output      logic [7:0]  RGBout_digit_thousands
);

    //wires to compute the digits
    logic [3:0] units;
    logic [3:0] tens;
    logic [3:0] hundrends;
    logic [3:0] thousands;

    //outputs of square objects (offset wires)
    logic [10:0] offsetX_units;
    logic [10:0] offsetY_units;
    
    logic [10:0] offsetX_tens;
    logic [10:0] offsetY_tens;
    
    logic [10:0] offsetX_hundrends;
    logic [10:0] offsetY_hundrends;
    
    logic [10:0] offsetX_thousands;
    logic [10:0] offsetY_thousands;

    //position of units display
    parameter int topLeftX_units = 0;
    parameter int topLeftY_units = 0;
    
    //position of tens display
    parameter int topLeftX_tens = 0;
    parameter int topLeftY_tens = 0;
    
    //position of hundrends display
    parameter int topLeftX_hundrends = 0;
    parameter int topLeftY_hundrends = 0;
    
    //position of thousands display
    parameter int topLeftX_thousands = 0;
    parameter int topLeftY_thousands = 0;
    
    
//---------------UNITS----------------------------------------- 
    
    square_object #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16)) square_objects_units(
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
    

    NumbersBitMap_bob       NumbersBitMap_units(
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
    square_object   #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16))    square_objects_tens(
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

    NumbersBitMap_bob       NumbersBitMap_tens(
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

//---------------THOUSANDS-----------------------------------------     
    square_object    #(.OBJECT_WIDTH_X (16), .OBJECT_HEIGHT_Y (16))   square_objects_thousands(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .pixelX (pixelX),
        .pixelY (pixelY),
        .topLeftX (topLeftX_thousands), //parameter
        .topLeftY (topLeftY_thousands), //parameter
        
        //outputs
        .offsetX (offsetX_thousands),
        .offsetY (offsetY_thousands),
        .drawingRequest (drawingRequest_box_thousands),
        .RGBout (RGBout_box_thousands)
    );

    NumbersBitMap_bob       NumbersBitMap_thousands(
        //inputs
        .clk (clk),
        .resetN (resetN),
        .offsetX (offsetX_thousands),
        .offsetY (offsetY_thousands),
        .InsideRectangle (drawingRequest_box_thousands),
        .digit (thousands),
        //outputs
        .drawingRequest (digit_thousands_DR),
        .RGBout (RGBout_digit_thousands)
    );


    always_comb begin
        units = binary_num % 10;
        tens = (binary_num / 10) % 10;
        hundrends = (binary_num / 100) % 10;
        thousands = (binary_num / 1000) % 10;
    end

endmodule