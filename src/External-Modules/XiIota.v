module XiIota(LinearB, LinearA,RC);
	output [1599:0] LinearA;
	input [1599:0] LinearB;
	input [63:0] RC;

	wire [63:0] A [0:4][0:4];
	wire [63:0] B [0:4][0:4];

	//  a[x][y][k] ==> (5x+y)w+k
	generate
		genvar x,y;
		for (x = 0; x < 5; x = x + 1) begin
			for (y = 0; y < 5; y = y + 1) begin
				assign B[x][y] = LinearB[320 * y + 64 * x + 63:320 * y + 64 * x]; 
			end
		end
	endgenerate

	generate
		for (x = 0; x < 5; x = x + 1) begin
			for (y = 0; y < 5; y = y + 1) begin
				assign  LinearA[320 * y + 64 * x + 63:320 * y + 64 * x] = A[x][y]; 
			end
		end
	endgenerate

	//A[x,y] = B[x,y] ^ (~(B[x+1,y]) & B[x+2,y])

	// x = 0
	assign A[0][0] = B[0][0] ^ (~B[1][0] & B[2][0]) ^ RC; //iotas
	assign A[0][1] = B[0][1] ^ (~B[1][1] & B[2][1]);
	assign A[0][2] = B[0][2] ^ (~B[1][2] & B[2][2]);
	assign A[0][3] = B[0][3] ^ (~B[1][3] & B[2][3]);
	assign A[0][4] = B[0][4] ^ (~B[1][4] & B[2][4]);

	// x = 1
	assign A[1][0] = B[1][0] ^ (~B[2][0] & B[3][0]);
	assign A[1][1] = B[1][1] ^ (~B[2][1] & B[3][1]);
	assign A[1][2] = B[1][2] ^ (~B[2][2] & B[3][2]);
	assign A[1][3] = B[1][3] ^ (~B[2][3] & B[3][3]);
	assign A[1][4] = B[1][4] ^ (~B[2][4] & B[3][4]);

	// x = 2
	assign A[2][0] = B[2][0] ^ (~B[3][0] & B[4][0]);
	assign A[2][1] = B[2][1] ^ (~B[3][1] & B[4][1]);
	assign A[2][2] = B[2][2] ^ (~B[3][2] & B[4][2]);
	assign A[2][3] = B[2][3] ^ (~B[3][3] & B[4][3]);
	assign A[2][4] = B[2][4] ^ (~B[3][4] & B[4][4]);

	// x = 3
	assign A[3][0] = B[3][0] ^ (~B[4][0] & B[0][0]);
	assign A[3][1] = B[3][1] ^ (~B[4][1] & B[0][1]);
	assign A[3][2] = B[3][2] ^ (~B[4][2] & B[0][2]);
	assign A[3][3] = B[3][3] ^ (~B[4][3] & B[0][3]);
	assign A[3][4] = B[3][4] ^ (~B[4][4] & B[0][4]);

	// x = 4
	assign A[4][0] = B[4][0] ^ (~B[0][0] & B[1][0]);
	assign A[4][1] = B[4][1] ^ (~B[0][1] & B[1][1]);
	assign A[4][2] = B[4][2] ^ (~B[0][2] & B[1][2]);
	assign A[4][3] = B[4][3] ^ (~B[0][3] & B[1][3]);
	assign A[4][4] = B[4][4] ^ (~B[0][4] & B[1][4]);


endmodule
