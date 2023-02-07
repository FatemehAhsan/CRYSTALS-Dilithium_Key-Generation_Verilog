// In the name of Allah


module shake256_absorb #(parameter in_len = 32)(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_state_s_in,
    input [31:0] state_pos_in,
    input [in_len * 8 - 1:0] linear_in,
    input [63:0] inlen,
    output [1599:0] linear_state_s_out,
    output [31:0] state_pos_out,
    output rts
    );
    
    localparam SHAKE256_RATE = 136;

    keccak_absorb #(.in_len(in_len)) keccak_absorb(
	   	.clock(clock),
	   	.reset(reset),
	   	.rtr(rtr),
	   	.linear_s_in(linear_state_s_in),
	   	.pos(state_pos_in),
	   	.r(SHAKE256_RATE),
	   	.linear_in(linear_in),
	   	.inlen(inlen),
	   	.linear_s_out(linear_state_s_out),
	   	.i(state_pos_out),
	   	.rts(rts)
	   	);
	   	
endmodule
