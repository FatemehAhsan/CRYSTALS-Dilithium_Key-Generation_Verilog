// In the name of Allah


module polyvecl_ntt(
    input clock,
    input reset,
	input rtr,
    input signed [40959:0] linear_v_in,
    output signed [40959:0] linear_v_out,
	output reg rts
	);
    
    localparam L = 5;
    
    wire signed [8191:0] v_in [L - 1:0];
    reg signed [8191:0] v_out [L - 1:0];
    
    reg signed [8191:0] v_in_reg;
    wire signed [8191:0] v_out_wire;
    
    reg rtr_ntt;
    wire rts_ntt;
    
    parallel_ntt_32bit parallel_ntt_32bit(
        .clock(clock),
        .reset(reset),
        .RTR(rtr_ntt),
        .inp(v_in_reg),
        .out(v_out_wire),
        .RTS(rts_ntt)
        );
	
	generate
        genvar x;
		for (x = 0; x < L; x = x + 1) begin
		    assign v_in[x] = linear_v_in[8192 * x + 8191: 8192 * x]; 
		    assign linear_v_out[8192 * x + 8191: 8192 * x] = v_out[x]; 
		end
	endgenerate
	
	localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
	
	reg [2:0] index;
	
    always @(posedge clock) begin
        if (reset == 1'b1) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE:
                begin
                    rts = 0;
                    rtr_ntt = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
                    rtr_ntt = 0;
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
                    rtr_ntt = 0;
                    next_state = 3;
                end
            3:
                begin
                    rts = 0;
                    rtr_ntt = 1;
                    next_state = 4;
                end
            4:
                begin
                    rts = 0;
                    if(rts_ntt) begin
	       	           if(index + 1 < L) begin
				          next_state = 3;
			           end
			           else begin
			              next_state = 5; 
			           end
			           rtr_ntt = 0;
	       	        end   
	       	        else begin	       
	                   next_state = 4;
			           rtr_ntt = 1;
			        end
                end
            5:
                begin
			        rts = 1;
			        rtr_ntt = 0;
                    if(~rtr) begin
				        next_state = IDLE;
			        end
			        else begin
			            next_state = 5;
			        end
			    end
            default:
                begin
                    next_state = IDLE;
                end
        endcase
    end
    
    always @ (posedge clock) begin
	   case (state)
	   RD_INP:
	   	   begin
	       	   index <= 0;	
	   	   end
	   3:
		  begin
		      v_in_reg <= v_in[index];
	   	  end
	   4:
		  begin
		      if(rts_ntt) begin
		          v_out[index] <= v_out_wire;
		          index <= index + 1;
		      end
	   	  end
	   endcase
	end   
endmodule
