// In the name of Allah


module polyvec_matrix_pointwise_montgomery(
    input clock,
	input reset,
	input rtr,
	input signed [40959:0] linear_v,
    input signed [65535:0] linear_mat1,
    input signed [65535:0] linear_mat2,
    input signed [65535:0] linear_mat3,
    input signed [49151:0] linear_mat4,
    output signed [49151:0] linear_t,
	output reg rts
	);
	
	localparam K = 6;
    
    // Inputs
    reg rtr_polyvecl_pointwise_acc_montgomery;
    reg signed [40959:0] linear_u;
	
    // Outputs
    wire signed [8191:0] linear_w;
    wire rts_polyvecl_pointwise_acc_montgomery;
    
    reg signed [8191:0] t [0:K - 1];
    
    polyvecl_pointwise_acc_montgomery polyvecl_pointwise_acc_montgomery(
        .clock(clock),
        .reset(reset),
        .rtr(rtr_polyvecl_pointwise_acc_montgomery),
        .linear_u(linear_u),
        .linear_v(linear_v),
        .linear_w(linear_w),
        .rts(rts_polyvecl_pointwise_acc_montgomery)
    );
    
    generate
        genvar x;
		for (x = 0; x < K; x = x + 1) begin
		    assign linear_t[8192 * x + 8191:8192 * x] = t[x]; 
		end
	endgenerate
	
    reg [2:0] i;
    
    always @ (*)
        case(i)
        0:
            linear_u <= linear_mat1[40959:0];
        1:
            linear_u <= {linear_mat2[16383:0], linear_mat1[65535:40960]};
        2:
            linear_u <= linear_mat2[57343:16384];
        3:
            linear_u <= {linear_mat3[32767:0], linear_mat2[65535:57344]};
        4:
            linear_u <= {linear_mat4[8191:0], linear_mat3[65535:32768]};
        5:
            linear_u <= linear_mat4[49151:8192];
        endcase
        
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
                    rtr_polyvecl_pointwise_acc_montgomery = 0;
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
                    rtr_polyvecl_pointwise_acc_montgomery = 0;
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
                    rtr_polyvecl_pointwise_acc_montgomery = 0;
                    next_state = 3;
                end
            3:
                begin
                    rts = 0;
                    rtr_polyvecl_pointwise_acc_montgomery = 1;
                    next_state = 4;
                end
            4:
                begin
                    rts = 0;
                    if(rts_polyvecl_pointwise_acc_montgomery) begin
                        rtr_polyvecl_pointwise_acc_montgomery = 0;
                        if (i + 1 < K) begin
			                next_state = 3;
			            end
			            else begin
			                next_state = 5;
			            end
			         end
			         else begin
			             rtr_polyvecl_pointwise_acc_montgomery = 1;
			             next_state = 4;
			         end
			    end
            5:
                begin    
                    rts = 1;
                    if (~rtr) begin
			            next_state = IDLE;
			        end
			        else begin
			            next_state = 5;
			        end
			    end    
        endcase
	end
	
    always @ (posedge clock) begin
	case (state)
	2:
	   	i <= 0;
	4:
	   	begin
	      	if(rts_polyvecl_pointwise_acc_montgomery) begin
	            t[i] <= linear_w;
	            i <= i + 1;
	        end
	   	end
	endcase
	end
	
endmodule
