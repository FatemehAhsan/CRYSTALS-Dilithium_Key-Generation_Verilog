`timescale 1ns / 1ps

module fqmul_32bit
    (
    input clock,
    input reset,
    input RTR,
    input signed [31:0] a,
    input signed [31:0] b,
    output RTS,
    output  signed [31:0] reduce
    );
    
    localparam SIZE = 1;
    localparam IDLE = 1'd0, CALC = 1'd1;
    
    reg [SIZE-1:0] state = 1'd0;
	reg [SIZE-1:0] next_state;
	
	reg signed [63:0] mult;
	reg new_montgomery_reduce_RTR;
	wire new_montgomery_reduce_RTS;
	
	montgomery_reduce_32bit new_montgomery_reduce_32bit(.clock(clock), .reset(reset), .RTR(new_montgomery_reduce_RTR), .RTS(new_montgomery_reduce_RTS),
	                                                    .a(mult), .t(reduce));	
	assign RTS = new_montgomery_reduce_RTS;
	
	always @(posedge clock)
        begin
            if (reset == 1'b1)
                begin
                    state <= IDLE;
                end
            else
                begin
                    state <= next_state;
                end
        end
    
    always @(*)
        begin
            case(state)
                IDLE:
                    begin
                        if (RTR == 1'b1)
                            begin
                                next_state = CALC;
                            end
                        else
                            begin
                                next_state = IDLE;
                            end
                    end
                
                CALC:
                    begin
                        if (new_montgomery_reduce_RTS == 1'b1)
                            begin
                                next_state = IDLE;
                            end
                        else
                            begin
                                next_state = CALC;
                            end
                    end
                 
                default:
                    begin
                        next_state = IDLE;
                    end
            endcase
        end
    
    always @(posedge clock)
        begin
            case(state)
                IDLE:
                    begin
                        if (RTR == 1'b1)
                            begin
                                mult <= a * b;
                                new_montgomery_reduce_RTR <= 1'b1;
                            end
                    end
                
                CALC:
                    begin
                        new_montgomery_reduce_RTR <= 1'b0;
                    end
                
                default:
                    begin
                        mult <= 64'sd0;
                        new_montgomery_reduce_RTR <= 1'b0;
                    end
            endcase
        end  
endmodule
