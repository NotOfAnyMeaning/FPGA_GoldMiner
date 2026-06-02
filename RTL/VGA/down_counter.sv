// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9 down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1,
	input logic enable2, 
	input logic enable3, 
	input logic [3:0] datain,
	
	output logic [3:0] count,
	output logic tc
   );

// Down counter
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'h0;
			
		end
				
      else 	begin		// Synchronic logic	
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  fill your code and paste to the report #1 
//--------------------------------------------------------------------------------------------------------------------			
	//count <= 4'h0; //## initializing a variable to enable compilation, change if needed 
			if( !loadN ) begin
				count <= datain;
			end
			else if( enable1 && enable2 && enable3) begin
				if( count == 0 ) begin
					count <= 'h9;
				end else begin
						count <= count - 'h1;
						end
					end
					
		end //Synch
	end //alwaysx

	
	// Asynchronic tc

	assign tc =  (count==0); //## initializing a variable to enable compilation, change if needed 
	

//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of fill to the report #1 
//--------------------------------------------------------------------------------------------------------------------			
	
endmodule
