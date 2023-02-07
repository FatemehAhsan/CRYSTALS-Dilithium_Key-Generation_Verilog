// In the name of Allah


module polyveck_power2round(
    input signed [49151:0] linear_v,
    output signed [49151:0] linear_v1,
    output signed [49151:0] linear_v0
    );
    
    localparam K = 6;
    
    wire signed [8191:0] v [0:K - 1];
    wire signed [8191:0] v0 [0:K - 1];
    wire signed [8191:0] v1 [0:K - 1];
    
    generate
        genvar x;
        for (x = 0; x < K; x = x + 1) begin
    	    assign v[x] = linear_v[8192 * x + 8191:8192 * x];
    	    poly_power2round poly_power2round(.linear_a(v[x]), .linear_a0(v0[x]), .linear_a1(v1[x]));
    	    assign linear_v0[8192 * x + 8191:8192 * x] = v0[x];
    	    assign linear_v1[8192 * x + 8191:8192 * x] = v1[x]; 
        end
    endgenerate
	
endmodule
