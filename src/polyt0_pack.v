// In the name of Allah


module polyt0_pack(
    input signed [8191:0] linear_a,
    output [3327:0] linear_r
    );
    
    localparam N = 256;
    localparam D = 13;
    
    wire [0:31] t [0:31][0:7];
    wire [0:7] r [0:415];
    
    generate
        genvar i;
        for (i = 0; i < N / 8; i = i + 1) begin
            assign t[i][0] = (1 << (D - 1)) - linear_a[256 * i + 31:256 * i];
            assign t[i][1] = (1 << (D - 1)) - linear_a[256 * i + 63:256 * i + 32];
            assign t[i][2] = (1 << (D - 1)) - linear_a[256 * i + 95:256 * i + 64];
            assign t[i][3] = (1 << (D - 1)) - linear_a[256 * i + 127:256 * i + 96];
            assign t[i][4] = (1 << (D - 1)) - linear_a[256 * i + 159:256 * i + 128];
            assign t[i][5] = (1 << (D - 1)) - linear_a[256 * i + 191:256 * i + 160];
            assign t[i][6] = (1 << (D - 1)) - linear_a[256 * i + 223:256 * i + 192];
            assign t[i][7] = (1 << (D - 1)) - linear_a[256 * i + 255:256 * i + 224];
            assign r[13 * i + 0]  =  t[i][0];
            assign r[13 * i + 1] = t[i][0] >> 8 | (t[i][1] << 5);
            assign r[13 * i + 2]  =  t[i][1] >> 3;
            assign r[13 * i + 3]  =  t[i][1] >> 11 | (t[i][2] << 2);
            assign r[13 * i + 4]  =  t[i][2] >> 6 | (t[i][3] << 7);
            assign r[13 * i + 5]  =  t[i][3] >> 1;
            assign r[13 * i + 6]  =  t[i][3] >> 9 | (t[i][4] << 4);
            assign r[13 * i + 7]  =  t[i][4] >> 4;
            assign r[13 * i + 8]  =  t[i][4] >> 12 | (t[i][5] << 1);
            assign r[13 * i + 9]  =  t[i][5] >>  7 | (t[i][6] << 6);
            assign r[13 * i + 10]  =  t[i][6] >> 2;
            assign r[13 * i + 11]  =  t[i][6] >> 10 | (t[i][7] << 3);
            assign r[13 * i + 12]  =  t[i][7] >> 5;
        end
	endgenerate
	
	generate
        for (i = 0; i < 416; i = i + 1) begin
            assign linear_r[8 * i + 7:8 * i] = r[i];
        end
    endgenerate
    
endmodule
