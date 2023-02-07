// In the name of Allah

module poly_uniform(
    input clock,
    input reset,
    input rtr,
    input [255:0] linear_seed,
    input [15:0] nonce,
    output signed [8191:0] linear_a,
    output reg rts
    );
    
    localparam N = 256;
    localparam SHAKE128_RATE = 168;
    
    //Inter Outputs
	wire [1599:0] linear_state_s;
	wire [31:0] state_pos;
	wire [6735:0] linear_buf;
    wire [1599:0] linear_state_s_out;
    
    reg rtr_dilithium_shake128_stream_init;
    wire rts_dilithium_shake128_stream_init;
    wire rts_shake128_squeezeblocks;
    
	reg [63:0] nblocks = 5;
	reg [31:0] len = 256;
	reg [31:0] buflen = 840;
	
	reg [7:0] buff [0:841];
	wire [7:0] buff_in [0:841];
	
	//Inter Outputs
	wire [31:0] ctr;
	
	wire rts_rej_uniform;
	 
	generate
        genvar x;
		for (x = 0; x < 842; x = x + 1) begin
		    assign buff_in[x] = linear_buf[8 * x + 7:8 * x]; 
		end
	endgenerate
	
    dilithium_shake128_stream_init dilithium_shake128_stream_init(
        .clock(clock),
        .reset(reset),
        .rtr(rtr_dilithium_shake128_stream_init),
        .linear_seed(linear_seed),
        .nonce(nonce),
        .linear_state_s(linear_state_s),
        .state_pos(state_pos),
        .rts(rts_dilithium_shake128_stream_init)
    );
    
    shake128_squeezeblocks shake128_squeezeblocks(
	   	.clock(clock),
	   	.reset(reset),
        .rtr(rts_dilithium_shake128_stream_init),
        .linear_state_s_in(linear_state_s),
	   	.nblocks(nblocks),
	   	.linear_out(linear_buf),
	   	.linear_state_s_out(linear_state_s_out),
	   	.rts(rts_shake128_squeezeblocks)
	   	);  
	
	rej_uniform rej_uniform(
	   	.clock(clock),
	   	.reset(reset),
        .rtr(rts_shake128_squeezeblocks),
	   	.len(len),
		.linear_buf(linear_buf),
		.buflen(buflen),
	   	.linear_a(linear_a),
	   	.ctr(ctr),
	   	.rts(rts_rej_uniform)
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
                    rts = 0;
                    rtr_dilithium_shake128_stream_init = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
                    rtr_dilithium_shake128_stream_init = 0;
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
                    if(rts_rej_uniform) begin
	       	           next_state = RD_INP;
	       	           rtr_dilithium_shake128_stream_init = 0;
	       	        end   
	       	        else begin	       
	                   rtr_dilithium_shake128_stream_init = 1;
	                   next_state = 3;
			         end
                end
            3:
                begin
                    if(rts_rej_uniform) begin
	       	           rts = 1;
			           if(~rtr) begin
				          next_state = IDLE;
				          rtr_dilithium_shake128_stream_init = 0;	
			           end
			           else begin
			              next_state = 3;
			              rtr_dilithium_shake128_stream_init = 1;
			           end
	       	        end   
	       	        else begin	       
	                   rts = 0;
			           next_state = 3;
			           rtr_dilithium_shake128_stream_init = 1;
			        end
                end
            default:
                begin
                    next_state = IDLE;
                end
        endcase
    end
       	
endmodule
