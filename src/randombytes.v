// In the name of Allah


module randombytes #(parameter in_len = 32)(
    output [in_len * 8 - 1:0] linear_out
    );
    
    assign linear_out = {8'd6, 8'd254, 8'd37, 8'd74, 8'd234, 8'd137, 8'd104, 8'd183, 8'd156, 8'd70, 8'd235, 8'd109, 8'd35, 8'd249, 8'd112, 8'd242, 8'd239, 8'd40, 8'd238, 8'd76, 8'd235, 8'd111, 8'd210, 8'd221, 8'd141, 8'd133, 8'd56, 8'd212, 8'd240, 8'd96, 8'd185, 8'd110};
    
endmodule
