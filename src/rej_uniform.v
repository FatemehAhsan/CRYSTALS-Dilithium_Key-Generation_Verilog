// In the name of Allah


module rej_uniform(
    input clock,
    input reset,
    input rtr,
    input [31:0] len,
    input [6735:0] linear_buf,
    input [31:0] buflen,
    output signed [8191:0] linear_a,
    output reg [31:0] ctr,
    output reg rts
    );
    
    localparam Q = 32'd8380417;
    
    reg signed [31:0] a [0:255];
    wire [7:0] buff [0:841];
    
    reg [31:0] t;
    reg [31:0] pos;
  
    generate
		genvar x;
		for (x = 0; x < 842; x = x + 1) begin
			assign buff[x] = linear_buf[8 * x + 7:8 * x]; 
		end
	endgenerate
	  
	generate
		for (x = 0; x < 256; x = x + 1) begin
			assign linear_a[32 * x + 31:32 * x] = a[x]; 
		end
	endgenerate
	  
	localparam SIZE = 4;
    localparam IDLE = 4'd0, PRE_RD_INP = 4'd1 ,RD_INP = 4'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
	
	always @(posedge clock) begin
        if (reset == 1'b1)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always @ (*) begin
        case (state)
        IDLE:
            begin
                rts = 0;
                next_state = 1;
            end
        PRE_RD_INP:
            begin
                rts = 0;
                if(rtr)
                    next_state = 2;
            end
        RD_INP: 
            begin
                rts = 0;
                next_state = 3;
            end
        3:
            begin
                rts = 0;
                if (ctr < len && pos + 3 <= buflen) begin
                    next_state = 4;
                end
                else
                    next_state = 8;
            end
        4:
            begin
                rts = 0;
                next_state = 5;
            end
        5:
            begin
                rts = 0;
                next_state = 6;
            end
        6:
            begin
                rts = 0;
                next_state = 7;
            end
        7:
            begin
                rts = 0;
                next_state = 3;
            end
        8:
            begin
                rts = 1;
                if(~rtr)
                    next_state = IDLE;
                else
                    next_state = 8;
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
                if (ctr < len && pos + 3 <= buflen) begin
                    pos <= pos + 1;
                    t <= buff[pos];
                end
            end
        4:
            begin
                t <= t | (buff[pos] << 8);
                pos <= pos + 1;
            end
        5:
            begin
                t <= t | (buff[pos] << 16);
                pos <= pos + 1;
            end
        6:
            begin
                t <= t & 'h7FFFFF;
            end
        7:
            begin
                if (t < Q) begin
                    a[ctr] <= t;
                    ctr <= ctr + 1;
                end
            end
        endcase
    end

endmodule
