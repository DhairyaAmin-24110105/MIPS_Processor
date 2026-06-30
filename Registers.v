`timescale 1ns / 1ps

module Registers (
    input wire clk, reset, reg_write,
    input wire [2:0] read_reg1, read_reg2, write_reg,
    input wire [15:0] write_data,
    output wire [15:0] read_data1, read_data2
);
    reg [15:0] regs [0:7];
    integer i;
    assign read_data1 = (read_reg1 == 3'b000) ? 16'd0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 3'b000) ? 16'd0 : regs[read_reg2];
    always @(posedge clk or posedge reset)
    begin
        if (reset) 
        begin
            for (i=0; i<8; i=i+1) regs[i] <= 16'd0;
        end 
        else if (reg_write && write_reg != 3'b000) 
        begin
            regs[write_reg] <= write_data;
        end
    end
endmodule
