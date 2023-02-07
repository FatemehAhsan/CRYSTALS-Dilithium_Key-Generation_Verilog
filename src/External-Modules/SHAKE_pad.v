module SHAKE_Pad #(parameter r = 1343, parameter len = 256)(N, P);
    input [len - 1:0] N;
    output [(len / 1088 + 1) * 1088 - 1:0] P;
    
    reg [(len / 1088 + 1) * 1088 - 1:0] pad;

    assign P = pad;
       
    always @(*) begin
	    pad = 0;
    	pad[(len / 1088 + 1) * 1088 - 1] = 1;
        pad[len - 1:0] = N;
        pad[len+:5] = 5'b11111;    
    end 
     
endmodule
