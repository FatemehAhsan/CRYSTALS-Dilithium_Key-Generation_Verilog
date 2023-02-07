module PermuteFunc_FourRound(LinearA,  LinearAout, round);

    input [1599:0] LinearA;
    output [1599:0]  LinearAout;
    input [2:0] round;

    wire [1599:0] A1;
    wire [1599:0] A2;
    wire [1599:0] A3;
	 
	 wire [4:0] round0 = 4*round;
	 wire [4:0] round1 = 4*round + 1;
	 wire [4:0] round2 = 4*round + 2;
	 wire [4:0] round3 = 4*round + 3;
	 
    PermuteFunction_oneRound PermuteFunction_oneRound_u0(.LinearA(LinearA), .LinearAout(A1),          .round(round0));
    PermuteFunction_oneRound PermuteFunction_oneRound_u1(.LinearA(A1),      .LinearAout(A2),          .round(round1));
    PermuteFunction_oneRound PermuteFunction_oneRound_u2(.LinearA(A2),      .LinearAout(A3),          .round(round2));
    PermuteFunction_oneRound PermuteFunction_oneRound_u3(.LinearA(A3),      .LinearAout(LinearAout),  .round(round3));

endmodule
