// In the name of Allah


module KeccakF1600_StatePermute(A, Aout, clk, reset, rtr, rts);

	input [1599:0] A;
	output [1599:0] Aout;
	input clk, reset, rtr;
	output reg rts;

	reg [1599:0] regA;
	reg [2:0] round;
	
    localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state = IDLE;
	
	always @(posedge clk) begin
        begin
            if(reset)
                state <= IDLE;
            else
                state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE:
                begin
                    rts = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
                    if (rtr == 1'b1) begin
			            next_state = RD_INP;
			        end
			        else begin
			            next_state = PRE_RD_INP;
			        end
                end
            RD_INP:
                begin
                    rts = 0;
                    next_state = 3;
                end
            3:
                if(round < 3'b101) begin
				    next_state = 3;
		   	    end
		   	    else
		      	   next_state = 4; 	   
            4:
                begin
                rts = 1;
                    if(~rtr) 
		          	   next_state = 0;
		      	    else
		      	       next_state = 4; 
		      	end
            endcase
        end
        
	always @(posedge clk) begin
	   	case (state)
	   	RD_INP:
	       begin
				regA <= A;
				round <= 3'b0;
			end 
	   	3:
	       	if(round < 3'b101) begin
				regA <= Aout;
				round <= round + 1;
		   	end
	   	4:
		  	begin
		      	
		  	end
	   endcase
	end

	PermuteFunc_FourRound PermuteFunc_FourRound_u0(.LinearA(regA), .LinearAout(Aout), .round(round));

endmodule
