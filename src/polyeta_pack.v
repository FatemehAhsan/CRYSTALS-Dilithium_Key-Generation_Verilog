// In the name of Allah


module polyeta_pack(
    input signed [8191:0] linear_a,
    output [767:0] linear_r
    );
    
    localparam N = 256;
    localparam ETA = 32'd4;
    
    wire [0:7] r [0:95];
    
    generate
        genvar i;
        for (i = 0; i < 96; i = i + 1) begin
		    assign r[i] = (ETA - linear_a[64 * i + 31:64 * i]) | (ETA - linear_a[64 * i + 63:64 * i + 32] << 4);
        end
	endgenerate
	
	generate
        for (i = 0; i < 96; i = i + 1) begin
		    assign linear_r[i * 8 + 7:i * 8] = r[i];
        end
	endgenerate
endmodule
