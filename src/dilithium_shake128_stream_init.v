// In the name of Allah


module dilithium_shake128_stream_init(
    input clock,
    input reset,
    input rtr,
    input [255:0] linear_seed,
    input [15:0] nonce,
    output [1599:0] linear_state_s,
    output [31:0] state_pos,
    output rts
    );
      
    localparam inlen_absorb1 = 64'd32;
    localparam inlen_absorb2 = 64'd2;
    reg rtr_absorb1;    
        
    wire [1599:0] linear_state_s_init;
    wire [1599:0] linear_state_s_absorb1;
    wire [1599:0] linear_state_s_absorb2;

    wire [31:0] state_pos_init;
    wire [31:0] state_pos_absorb1;
    wire [31:0] state_pos_absorb2;
   
    wire [7:0] t [0:1];
    
    wire rts_absorb1;
    wire rts_absorb2;
    wire rts_finalize;
    
    assign rts = rts_finalize;
    
    assign t[0] = nonce;
    assign t[1] = nonce >> 8;    
    
    wire [15:0] linear_t;
    
    generate
        genvar x;
		for (x = 0; x < 2; x = x + 1) begin
		    assign linear_t[8 * x + 7:8 * x] = t[x]; 
		end
	endgenerate
    
    shake128_init shake128_init(
	   	.linear_state_s(linear_state_s_init),
	   	.state_pos(state_pos_init)
	   	);
	   	
	shake128_absorb #(.in_len(inlen_absorb1)) shake128_absorb1(
	   	.clock(clock),
	   	.reset(reset),
	   	.rtr(rtr_absorb1),
	   	.linear_state_s_in(linear_state_s_init),
	   	.state_pos_in(state_pos_init),
	   	.linear_in(linear_seed),
	   	.inlen(inlen_absorb1),
	   	.linear_state_s_out(linear_state_s_absorb1),
	   	.state_pos_out(state_pos_absorb1),
	   	.rts(rts_absorb1)
	   	);
	   	
	shake128_absorb #(.in_len(inlen_absorb2)) shake128_absorb2(
	   	.clock(clock),
	   	.reset(reset),
	   	.rtr(rts_absorb1),
	   	.linear_state_s_in(linear_state_s_absorb1),
	   	.state_pos_in(state_pos_absorb1),
	   	.linear_in(linear_t),
	   	.inlen(inlen_absorb2),
	   	.linear_state_s_out(linear_state_s_absorb2),
	   	.state_pos_out(state_pos_absorb2),
	   	.rts(rts_absorb2)
	   	);
	
	shake128_finalize shake128_finalize(
	   	.clock(clock),
	   	.reset(reset),
	   	.rtr(rts_absorb2),
	   	.linear_state_s_in(linear_state_s_absorb2),
	   	.state_pos_in(state_pos_absorb2),
	   	.linear_state_s_out(linear_state_s),
	   	.state_pos_out(state_pos),
	   	.rts(rts_finalize)
	   	);
	
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
                    rtr_absorb1 = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rtr_absorb1 = 0;
			        if (rtr == 1'b1) begin
			            next_state = RD_INP;
			        end
			        else begin
			            next_state = PRE_RD_INP;
			        end
                end
            RD_INP:
                begin
                    rtr_absorb1 = 1;
                    next_state = 3;
                end
            3:
                begin
                    if(rts_finalize) begin
	       	           if(~rtr) begin
				          next_state = IDLE;
				          rtr_absorb1 = 0;	
			           end
			           else begin
			              next_state = 3;
			              rtr_absorb1 = 1;
			           end
	       	        end   
	       	        else begin	       
	                   next_state = 3;
			           rtr_absorb1 = 1;
			        end
                end
            default:
                begin
                    next_state = IDLE;
                end
        endcase
    end
    
endmodule
