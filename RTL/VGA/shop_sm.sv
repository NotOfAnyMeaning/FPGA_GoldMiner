//shop 

module shop_sm (
    input  logic        clk,
    input  logic        resetN,
    input  logic        startOfFrame,      // short pulse every start of frame 30Hz
	 input  logic			game_mode,			//if 0 then in shop mode 1 game mode	 
	 input  logic			right_is_pressed,  // input keyispressed , 6 is right
	 input  logic			enter_is_pressed, // enter is pressed
	 input  logic	[9:0] initial_balance,     // current money balance
	 input  logic			load_game,	
	 
	 output logic 			Item1_bought,
	 output logic 			Item2_bought,
	 output logic 			Item3_bought,
	 output logic			shop_modeN,   // 1 when finished to shop transfer into gamecontroller , 0 whilst shopping
	 output logic	[9:0]	updated_balance, // sending the balance to the gamecontroller post-purchase
	 output logic [2:0]  current_selection,  // 0=None/Idle, 1=Item1, 2=Item2, 3=Item3 4=exit
	 output logic [9:0]  curr_balance// balance we use during the shopping , then assigned to the output updated_balance
); 


	//prices 
	parameter int Item1_price = 32;  
	parameter int Item2_price = 15 ;
	parameter int Item3_price = 25 ;
	
	
	logic       right_d; // Delayed version of Right Button
   logic       enter_d; // Delayed version of Enter Button
   logic       right_pulse; 
   logic       enter_pulse; 

	assign right_pulse = right_is_pressed && !right_d;
   assign enter_pulse = enter_is_pressed && !enter_d;
	
   logic [2:0] selection_logic;
    enum logic [2:0] {

		  IDLE_ST,
		  CHECK_INVENTORY_ST, //sorting state
		  ITEM1_ST,
		  ITEM2_ST,
		  ITEM3_ST,
		  END_SHOP_ST
    } SM_Shop;

	
	logic game_mode_d ;// delayed game mode to detect falling edge
    always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
        if (resetN == 1'b0) begin 
            SM_Shop      <= IDLE_ST;
				Item1_bought <= 0;
				Item2_bought <= 0;
				Item3_bought <= 0;
				shop_modeN   <= 1;
				curr_balance <= 0;
				game_mode_d  <= 1;
            
        end
		  
            else begin
					//defults 
					game_mode_d <= game_mode;
					right_d     <= right_is_pressed;
					enter_d     <= enter_is_pressed;
					shop_modeN   <= 0;
					
					
				if ( load_game ) begin
					SM_Shop      <= IDLE_ST;
					Item1_bought <= 0;
					Item2_bought <= 0;
					Item3_bought <= 0;
					shop_modeN   <= 1;
				end	
					 case(SM_Shop)
							//------------
                    // THE DEFAULT CASE
                    //------------
                    default: begin
                        SM_Shop <= IDLE_ST;
                    end
						  
						  //------------
                    IDLE_ST: begin
                    //------------
								shop_modeN   <= 1;
								if (game_mode_d == 1 && game_mode == 0) begin //detecting the level is over and enters to shop
									curr_balance <= initial_balance ; //intializing the current balance 
									SM_Shop <= CHECK_INVENTORY_ST;
								end
                    end
						  
						  //------------
                    CHECK_INVENTORY_ST: begin //check which of items were sold so that the cursor is always pointed at the first avaliable item
                    //------------
						  if (!Item1_bought)      
										SM_Shop <= ITEM1_ST;      // Item 1 is available
			  
									else if (!Item2_bought) 
										SM_Shop <= ITEM2_ST;      // Item 1 sold, start at 2
			  
									else if (!Item3_bought) 
										SM_Shop <= ITEM3_ST;      // Items 1 & 2 sold, start at 3
			  
									else                    
										SM_Shop <= END_SHOP_ST;   // Shop is empty
						  end
                    //------------
                    ITEM1_ST: begin
                    //------------
								if(right_pulse) begin // player want to move to the next item without purchasing
									if (!Item2_bought)      SM_Shop <= ITEM2_ST;
									else if (!Item3_bought) SM_Shop <= ITEM3_ST;
                           else                    SM_Shop <= END_SHOP_ST;
								end
								else if( enter_pulse && !Item1_bought ) begin // player makes a purchase
										if (curr_balance  >= Item1_price) begin
											curr_balance <= curr_balance - Item1_price;
											Item1_bought <= 1;
										end
								end	
							
						  end

                    //------------
                    ITEM2_ST: begin       
                    //------------ 
                        if(right_pulse) begin
									if (!Item3_bought)	SM_Shop <= ITEM3_ST;
									else SM_Shop <= END_SHOP_ST;
								end
								else if( enter_pulse && !Item2_bought ) begin
										if (curr_balance  >= Item2_price) begin
											curr_balance <= curr_balance - Item2_price;
											Item2_bought <= 1;
										end
								end	
                    end     
    
                    //------------
                    ITEM3_ST: begin      
                    //------------ 
                        if(right_pulse) begin
									 SM_Shop <= END_SHOP_ST;
								end
								else if( enter_pulse && !Item3_bought ) begin
										if (curr_balance  >= Item3_price) begin
											curr_balance <= curr_balance - Item3_price;
											Item3_bought <= 1;
										end
								end
                    end 
        
                    //------------
                    END_SHOP_ST: begin
                    //------------
                        if( right_pulse) begin //player wants to look through the items again
										SM_Shop <= CHECK_INVENTORY_ST;
								end		
								else if(enter_pulse) begin //player can stay in the shop until he presses exit
									shop_modeN <= 1;
									SM_Shop <= IDLE_ST;
								end
                    end
        
        
                endcase // case 
					 
            end
        end 

	
		assign updated_balance = curr_balance; 
	always_comb begin
		selection_logic = 0;
		case (SM_Shop)
            default:		 selection_logic = 0;	//check inventory and idle are zero
				ITEM1_ST:    selection_logic = 1;
            ITEM2_ST:    selection_logic = 2;
            ITEM3_ST:    selection_logic = 3;
				END_SHOP_ST: selection_logic = 4;	
		endcase
	end
	// updating curr selection every start of frame for smooth transition of hand cursor
	always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            current_selection <= 0;
        end
        else begin
            if (startOfFrame) begin
                current_selection <= selection_logic;
            end
        end
    end	

endmodule
