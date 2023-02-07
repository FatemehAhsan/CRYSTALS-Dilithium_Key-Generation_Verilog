// In the name of Allah


module shake256_init(
    output [1599:0] linear_state_s,
    output [31:0] state_pos
    );
    
    keccak_init keccak_init(
	   	.linear_s(linear_state_s)
	   	);
	
	assign state_pos = 0;
	
endmodule
