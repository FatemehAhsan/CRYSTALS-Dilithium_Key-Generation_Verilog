// In the name of Allah


module pack_sk(
    input [255:0] linear_rho,
    input [255:0] linear_key,
    input [255:0] linear_tr,
    input [49151:0] linear_t0,
	input [40959:0] linear_s1,
	input [49151:0] linear_s2,
	output [29183:0] linear_sk
    );
    
    localparam K = 6;
    localparam L = 5;
    localparam POLYETA_PACKEDBYTES = 96;
    
    assign linear_sk[255:0] = linear_rho;
    assign linear_sk[511:256] = linear_key;
    assign linear_sk[767:512] = linear_tr;
    
    wire [3839:0] polyeta_pack_s1;
    
    generate
        genvar i;
        for (i = 0; i < L; i = i + 1) begin
             polyeta_pack polyeta_pack_1(.linear_a(linear_s1[8192 * i + 8191:8192 * i]), .linear_r(polyeta_pack_s1[768 * i + 767:768 * i]));
	    end
    endgenerate

    assign linear_sk[4607:768] = polyeta_pack_s1;
    
    wire [4607:0] polyeta_pack_s2;
    
    generate
        for (i = 0; i < K; i = i + 1) begin
             polyeta_pack polyeta_pack_2(.linear_a(linear_s2[8192 * i + 8191:8192 * i]), .linear_r(polyeta_pack_s2[768 * i + 767:768 * i]));
	    end
    endgenerate

    assign linear_sk[9215:4608] = polyeta_pack_s2; 
    wire [19967:0] polyet0_pack;
    
    generate
        for (i = 0; i < K; i = i + 1) begin
             polyt0_pack polyt0_pack_1(.linear_a(linear_t0[8192 * i + 8191:8192 * i]), .linear_r(polyet0_pack[3328 * i + 3327:3328 * i]));
	    end
    endgenerate
    
    assign linear_sk[29183:9216] = polyet0_pack; 
    	
endmodule
