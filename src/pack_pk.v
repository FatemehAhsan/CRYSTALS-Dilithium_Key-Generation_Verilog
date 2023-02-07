// In the name of Allah


module pack_pk(
    input [255:0] linear_rho,
    input [49151:0] linear_t1,
	output [15615:0] linear_pk
    );
    
    localparam POLYT1_PACKEDBYTES = 320;
    localparam SEEDBYTES = 32;
    localparam K = 6;
    
    assign linear_pk[255:0] = linear_rho;
    
    generate
        genvar i;
        for (i = 0; i < K; i = i + 1)
            polyt1_pack polyt1_pack(.linear_a(linear_t1[8192 * i + 8191:8192 * i]), .linear_r(linear_pk[8 * POLYT1_PACKEDBYTES * i + 8 * POLYT1_PACKEDBYTES - 1 + 256:8 * POLYT1_PACKEDBYTES * i + 256]));
	endgenerate
	
endmodule
