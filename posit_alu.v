`timescale 1ns / 1ps

module posit_alu (
    input wire [15:0] a, b,
    input wire [3:0] alu_control,
    input wire [2:0] shamt,
    output reg [15:0] result,
    output wire zero
);
    wire s_a, s_b, z_a, z_b, n_a, n_b;
    wire signed [7:0] exp_a, exp_b;
    wire [16:0] frac_a, frac_b;

    posit_to_float unpack_a(a, s_a, exp_a, frac_a, z_a, n_a);
    posit_to_float unpack_b(b, s_b, exp_b, frac_b, z_b, n_b);

    wire s_res, z_res, n_res;
    wire signed [7:0] exp_res;
    wire [31:0] frac_res;

    internal_float_alu float_math(
        .s_a(s_a), .s_b(s_b), .z_a(z_a), .z_b(z_b), .n_a(n_a), .n_b(n_b),
        .exp_a(exp_a), .exp_b(exp_b), .frac_a(frac_a), .frac_b(frac_b),
        .alu_control(alu_control),
        .s_res(s_res), .exp_res(exp_res), .frac_res(frac_res), .z_res(z_res), .n_res(n_res)
    );

    wire [15:0] math_result;
    float_to_posit packer(s_res, exp_res, frac_res, z_res, n_res, math_result);

    always @(*) begin
        case(alu_control)
            4'b0000, 4'b0001, 4'b0010, 4'b0011: result = math_result; 
            4'b0100: result = a << shamt;
            4'b0101: result = a >> shamt;
            4'b0110: result = a & b;
            4'b0111: result = a | b;
            4'b1000: result = a + b; 
            4'b1001: result = a - b; 
            4'b1010: result = {b[5:0], 10'd0}; 
            default: result = 16'd0;
        endcase
    end
    assign zero = (result == 16'd0);
endmodule
