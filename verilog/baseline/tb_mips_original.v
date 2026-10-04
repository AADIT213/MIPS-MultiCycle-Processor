module tb_mips;

    reg clk;
    reg reset;

    mips mips_DUT(clk, reset);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;

        #10;
        reset = 0;

        // Allow the processor to execute the loaded program
        #6000;

        $display("");
        $display("========================================");
        $display("   MIPS MULTI-CYCLE VERIFICATION");
        $display("========================================");

        $display("PC       = %h", mips_DUT.datapath_D.PC);
        $display("R8       = %h", mips_DUT.datapath_D.registers[8]);
        $display("R9       = %h", mips_DUT.datapath_D.registers[9]);
        $display("R10      = %h", mips_DUT.datapath_D.registers[10]);
        $display("MEM[16]  = %h", mips_DUT.datapath_D.mem[16]);

        $display("");
        $display("Simulation completed.");
        $display("========================================");

        $finish;
    end

endmodule
