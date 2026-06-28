`timescale 1ns / 1ps

module MIPS_16bit_Posit (
    input wire clk, reset
);
    // -- Instruction Fetch Wires --
    wire [15:0] pc_current, pc_next, instruction;
    wire [15:0] pc_updated = pc_current + 1;

    // -- Decode Wires --
    wire [3:0] opcode = instruction[15:12];
    wire [2:0] func   = instruction[2:0];
    wire [2:0] shamt  = instruction[8:6];
    wire [2:0] rs = instruction[11:9];
    wire [2:0] rt = instruction[8:6];
    wire [2:0] rd = instruction[5:3];
    wire [15:0] sign_ext_imm = {{10{instruction[5]}}, instruction[5:0]};

    // -- Control Signals --
    wire reg_dst    = (opcode == 4'b0000);
    wire alu_src    = (opcode != 4'b0000 && opcode != 4'b0100 && opcode != 4'b0101);
    wire mem_to_reg = (opcode == 4'b0010);
    wire reg_write  = (opcode == 4'b0000 || opcode == 4'b0001 || opcode == 4'b0010 || opcode == 4'b0110 || opcode == 4'b0111);
    wire mem_read   = (opcode == 4'b0010);
    wire mem_write  = (opcode == 4'b0011);
    wire branch_eq  = (opcode == 4'b0100);
    wire branch_ne  = (opcode == 4'b0101);
    wire jump       = (opcode == 4'b1110);
    
    wire halt = (instruction == 16'hf000); // Halt instruction 


    reg [3:0] r_type;
    always @(*) begin
        case (func)
            3'b010:  r_type = 4'b0000; // ADD
            3'b000:  r_type = 4'b0001; // SUB
            3'b011:  r_type = 4'b0010; // MUL
            3'b001:  r_type = 4'b0011; // DIV
            3'b100:  r_type = 4'b0100; // SLL (Shift Left Logical) 
            3'b101:  r_type = 4'b0101; // SRL (Shift Right Logical) 
            default: r_type = 4'b0000;
        endcase
    end

    wire [3:0] alu_ctrl = (opcode == 4'b0000) ? r_type : 
                          (opcode == 4'b0100 || opcode == 4'b0101) ? 4'b1001 : 
                          (opcode == 4'b0110) ? 4'b1010 : 
                          4'b1000;

    // Datapath Registers 
    wire [15:0] read_data1, read_data2, write_back_data;
    wire [2:0]  write_reg = reg_dst ? rd : rt;

    // ALU Wires 
    wire [15:0] alu_in_b = alu_src ? sign_ext_imm : read_data2;
    wire [15:0] alu_result;
    wire alu_zero;

    // Branch Logic 
    wire [15:0] branch_target = pc_updated + sign_ext_imm;
    wire [15:0] jump_target   = {pc_current[15:12], instruction[11:0]};
    wire branch_taken = (branch_eq & alu_zero) | (branch_ne & ~alu_zero);

    assign pc_next = jump ? jump_target :
                     branch_taken ? branch_target : 
                     pc_updated;

// Intializing modules for imem, ALU, dmem and registers

    reg [15:0] pc_reg;
    always @(posedge clk or posedge reset) begin
    if (reset) pc_reg <= 16'd0;
    else if (!halt) pc_reg <= pc_next; // For halting the processor 
end
    assign pc_current = pc_reg;

    Instruction_Memory imem (.pc(pc_current), .instruction(instruction));

    Registers regs (
        .clk(clk), .reset(reset), .reg_write(reg_write),
        .read_reg1(rs), .read_reg2(rt), .write_reg(write_reg), 
        .write_data(write_back_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );

    posit_alu main_alu (
        .a(read_data1), .b(alu_in_b),
        .alu_control(alu_ctrl), .shamt(shamt),
        .result(alu_result), .zero(alu_zero)
    );

    wire [15:0] mem_read_data;
    Data_Memory dmem (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
        .address(alu_result), .write_data(read_data2),
        .read_data(mem_read_data)
    );

    assign write_back_data = mem_to_reg ? mem_read_data : alu_result;

endmodule
