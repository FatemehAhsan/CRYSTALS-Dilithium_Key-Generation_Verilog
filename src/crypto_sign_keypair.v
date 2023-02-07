// In the name of Allah


module crypto_sign_keypair(
    input clock,
    input reset,
	input rtr,
    output rts,
    output [15615:0] linear_pk,
    output [29183:0] linear_sk
    );
    
    localparam K = 6;
    localparam L = 5;
    
    wire [255:0] linrear_randombytes;
    wire [1023:0] linear_seedbuf_shaked;
    wire [255:0] linear_rho;
    wire [511:0] linear_rhoprime;
    wire [255:0] linear_key;
    wire [255:0] linear_tr;
    wire signed [65535:0] linear_mat1;
	wire signed [65535:0] linear_mat2;
	wire signed [65535:0] linear_mat3;
	wire signed [49151:0] linear_mat4;
	wire [15:0] nonce_polyvecl_uniform_eta = 0;
    wire [15:0] nonce_polyveck_uniform_eta = L;
    wire signed [40959:0] linear_s1;
    wire signed [49151:0] linear_s2;
    wire signed [40959:0] linear_s1hat;
    wire rts_shake_1;
    wire rts_shake_2;
    wire rts_polyvecl_uniform_eta;
    wire rts_polyveck_uniform_eta;
    wire rts_polyvec_matrix_expand;
    wire rts_polyvecl_ntt;
	wire rts_polyvec_matrix_pointwise_montgomery;
	wire rts_polyvecl_invntt;
	wire signed [49151:0] linear_t1;
	wire signed [49151:0] linear_t1_reduced;
	wire signed [49151:0] linear_t1_invntt;
	wire signed [49151:0] linear_t1_added;
	wire signed [49151:0] linear_t1_caddqed;
	wire signed [49151:0] linear_t0;
	wire signed [49151:0] linear_t1_power2round;
	wire [255:0] linear_tr_inversed;
    
	 assign rts = rts_shake_2;
    
    randombytes #(.in_len(32)) randombytes(
        .linear_out(linrear_randombytes)
    );
    
	 localparam outlen_shake_1 = 1023;
    localparam len_shake_1 = 256;
    
    localparam outlen_shake_2 = 255;
    localparam len_shake_2 = 15616;
    
    SHAKE #(.r(1087), .c(511), .outlen(outlen_shake_1), .len(len_shake_1)) shake256_1 (
		.N(linrear_randombytes), 
		.reset(reset), 
		.clk(clock), 
		.SHAKEout(linear_seedbuf_shaked),
		.rtr(rtr),
		.rts(rts_shake_1)
	);
	
	wire [1023:0] linear_seedbuf_shaked_inverse;
    
    generate
		  genvar x;
		  for (x = 0; x < 128; x = x + 1) begin
			  assign linear_seedbuf_shaked_inverse[8 * x + 7:8 * x] = linear_seedbuf_shaked[8 * (127 - x) + 7:8 * (127 - x)];
		  end
	endgenerate
	  
    assign linear_rho = linear_seedbuf_shaked_inverse[255:0];
    assign linear_rhoprime = linear_seedbuf_shaked_inverse[767:256];
    assign linear_key = linear_seedbuf_shaked_inverse[1023:768];
    
    polyvec_matrix_expand polyvec_matrix_expand(
        .clock(clock),
        .reset(reset),
        .rtr(rts_shake_1),
        .linear_rho(linear_rho),
        .linear_mat1(linear_mat1),
        .linear_mat2(linear_mat2),
        .linear_mat3(linear_mat3),
        .linear_mat4(linear_mat4),
        .rts(rts_polyvec_matrix_expand)
    );
    
    polyvecl_uniform_eta polyvecl_uniform_eta(
        .clock(clock),
        .reset(reset),
        .rtr(rts_shake_1),
        .nonce(nonce_polyvecl_uniform_eta),
        .linear_seed(linear_rhoprime),
        .linear_v(linear_s1),
        .rts(rts_polyvecl_uniform_eta)
    );
    
    polyveck_uniform_eta polyveck_uniform_eta(
        .clock(clock),
        .reset(reset),
        .rtr(rts_shake_1),
        .nonce(nonce_polyveck_uniform_eta),
        .linear_seed(linear_rhoprime),
        .linear_v(linear_s2),
        .rts(rts_polyveck_uniform_eta)
    );
    
    wire [40959:0] linear_s1_inverse;
    
    generate
          genvar y;
		  for (x = 0; x < L; x = x + 1) begin
			  for (y = 0; y < 256; y = y + 1) begin
			  assign linear_s1_inverse[8192 * x + 32 * y + 31:8192 * x + 32 * y] = linear_s1[8192 * x + 32 * (255 - y) + 31:8192 * x + 32 * (255 - y)];
		      end
		  end
	endgenerate
   
    polyvecl_ntt polyvecl_ntt(
        .clock(clock),
        .reset(reset),
        .rtr(rts_polyvecl_uniform_eta),
        .linear_v_in(linear_s1_inverse),
        .linear_v_out(linear_s1hat),
        .rts(rts_polyvecl_ntt)
    );
    
    wire [40959:0] linear_s1hat_inverse;
    
    generate
          for (x = 0; x < L; x = x + 1) begin
			  for (y = 0; y < 256; y = y + 1) begin
			  assign linear_s1hat_inverse[8192 * x + 32 * y + 31:8192 * x + 32 * y] = linear_s1hat[8192 * x + 32 * (255 - y) + 31:8192 * x + 32 * (255 - y)];
		      end
		  end
	endgenerate
	
    polyvec_matrix_pointwise_montgomery polyvec_matrix_pointwise_montgomery(
        .clock(clock),
        .reset(reset),
        .rtr(rts_polyvecl_uniform_eta & rts_polyvec_matrix_expand),
        .linear_v(linear_s1hat_inverse),
        .linear_mat1(linear_mat1),
        .linear_mat2(linear_mat2),
        .linear_mat3(linear_mat3),
        .linear_mat4(linear_mat4),
        .linear_t(linear_t1),
        .rts(rts_polyvec_matrix_pointwise_montgomery)
    );
    
    polyveck_reduce polyveck_reduce(
        .linear_v_in(linear_t1),
        .linear_v_out(linear_t1_reduced)
    );
    
    wire [49151:0] linear_t1_reduced_inverse;
    
    generate
          for (x = 0; x < K; x = x + 1) begin
			  for (y = 0; y < 256; y = y + 1) begin
			  assign linear_t1_reduced_inverse[8192 * x + 32 * y + 31:8192 * x + 32 * y] = linear_t1_reduced[8192 * x + 32 * (255 - y) + 31:8192 * x + 32 * (255 - y)];
		      end
		  end
	endgenerate
	
    polyveck_invntt_tomont polyveck_invntt_tomont(
        .clock(clock),
        .reset(reset),
        .rtr(rts_polyvec_matrix_pointwise_montgomery),
        .linear_v_in(linear_t1_reduced_inverse),
        .linear_v_out(linear_t1_invntt),
        .rts(rts_polyvecl_invntt)
    );
    
    wire [49151:0] linear_t1_invntt_inverse;
    
    generate
          for (x = 0; x < K; x = x + 1) begin
			  for (y = 0; y < 256; y = y + 1) begin
			  assign linear_t1_invntt_inverse[8192 * x + 32 * y + 31:8192 * x + 32 * y] = linear_t1_invntt[8192 * x + 32 * (255 - y) + 31:8192 * x + 32 * (255 - y)];
		      end
		  end
	endgenerate
	
    polyveck_add polyveck_add(
        .linear_v(linear_t1_invntt_inverse),
        .linear_u(linear_s2),
        .linear_w(linear_t1_added)
    );
    
    polyveck_caddq polyveck_caddq(
        .linear_v_in(linear_t1_added),
        .linear_v_out(linear_t1_caddqed)
    );
    
    polyveck_power2round polyveck_power2round(
	    .linear_v(linear_t1_caddqed),
		.linear_v0(linear_t0),
	   	.linear_v1(linear_t1_power2round)
	   	);
    
    pack_pk pack_pk(
	    .linear_rho(linear_rho),
		.linear_t1(linear_t1_power2round),
	   	.linear_pk(linear_pk)
	   	);

	SHAKE #(.r(1087), .c(511), .outlen(outlen_shake_2), .len(len_shake_2)) shake256_2 (
		.N(linear_pk), 
		.reset(reset), 
		.clk(clock), 
		.rtr(rts_polyvecl_invntt),
		.SHAKEout(linear_tr),
		.rts(rts_shake_2)
	);
	
	generate
		  for (x = 0; x < 32; x = x + 1) begin
			  assign linear_tr_inversed[8 * x + 7:8 * x] = linear_tr[8 * (31 - x) + 7:8 * (31 - x)];
		  end
	endgenerate
	
	pack_sk pack_sk(
	    .linear_rho(linear_rho),
		.linear_key(linear_key),
	   	.linear_tr(linear_tr_inversed),
	   	.linear_t0(linear_t0),
	   	.linear_s1(linear_s1),
	   	.linear_s2(linear_s2),
	   	.linear_sk(linear_sk)
	   	);
	   	   	
    localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
	
    always @(posedge clock) begin
        if (reset == 1'b1) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE:
                begin
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                    begin
			            if (rtr == 1'b1) begin
			                next_state = RD_INP;
			            end
			            else begin
			                 next_state = PRE_RD_INP;
			            end
                    end
            RD_INP:
                    begin
                    end
        endcase
    end
    	    
endmodule
