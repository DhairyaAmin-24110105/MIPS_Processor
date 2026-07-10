`timescale 1ns / 1ps

module tb_processor;

    reg clk;
    reg reset;

    MIPS_16bit_Posit uut (
        .clk(clk), 
        .reset(reset)
    );
    
    always begin
        #5 clk = ~clk;
    end

    initial 
    begin
        clk = 0;
        reset = 1;

        #10;
        reset = 0;
        
        $display("\n==========================================================================================");
        $display("Time |  PC  | Instruction | R1 | R2 | R3(Add) | R4(Sub) | R5(Mul) | R6(Div) | R7(LW)");
        $display("==========================================================================================");
        
        forever @(posedge clk) begin
            #1; 
            $display("%4d | %4h |    %4h     |  %4h   |  %4h   |  %4h   |  %4h   |  %4h   |  %4h   |  %4h", 
                     $time, 
                     uut.pc_current, 
                     uut.instruction,
                     uut.regs.regs[1], 
                     uut.regs.regs[2], 
                     uut.regs.regs[3], 
                     uut.regs.regs[4], 
                     uut.regs.regs[5], 
                     uut.regs.regs[6], 
                     uut.regs.regs[7]);
        end
    end
    
    initial 
    begin
        #500; 
        $display("==========================================================================================");
        $display("Simulation finished.");
        $display("==========================================================================================\n");
        $finish;
    end
    
      
endmodule

