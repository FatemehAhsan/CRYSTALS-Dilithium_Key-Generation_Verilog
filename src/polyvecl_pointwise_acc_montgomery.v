// In the name of Allah


module polyvecl_pointwise_acc_montgomery(
    input clock,
	input reset,
	input rtr,
	input [40959:0] linear_u,
    input [40959:0] linear_v,
    output reg [8191:0] linear_w,
    output reg rts
	);
	
	localparam L = 5;
    
    // Inputs
    reg [8191:0] linear_a;
    reg [8191:0] linear_b;
    
    wire [8191:0] linear_c_add;
    
    // Outputs
    wire [8191:0] linear_t;
 
    wire [8191:0] u [0:L - 1];
    wire [8191:0] v [0:L - 1];
    
    poly_pointwise_montgomery poly_pointwise_montgomery(
        .linear_a(linear_a),
        .linear_b(linear_b),
        .linear_c(linear_t)
    );
    
    poly_add poly_add(
        .linear_a(linear_w),
        .linear_b(linear_t),
        .linear_c(linear_c_add)
    );
    
	generate
	       genvar x;
        for (x = 0; x < L; x = x + 1) begin
		    assign u[x] = linear_u[8192 * x + 8191:8192 * x];
		    assign v[x] = linear_v[8192 * x + 8191:8192 * x]; 
		end
	endgenerate
	
    reg [2:0] i;
    
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
                    next_state = PRE_RD_INP;
                end
            PRE_RD_INP:
                begin
                    rts = 0;
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
                    next_state = 3;
                end
            3:
                begin
                    rts = 0;
                    next_state = 4;
                end
            4:
                begin
                    rts = 0;
                    if (i + 1 < L) begin
			            next_state = 3;
			        end
			        else begin
			            next_state = 5;
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
	   	begin
	       	begin
	       		i <= 0;
	       		linear_w <= 8192'd0;
			end
	   	end
	3:
	   	begin
	   	    linear_a <= u[i];
	        linear_b <= v[i];
	   	end
	4:
	   	begin
	      	linear_w <= linear_c_add;
	        i <= i + 1;    
	   	end
	endcase
	end
	
endmodule
