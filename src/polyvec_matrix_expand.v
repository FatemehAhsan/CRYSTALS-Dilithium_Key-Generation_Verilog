// In the name of Allah


module polyvec_matrix_expand(
    input clock,
    input reset,
	input rtr,
    input [255:0] linear_rho,
    output signed [65535:0] linear_mat1,
    output signed [65535:0] linear_mat2,
    output signed [65535:0] linear_mat3,
    output signed [49151:0] linear_mat4,
	output reg rts
    );
    
    localparam K = 6;
    localparam L = 5;
    
    reg [2:0] i;
    reg [2:0] j;
	
	wire [15:0] nonce = (i << 8) + j;                
    
    reg rtr_poly_uniform;
    reg [4:0] linear_mat_column_i;
	
    // Outputs
    wire signed [8191:0] linear_a;
    wire rts_poly_uniform;
    
    reg signed [8191:0] linear_mat_column1 [0:7];
    reg signed [8191:0] linear_mat_column2 [0:7];
    reg signed [8191:0] linear_mat_column3 [0:7];
    reg signed [8191:0] linear_mat_column4 [0:5];
   
    poly_uniform poly_uniform(
        .clock(clock),
        .reset(reset),
        .rtr(rtr_poly_uniform),
        .linear_seed(linear_rho),
        .nonce(nonce),
        .linear_a(linear_a),
        .rts(rts_poly_uniform)
    );
    
    generate
        genvar x;
		for (x = 0; x < 8; x = x + 1) begin
		    assign linear_mat1[8192 * x + 8191:8192 * x] = linear_mat_column1[x]; 
		end
	endgenerate
	
	generate
        for (x = 0; x < 8; x = x + 1) begin
		    assign linear_mat2[8192 * x + 8191:8192 * x] = linear_mat_column2[x]; 
		end
	endgenerate
	
	generate
        for (x = 0; x < 8; x = x + 1) begin
		    assign linear_mat3[8192 * x + 8191:8192 * x] = linear_mat_column3[x]; 
		end
	endgenerate
	
	generate
        for (x = 0; x < 6; x = x + 1) begin
		    assign linear_mat4[8192 * x + 8191:8192 * x] = linear_mat_column4[x]; 
		end
	endgenerate
	
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
                    rts = 0;
                    rtr_poly_uniform = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
			        rtr_poly_uniform = 0;
                    if (rtr == 1'b1) begin
			            next_state = RD_INP;
			        end
			        else begin
			            next_state = PRE_RD_INP;
			        end
                end
            RD_INP:
                begin
                    rts = 0;
                    rtr_poly_uniform = 0;
                    next_state = 3;
                end
            3:
                begin
                    rts = 0;
                    rtr_poly_uniform = 1;
                    next_state = 4;
                end
            4:
                begin
                    rts = 0;
                    if(rts_poly_uniform) begin
                       if(~(i + 1 == K && j + 1 == L))
	                       next_state = 3;
				       else
					       next_state = 5;
					   rtr_poly_uniform = 0;
                    end
                    else begin
                        next_state = 4;
                        rtr_poly_uniform = 1;
                    end     
                end
            5:
                begin
                    rts = 1;
			        rtr_poly_uniform = 0;
                    if(~rtr) begin
				        next_state = IDLE;
			        end
			        else begin
			            next_state = 5;
			        end
                end
            default:
                begin
                    next_state = IDLE;
                end
        endcase
    end
    
    always @ (posedge clock) begin
	case (state)
	RD_INP:
	   	begin
	       	i <= 0;
		    j <= 0;
		   	linear_mat_column_i <= 0;			
	   	end
	3:
		begin
	   	end
	4:
	   	begin
	      	if(rts_poly_uniform) begin
	            if(linear_mat_column_i < 8)
	               linear_mat_column1[linear_mat_column_i] <= linear_a;
	            else if (linear_mat_column_i < 16)
	               linear_mat_column2[linear_mat_column_i - 8] <= linear_a;
	            else if (linear_mat_column_i < 24)
	               linear_mat_column3[linear_mat_column_i - 16] <= linear_a;
	            else
	               linear_mat_column4[linear_mat_column_i - 24] <= linear_a;
	            linear_mat_column_i <= linear_mat_column_i + 1;
	            if(j + 1 == L) begin
	               i <= i + 1;
	               j <= 0;
	            end
	            else
	               j <= j + 1;
	        end
	   	end
	5:
		begin
		end		
	endcase
	end
	
endmodule
