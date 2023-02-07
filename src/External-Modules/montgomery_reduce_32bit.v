`timescale 1ns / 1ps

module montgomery_reduce_32bit
    (
    input clock,
    input reset,
    input RTR,
    input signed [63:0] a,
    output RTS,
    output signed [31:0] t
    );
    
    localparam SIZE = 2;
    localparam IDLE = 2'd0, CALC_1 = 2'd1 ,CALC_2 = 2'd2;
	
	reg [SIZE-1:0] state = 2'd0;
	reg [SIZE-1:0] next_state;
    
	reg signed [31:0] temp1;
	reg signed [63:0] temp2;
	
	reg temp_RTS;
	reg signed [31:0] temp_t;
	
	assign RTS = temp_RTS;
	assign t = temp_t;
	
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
                                next_state = CALC_1;
                            end
                        else
                            begin
                                next_state = IDLE;
                            end
                    end
                
                CALC_1:
                    begin
                        next_state = CALC_2;
                    end
                
                CALC_2:
                    begin
                        next_state = IDLE;
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
                                temp1 <= a * 32'sd58728449;
                            end
                        else
                            begin
                                temp_RTS <= 1'b0;
                                temp_t <= 32'sd0;
                            end
                    end
                 
                CALC_1:
                    begin
                        temp2 <= temp1 * 32'sd8380417;
                    end
               
                CALC_2:
                    begin
                        temp_RTS <= 1'b1;
                        temp_t <= (a - temp2) >> 32;
                    end
                
                default:
                    begin
                        temp1 <= 32'sd0;
                        temp2 <= 64'sd0;
                        temp_RTS <= 1'b0;
                        temp_t <= 32'sd0;
                    end
            endcase
        end
endmodule 
