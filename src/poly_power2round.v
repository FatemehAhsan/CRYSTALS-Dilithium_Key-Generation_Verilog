// In the name of Allah


module poly_power2round(
    input signed [8191:0] linear_a,
    output signed [8191:0] linear_a0,
    output signed [8191:0] linear_a1
    );

    localparam N = 256;

    wire signed [31:0] a [0:255];
    wire signed [31:0] a0 [0:255];
    wire signed [31:0] a1 [0:255];  

	   	
    generate
		genvar x;
		for (x = 0; x < N; x = x + 1) begin
		    assign a[x] = linear_a[32 * x + 31:32 * x];
		    power2round power2round(.a(a[x]), .a0(a0[x]), .a1(a1[x]));
		    assign linear_a0[32 * x + 31:32 * x] = a0[x]; 
		    assign linear_a1[32 * x + 31:32 * x] = a1[x];
		end
	endgenerate

endmodule
