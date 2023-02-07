// In the name of Allah


module polyveck_caddq(
    input signed [49151:0] linear_v_in,
    output signed [49151:0] linear_v_out
	);
    
    localparam K = 6;
    
    wire signed [8191:0] v_in [0:K - 1];
    wire signed [8191:0] v_out [0:K - 1];
    
    generate
        genvar x;
        for (x = 0; x < K; x = x + 1) begin
		    assign v_in[x] = linear_v_in[8192 * x + 8191:8192 * x];
		    poly_caddq poly_caddq(.linear_a_in(v_in[x]), .linear_a_out(v_out[x]));
		    assign linear_v_out[8192 * x + 8191:8192 * x] = v_out[x];
		end
	endgenerate
	
endmodule
