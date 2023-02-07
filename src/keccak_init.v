// In the name of Allah

module keccak_init(
    output [1599:0] linear_s
    );
    
    wire [63:0] s [0:24];
    
    generate
        genvar x;
		for (x = 0; x < 25; x = x + 1) begin
		    assign s[x] = 0;
			assign linear_s[64 * x + 63:64 * x] = s[x];
		end
	endgenerate
	
endmodule
