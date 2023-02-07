// In the name of Allah


module keccak_absorb #(parameter in_len = 32)(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_s_in,
    input [31:0] pos,
    input [31:0] r,
    input [in_len * 8 - 1:0] linear_in,
    input [63:0] inlen,
    output [1599:0] linear_s_out,
    output reg [31:0] i,
    output reg rts
    );
     
    wire [7:0] in [0:in_len - 1];
    wire [63:0] s_in [0:24];
    wire [63:0] s_permute [0:24];
    reg [63:0] s [0:24];
    
    wire [1599:0] linear_s_permute;
    
    reg [63:0] inlen_reg;
    reg [31:0] pos_reg;
    reg rtr_permute;
    wire rts_permute;
    
    generate
        genvar x;
		for (x = 0; x < 25; x = x + 1) begin
		    assign s_in[x] = linear_s_in[64 * x + 63:64 * x];
		    assign s_permute[x] = linear_s_permute[64 * x + 63:64 * x];  
		end
	endgenerate
        
    generate
		for (x = 0; x < in_len; x = x + 1) begin
			assign in[x] = linear_in[8 * x + 7:8 * x];
		end
	endgenerate
	  
	generate
		for (x = 0; x < 25; x = x + 1) begin
		    assign linear_s_out[64 * x + 63:64 * x] = s[x];
		end
	endgenerate
	
	KeccakF1600_StatePermute KeccakF1600_StatePermute( .A(linear_s_out), .Aout(linear_s_permute), .clk(clock), .reset(reset), .rtr(rtr_permute), .rts(rts_permute));
    
	reg [8:0] index;
	reg [5:0] in_index;
	
	localparam SIZE = 4;
    localparam IDLE = 4'd0, PRE_RD_INP = 4'd1 ,RD_INP = 4'd2;
	
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
                    rtr_permute = 0;
	           	    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
                    rtr_permute = 0;
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
                    rtr_permute = 0;
	           	    next_state = 3;
                end
            3:
                begin
                    rts = 0;
                    rtr_permute = 0;
	           	    next_state = 4;
                end
            4:
                begin
                    rts = 0;
                    rtr_permute = 0;
	           	    if(index < 25)
	               	   next_state = 3;
	           	    else
	           	       next_state = 5;
                end
            5:
                begin
                    rts = 0;
                    rtr_permute = 0;
	           	    if(pos_reg + inlen_reg >= r)
	               	   next_state = 6;
	           	    else
	               	   next_state = 10;
                end
            6:
                begin
                    rts = 0;
                    rtr_permute = 0;
	           	    if(index < r)
	               	   next_state = 6;
	           	    else
	               	   next_state = 7;
                end
            7:
                begin
                    rts = 0;
                    rtr_permute = 1;
	           	    next_state = 8;
                end
            8:
                begin
                    rts = 0;
						  rtr_permute = 1;
                    if(rts_permute) begin
	               	   next_state = 9;
	           	    end
	           	    else begin
	               	   next_state = 8;	               	   
	               	end
                end
            9:
					begin
						rts = 0;
                  rtr_permute = 0;
                  next_state = 10;    
					end
				10:
                begin
                    rts = 0;
                    next_state = 11;
                    rtr_permute = 0;
                end
            11:
                begin
                    rts = 0;
                    rtr_permute = 0;
	           	    if(index < pos_reg + inlen)
	               	   next_state = 10;
	           	    else
	               	   next_state = 12;
                end
            12:
                begin
                    rts = 1;
                    rtr_permute = 0;
	           	    if(~rtr)
	               	   next_state = 0;
	           	    else
	               	   next_state = 12;
                end
        endcase
    end
    
	always @ (posedge clock) begin
	   case (state)
	   	RD_INP:
	       	begin
	            index <= 0;
	           	in_index <= 0;
	        end
	   	3:
	       	begin
               	s[index] <= s_in[index];
				index <= index + 1;
	        end
		4:
	       	begin
	           	if(~(index < 25)) begin
	                inlen_reg <= inlen;
	    	       	pos_reg <= pos;
	           	end
	       end
	   	5:
	       	begin
	           	index <= pos_reg;
	           	in_index <= 0;
          	end
	   	6:
	       	if(index < r) begin
	            s[index / 8] <= s[index / 8] ^ (in[in_index] << (8 * (index % 8)));
	           	index <= index + 1;
	            in_index <= in_index + 1;
	        end
	   	7:
	       	begin
	           	inlen_reg <= inlen_reg - (r - pos_reg);
	           	index <= 0;
	       	end
	   	8:
	       	if (rts_permute) begin
	            s[index] <= s_permute[index];
	            index <= index + 1;
	       	end
	   	9:
	       	if(~(index < 25)) begin
	            pos_reg <= 0;
	          	index <= 0;
	        end
	   	10:
	       	begin
	           s[index / 8] <= s[index / 8] ^ (in[in_index] << (8 * (index % 8)));
	           index <= index + 1;
	           in_index <= in_index + 1;
	        end
	   	11:
	       	begin
	           	if(~(index < pos_reg + inlen))
	                i <= index;
	        end
	   	endcase
	end
	  
endmodule
