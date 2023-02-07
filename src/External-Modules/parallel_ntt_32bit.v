`timescale 1ns / 1ps

module parallel_ntt_32bit
    (
    input clock,
    input reset,
	input RTR,
	input signed [0:8191] inp,
	output rd_ready,
	output rd_done,
	output RTS,
	output wr_done,
	output signed [0:8191] out
    );
    
    localparam SIZE = 3;
    localparam IDLE = 3'd0, PRE_RD_INP = 3'd1 ,RD_INP = 3'd2, CALC_1 = 3'd3, CALC_2 = 3'd4, WR_OUT = 3'd5, DONE = 3'd6;
	
	reg [SIZE-1:0] state;
	reg [SIZE-1:0] next_state;
    
    reg [7:0] len;
    
    reg signed [0:8191] temp_inp;
    reg temp_rd_ready;
	reg temp_rd_done;
	reg temp_RTS;
	reg temp_wr_done;
	reg signed [0:8191] temp_out;
	
	reg new_fqmul_32bit_RTR;
	wire [0:127] new_fqmul_32bit_RTS;
	wire new_fqmul_32bit_final_RTS;
	reg signed [0:4095] temp_i1;
	reg signed [0:4095] temp_i2;
	wire signed [0:4095] temp_o1;
	reg signed [0:4095] temp_o2;
		
	integer n;
	integer m;
	
    reg signed [0:8191] zetas =
    {
    32'sd0, 32'sd25847, -32'sd2608894, -32'sd518909, 32'sd237124, -32'sd777960, -32'sd876248, 32'sd466468, 
    32'sd1826347, 32'sd2353451, -32'sd359251, -32'sd2091905, 32'sd3119733, -32'sd2884855, 32'sd3111497, 32'sd2680103, 
    32'sd2725464, 32'sd1024112, -32'sd1079900, 32'sd3585928, -32'sd549488, -32'sd1119584, 32'sd2619752, -32'sd2108549, 
    -32'sd2118186, -32'sd3859737, -32'sd1399561, -32'sd3277672, 32'sd1757237, -32'sd19422, 32'sd4010497, 32'sd280005, 
    32'sd2706023, 32'sd95776, 32'sd3077325, 32'sd3530437, -32'sd1661693, -32'sd3592148, -32'sd2537516, 32'sd3915439, 
    -32'sd3861115, -32'sd3043716, 32'sd3574422, -32'sd2867647, 32'sd3539968, -32'sd300467, 32'sd2348700, -32'sd539299, 
    -32'sd1699267, -32'sd1643818, 32'sd3505694, -32'sd3821735, 32'sd3507263, -32'sd2140649, -32'sd1600420, 32'sd3699596, 
    32'sd811944, 32'sd531354, 32'sd954230, 32'sd3881043, 32'sd3900724, -32'sd2556880, 32'sd2071892, -32'sd2797779, 
    -32'sd3930395, -32'sd1528703, -32'sd3677745, -32'sd3041255, -32'sd1452451, 32'sd3475950, 32'sd2176455, -32'sd1585221, 
    -32'sd1257611, 32'sd1939314, -32'sd4083598, -32'sd1000202, -32'sd3190144, -32'sd3157330, -32'sd3632928, 32'sd126922, 
    32'sd3412210, -32'sd983419, 32'sd2147896, 32'sd2715295, -32'sd2967645, -32'sd3693493, -32'sd411027, -32'sd2477047, 
    -32'sd671102, -32'sd1228525, -32'sd22981, -32'sd1308169, -32'sd381987, 32'sd1349076, 32'sd1852771, -32'sd1430430, 
    -32'sd3343383, 32'sd264944, 32'sd508951, 32'sd3097992, 32'sd44288, -32'sd1100098, 32'sd904516, 32'sd3958618, 
    -32'sd3724342, -32'sd8578, 32'sd1653064, -32'sd3249728, 32'sd2389356, -32'sd210977, 32'sd759969, -32'sd1316856, 
    32'sd189548, -32'sd3553272, 32'sd3159746, -32'sd1851402, -32'sd2409325, -32'sd177440, 32'sd1315589, 32'sd1341330, 
    32'sd1285669, -32'sd1584928, -32'sd812732, -32'sd1439742, -32'sd3019102, -32'sd3881060, -32'sd3628969, 32'sd3839961, 
    32'sd2091667, 32'sd3407706, 32'sd2316500, 32'sd3817976, -32'sd3342478, 32'sd2244091, -32'sd2446433, -32'sd3562462, 
    32'sd266997, 32'sd2434439, -32'sd1235728, 32'sd3513181, -32'sd3520352, -32'sd3759364, -32'sd1197226, -32'sd3193378, 
    32'sd900702, 32'sd1859098, 32'sd909542, 32'sd819034, 32'sd495491, -32'sd1613174, -32'sd43260, -32'sd522500, 
    -32'sd655327, -32'sd3122442, 32'sd2031748, 32'sd3207046, -32'sd3556995, -32'sd525098, -32'sd768622, -32'sd3595838, 
    32'sd342297, 32'sd286988, -32'sd2437823, 32'sd4108315, 32'sd3437287, -32'sd3342277, 32'sd1735879, 32'sd203044, 
    32'sd2842341, 32'sd2691481, -32'sd2590150, 32'sd1265009, 32'sd4055324, 32'sd1247620, 32'sd2486353, 32'sd1595974, 
    -32'sd3767016, 32'sd1250494, 32'sd2635921, -32'sd3548272, -32'sd2994039, 32'sd1869119, 32'sd1903435, -32'sd1050970, 
    -32'sd1333058, 32'sd1237275, -32'sd3318210, -32'sd1430225, -32'sd451100, 32'sd1312455, 32'sd3306115, -32'sd1962642, 
    -32'sd1279661, 32'sd1917081, -32'sd2546312, -32'sd1374803, 32'sd1500165, 32'sd777191, 32'sd2235880, 32'sd3406031, 
    -32'sd542412, -32'sd2831860, -32'sd1671176, -32'sd1846953, -32'sd2584293, -32'sd3724270, 32'sd594136, -32'sd3776993, 
    -32'sd2013608, 32'sd2432395, 32'sd2454455, -32'sd164721, 32'sd1957272, 32'sd3369112, 32'sd185531, -32'sd1207385, 
    -32'sd3183426, 32'sd162844, 32'sd1616392, 32'sd3014001, 32'sd810149, 32'sd1652634, -32'sd3694233, -32'sd1799107, 
    -32'sd3038916, 32'sd3523897, 32'sd3866901, 32'sd269760, 32'sd2213111, -32'sd975884, 32'sd1717735, 32'sd472078, 
    -32'sd426683, 32'sd1723600, -32'sd1803090, 32'sd1910376, -32'sd1667432, -32'sd1104333, -32'sd260646, -32'sd3833893, 
    -32'sd2939036, -32'sd2235985, -32'sd420899, -32'sd2286327, 32'sd183443, -32'sd976891, 32'sd1612842, -32'sd3545687, 
    -32'sd554416, 32'sd3919660, -32'sd48306, -32'sd1362209, 32'sd3937738, 32'sd1400424, -32'sd846154, 32'sd1976782
    };
    
    task set_inp;
        input integer task_int_len;
        input integer task_int_inv_len;
        
        begin
            for (n = 0; n < task_int_inv_len; n = n + 1)
                begin
                    for (m = 0; m < task_int_len; m = m + 1)
                        begin
                            temp_i1[(((n * task_int_len) +  m) * 32) +: 32] <= zetas[((task_int_inv_len + n) * 32) +: 32];
                            temp_i2[(((n * task_int_len) +  m) * 32) +: 32] <= temp_inp[((((n * 2) * task_int_len) + task_int_len + m) * 32) +: 32];
                        end
                end
        end 
    endtask
    
    task set_out;
        input integer task_int_len;
        input integer task_int_inv_len;
        
        begin
            for (n = 0; n < task_int_inv_len; n = n + 1)
                begin
                    for (m = 0; m < task_int_len; m = m + 1)
                        begin
                            temp_inp[((((n * 2) * task_int_len) + task_int_len + m) * 32) +: 32] <= temp_inp[((((n * 2) * task_int_len) + m) * 32) +: 32] -
                                                                                                    temp_o2[(((n * task_int_len) +  m) * 32) +: 32];
                            
                            temp_inp[((((n * 2) * task_int_len) + m) * 32) +: 32] <= temp_inp[((((n * 2) * task_int_len) + m) * 32) +: 32] +
                                                                                     temp_o2[(((n * task_int_len) +  m) * 32) +: 32];
                        end
                end
        end 
    endtask
    
	genvar i;
	generate
	   for (i = 0; i < 128; i = i + 1)
	       begin: fqmul_32bit
	           fqmul_32bit new_fqmul_32bit (.clock(clock), .reset(reset), .RTR(new_fqmul_32bit_RTR), .RTS(new_fqmul_32bit_RTS[i]),
	                                        .a(temp_i1[(i * 32) +: 32]), .b(temp_i2[(i * 32) +: 32]), .reduce(temp_o1[(i * 32) +: 32]));
	       end
	endgenerate
	
	assign new_fqmul_32bit_final_RTS = &new_fqmul_32bit_RTS;
	
	assign rd_ready = temp_rd_ready;
	assign rd_done = temp_rd_done;
	assign RTS = temp_RTS;
	assign wr_done = temp_wr_done;
	assign out = temp_out;
	
	always @(*)
	   begin
	       temp_o2 = temp_o1;
	   end
	
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
            case (state)
                IDLE:
                    begin
                        next_state = PRE_RD_INP;
                    end
                
                PRE_RD_INP:
                    begin
			            if (RTR == 1'b1)
			                begin
			                    next_state = RD_INP;
			                end
			            else
			                begin
			                    next_state = PRE_RD_INP;
			                end
                    end
                
                RD_INP:
                    begin
                        next_state = CALC_1;
                    end
                
                CALC_1:
                    begin
                        next_state = CALC_2;
                    end
                
                CALC_2:
                    begin
                        if (new_fqmul_32bit_final_RTS == 1'b1)
                            begin
                                if (len >> 1 >= 1'd1)
                                    begin
                                        next_state = CALC_1;
                                    end
                                else
                                  begin
                                      next_state = WR_OUT;
                                  end
                            end
                        else
                            begin
                                next_state = CALC_2;
                            end
                    end
                
                WR_OUT:
                    begin
                        next_state = DONE;
                    end
                
                DONE:
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
            case (state)
                IDLE:
                    begin
                         temp_rd_ready <= 1'b0;
                         temp_rd_done <= 1'b0;
                         temp_RTS <= 1'b0;
                         temp_wr_done <= 1'b0;
                         temp_out <= 8192'sd0;
                         len <= 8'd128;
                    end
                
                PRE_RD_INP:
                    begin
			            if (RTR == 1'b1)
			                begin
			                    temp_rd_ready <= 1'b1;
			                end
                    end
                
                RD_INP:
                    begin
                        temp_inp <= inp;
                        temp_rd_ready <= 1'b0;
                        temp_rd_done <= 1'b1;
                    end
                
                CALC_1:
                    begin
                        new_fqmul_32bit_RTR <= 1'b1;
                        
                        case(len)
                            8'd128:
                                begin
                                    set_inp(128, 1);
                                end
                                
                            8'd64:
                                begin
                                    set_inp(64, 2);
                                end
                                
                            8'd32:
                                begin
                                    set_inp(32, 4);
                                end
                                
                            8'd16:
                                begin
                                    set_inp(16, 8);
                                end
                                
                            8'd8:
                                begin
                                    set_inp(8, 16);
                                end
                                
                            8'd4:
                                begin
                                    set_inp(4, 32);
                                end
                                
                            8'd2:
                                begin
                                    set_inp(2, 64);
                                end
                            
                            8'd1:
                                begin
                                    set_inp(1, 128);
                                end
                            
                            default:
                                begin
                                    set_inp(0, 0);
                                end
                        endcase
                    end
                
                CALC_2:
                    begin
                        new_fqmul_32bit_RTR <= 1'b0;
                        
                        if (new_fqmul_32bit_final_RTS == 1'b1)
                            begin
                                case(len)
                                    8'd128:
                                        begin
                                            set_out(128, 1);
                                        end
                                    
                                    8'd64:
                                        begin
                                            set_out(64, 2);
                                        end
                                    
                                    8'd32:
                                        begin
                                            set_out(32, 4);
                                        end
                                    
                                    8'd16:
                                        begin
                                            set_out(16, 8);
                                        end
                                    
                                    8'd8:
                                        begin
                                            set_out(8, 16);
                                        end
                                    
                                    8'd4:
                                        begin
                                            set_out(4, 32);
                                        end
                                    
                                    8'd2:
                                        begin
                                            set_out(2, 64);
                                        end
                                    
                                    8'd1:
                                        begin
                                            set_out(1, 128);
                                        end
                                    
                                    default:
                                        begin
                                            set_out(0, 0);
                                        end
                                endcase
                                
                                len <= len >> 1;
                            end
                    end
                
                WR_OUT:
                    begin
                        temp_out <= temp_inp;
                        temp_RTS <= 1'b1;
                        temp_wr_done <= 1'b1;
                    end
                
                DONE:
                    begin
                       temp_RTS <= 1'b0;
                    end
            
                default:
                    begin
                        new_fqmul_32bit_RTR <= 1'b0;
                        temp_inp <= 8192'sd0;
                        temp_i1 <= 4096'sd0;
                        temp_i2 <= 4096'sd0;
                        temp_rd_ready <= 1'b0;
                        temp_rd_done <= 1'b0;
                        temp_RTS <= 1'b0;
                        temp_wr_done <= 1'b0;
                        temp_out <= 8192'sd0;
                        len <= 8'd128;
                    end
            endcase
        end
endmodule
