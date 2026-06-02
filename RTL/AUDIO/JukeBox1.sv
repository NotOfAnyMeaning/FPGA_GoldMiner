//
// (c) Technion IIT, The Faculty of Electrical and Computer Engineering, 2025
//
//
//  PRELIMINARY VERSION  -  06 April 2025
//


module JukeBox1

    (
    // Declare wires and regs :
 
 input logic [3:0] melodySelect ,     // selector of one melody  
 input logic [4:0] noteIndex,         // serial number of current note. ( maximum 31 ). noteIndex determines freqIndex and note_length, via JueBox
 
 output logic [4:0] tone,        // index to toneDecoder
 output logic [3:0] note_length,      // length of notes, in beats
 output logic silenceOutN ) ;         //  a silence note: disable sound
 

 localparam MaxMelodyLength = 6'h32;  // maximum melody length, in notes. 
	

// ************** frequencies: *************************************************************************************************
    typedef enum logic [4:0] {do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, re_DH, la_DH, si_H, si_3, mi_3, silence } musicNote ;//*
//              Hex value:     0    1    2   3   4    5   6    7     8    9   A   B    C      D    E      F     10      11    12    13      14 //*
// *****************************************************************************************************************************
      
   // type of frequency is musicNote   (enum)  
   // Frequency index is 0....15   
   // length is in beats ( 1 to 15 )
   // length = 0 means end of melody		

musicNote frq[(MaxMelodyLength-1'b1):0]  ;     // frq is the array of frequency indices of the melody. it includes up to 32 notes.  
logic [3:0] len[(MaxMelodyLength-1'b1):0] ;   // len is the array of note lengths , in terms of beats. it includes up to 32 notes.		

assign silenceOutN = !( tone == silence ) ; // disable sound if note is "silence"	 
	 
	 
	 
always_comb begin	 
    frq = '{default: 0};
	 len = '{default: 0}; 
  case (melodySelect)  
      0:   begin
	
			
	
       end 

      1:   begin
			
			//************************************************************************************************** 
			// Sheet Music of melody:  good sound                                               *
			//**************************************************************************************************
			 
				   frq[0] = mi;     len[0] = 1; 
					frq[1] = sol;    len[1] = 1; 
					frq[2] = do_H;   len[2] = 4; 
		
				   frq[3] = do_;    len[3] = 0; // length = 0 means end of melody
  
      end // case 1 


      2:   begin		
			//************************************************************************************************** 
			// Sheet Music of melody:  bad sound                                            *
			//**************************************************************************************************			 
			frq[0] = fa;     len[0] = 3; 
			frq[1] = mi;     len[1] = 3; 
			frq[2] = reD;    len[2] = 3; 
			frq[3] = re;     len[3] = 3; 
			frq[4] = do_;    len[4] = 8; 
    
			frq[5] = do_;    len[5] = 0; // length = 0 means end of melody
      end // case 2
		
		3: begin //will it sponge the bob?  
		
				frq[0] = mi;      len[0] = 8;   
            frq[1] = si;      len[1] = 8;
				frq[2] = solD;		len[2] = 8;
            frq[3] = si;    	len[3] = 8;
				
				
				frq[4] = mi;      len[4] = 8;   
            frq[5] = si;      len[5] = 8;
				frq[6] = solD;		len[6] = 8;
            frq[7] = si;    	len[7] = 8;
				
				
				frq[8] = si;      len[8] = 2;   
            frq[9] = laD;     len[9] = 1;
				frq[10] = si;		len[10] = 2;
            frq[11] = doDH;   len[11] = 1;
				frq[12] = si;		len[12] = 10;
				frq[13] = mi;		len[13] = 8;
				frq[14] = si;		len[14] = 8;
				
				
				frq[15] = si;     len[15] = 2;   
            frq[16] = laD;    len[16] = 1;
				frq[17] = si;		len[17] = 2;
            frq[18] = doDH;   len[18] = 1;
				frq[19] = si;		len[19] = 10;
				frq[20] = mi;		len[20] = 8;
				frq[21] = si;		len[21] = 8;
				frq[22] = mi;		len[22] = 8;
				
				
				
				
				
				
				
				
				
				
  
        
            frq[23] = silence; len[23] = 0;   

      end

		
		default: begin
				
			//************************************************************************************************** 
			// Sheet Music     S O S                                                                           *
			//**************************************************************************************************
				 // First phrase
				  frq[0]  =  do_H ;      len[0]  = 2  ;   
				  frq[1]  =  do_H ;      len[1]  = 2  ;   
				  frq[2]  =  do_H ;      len[2]  = 2  ; 
				  
				  frq[3]  =  silence ;   len[3]  = 3  ;
				  
				  frq[4]  =  do_H ;      len[4]  = 4  ;  
              frq[5]  =  silence ;   len[5]  = 1  ;
				  frq[6]  =  do_H ;      len[6]  = 4  ;  
              frq[7]  =  silence ;   len[7]  = 1  ;
				  frq[8]  =  do_H ;      len[8]  = 4  ;   
				  
				  frq[9]  =  silence ;   len[9]  = 3  ;
				  
				  frq[10]  =  do_H ;     len[10]  = 2  ;   
				  frq[11]  =  do_H ;     len[11]  = 2  ;   
				  frq[12] =  do_H ;      len[12]  = 2  ;   

	 			  frq[13] = do_H ;       len[13] = 0 ;    // length = 0 means end of melod
	
      end
   endcase
  end // always 
 
//***********************************************************************
//     Extract outputs of specific note from sheet music :                                                        *
//***********************************************************************

assign tone   = frq[noteIndex] ;
assign note_length = len[noteIndex] ; 

 
 
endmodule

