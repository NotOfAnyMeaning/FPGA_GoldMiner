
// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	updated_objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					input		logic	game_mode, //decides which objects to display, game objects or shop objects
					input		logic wait_mode,
		   // bubble 
					input		logic	bubbleDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] bubbleRGB,
					     
		  //text inputs
					input		logic text_DR,
					input		logic [7:0] RGB_text,
		  //square object
		  
					
					input 	logic boxDrawingRequest_L,
					input 	logic [7:0]boxRGB_L,
					input 	logic boxDrawingRequest_H,
					input 	logic [7:0]boxRGB_H,
					input		logic LnumberDrawingRequest,
					input		logic [7:0] RGBLDigit,
					input		logic HnumberDrawingRequest,
					input		logic [7:0] RGBHDigit,
			
			// Shop Objects
					input logic HandDrawingRequest,
					input logic [7:0] HandRGB,
					input logic Item1DrawingRequest,
					input logic [7:0] Item1RGB,
					input logic Item2DrawingRequest,
					input logic [7:0] Item2RGB,
					input logic Item3DrawingRequest,
					input logic [7:0] Item3RGB,
					input logic Exit_Sign_DrawingRequest,
					input logic [7:0] Exit_Sign_RGB,
					input logic mr_krab_DR,
					input logic [7:0] RGB_mr_krab,
					input logic shelvesDR,
					input logic [7:0] shelvesRGB,

					
			  
		  ////////////////////////
		  //  
					
					
					
					input    logic BurgerDrawingRequest, //burgers
					input		logic	[7:0] burgerRGB,
					input		logic BadPattyDR,
					input		logic [7:0] BadPattyRGB,
					
					input    logic JellyfishDrawingRequest, //jellyfish
					input		logic	[7:0] JellyfishRGB,						
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] RGB_MIF, 
				    output	logic	[7:0] RGBOut,
					output	logic [7:0] RGB_out_final,
					
			/////////////////////////
			//cur_points_display
					//outputs for units
					input      logic [7:0]  RGBout_box_units,
					input      logic        drawingRequest_box_units,
					input      logic        digit_units_DR,
					input      logic [7:0]  RGBout_digit_units,
    
					//outputs for tens
					input      logic [7:0]  RGBout_box_tens,
					input      logic        drawingRequest_box_tens,
					input      logic        digit_tens_DR,
					input      logic [7:0]  RGBout_digit_tens,
    
					//outputs for hundreds
					input      logic [7:0]  RGBout_box_hundrends,
					input      logic        drawingRequest_box_hundrends,
					input      logic        digit_hundrends_DR,
					input      logic [7:0]  RGBout_digit_hundrends,
    
					//outputs for thousands
					input      logic [7:0]  RGBout_box_thousands,
					input      logic        drawingRequest_box_thousands,
					input      logic        digit_thousands_DR,
					input      logic [7:0]  RGBout_digit_thousands,
					
					
					// goal score display
					input		  logic			goal_units_DR,
					input		  logic [7:0]  RGB_goal_units,
					input		  logic			goal_tens_DR,
					input		  logic [7:0]  RGB_goal_tens,
					input		  logic			goal_hundrends_DR,
					input		  logic [7:0]  RGB_goal_hundrends,
					input		  logic			goal_slash_DR,
					input		  logic [7:0]  RGB_goal_slash,
					
					
			
			
		//////////shop_curr_balance display
					//outputs for units
					
					input      logic        shop_digit_units_DR,
					input      logic [7:0]  shop_RGBout_digit_units,
    
					//outputs for tens
					
					input      logic        shop_digit_tens_DR,
					input      logic [7:0]  shop_RGBout_digit_tens,
    
					//outputs for hundreds
					
					input      logic        shop_digit_hundrends_DR,
					input      logic [7:0]  shop_RGBout_digit_hundrends,
    
					//outputs for thousands
					
					input      logic        shop_digit_thousands_DR,
					input      logic [7:0]  shop_RGBout_digit_thousands,
				
				//////prices display
				
					input		  logic			item1_price_units_DR,
					input		  logic [7:0]	RGB_item1_price_units,
					input		  logic			item1_price_tens_DR,
					input		  logic [7:0]	RGB_item1_price_tens,
					input		  logic			item2_price_units_DR,
					input		  logic [7:0]	RGB_item2_price_units,
					input		  logic			item2_price_tens_DR,
					input		  logic [7:0]	RGB_item2_price_tens,
					input		  logic			item3_price_units_DR,
					input		  logic [7:0]	RGB_item3_price_units,
					input		  logic			item3_price_tens_DR,
					input		  logic [7:0]	RGB_item3_price_tens,
			
			//inputs for darkness
					input		  logic [1:0] in_radius,
					input		  logic [2:0] level_sel
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if ( wait_mode ) begin
			if ( text_DR ) begin
					RGBOut <= RGB_text;
			end
			else if ( BGDrawingRequest )
					RGBOut <= backGroundRGB ;
			else RGBOut <= RGB_MIF ;				
		end
		
		else if(game_mode) begin  // wrapper condition for displaying the game
			 
			 if ( bubbleDrawingRequest == 1'b1 )
				RGBOut <= bubbleRGB; 
	//--- add logic for box here ------------------------------------------------------		
			else if(level_sel == 3'b10 && in_radius != 2'b01) begin //the drakness level
						//outside the radius
//						if(in_radius == 2'b00) begin
//							//display the goal score
//							if (goal_units_DR) begin
//								RGBOut <= RGB_goal_units;
//							end
//							else if (goal_tens_DR) begin
//								RGBOut <= RGB_goal_tens;
//							end
//							else if (goal_hundrends_DR) begin
//								RGBOut <= RGB_goal_hundrends;
//							end
//							else if (goal_slash_DR) begin
//								RGBOut <= RGB_goal_slash;
//							end
//							//display the current score
//							else if (digit_units_DR) begin
//										RGBOut <= RGBout_digit_units;
//									end	
//				
//							else if (digit_tens_DR) begin
//										RGBOut <= RGBout_digit_tens;
//									end	
//				
//							else if (digit_hundrends_DR) begin
//										RGBOut <= RGBout_digit_hundrends;
//									end	
//				
//							else if (digit_thousands_DR) begin
//										RGBOut <= RGBout_digit_thousands;
//									end
//							//display the timer
//							else if(LnumberDrawingRequest == 1'b1 ) begin
//										RGBOut <= RGBLDigit;
//								  end 
//				
//							else if(HnumberDrawingRequest == 1'b1 ) begin
//										RGBOut <= RGBHDigit;
//									end 
//							else begin
//								RGBOut <= 8'h00;
//							end
//						end 
						
						
						
						
						//in the most outer radius
//						else if(in_radius == 2'b11) begin
//							RGBOut <= 8'hE0;
//							//RGBOut[1:0] = RGBin[1:0] >> 1; DO NOT IGNORE!!!!!!!!!!!!!!
//						end
//						//in the middle radius
//						else if(in_radius == 2'b10) begin
//							RGBOut <= 8'hFC;
//						end
			end
			
			else if(LnumberDrawingRequest == 1'b1 ) begin
						RGBOut <= RGBLDigit;
				  end 

			else if(HnumberDrawingRequest == 1'b1 ) begin
						RGBOut <= RGBHDigit;
					end 

			else if (digit_units_DR) begin
						RGBOut <= RGBout_digit_units;
					end	

			else if (digit_tens_DR) begin
						RGBOut <= RGBout_digit_tens;
					end	

			else if (digit_hundrends_DR) begin
						RGBOut <= RGBout_digit_hundrends;
					end	

			else if (digit_thousands_DR) begin
						RGBOut <= RGBout_digit_thousands;
					end	
		
			else if (goal_units_DR) begin
						RGBOut <= RGB_goal_units;
					end
			else if (goal_tens_DR) begin
						RGBOut <= RGB_goal_tens;
					end
			else if (goal_hundrends_DR) begin
						RGBOut <= RGB_goal_hundrends;
					end
			else if (goal_slash_DR) begin
						RGBOut <= RGB_goal_slash;
					end

			else if (BurgerDrawingRequest == 1'b1)
					RGBOut <= burgerRGB;
			else if ( BadPattyDR )
					RGBOut <= BadPattyRGB;
			else if (JellyfishDrawingRequest == 1'b1)
					RGBOut <= JellyfishRGB;		
			else if (BGDrawingRequest == 1'b1)
					RGBOut <= backGroundRGB ;
			else RGBOut <= RGB_MIF ;// last priority 
		end
		
		//-------SHOP PRIORITIES----------
		
		else begin  //shop related DR
			if( HandDrawingRequest )
				RGBOut <= HandRGB;
			// shop balance
			else if( shop_digit_units_DR )
				RGBOut <= shop_RGBout_digit_units;
			else if( shop_digit_tens_DR )
				RGBOut <= shop_RGBout_digit_tens;
			else if( shop_digit_hundrends_DR )
				RGBOut <= shop_RGBout_digit_hundrends;
			else if( shop_digit_thousands_DR )
				RGBOut <= shop_RGBout_digit_thousands;	
			// prices display
			else if( item1_price_units_DR )
				RGBOut <= RGB_item1_price_units;
			else if( item1_price_tens_DR )
				RGBOut <= RGB_item1_price_tens;
			else if( item2_price_units_DR )
				RGBOut <= RGB_item2_price_units;
			else if( item2_price_tens_DR )
				RGBOut <= RGB_item2_price_tens;	
			else if( item3_price_units_DR )
				RGBOut <= RGB_item3_price_units;
			else if( item3_price_tens_DR )
				RGBOut <= RGB_item3_price_tens;
			
			
			//
			else if( Item1DrawingRequest )
				RGBOut <= Item1RGB;
			else if ( Item2DrawingRequest )
				RGBOut <= Item2RGB;
			else if ( Item3DrawingRequest )
				RGBOut <= Item3RGB;
			else if ( Exit_Sign_DrawingRequest )
				RGBOut <= Exit_Sign_RGB;
			else if ( mr_krab_DR )
				RGBOut <= RGB_mr_krab;
			else if ( shelvesDR )
				RGBOut <= shelvesRGB;
			else if ( BGDrawingRequest )
					RGBOut <= backGroundRGB ;
			else RGBOut <= RGB_MIF ;		
		end
	end
end
always_comb begin
	RGB_out_final = RGBOut;
	if(level_sel == 3'b10 && !wait_mode) begin
	//if outside of the radius
		 if(in_radius == 0) begin
				
				
				//display the goal score
							if (goal_units_DR) begin
								RGB_out_final = RGB_goal_units;
							end
							else if (goal_tens_DR) begin
								RGB_out_final = RGB_goal_tens;
							end
							else if (goal_hundrends_DR) begin
								RGB_out_final = RGB_goal_hundrends;
							end
							else if (goal_slash_DR) begin
								RGB_out_final = RGB_goal_slash;
							end
							
							
				//display the current score
							else if (digit_units_DR) begin
										RGB_out_final = RGBout_digit_units;
									end	
				
							else if (digit_tens_DR) begin
										RGB_out_final = RGBout_digit_tens;
									end	
				
							else if (digit_hundrends_DR) begin
										RGB_out_final = RGBout_digit_hundrends;
									end	
				
							else if (digit_thousands_DR) begin
										RGB_out_final = RGBout_digit_thousands;
									end
							
							
				//display the timer
							else if(LnumberDrawingRequest == 1'b1 ) begin
										RGB_out_final = RGBLDigit;
								  end 
				
							else if(HnumberDrawingRequest == 1'b1 ) begin
										RGB_out_final = RGBHDigit;
									end 
							else begin
								RGB_out_final = 8'h00;
							end 
		 end
		 else if(in_radius == 2'b11) begin
			  RGB_out_final[1:0] = RGBOut[1:0] >> 2;
			  RGB_out_final[4:2] = RGBOut[4:2] >> 2;
			  RGB_out_final[7:5] = RGBOut[7:5] >> 2;
		 end
		 else if(in_radius == 2'b10) begin
			  RGB_out_final[1:0] = RGBOut[1:0] >> 1;
			  RGB_out_final[4:2] = RGBOut[4:2] >> 1;
			  RGB_out_final[7:5] = RGBOut[7:5] >> 1;
		 end
		 else begin
			  RGB_out_final = RGBOut;
		 end
	end
	else begin 
		RGB_out_final = RGBOut;
	end
end

endmodule


