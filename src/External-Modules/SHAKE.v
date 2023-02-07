module SHAKE #(parameter r = 1343, parameter c = 127, parameter outlen = 511, parameter len = 512) (N, clk, reset, SHAKEout, rtr, rts);  
    input [len - 1:0] N;
    input reset, clk;
    output [outlen:0] SHAKEout;
    input rtr;
	output reg rts;
	
    reg [1599:0] A;
    wire [1599:0] Aout;
    wire [1087:0] P_slices [0:len / 1088];
    wire [(len / 1088 + 1) * 1088 - 1:0] P;
    wire [outlen:0] SHAKE;

    reg rstPF;
    reg [2:0] rstPFCount;
    
    reg [3:0] index;
	
	generate
		  genvar x;
		  for (x = 0; x <= len / 1088; x = x + 1) begin
			  assign P_slices[x] = P[1088 * x + 1087:1088 * x];
		  end
	endgenerate
	 
    localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state = IDLE;
	
	always @(posedge clk) begin
        begin
            if(reset)
                state <= IDLE;
            else
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
                    if(rstPFCount < 3'b101) begin
				        next_state = 4;
		   	        end
		   	        else 
		      	       if(index <= len / 1088)
		      	           next_state = 3;
		      	       else
		      	           next_state = 5;
		      	 end 	   
            5:
                begin
                    rts = 1;
                    if(~rtr) 
		          	    next_state = 0;
		      	    else
		      	        next_state = 5; 
		      	end
            endcase
        end
    
    always @(posedge clk) begin
        case (state)
        RD_INP:
            begin
                index <= 0;
            end 
        3:
            begin
                index <= index + 1;  
                if(index == 0) begin
                    A <= 0;
                    A[r:0] <= P_slices[index];
                end
                else
                    A <= Aout ^ P_slices[index];
                rstPF <= 1;
                rstPFCount <= 3'b0;
            end
        4:
            if(rstPFCount < 3'b101 ) begin
                rstPF <= 0;
                rstPFCount <= rstPFCount + 1;
            end
        endcase
    end

    SHAKE_Pad #(.r(r), .len(len)) SHAKE_Pad_u(.N(N), .P(P));
    PermuteFunction PermuteFunction_u( .A(A), .Aout(Aout), .clk(clk), .rst(rstPF));
    assign SHAKE = Aout[outlen:0];
    
    generate
        for (x = 0; x < (outlen + 1) / 8; x = x + 1)begin
	        assign SHAKEout[8 * (((outlen + 1) / 8 - 1) - x) + 7: 8 * (((outlen + 1) / 8 - 1) - x)] = SHAKE[8 * x + 7: 8 * x];
        end
    endgenerate
    
endmodule
