// In the name of Allah


module shake256_squeezeblocks(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_sate_s_in,
    input [63:0] nblocks,
    output [2175:0] linear_out,
    output [1599:0] linear_state_s_out,
    output rts
    );
    
    localparam SHAKE256_RATE = 136;
    
    keccak_squeezeblocks#(.outlen(2176)) keccak_squeezeblocks(
	   	.clock(clock),
	   	.reset(reset),
	   	.rtr(rtr),
	   	.nblocks(nblocks),
	   	.linear_s_in(linear_sate_s_in),
	   	.r(SHAKE256_RATE),
	   	.linear_out(linear_out),
	   	.linear_s_out(linear_state_s_out),
	   	.rts(rts)
	   	);
	   	 	
endmodule
