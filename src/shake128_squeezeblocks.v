// In the name of Allah


module shake128_squeezeblocks(
    input clock,
    input reset,
    input rtr,
    input [1599:0] linear_state_s_in,
    input [63:0] nblocks,
    output [6735:0] linear_out,
    output [1599:0] linear_state_s_out,
    output rts
    );
    
    localparam SHAKE128_RATE = 168;
    
    keccak_squeezeblocks#(.outlen(6736)) keccak_squeezeblocks(
	   	.clock(clock),
	   	.reset(reset),
        .rtr(rtr),
	   	.nblocks(nblocks),
	   	.linear_s_in(linear_state_s_in),
	   	.r(SHAKE128_RATE),
	   	.linear_out(linear_out),
	   	.linear_s_out(linear_state_s_out),
	   	.rts(rts)
	   	);
	   	 	
endmodule
