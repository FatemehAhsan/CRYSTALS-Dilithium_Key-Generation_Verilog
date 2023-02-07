module caddq(
    input signed [31:0] a,
    output  signed [31:0] out
    );
    wire signed [31:0] temp;
    assign temp = (a >>> 31) & 32'sd8380417;
    assign out = a + temp;
endmodule
