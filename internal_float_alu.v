`timescale 1ns / 1ps

module internal_float_alu (
    input wire s_a, s_b, z_a, z_b, n_a, n_b,
    input wire signed [7:0] exp_a, exp_b,
    input wire [16:0] frac_a, frac_b,
    input wire [3:0] alu_control,

    output reg s_res,
    output reg signed [7:0] exp_res,
    output reg [31:0] frac_res,
    output reg z_res,
    output reg n_res
);
    reg [31:0] f_a_align;
    reg [31:0] f_b_align;
    reg [31:0] shift_mask;
    reg [7:0] exp_diff;
    reg eff_sub;

    reg [33:0] mul_temp;
    reg [63:0] div_temp;
    reg [31:0] raw_frac;
    reg signed [7:0] raw_exp;
    reg [5:0] msb_pos;
    reg found;
    integer i;

    always @(*) begin
        s_res = 0; raw_exp = 0; raw_frac = 0; z_res = 0; n_res = 0;
        
        case (alu_control)
            4'b0000, 4'b0001: begin 
                if (n_a || n_b) n_res = 1;
                else if (z_a) begin 
                    s_res = (alu_control == 4'b0001) ? ~s_b : s_b; 
                    raw_exp = exp_b; 
                    raw_frac = {1'b0, frac_b, 14'd0}; 
                end
                else if (z_b) begin 
                    s_res = s_a; 
                    raw_exp = exp_a; 
                    raw_frac = {1'b0, frac_a, 14'd0}; 
                end
                else begin
                    f_a_align = {1'b0, frac_a, 14'd0}; 
                    f_b_align = {1'b0, frac_b, 14'd0};
                    eff_sub = s_a ^ (s_b ^ (alu_control == 4'b0001)); 
                    
                    if (exp_a > exp_b) begin
                        exp_diff = exp_a - exp_b;
                        if (exp_diff >= 32) f_b_align = 0; 
                        else begin
                            shift_mask = (32'd1 << exp_diff) - 1;
                            f_b_align = (f_b_align >> exp_diff) | ((f_b_align & shift_mask) != 0);
                        end
                        raw_exp = exp_a;
                        s_res = s_a;
                    end else if (exp_b > exp_a) begin
                        exp_diff = exp_b - exp_a;
                        if (exp_diff >= 32) f_a_align = 0;
                        else begin
                            shift_mask = (32'd1 << exp_diff) - 1;
                            f_a_align = (f_a_align >> exp_diff) | ((f_a_align & shift_mask) != 0);
                        end
                        raw_exp = exp_b;
                        s_res = (alu_control == 4'b0001) ? ~s_b : s_b;
                    end else 
                    begin
                        raw_exp = exp_a;
                        if (f_a_align >= f_b_align) begin
                            s_res = s_a;
                        end else begin
                            s_res = (alu_control == 4'b0001) ? ~s_b : s_b;
                        end
                    end
                    
                    if (eff_sub)
                    begin
                        raw_frac = (f_a_align >= f_b_align) ? (f_a_align - f_b_align) : (f_b_align - f_a_align);
                    end else 
                    begin
                        raw_frac = f_a_align + f_b_align;
                    end
                end
            end
            
            4'b0010: begin 
                if (n_a || n_b) n_res = 1;
                else if (z_a || z_b) z_res = 1;
                else begin
                    s_res = s_a ^ s_b;
                    raw_exp = exp_a + exp_b;
                    mul_temp = {17'd0, frac_a} * {17'd0, frac_b}; 
                    raw_frac = mul_temp[33:2]; 
                end
            end
            
            4'b0011: begin 
                if (n_a || n_b || z_b) n_res = 1;
                else if (z_a) z_res = 1;
                else begin
                    s_res = s_a ^ s_b;
                    raw_exp = exp_a - exp_b;
                    div_temp = {17'd0, frac_a, 30'd0} / {47'd0, frac_b};
                    raw_frac = div_temp[31:0]; 
                end
            end
        endcase
        
        if (z_res || n_res || raw_frac == 0) 
        begin
            frac_res = 0;
            exp_res = 0;
            if (raw_frac == 0) z_res = 1;
        end else 
        begin
            msb_pos = 0;
            found = 0;
            for (i = 31; i >= 0; i = i - 1) begin
                if (!found && raw_frac[i] == 1'b1) 
                begin
                    msb_pos = i;
                    found = 1;
                end
            end
            
            if (msb_pos > 30) 
            begin
                frac_res = raw_frac >> (msb_pos - 30);
                exp_res  = raw_exp + (msb_pos - 30);
            end else if (msb_pos < 30)
             begin
                frac_res = raw_frac << (30 - msb_pos);
                exp_res  = raw_exp - (30 - msb_pos);
            end else 
            begin
                frac_res = raw_frac;
                exp_res  = raw_exp;
            end
        end
    end
endmodule
