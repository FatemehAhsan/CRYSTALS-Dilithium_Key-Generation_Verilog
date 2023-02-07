// In the name of Allah


module keccak_finalize(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_s_in,
    input [31:0] pos,
    input [31:0] r,
    input [7:0] p,
    output [1599:0] linear_s_out,
    output reg rts
    );
    
    wire [63:0] s_in [0:24];
    reg [63:0] s [0:24];
    
    generate
        genvar x;
		for (x = 0; x < 25; x = x + 1) begin
		    assign s_in[x] = linear_s_in[64 * x + 63:64 * x]; 
		end
	endgenerate
	
	generate
		for (x = 0; x < 25; x = x + 1) begin
		    assign linear_s_out[64 * x + 63:64 * x] = s[x];
		end
	endgenerate
	
	reg [5:0] index = 0;
	
	localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
	
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
                if(index < 25)
	               	next_state = RD_INP;
	           	else
	                next_state = 4;
            4:
                next_state = 5;
            5:
                begin
                    rts = 1;
				    if(~rtr) begin
					   next_state = IDLE;
				    end
				    else begin
				        next_state = 5;
				    end
				end
            endcase
        end
        
	always @ (posedge clock) begin
	   	case (state)
	   	RD_INP:
	       	begin
	       	   s[index] <= s_in[index];
	           index <= index + 1;
	        end
	   	4:
	       	begin
	            s[pos / 8] <= s_in[pos / 8] ^ (p << (8 * (pos % 8)));
                s[r / 8 - 1] <= s_in[r / 8 - 1] ^ (1 << 63);
	        end 
	   	5:
	       begin
	       end
	   	endcase
	end
	           
endmodule
