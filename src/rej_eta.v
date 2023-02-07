// In the name of Allah


module rej_eta(
    input clock,
    input reset,
    input rtr,
    input [31:0] len,
    input [2175:0] linear_buf,
    input [31:0] buflen,
    output signed [8191:0] linear_a,
    output reg [31:0] ctr,
    output reg rts
    );
    
    localparam Q = 32'd8380417;
    
    reg signed [31:0] a [0:255];
    wire [7:0] buff [0:271];
    
    reg [31:0] t0, t1, pos;

    generate
		genvar x;
		for (x = 0; x < 272; x = x + 1) begin
			assign buff[x] = linear_buf[8 * x + 7:8 * x]; 
		end
	endgenerate
	  
	generate
		for (x = 0; x < 256; x = x + 1) begin
			assign linear_a[32 * x + 31:32 * x] = a[x]; 
		end
	endgenerate
	  
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
                if(ctr < len && pos < buflen)
	               	next_state = 4;
	           	else
	                next_state = 6;
            4:
                next_state = 5;
            5:
                next_state = 3;
            6:
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
                pos <= 0;
                ctr <= 0;
            end
        3:
            begin
                if (ctr < len && pos < buflen) begin
                    t0 <= buff[pos] & 'h0F;
                end
            end
        4:
            begin
                t1 <= buff[pos] >> 4;
                pos <= pos + 1;
                if (t0 < 9) begin
                    a[ctr] <= 4 - t0;
                    ctr <= ctr + 1;
                end
            end
        5:
            begin
                if(t1 < 9 && ctr < len) begin
                    a[ctr] <= 4 - t1;
                    ctr <= ctr + 1;
                end
            end
        endcase
    end

endmodule
