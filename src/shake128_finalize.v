// In the name of Allah


module shake128_finalize(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_state_s_in,
    input [31:0] state_pos_in,
    output [1599:0] linear_state_s_out,
    output [31:0] state_pos_out,
    output rts
    );
    
    localparam SHAKE128_RATE = 168;
    localparam p = 8'd31;
    
    keccak_finalize keccak_finalize(
	   	.clock(clock),
	   	.rtr(rtr),
	   	.reset(reset),
	   	.linear_s_in(linear_state_s_in),
	   	.pos(state_pos_in),
	   	.r(SHAKE128_RATE),
	   	.p(p),
	   	.linear_s_out(linear_state_s_out),
	   	.rts(rts)
	   	);
	   	
	assign state_pos_out = SHAKE128_RATE;
	   	
endmodule
