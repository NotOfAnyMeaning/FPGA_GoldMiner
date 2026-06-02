// (c) Technion IIT, Department of Electrical Engineering 2022 
// Written By Liat Schwartz August 2018 
// Updated by Mor Dahan - January 2022

// Implements a BCD down counter 99 down to 0 with several enable inputs and loadN data
// having countL, countH and tc outputs
// by instantiating two one bit down-counters


module bcddn_bubble
	(
	input  logic clk, 
	input  logic resetN, 
	input  logic loadN, 
	input  logic enable1, 
	input  logic enable2,
	input  logic [7:0] datain,
	
	output logic [3:0] countL, 
	output logic [3:0] countH,
	output logic tc,
	output logic tc_const_1,
	output logic tcd_1,
	output logic tclow_1,
	output logic tchigh_1
   );

// -----------------------------------------------------------
	
	logic  tclow, tchigh;
	logic	[3:0] datainL, datainH;// internal variables terminal count
	logic tcd;
	logic tc_const;
	
// Low counter instantiation
	down_counter lowc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable1(enable1), 
							.enable2(enable2),
							.enable3(1'b1), 	
							.datain(datainL), 
							.count(countL), 
							.tc(tclow) );
	
// High counter instantiation
	down_counter highc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable1(enable1), 
							.enable2(enable2),
							.enable3(tclow), 	
							.datain(datainH), 
							.count(countH), 
							.tc(tchigh) );
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  fill your code and paste to the report #2 
//--------------------------------------------------------------------------------------------------------------------			
 assign datainL = datain % 10;
 assign datainH = datain / 10;
 //assign countH = 4'h0 ; //  ## initializing a variable to enable compilation, change if needed 
assign tc_const = (tchigh && tclow);
//------------------------------------------------------------------------------------------ 
 
always_ff @(posedge clk or negedge resetN) begin
	if(!resetN) begin
		tcd <= 0;
	end
	else begin
		tcd <= tc_const;
	end			
end

assign tc = (tc_const && !tcd);
assign tcd_1 = tcd;
assign tc_const_1 = tc_const;
assign tclow_1 = tclow;
assign tchigh_1 = tchigh;
endmodule



