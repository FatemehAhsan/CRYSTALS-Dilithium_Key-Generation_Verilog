module montgomery_reduce(
    input signed [63:0] a,
    output signed [31:0]t
    );
	 wire signed [31:0] temp;
	 wire signed [63:0] temp2;
	 assign temp = a * 32'sd58728449;
	 assign temp2 = temp * 32'sd8380417;
	 assign t = (a - temp2) >> 32;
endmodule 