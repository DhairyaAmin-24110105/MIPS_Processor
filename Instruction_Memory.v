`timescale 1ns / 1ps

module Instruction_Memory (
    input wire [15:0] pc, output wire [15:0] instruction
);
    reg [15:0] memory [0:255]; 
    initial 
    begin
        $readmemh("imem.hex", memory); //Imem.hex will go here as set of instructions stored in instruction memory
    end
    assign instruction = memory[pc[7:0]];
endmodule
