// In the name of Allah


module poly_add(
    input signed [8191:0] linear_a,
    input signed [8191:0] linear_b,
    output signed [8191:0] linear_c
    );
    
    localparam N = 256;
    
    wire signed [31:0] a [0:N - 1];
    wire signed [31:0] b [0:N - 1];
    wire signed [31:0] c [0:N - 1];

    generate
        genvar x;
        for (x = 0; x < N; x = x + 1) begin
		    assign a[x] = linear_a[32 * x + 31:32 * x];
		    assign b[x] = linear_b[32 * x + 31:32 * x];
		    assign c[x] = a[x] + b[x];
		    assign linear_c[32 * x + 31:32 * x] = c[x];
		end
	endgenerate
    
endmodule
