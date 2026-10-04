module mips(input clk, input reset);
    wire IRWrite, MemWrite, RegWrite, RegDst, MemToReg;
    wire [1:0] ALUSrcB, ALUOp, PCSource;
    wire ALUSrcA, PCWrite, PCCond, JALWrite, OverflowEnable;
    wire [3:0] ALUCtrl;
    wire [5:0] Op, Function;
    wire Zero;
    wire Overflow;

    control control_D(
        clk, reset, Op,
        IRWrite, MemWrite, RegWrite, RegDst, MemToReg,
        ALUSrcB, ALUSrcA, ALUOp,
        PCWrite, PCCond, PCSource, JALWrite, OverflowEnable
    );

    alucontrol alucontrol_D(
        ALUOp, Function, ALUCtrl
    );

    datapath datapath_D(
        clk, reset,
        IRWrite, MemWrite, RegWrite, RegDst, MemToReg,
        ALUSrcB, ALUSrcA, ALUOp,
        PCWrite, PCCond, PCSource, JALWrite,
        ALUCtrl, Op, Function, Zero, Overflow
    );
endmodule
