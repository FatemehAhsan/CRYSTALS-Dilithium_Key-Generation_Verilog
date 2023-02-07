// In the name of Allah


module keccak_squeezeblocks #(parameter outlen = 2176)(
    input clock,
    input reset,
    input rtr,
    input [63:0] nblocks,
    input [1599:0] linear_s_in,
    input [31:0] r,
    output [outlen - 1:0] linear_out,
    output [1599:0] linear_s_out,
    output reg rts
    );
    
    reg rtr_permute;
    wire rts_permute;
    
    reg [63:0] nblocks_reg;
    wire [63:0] s_in [0:24];
    
    reg [7:0] out [0:outlen / 8 - 1];
    
    reg [1599:0] linear_s_in_permute;
    
    KeccakF1600_StatePermute KeccakF1600_StatePermute( .A(linear_s_in_permute), .Aout(linear_s_out), .clk(clock), .reset(reset), .rtr(rtr_permute), .rts(rts_permute));
    
	generate
        genvar x;
		for (x = 0; x < outlen / 8 - 1; x = x + 1) begin
		    assign linear_out[8 * x + 7:8 * x] = out[x]; 
		end
	endgenerate
	
	generate
        for (x = 0; x < 25; x = x + 1) begin
		    assign s_in[x] = linear_s_out[64 * x + 63:64 * x];
		end
	endgenerate
	
	reg [4:0] index;
	reg [9:0] out_index;
	
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
	       	        if (nblocks_reg) begin
	                    rtr_permute = 1;
	           	        next_state = 4;
	                end
	       	        else begin
	          	        rtr_permute = 0;
	           	        next_state = 7;
	          	    end
	           end
	        4:
            begin
                rts = 0;
                if (rts_permute) begin
	               	rtr_permute = 0;
	               	next_state = 5;
	           	end
	           	else begin
	           	    rtr_permute = 1;
	           	    next_state = 4;
	           	end
            end
            5:
                begin
                    rts = 0;
                    rtr_permute = 0;
                    next_state = 6;
                end 
            6:
                begin
                    rts = 0;
                    rtr_permute = 0;
                    if (index < r / 8)
                        next_state = 5;
	           	    else
	           	        next_state = 3;
	            end
	         7:
                begin
                    rtr_permute = 0;
                    rts = 1;
				    if(~rtr) begin
					   rts = 0;
					   next_state = IDLE;
				    end
				    else begin
				        next_state = 7;
				    end
				end             
          endcase
    end
    
	always @ (posedge clock) begin
	   	case (state)
	   	RD_INP:
	   	    begin
	       	    nblocks_reg <= nblocks;
	           	index <= 0;
				linear_s_in_permute <= linear_s_in;
	   	        out_index <= 0;
	   	    end
	   	4:
	       	begin
	           	if (rts_permute) begin
	           	    linear_s_in_permute <= linear_s_out;
	               	index <= 0;
	           	end
	       	end
	    5: 
	       	begin
	           	index <= index + 1;
	           	out[out_index + index * 8 + 0] <= s_in[index][7:0];
	           	out[out_index + index * 8 + 1] <= s_in[index][15:8];
	           	out[out_index + index * 8 + 2] <= s_in[index][23:16];
	           	out[out_index + index * 8 + 3] <= s_in[index][31:24];
	           	out[out_index + index * 8 + 4] <= s_in[index][39:32];
	           	out[out_index + index * 8 + 5] <= s_in[index][47:40];
	           	out[out_index + index * 8 + 6] <= s_in[index][55:48];
	           	out[out_index + index * 8 + 7] <= s_in[index][63:56];
	       	end
	    6: 
	       	begin
	           	if (~(index < r / 8)) begin
	                out_index <= out_index + r;
	                nblocks_reg <= nblocks_reg - 1;
	            end
	       	end
		7: 
			begin
			end
	   endcase
	end
endmodule
