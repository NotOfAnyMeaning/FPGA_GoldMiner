// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal MAR 2024
// good practice code - Dudy MAR 2025

module bubble_move (
	 
    input  logic        clk,
    input  logic        resetN,
    input  logic        startOfFrame,      // short pulse every start of frame 30Hz 
    input  logic        Y_direction_key,   // lunches the bubble     
    input  logic        collision,         // collision if bubble hits an object
    input  logic        timer_ended,       // 1 when the timer finished countdown
    input  logic [15:0] cos_angle,         
    input  logic [15:0] sin_angle,
	 input  logic [7:0]  rand_time_explosion,
	 input  logic 			bubble_borders_collision,
	 input  logic 			item1_bought,
	 input  logic 			cheat_key, 			//9 on the keyboard is used for instant explosion
    
	 
	 output logic [7:0]  angle_out,         
    output logic signed [10:0] topLeftX,   // output the top left corner 
    output logic signed [10:0] topLeftY,   // can be negative , if the object is partliy outside 
    output logic        timer_loadN,       // enables loading to the counter
    output logic [7:0]  timer_data,        // time to be loaded into the timer
    output logic        timer_enable,       // will be used to make sure the timer doesn't start while in idle or aim 
	 output logic			idle_state,         // 1 when in idle_ST 0 otherwise, used as the rise for the bubble random timer
	 output logic			is_exploding       // 1 when we are in explosion mode 0 otherwise, used as assign
	 
);

  

    parameter int INITIAL_X = 280;
    parameter int INITIAL_Y = 400;
    parameter int INITIAL_X_SPEED = 0;
    parameter int INITIAL_Y_SPEED = 0;
    parameter int Y_ACCEL = 0;
    parameter int bubble_speed_default = 2;
    logic [5:0] bubble_speed;
	 logic cheat_key_d;
	 assign bubble_speed = (item1_bought) ? 6'b000011 : bubble_speed_default;
	 
	 
    // timer values
    parameter int explo_duration = 8'b00000010; //2 seconds of explosion animation

//    const int MAX_Y_SPEED = 500;
    const int FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
	
    // movement limits 
    const int OBJECT_WIDTH_X = 32;
    const int OBJECT_HIGHT_Y = 32;
    const int SafetyMargin   = 1;

    const int x_FRAME_LEFT   = (SafetyMargin) * FIXED_POINT_MULTIPLIER; 
    const int x_FRAME_RIGHT  = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER; 
    const int y_FRAME_TOP    = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
    const int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HIGHT_Y) * FIXED_POINT_MULTIPLIER; 

    enum logic [2:0] {
        IDLE_ST,            // initial state
        MOVE_ST,            // moving no colision 
        //START_OF_FRAME_ST,  // startOfFrame activity-after all data collected 
        POSITION_CHANGE_ST, // position updating 
        POSITION_LIMITS_ST, // check if inside the frame
        EXPLOSION_ST,       // exploding animation
        AIM_ST              // aiming the bubble
    } SM_Motion;

    int Xspeed; 
    int Yspeed; 
    int Xposition; 
    int Yposition;

    int angle;          
    logic bubble_dir;     // 0 for clockwise, 1 for anticlockwise
    

   
    logic [4:0] hit_reg = 5'b00000;

    always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
        if (resetN == 1'b0) begin 
            SM_Motion <= IDLE_ST; 
            Xspeed <= 0; 
            Yspeed <= 0; 
            Xposition <= 280; 
            Yposition <= 400; 
            hit_reg <= 5'b0;
            angle <= 90; 
            bubble_dir <= 1'b1;
				idle_state <= 0;	
        end 
        else begin
				cheat_key_d <= cheat_key;
            timer_loadN  <= 1'b1; 
            timer_enable <= 1'b1;
				idle_state <= 0;
     
//this condition wil check if the SM is in the correct state (moving, not aiming or idle or already exploding) and if
//the timer that counts until explosion randomly finshed counting. if so, we'll go into explostion mode.	  
            if ((timer_ended && SM_Motion != EXPLOSION_ST && SM_Motion != IDLE_ST && SM_Motion != AIM_ST) 
						|| bubble_borders_collision || (cheat_key && (!cheat_key_d))) begin
						
							timer_loadN <= 1'b0;
							timer_data  <= explo_duration;
							SM_Motion   <= EXPLOSION_ST;
					  
            end 
            else begin
                case(SM_Motion)
                
                    //------------
                    IDLE_ST: begin
                    //------------
								
                        idle_state <= 1;
								angle <= 90; 
                        Xspeed  <= INITIAL_X_SPEED; 
                        Yspeed  <= INITIAL_Y_SPEED; 
                        Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
                        Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 
                        hit_reg <= 5'b00000; 
                        timer_loadN <= 1'b0; 
                        timer_data <= rand_time_explosion; 
                        timer_enable <= 1'b0; 
                        
                        if (startOfFrame) 
                            SM_Motion <= AIM_ST;
                    end

//this state will be used for aiming the bubble. the bubble will move between a min angle and a max angle in a circular
//motion and when the up arrow key is pressed the bubble will launch.
                    //------------
                    AIM_ST: begin       
                    //------------ 
                        timer_enable <= 1'b0; //not counting until the bubble is launched
								if (startOfFrame) begin 
                            if (bubble_dir == 1'b1) begin //cheking if the bubble moves anticlockwise and haven't reached
                                if (angle < 170)			//the max angle 
                                    angle <= angle + 1;
                                else
                                    bubble_dir <= 1'b0; // Switch direction to clockwise if reached max angle
                            end
                            else begin
                                if (angle > 10) //the bubble is moving clockwise and change direction if the min angle is reached
                                    angle <= angle - 1;
                                else
                                    bubble_dir <= 1'b1; // Switch direction to Left
                            end
                        end
								//these will update the bubble's positions while in circular motion
                        if (angle > 90) //if the angle is greater than 90 then the bubble position in x is decreased, it moved left
                            Xposition <= (INITIAL_X - cos_angle) * FIXED_POINT_MULTIPLIER;
                        else begin //the bubble position in x is increased 
                            Xposition <= (INITIAL_X + cos_angle) * FIXED_POINT_MULTIPLIER;
								end
                        Yposition <= (INITIAL_Y - sin_angle) * FIXED_POINT_MULTIPLIER; //the y position is always decreased,
																													// the intial position in y is the highest point on the circle
                        if (startOfFrame && Y_direction_key) begin //if bubble is launched
                             SM_Motion <= MOVE_ST;
                        end                    
                    end     
    
                    //------------
                    MOVE_ST: begin      // moving and collecting collisions 
                    //------------ 
                        if (angle > 90)
                            Xspeed <= -(bubble_speed * cos_angle); 
                        else
                            Xspeed <= (bubble_speed * cos_angle);  
                            
                        Yspeed <= -(bubble_speed * sin_angle); 

                        // collecting collisions     
//                        if (collision) begin
//                            hit_reg[1] <= 1;
//                        end
                        if (startOfFrame)
                            SM_Motion <= POSITION_CHANGE_ST; 
                    end 
        
                    //------------
                    EXPLOSION_ST: begin //the bubble stops and exploding animation is displayed 
                    //------------
                        Yspeed <= 0;
                        Xspeed <= 0;
                        if (timer_ended) 
                            SM_Motion <= IDLE_ST;
                    end
        
//                    //------------
//                    START_OF_FRAME_ST: begin        
//                    //------------                 
//                            SM_Motion <= POSITION_CHANGE_ST; 
//                    end

                    //------------------------
                    POSITION_CHANGE_ST: begin  // position updating 
                    //------------------------
                        Xposition <= Xposition + Xspeed; 
                        Yposition <= Yposition + Yspeed;
//								if (Yspeed < MAX_Y_SPEED) begin 
//                            Yspeed <= Yspeed - Y_ACCEL; 
//								end
                        
                        SM_Motion <= POSITION_LIMITS_ST; 
                    end
        
                    //------------------------
                    POSITION_LIMITS_ST: begin  // check if still inside the frame 
                    //------------------------
                        if (Xposition < x_FRAME_LEFT) 
                            Xposition <= x_FRAME_LEFT; 
                        if (Xposition > x_FRAME_RIGHT)
                            Xposition <= x_FRAME_RIGHT; 
                        if (Yposition < y_FRAME_TOP) 
                            Yposition <= y_FRAME_TOP; 
                        if (Yposition > y_FRAME_BOTTOM) 
                            Yposition <= y_FRAME_BOTTOM; 

                        SM_Motion <= MOVE_ST; 
                    end
        
                endcase // case 
            end
        end 
    end 

    assign angle_out = (angle > 90) ? (180 - angle) : angle;

    // return from FIXED point trunc back to frame size parameters 
    assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER; 
    assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER;
	 assign is_exploding = (SM_Motion == EXPLOSION_ST ) ? 1 : 0 ;

endmodule
//-----------------------------------------------------------------------------------------------------
//garbage collection
 
 //this is the start of frame state with a lot of conditions that we don't need. it doesn't matter to us
 //where the bubble hit the edges, just that it hit something
// 		
//			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
//		//------------
//		if (hit_reg != 5'b00000) begin //important change: only checks where is the collision if a collision was detected
//			if (hit_reg == CORNER)   // pure corner //for every type of collision, return to original place to try again
//					begin
////							Yspeed <= 0-Xspeed ;
////							Xspeed <= 0-Yspeed ;
////              Yspeed <= 0-Yspeed ;
////				  Xspeed <= 0-Xspeed ;
//					SM_Motion <= EXPLOSION_ST;
//					end
//			else begin 
//				case (hit_reg[3:0] )  // test sides 
//	
//					TOP+RIGHT, LEFT+BOTTOM, TOP+LEFT, BOTTOM+RIGHT :  // two sides - corner 
//					begin
////							 Yspeed <= 0-Yspeed ;
////				          Xspeed <= 0-Xspeed ;
//							SM_Motion <= EXPLOSION_ST;	
//					end
//					LEFT, TOP+RIGHT+BOTTOM : // left side or cavity  
//					begin
////						if (Xspeed < 0) // left 
////							  Xspeed <= 0-Xspeed ;
//						SM_Motion <= EXPLOSION_ST;
//					end
//	
//					RIGHT, LEFT+BOTTOM +TOP :   // right side or cavity  
//					begin
////						if (Xspeed > 0) // right 
////							  Xspeed <= 0-Xspeed ;
//							SM_Motion <= EXPLOSION_ST;
//					end
//					
//					TOP, RIGHT+LEFT+BOTTOM :  // top side or cavity  
//					begin
////						if (Yspeed < 0) // up 
////							  Yspeed <= 0-Yspeed ;
//							SM_Motion <= EXPLOSION_ST;
//					end
//				
//				BOTTOM, TOP+LEFT+RIGHT :  // bottom side or cavity  
//					begin
////						if (Yspeed > 0) // doun 
////							  Yspeed <= -Yspeed ;
//							SM_Motion <= EXPLOSION_ST;
//					end
//					
//					default: ; 
//	
//			  endcase
//			end // else 
//			end else begin
//				hit_reg <= 5'b00000;						
//				SM_Motion <= POSITION_CHANGE_ST ; 
//			end 
//		end




//----------------------------------------------move state grabage
//------------
//			MOVE_ST:  begin     // moving collecting colisions 
//		//------------
//		// keys direction change 
//				if (Y_direction_key)//removed while moving condition
//					Yspeed <= 15;//changed to speed 15 when 8 is pressed ; 
//					
//				if (toggle_x_key & !toggle_x_key_D) //rizing edge 
//					Xspeed <= -Xspeed ; // toggle direction 
//	
//       // collcting collisions 	
//				if (collision) begin
//					hit_reg[HitEdgeCode]<=1'b1;
//
//				end
//				
//				if (startOfFrame)
//					SM_Motion <= START_OF_FRAME_ST ; 
//					
//					
//				
//		end 