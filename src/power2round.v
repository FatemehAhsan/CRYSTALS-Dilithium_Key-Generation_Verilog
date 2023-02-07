// In the name of Allah


module power2round(
    input signed [31:0] a,
    output signed [31:0] a0,
    output signed [31:0] a1
    );

    localparam D = 13;

    assign a1 = (a + (1 << (D-1)) - 1) >> D;
    assign a0 = a - (a1 << D);

endmodule
