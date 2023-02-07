// In the name of Allah


module polyveck_add(
    input signed [49151:0] linear_u,
    input signed [49151:0] linear_v,
    output signed [49151:0] linear_w
	);
    
    localparam K = 6;
    
    wire signed [8191:0] u [0:K - 1];
    wire signed [8191:0] v [0:K - 1];
    wire signed [8191:0] w [0:K - 1];
    
    generate
        genvar x;
        for (x = 0; x < K; x = x + 1) begin
		    assign u[x] = linear_u[8192 * x + 8191:8192 * x];
		    assign v[x] = linear_v[8192 * x + 8191:8192 * x];
		    poly_add poly_add(.linear_a(u[x]), .linear_b(v[x]), .linear_c(w[x]));
		    assign linear_w[8192 * x + 8191:8192 * x] = w[x];
		end
	endgenerate
	
endmodule
