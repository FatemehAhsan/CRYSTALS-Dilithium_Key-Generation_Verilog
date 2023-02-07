module RhoAndPi( LinearA, LinearB);

	input [1599:0] LinearA;
	output [1599:0] LinearB;

	wire [63:0] A [0:4][0:4];
	wire [63:0] B [0:4][0:4];



//  a[x][y][k] ==> (5x+y)w+k

	generate
		genvar x,y;
		for (x = 0; x < 5; x = x + 1) begin
			for (y = 0; y < 5; y = y + 1) begin
				assign A[x][y] = LinearA[320 * y + 64 * x + 63:320 * y + 64 * x]; 
			end
		end
	endgenerate

	generate
		for (x = 0; x < 5; x = x + 1) begin
			for (y = 0; y < 5; y = y + 1) begin
				assign LinearB[320 * y + 64 * x + 63:320 * y + 64 * x] = B[x][y]; 
			end
		end
	endgenerate


// B[y, 2x+3y] = rot(A[x,y], r[x,y]);  x,y = 0,1,2,3,4

	// x = 0
	assign B[0][0] = A[0][0]; //y = 0; r = 0
	assign B[1][3] = {A[0][1][27:0],A[0][1][63:28]}; //y = 1; r = 36
	assign B[2][1] = {A[0][2][60:0],A[0][2][63:61]}; //y = 2; r = 3
	assign B[3][4] = {A[0][3][22:0],A[0][3][63:23]}; //y = 3; r = 41
	assign B[4][2] = {A[0][4][45:0],A[0][4][63:46]}; //y = 4; r = 18

	// x = 1
	assign B[0][2] = {A[1][0][62:0],A[1][0][63]}; //y = 0; r = 1
	assign B[1][0] = {A[1][1][19:0],A[1][1][63:20]}; //y = 1; r = 44
	assign B[2][3] = {A[1][2][53:0],A[1][2][63:54]}; //y = 2; r = 10
	assign B[3][1] = {A[1][3][18:0],A[1][3][63:19]}; //y = 3; r = 45
	assign B[4][4] = {A[1][4][61:0],A[1][4][63:62]}; //y = 4; r = 2 

	// x = 2
	assign B[0][4] = {A[2][0][1:0],A[2][0][63:2]}; //y = 0; r = 62
	assign B[1][2] = {A[2][1][57:0],A[2][1][63:58]}; //y = 1; r = 6
	assign B[2][0] = {A[2][2][20:0],A[2][2][63:21]}; //y = 2; r = 43
	assign B[3][3] = {A[2][3][48:0],A[2][3][63:49]}; //y = 3; r = 15
	assign B[4][1] = {A[2][4][2:0],A[2][4][63:3]}; //y = 4; r = 61 

	// x = 3
	assign B[0][1] = {A[3][0][35:0],A[3][0][63:36]}; //y = 0; r = 28
	assign B[1][4] = {A[3][1][8:0],A[3][1][63:9]}; //y = 1; r = 55
	assign B[2][2] = {A[3][2][38:0],A[3][2][63:39]}; //y = 2; r = 25
	assign B[3][0] = {A[3][3][42:0],A[3][3][63:43]}; //y = 3; r = 21
	assign B[4][3] = {A[3][4][7:0],A[3][4][63:8]}; //y = 4; r = 56 

	// x = 4
	assign B[0][3] = {A[4][0][36:0],A[4][0][63:37]}; //y = 0; r = 27
	assign B[1][1] = {A[4][1][43:0],A[4][1][63:44]}; //y = 1; r = 20
	assign B[2][4] = {A[4][2][24:0],A[4][2][63:25]}; //y = 2; r = 39
	assign B[3][2] = {A[4][3][55:0],A[4][3][63:56]}; //y = 3; r = 8
	assign B[4][0] = {A[4][4][49:0],A[4][4][63:50]}; //y = 4; r = 14


endmodule
