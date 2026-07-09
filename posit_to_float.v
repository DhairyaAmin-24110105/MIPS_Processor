`timescale 1ns / 1ps

module posit_to_float (
    input wire [15:0] posit_in,
    output wire sign,
    output reg signed [7:0] int_exp,  
    output reg [16:0] int_frac,       
    output wire is_zero,
    output wire is_nar
);
    assign sign = posit_in[15];
    assign is_zero = (posit_in == 16'h0000);
    assign is_nar  = (posit_in == 16'h8000);
 
    wire [15:0] twos_comp = sign ? -posit_in : posit_in;
    wire [14:0] bits = twos_comp[14:0];
    wire rc = bits[14]; 

    integer i;
    reg [3:0] k_count; 
    reg signed [5:0] k_val;
    reg e_val;
    reg checking; 
    reg [31:0] wide_bits;

    always @(*) begin
        k_count = 0; 
        checking = 1; 
        
        for (i = 14; i >= 1; i = i - 1)
        begin
            if (checking && (bits[i] == rc)) k_count = k_count + 1;
            else checking = 0; 
        end
        
        
        if (checking && (bits[0] == rc) && (k_count < 14)) k_count = k_count + 1;
        
        k_val = rc ? ($signed({2'b0, k_count}) - 1) : -$signed({2'b0, k_count});
        
        wide_bits = {bits, 17'b0}; 
        

    if (k_count < 14) 
    begin
        e_val = bits[13 - k_count];                        
        wide_bits = wide_bits << (k_count + 2);            
        int_frac = {1'b1, wide_bits[31:16]};               
    end 
    else 
    begin
        e_val = 1'b0;                                      
        int_frac = 17'h10000;                              
    end
        
        int_exp = (k_val * 2) + $signed({7'b0, e_val});
    end
endmodule
