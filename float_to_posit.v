`timescale 1ns / 1ps

module float_to_posit (
    input wire s_res, input wire signed [7:0] exp_res,
    input wire [31:0] frac_res, input wire z_res, input wire n_res,
    output reg [15:0] posit_out
);
    integer i;
    reg [4:0] shift_amt;
    reg [31:0] norm_frac;
    reg signed [7:0] norm_exp;
    reg [7:0] abs_norm_exp;
    reg [7:0] k_val;
    reg [14:0] abs_posit;
    reg [7:0] abs_k;
    
    reg [15:0] full_frac; 
    reg [4:0] frac_shift;
    reg [15:0] truncated_bits;
    reg round_bit, sticky_bit, lsb_bit, round_up;

    always @(*) begin
        if (n_res) posit_out = 16'h8000;
        else if (z_res || frac_res == 0) posit_out = 16'h0000;
        else
         begin
            shift_amt = 0;
            for (i = 0; i <= 31; i = i + 1) begin
                if (frac_res[i] == 1'b1) shift_amt = 31 - i; 
            end
            
            norm_frac = frac_res << shift_amt;
            norm_exp = exp_res + 1 - $signed({1'b0, shift_amt}); 
            
            full_frac = {norm_exp[0], norm_frac[30:16]}; 
            
            if (!norm_exp[7])
             begin      
                k_val = norm_exp >> 1; 
                
                if (k_val >= 14)
                 begin
                    abs_posit = 15'h7FFF; 
                    frac_shift = 16;     
                end else
                 begin
                    abs_posit = (15'h7FFF << (14 - k_val)) & 15'h7FFF; 
                    frac_shift = k_val + 3; 
                    abs_posit = abs_posit | (full_frac >> frac_shift);
                end
            end else 
            begin 
                abs_norm_exp = -norm_exp;
                abs_k = (abs_norm_exp + 1) >> 1; 
                
                if (abs_k >= 15)
                 begin
                    abs_posit = 15'h0000; 
                    frac_shift = 17;      
                end else 
                begin
                    abs_posit = 15'h0000;
                    abs_posit = abs_posit | (1'b1 << (14 - abs_k)); 
                    frac_shift = abs_k + 2; 
                    abs_posit = abs_posit | (full_frac >> frac_shift);
                end
            end
            
            if (frac_shift < 16) 
            begin
                truncated_bits = full_frac & ((16'd1 << frac_shift) - 1);
                round_bit = (frac_shift > 0) ? full_frac[frac_shift - 1] : 1'b0;
                sticky_bit = (frac_shift > 1) ? ((truncated_bits & ((16'd1 << (frac_shift - 1)) - 1)) != 0) : 1'b0;
            end 
            else if (frac_shift == 16) 
            begin
                round_bit = full_frac[15]; 
                sticky_bit = (full_frac[14:0] != 0);
            end else 
            begin
                round_bit = 1'b0;
                sticky_bit = (full_frac != 0);
            end
            
            lsb_bit = abs_posit[0];
            round_up = round_bit & (sticky_bit | lsb_bit);
            
            if (round_up && abs_posit != 15'h7FFF)
            begin
                abs_posit = abs_posit + 1;
            end
            
            posit_out = s_res ? -{1'b0, abs_posit} : {1'b0, abs_posit};
        end
    end
endmodule
