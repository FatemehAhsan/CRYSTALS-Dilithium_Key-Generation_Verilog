// In the name of Allah


module polyt1_pack(
    input signed [8191:0] linear_a,
    output [2559:0] linear_r
    );
    
    localparam N = 256;
    
    generate
        genvar i;
        for (i = 0; i < N / 4; i = i + 1) begin
		    assign linear_r[8 * (5 * i) + 7:8 * (5 * i)] = (linear_a[32 * (4 * i) + 31:32 * (4 * i)] >> 0);
            assign linear_r[8 * (5 * i + 1) + 7:8 * (5 * i + 1)] = (linear_a[32 * (4 * i) + 31:32 * (4 * i)] >> 8) | (linear_a[32 * (4 * i + 1) + 31:32 * (4 * i + 1)] << 2);
            assign linear_r[8 * (5 * i + 2) + 7:8 * (5 * i + 2)] = (linear_a[32 * (4 * i + 1) + 31:32 * (4 * i + 1)] >> 6) | (linear_a[32 * (4 * i + 2) + 31:32 * (4 * i + 2)] << 4);
            assign linear_r[8 * (5 * i + 3) + 7:8 * (5 * i + 3)] = (linear_a[32 * (4 * i + 2) + 31:32 * (4 * i + 2)] >> 4) | (linear_a[32 * (4 * i + 3) + 31:32 * (4 * i + 3)] << 6);
            assign linear_r[8 * (5 * i + 4) + 7:8 * (5 * i + 4)] = (linear_a[32 * (4 * i + 3) + 31:32 * (4 * i + 3)] >> 2);
		end
	endgenerate
	
endmodule
