// In the name of Allah


module poly_caddq(
    input signed [8191:0] linear_a_in,
    output signed [8191:0] linear_a_out
    );
    
    localparam N = 256;
    
    wire signed [31:0] a_in [0:N - 1];
    wire signed [31:0] a_out [0:N - 1];
   
    generate
        genvar x;
        for (x = 0; x < N; x = x + 1) begin
		    assign a_in[x] = linear_a_in[32 * x + 31:32 * x];
		    caddq caddq(.a(a_in[x]), .out(a_out[x]));
		    assign linear_a_out[32 * x + 31:32 * x] = a_out[x];
		end
	endgenerate
    
endmodule
