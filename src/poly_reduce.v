// In the name of Allah


module poly_reduce(
    input signed [8191:0] linear_a_in,
    output signed [8191:0] linear_a_out
    );
    
    localparam N = 256;
    
    wire signed [31:0] a [0:N - 1];
    wire signed [31:0] t [0:N - 1];
  
    generate
        genvar x;
        for (x = 0; x < N; x = x + 1) begin
		    assign a[x] = linear_a_in[32 * x + 31:32 * x];
		    reduce32 reduce32(.a(a[x]), .t(t[x]));
		    assign linear_a_out[32 * x + 31:32 * x] = t[x];
		end
	endgenerate
    
endmodule
