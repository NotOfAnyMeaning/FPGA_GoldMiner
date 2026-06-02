// Game Controller
// Original Author: Dudy (Feb 2020) | Technion IIT (2021) | Updated: Eyal Lev (2021)
// Refactored for clarity

module game_controller (
    //-------------------------------------------------------------------------
    // System & Timing Inputs
    //-------------------------------------------------------------------------
    input  logic        clk,
    input  logic        resetN,
    input  logic        startOfFrame,           // Short pulse 30Hz 
    input  logic        level_timer_ended,      // Active when level timer reaches 0

    //-------------------------------------------------------------------------
    // User Control Inputs
    //-------------------------------------------------------------------------
    input  logic        seven_is_pressed,
    input  logic        zero_is_pressed,

    //-------------------------------------------------------------------------
    // Game Event Inputs
    //-------------------------------------------------------------------------
    input  logic        add_points, //add points for burger
    input  logic        ded_points, //deduct points for jellyfish
    input  logic        ded_points_rotten, //deduct points for rotten burger
    input  logic        is_exploding, //the bubble is in explosion state and now is the time to register collisions 

    //-------------------------------------------------------------------------
    // Shop & Economy Inputs
    //-------------------------------------------------------------------------
    input  logic        shop_modeN, //1 when NOT in shop
    input  logic        Item1_bought, //doubles the bubble speed
    input  logic        Item2_bought, //doubels the moeny for burgers
    input  logic        Item3_bought, //removes the jellyfishes
    input  logic [9:0]  post_shop_balance,

    //-------------------------------------------------------------------------
    // Drawing Requests (Collision Inputs)
    //-------------------------------------------------------------------------
    input  logic        drawing_request_bubble,
    input  logic        drawing_request_boarders, 
    input  logic        drawing_request_burger,      
    input  logic        drawing_request_Jellyfish,
    input  logic        drawing_request_badPatty,

    //-------------------------------------------------------------------------
    // Game State & Display Outputs
    //-------------------------------------------------------------------------
    output logic        game_mode,              // 0 for shop, 1 for levels
    output logic        load_game,					//used to restart the game
    output logic        wait_mode,					//used to display the ending/ starting screens
    output logic [2:0]  level_sel,					//0 for level 1
    output logic [1:0]  choose_text,            // Displaying relevant text, 0 for lost, 1 for won, 2 for start

    //-------------------------------------------------------------------------
    // Timer Control Outputs
    //-------------------------------------------------------------------------
    output logic [7:0]  level_timer_data,       // Sets level length
    output logic        level_timer_enable,     // Starts timer
    output logic        level_timer_loadN,      // Loads into the timer

    //-------------------------------------------------------------------------
    // Score & Economy Outputs
    //-------------------------------------------------------------------------
    output logic [9:0]  cur_points,              
    output logic [6:0]  curr_goal_score,
    output logic [9:0]  post_game_balance,      // For coin collection

    //-------------------------------------------------------------------------
    // Collision Outputs
    //-------------------------------------------------------------------------              
    output logic        bubble_borders_collision,
    output logic        collision_Bubble_Burger,
    output logic        collision_Bubble_Jellyfish,
    output logic        collision_Bubble_BadPatty,

    //-------------------------------------------------------------------------
    // Audio Outputs
    //-------------------------------------------------------------------------
    output logic [1:0]  melodySelect,           // 1 for "good", 2 for "bad"
    output logic        melody_start,           // Plays the sound 
    output logic        BG_music						//the background music 
);

    //-------------------------------------------------------------------------
    // Parameters 
    //-------------------------------------------------------------------------
    parameter int LEVEL1_LENGTH = 60;
    parameter int LEVEL2_LENGTH = 50;
    parameter int LEVEL3_LENGTH = 35;
    parameter int LEVEL1_TARGET_POINTS = 50;
    parameter int LEVEL2_TARGET_POINTS = 100;
    parameter int LEVEL3_TARGET_POINTS = 70;
	 
	 parameter BAD_SOUND = 2'b10;
	 parameter GOOD_SOUND =2'b01;
	 parameter BG_MUSIC = 2'b11;
	 parameter YOU_LOST = 2'b00;
	 parameter YOU_WON = 2'b01;
	 parameter START_TEXT = 2'b10;
    
    parameter int BURGER_POINTS = 25;
    parameter int BURGER_POINTS_BONUS = 50;

    parameter int JELLYFISH_POINTS = -15;
    
    parameter int ROTTEN_BURGER_POINTS = -5;
    
    //=========================================================================
    // Internal Signals & State Definitions
    //=========================================================================;                        
    logic collision_bubble_number;     
    logic collision_bubble_borders;
    
    logic shop_modeN_d;
    logic [9:0] balance;
    
    logic [2:0] past_st; //the state from which we entered the shop from
    
    logic seven_d;
    logic seven_pulse;
    assign seven_pulse = seven_is_pressed && !seven_d;
    
    logic zero_d;
    logic zero_pulse;
    assign zero_pulse = zero_is_pressed && !zero_d;

    // State Machine for Levels
    enum logic [2:0] {
        START_ST,
        LEVEL1_ST,             
        LEVEL2_ST,   
        LEVEL3_ST, 
        SHOP_ST, 
        LOST_ST,
        WON_ST          
    } SM_LEVELS;

    //=========================================================================
    // Collision Logic
    //=========================================================================
    
    // Collision of bubble with the borders
    assign bubble_borders_collision = (drawing_request_bubble && drawing_request_boarders && !is_exploding);
    
    

    // Checks if the bubble is in explosion mode. iff then register collisions 
    assign collision_Bubble_Burger    = (is_exploding) ? (drawing_request_bubble && drawing_request_burger) : 0;
    assign collision_Bubble_Jellyfish = (is_exploding) ? (drawing_request_bubble && drawing_request_Jellyfish) : 0;
    assign collision_Bubble_BadPatty  = (is_exploding) ? (drawing_request_bubble && drawing_request_badPatty) : 0;

    //=========================================================================
    // Game Logic & State Management
    //=========================================================================
    
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            SM_LEVELS              <= START_ST;
            game_mode              <= 1;
            shop_modeN_d           <= 1'b0;
            
            // Initial Game Values
            cur_points             <= 10'b0; 
            level_timer_loadN      <= 0;
            level_timer_data       <= LEVEL1_LENGTH;
        end 
        else begin
            
            //-----------------------------------------------------------------
            // defaults
            //----------------------------------------------------------------- 
            shop_modeN_d               <= shop_modeN;
            level_timer_enable         <= 1'b0; 
            game_mode                  <= 1;
            level_timer_loadN          <= 1;  
            melody_start               <= 0;
            wait_mode                  <= 0;
            load_game                  <= 0;
            choose_text                <= 2'b10;
            BG_music                   <= 0;
        
            //-----------------------------------------------------------------
            // checks for every clock
            //-----------------------------------------------------------------
            
            if (startOfFrame) begin
                melody_start <= 0;
            end

            // Point Calculation
            if (add_points) begin //hit a burger 
                if(Item2_bought) begin //if player bought item 2 then add points accordingly 
                    cur_points <= cur_points + BURGER_POINTS_BONUS;
                end else begin
                    cur_points <= cur_points + BURGER_POINTS;
                end 
                melodySelect <= GOOD_SOUND; //good sound 
                melody_start <= 1; 
            end
            
            if (ded_points) begin //hit a jellyfish
					melodySelect <= BAD_SOUND; //bad sound
               melody_start <= 1;
                if (cur_points!=0) begin
                    cur_points <= cur_points + JELLYFISH_POINTS;
                    
                end
            end
            
            if (ded_points_rotten) begin //hit rotten
                melodySelect <= BAD_SOUND; //bad sound
                melody_start <= 1;
					 if (cur_points!=0) begin
                    cur_points <= cur_points + ROTTEN_BURGER_POINTS;
                end
            end
            
            //-----------------------------------------------------------------
            // State Machine
            //-----------------------------------------------------------------
            case(SM_LEVELS)
                
                //------------
                START_ST: begin
                //------------
                    //starting screen and music 
                    choose_text        <= START_TEXT;
                    BG_music           <= 1;
                    melodySelect       <= BG_MUSIC;
                    wait_mode          <= 1;
                    
                    //game setup
                    cur_points         <= 0;
                    level_timer_data   <= LEVEL1_LENGTH;
                    level_timer_loadN  <= 0;
						  curr_goal_score <= 7'b1;

                    // starting the game 
                    if (seven_pulse) begin
                        SM_LEVELS <= LEVEL1_ST;
                    end
                end

                //------------
                LEVEL1_ST: begin
                //------------
                    
                    past_st            <= LEVEL1_ST;
                    level_sel          <= 3'b0; 
                    level_timer_enable <= 1'b1;
						  curr_goal_score    <= LEVEL1_TARGET_POINTS;
                    
                    
                    if (cur_points >= curr_goal_score || zero_pulse) begin
                        
								// setting timer the next level
                        level_timer_data   <= LEVEL2_LENGTH;
                        level_timer_loadN  <= 0;
								
								//shop 
                        post_game_balance  <= cur_points + post_shop_balance;
                        SM_LEVELS          <= SHOP_ST;
                    end
                    else if (level_timer_ended == 1) begin //losing 
                        SM_LEVELS <= LOST_ST;
                    end
                end
                    
                //------------
                LEVEL2_ST: begin
                //------------
                    
                    past_st            <= LEVEL2_ST;
                    level_sel          <= 3'b001; 
                    level_timer_enable <= 1'b1;
                    curr_goal_score    <= LEVEL2_TARGET_POINTS;
                    
                    
                    if (cur_points >= curr_goal_score || zero_pulse) begin
                        // setting timer for next level
                        level_timer_data   <= LEVEL3_LENGTH;
                        level_timer_loadN  <= 0;
								//shop
                        post_game_balance  <= post_shop_balance + cur_points;
                        SM_LEVELS          <= SHOP_ST;
                    end
                    else if (level_timer_ended == 1) begin //losing
                        SM_LEVELS <= LOST_ST;
                    end
                end
                    
                //------------
                LEVEL3_ST: begin
                //------------
                    
                    past_st            <= LEVEL3_ST;
                    level_sel          <= 3'b010; 
                    level_timer_enable <= 1'b1;
                    level_timer_data   <= LEVEL3_LENGTH;
						  curr_goal_score    <= LEVEL3_TARGET_POINTS;
                    
                    
                    if (cur_points >= curr_goal_score || zero_pulse) begin //winning the game. weeeee
                        post_game_balance <= post_shop_balance + cur_points;
                        SM_LEVELS         <= WON_ST;
                    end
                    else if (level_timer_ended == 1) begin //losing 
                        SM_LEVELS <= LOST_ST;
                    end
                end
                    
                //------------
                SHOP_ST: begin
                //------------
                    // shop updates 
                    game_mode          <= 0;
                    level_timer_enable <= 0;
                    shop_modeN_d       <= shop_modeN;

                    // leaving shop
                    if (shop_modeN == 1 && shop_modeN_d == 0) begin
                        cur_points <= 0;
                        
                        // going back to the correct state
                        case (past_st) 
                            LEVEL1_ST: SM_LEVELS <= LEVEL2_ST; 
                            LEVEL2_ST: SM_LEVELS <= LEVEL3_ST;  
                            default:   SM_LEVELS <= LEVEL1_ST;
                        endcase
                    end
                end
                
                //------------
                WON_ST: begin
                //------------
                    
                    game_mode          <= 1;
                    wait_mode          <= 1;
                    load_game          <= 1;
                    
                    // screen and audio
                    choose_text        <= YOU_WON;
                    BG_music           <= 1;
                    melodySelect       <= BG_MUSIC;
                    
                    
                    level_timer_enable <= 0;
                    //reseting stats
						  post_game_balance  <= 0;
                    cur_points         <= 0;
                    
                    // restarting game
                    if (seven_pulse) begin
                        SM_LEVELS <= START_ST;
                    end
                end
            
                //------------
                LOST_ST: begin
                //------------
                    
                    game_mode          <= 1;
                    wait_mode          <= 1;
                    load_game          <= 1;
                    
                    //screen and audio
                    choose_text        <= YOU_LOST;
                    BG_music           <= 1;
                    melodySelect       <= BG_MUSIC;
                    
                    
                    level_timer_enable <= 0;
                    //reseting stats
						  post_game_balance  <= 0;
                    cur_points         <= 0;
                    
                    //restarting the game
                    if (seven_pulse) begin
                        SM_LEVELS <= START_ST;
                    end
                end
                
            endcase
        end 
    end 

endmodule