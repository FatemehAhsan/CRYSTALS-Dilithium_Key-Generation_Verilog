module PermuteFunction_oneRound (LinearA, LinearAout, round);

	input [1599:0] LinearA;
	output [1599:0] LinearAout;
	input [4:0] round;

	wire [1599:0] A1;
	wire [1599:0] B1;
	reg [63:0] RC;

	Theta Theta_u(.LinearA(LinearA), .LinearAout(A1));
	RhoAndPi RhoAndPi_u(.LinearA(A1), .LinearB(B1)); 
	XiIota XiIota_u(.LinearB(B1), .LinearA(LinearAout), .RC(RC));

	always @(*) begin
		RC = 64'h8000000080008008;
		case (round) 
			5'd0:
				RC = 64'h0000000000000001;
			5'd1:
				RC = 64'h0000000000008082;
			5'd2:
				RC = 64'h800000000000808A;
			5'd3:
				RC = 64'h8000000080008000;
			5'd4:
				RC = 64'h000000000000808B;
			5'd5:
				RC = 64'h0000000080000001;
			5'd6:
				RC = 64'h8000000080008081;
			5'd7:
				RC = 64'h8000000000008009;
			5'd8:
				RC = 64'h000000000000008A;
			5'd9:
				RC = 64'h0000000000000088;
			5'd10:
				RC = 64'h0000000080008009;
			5'd11:
				RC = 64'h000000008000000A;
			5'd12:
				RC = 64'h000000008000808B;
			5'd13:
				RC = 64'h800000000000008B;
			5'd14:
				RC = 64'h8000000000008089;
			5'd15:
				RC = 64'h8000000000008003;
			5'd16:
				RC = 64'h8000000000008002;
			5'd17:
				RC = 64'h8000000000000080;
			5'd18:
				RC = 64'h000000000000800A;
			5'd19:
				RC = 64'h800000008000000A;
			5'd20:
				RC = 64'h8000000080008081;
			5'd21:
				RC = 64'h8000000000008080;
			5'd22:
				RC = 64'h0000000080000001;
			5'd23:
				RC = 64'h8000000080008008;
			default:
				RC = 64'h8000000080008008;
		endcase
	end


endmodule
