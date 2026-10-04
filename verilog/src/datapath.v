module datapath(
    input clk,
    input reset,
    input IRWrite,
    input MemWrite,
    input RegWrite,
    input RegDst,
    input MemToReg,
    input [1:0] ALUSrcB,
    input ALUSrcA,
    input [1:0] ALUOp,
    input PCWrite,
    input PCCond,
    input [1:0] PCSource,
    input JALWrite,
    input [3:0] ALUCtrl,
    output [5:0] Op,
    output [5:0] Function,
    output Zero,
    output reg Overflow
);

    reg [31:0] PC;
    reg [31:0] Instruction;
    reg [31:0] A, B;
    reg [31:0] ALUOut;
    reg [31:0] MDR;
    reg [31:0] registers [0:31];
    reg [31:0] mem [0:255];

    wire [31:0] MemData;
    wire [31:0] SrcA;
    reg  [31:0] SrcB;
    reg  [31:0] ALUResult;
    wire [31:0] SignExtImm;
    wire [31:0] BranchTarget;
    wire [31:0] JumpTarget;
    wire signed [31:0] SignedA;
    wire signed [31:0] SignedB;
    wire signed [31:0] SignedResult;

    integer i;

    assign Op       = Instruction[31:26];
    assign Function = Instruction[5:0];

    assign SignExtImm = {{16{Instruction[15]}}, Instruction[15:0]};
    assign BranchTarget = PC + (SignExtImm << 2);
    assign JumpTarget = {PC[31:28], Instruction[25:0], 2'b00};

    // Byte-addressed memory: each 32-bit word occupies one array element.
    assign MemData = mem[ALUOut[9:2]];

    assign SrcA = ALUSrcA ? A : PC;

    always @(*) begin
        case (ALUSrcB)
            2'b00: SrcB = B;
            2'b01: SrcB = 32'd4;
            2'b10: SrcB = SignExtImm;
            2'b11: SrcB = (SignExtImm << 2);
            default: SrcB = 32'b0;
        endcase
    end

    always @(*) begin
        case (ALUCtrl)
            4'b0000: ALUResult = SrcA & SrcB;
            4'b0001: ALUResult = SrcA | SrcB;
            4'b0010: ALUResult = SrcA + SrcB;
            4'b0110: ALUResult = SrcA - SrcB;
            4'b0111: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0;
            default: ALUResult = 32'b0;
        endcase
    end

    assign Zero = (ALUResult == 32'b0);

    assign SignedA = SrcA;
    assign SignedB = SrcB;
    assign SignedResult = ALUResult;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC = 32'b0;
            Instruction = 32'b0;
            A = 32'b0;
            B = 32'b0;
            ALUOut = 32'b0;
            MDR = 32'b0;
            Overflow = 1'b0;
            for (i = 0; i < 32; i = i + 1)
                registers[i] = 32'b0;
        end else begin
            if (IRWrite)
                Instruction <= mem[PC[9:2]];

            A <= (Instruction[25:21] == 0) ? 32'b0 : registers[Instruction[25:21]];
            B <= (Instruction[20:16] == 0) ? 32'b0 : registers[Instruction[20:16]];

            if (MemWrite)
                mem[ALUOut[9:2]] <= B;

            if (RegWrite) begin
                if (RegDst)
                    registers[Instruction[15:11]] <= MemToReg ? MDR : ALUOut;
                else
                    registers[Instruction[20:16]] <= MemToReg ? MDR : ALUOut;
            end

            if (JALWrite)
                registers[31] <= PC;

            MDR <= MemData;
            ALUOut <= ALUResult;

            if ((ALUCtrl == 4'b0010) && ((SignedA[31] == SignedB[31]) && (SignedResult[31] != SignedA[31])))
                Overflow <= 1'b1;

            if (PCWrite || (PCCond && Zero)) begin
                case (PCSource)
                    2'b00: PC <= ALUResult;
                    2'b01: PC <= BranchTarget;
                    2'b10: PC <= JumpTarget;
                    default: PC <= PC;
                endcase
            end

            registers[0] <= 32'b0;
        end
    end
endmodule
