
module reduce32(
    input signed [31:0]a,
    output signed [31:0]t
    );
wire signed [63:0] temp;
assign temp = (a + (1 << 22)) >> 23;
wire signed [63:0] temp2;
assign temp2 = temp * 32'sd8380417;
assign t = a - temp2;


endmodule
