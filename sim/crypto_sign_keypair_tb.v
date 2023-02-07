// In the name of Allah


module crypto_sign_keypair_tb;
    
    // Inputs
    reg clock = 1'b0;
    reg reset = 1'b1;
	wire rtr = 1'b1;
	
	// Outputs
    wire rts;
    
    wire [15615:0] linear_pk;
    wire [29183:0] linear_sk;
    
    wire [7:0] pk [1951:0];
    wire [7:0] sk [3647:0];
    
    crypto_sign_keypair uut(
        .clock(clock),
        .reset(reset),
        .rtr(rtr),
        .rts(rts),
        .linear_pk(linear_pk),
        .linear_sk(linear_sk)
    );
    
    generate
		  genvar x;
		  for (x = 0; x < 1952; x = x + 1) begin
			  assign pk[x] = linear_pk[8 * x + 7:8 * x];
		  end
	endgenerate
	
	generate
		  for (x = 0; x < 3648; x = x + 1) begin
			  assign sk[x] = linear_sk[8 * x + 7:8 * x];
		  end
	endgenerate
	
	integer i, j;  
	 
    always #1 clock = ~clock; 
      
    initial
        begin
            #100 reset <= 1'b0;  
            #115000
            for(i = 0; i < 1952; i = i + 1) begin  
                $display("%x", pk[i]);  
            end
            for(j = 0; j < 3648; j = j + 1) begin  
                $display("%x", sk[j]);  
            end
        end
endmodule
