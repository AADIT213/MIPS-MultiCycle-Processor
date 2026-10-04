`timescale 1ns/1ps

module tb_mips;

    reg clk;
    reg reset;
    integer errors;

    mips dut(clk, reset);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task clear_memory;
        integer k;
        begin
            for (k = 0; k < 256; k = k + 1)
                dut.datapath_D.mem[k] = 32'b0;
        end
    endtask

    task reset_cpu;
        begin
            reset = 1;
            #12;
            reset = 0;
            #2;
        end
    endtask

    task check_reg;
        input integer index;
        input [31:0] expected;
        input [255:0] name;
        begin
            if (dut.datapath_D.registers[index] !== expected) begin
                $display("FAIL: %s expected %h, got %h", name, expected, dut.datapath_D.registers[index]);
                errors = errors + 1;
            end else
                $display("PASS: %s = %h", name, expected);
        end
    endtask

    task run_cycles;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1)
                @(posedge clk);
        end
    endtask

    initial begin
        errors = 0;
        reset = 0;
        clear_memory();

        // ADDI $8,$0,10 ; ADDI $9,$8,5 ; ADD $10,$8,$9 ; HALT via zero words
        dut.datapath_D.mem[0] = 32'h2008000A;
        dut.datapath_D.mem[1] = 32'h21090005;
        dut.datapath_D.mem[2] = 32'h01095020;
        dut.datapath_D.mem[3] = 32'h00000000;

        reset_cpu();
        run_cycles(25);
        check_reg(8, 32'd10, "ADDI R8");
        check_reg(9, 32'd15, "ADDI R9");
        check_reg(10, 32'd25, "ADD R10");

        // LW / SW
        clear_memory();
        dut.datapath_D.mem[0] = 32'h8C080040; // lw $8,64($0)
        dut.datapath_D.mem[1] = 32'hAC080044; // sw $8,68($0)
        dut.datapath_D.mem[16] = 32'h0000002A;
        reset_cpu();
        run_cycles(15);
        check_reg(8, 32'd42, "LW R8");
        if (dut.datapath_D.mem[17] !== 32'd42) begin
            $display("FAIL: SW MEM[17] expected 0000002A, got %h", dut.datapath_D.mem[17]);
            errors = errors + 1;
        end else
            $display("PASS: SW MEM[17] = 0000002A");

        // BEQ: skip the ADDI at instruction index 2.
        clear_memory();
        dut.datapath_D.mem[0] = 32'h20080001; // addi $8,$0,1
        dut.datapath_D.mem[1] = 32'h20090001; // addi $9,$0,1
        dut.datapath_D.mem[2] = 32'h11090001; // beq $8,$9,+1
        dut.datapath_D.mem[3] = 32'h200A0063; // skipped
        dut.datapath_D.mem[4] = 32'h200A0007; // executed
        reset_cpu();
        run_cycles(25);
        check_reg(10, 32'd7, "BEQ target");

        // JAL: jump to instruction 4 and save return PC (8) in R31.
        clear_memory();
        dut.datapath_D.mem[0] = 32'h0C000004; // jal 4
        dut.datapath_D.mem[4] = 32'h2008002A; // addi $8,$0,42
        reset_cpu();
        run_cycles(15);
        check_reg(31, 32'd4, "JAL link R31");
        check_reg(8, 32'd42, "JAL target R8");

        // Signed overflow: 0x7fffffff + 1.
        clear_memory();
        dut.datapath_D.mem[0] = 32'h01094820; // add $9,$8,$9
        reset_cpu();
        dut.datapath_D.registers[8] = 32'h7FFFFFFF;
        dut.datapath_D.registers[9] = 32'h00000001;
        run_cycles(6);
        if (dut.datapath_D.Overflow !== 1'b1) begin
            $display("FAIL: signed overflow flag was not asserted");
            errors = errors + 1;
        end else
            $display("PASS: signed overflow detected");

        $display("");
        if (errors == 0) begin
            $display("========================================");
            $display("ALL ENHANCED MIPS TESTS PASSED");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("%0d TEST(S) FAILED", errors);
            $display("========================================");
        end

        $finish;
    end
endmodule


