`timescale 1ns / 1ps

module Data_Memory (
    input wire clk, mem_write, mem_read,
    input wire [15:0] address, write_data,
    output wire [15:0] read_data
);
    reg [15:0] memory [0:255];
    
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 16'd0;
        end
    end

    always @(posedge clk) begin
        if (mem_write) memory[address[7:0]] <= write_data;
    end
    
    assign read_data = (mem_read) ? memory[address[7:0]] : 16'd0;
endmodule
