module Theta( LinearA, LinearAout);
    input [1599:0] LinearA;
    output [1599:0] LinearAout;

    wire [63:0] A [0:4][0:4];
    wire [63:0] Aout [0:4][0:4];

//  a[x][y][k] ==> (5x+y)w+k
    generate
        genvar x,y;
        for (x = 0; x<5; x = x+1)begin
	        for (y = 0; y<5; y = y +1)begin	
	            assign A[x][y] = LinearA[320 * y + 64 * x + 63:320 * y + 64 * x]; 
	
	        end
        end

    endgenerate


    generate
        for (x = 0; x<5; x = x+1)begin
        	for (y = 0; y<5; y = y +1)begin	
            	assign  LinearAout[320 * y + 64 * x + 63:320 * y + 64 * x] = Aout[x][y]; 

        	end
        end
    endgenerate


    wire  [63:0] C [4:0];
    wire  [63:0] D [4:0];

// C[x] = A[x,0] ^ A[x,1]^ A[x,2]^ A[x,3]^A[x,4]
    assign C[0] = A [0][0] ^ A [0][1] ^ A [0][2] ^ A [0][3] ^ A[0][4] ; 
    assign C[1] = A [1][0] ^ A [1][1] ^ A [1][2] ^ A [1][3] ^ A[1][4] ;     
    assign C[2] = A [2][0] ^ A [2][1] ^ A [2][2] ^ A [2][3] ^ A[2][4] ; 
    assign C[3] = A [3][0] ^ A [3][1] ^ A [3][2] ^ A [3][3] ^ A[3][4] ; 
    assign C[4] = A [4][0] ^ A [4][1] ^ A [4][2] ^ A [4][3] ^ A[4][4] ; 

// D[x] = C[x-1] + rot(C[x+1],1);

    assign D[0] = C[4] ^ {C[1][62:0],C[1][63]};
    assign D[1] = C[0] ^ {C[2][62:0],C[2][63]};
    assign D[2] = C[1] ^ {C[3][62:0],C[3][63]};
    assign D[3] = C[2] ^ {C[4][62:0],C[4][63]};
    assign D[4] = C[3] ^ {C[0][62:0],C[0][63]};

// A(x,y) = A (x,y)+ D[x];

    // y = 0
    assign Aout[0][0] =  A[0][0] ^ D[0];
    assign Aout[1][0] =  A[1][0] ^ D[1];
    assign Aout[2][0] =  A[2][0] ^ D[2];
    assign Aout[3][0] =  A[3][0] ^ D[3];
    assign Aout[4][0] =  A[4][0] ^ D[4];
    // y = 1
    assign Aout[0][1] =  A[0][1] ^ D[0];
    assign Aout[1][1] =  A[1][1] ^ D[1];
    assign Aout[2][1] =  A[2][1] ^ D[2];
    assign Aout[3][1] =  A[3][1] ^ D[3];
    assign Aout[4][1] =  A[4][1] ^ D[4];
    // y = 2
    assign Aout[0][2] =  A[0][2] ^ D[0];
    assign Aout[1][2] =  A[1][2] ^ D[1];
    assign Aout[2][2] =  A[2][2] ^ D[2];
    assign Aout[3][2] =  A[3][2] ^ D[3];
    assign Aout[4][2] =  A[4][2] ^ D[4];
    // y = 3
    assign Aout[0][3] =  A[0][3] ^ D[0];
    assign Aout[1][3] =  A[1][3] ^ D[1];
    assign Aout[2][3] =  A[2][3] ^ D[2];
    assign Aout[3][3] =  A[3][3] ^ D[3];
    assign Aout[4][3] =  A[4][3] ^ D[4];
    // y = 4
    assign Aout[0][4] =  A[0][4] ^ D[0];
    assign Aout[1][4] =  A[1][4] ^ D[1];
    assign Aout[2][4] =  A[2][4] ^ D[2];
    assign Aout[3][4] =  A[3][4] ^ D[3];
    assign Aout[4][4] =  A[4][4] ^ D[4];




endmodule

