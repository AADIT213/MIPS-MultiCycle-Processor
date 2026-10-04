module control(
    input clk,
    input reset,
    input [5:0] Op,
    output reg IRWrite,
    output reg MemWrite,
    output reg RegWrite,
    output reg RegDst,
    output reg MemToReg,
    output reg [1:0] ALUSrcB,
    output reg ALUSrcA,
    output reg [1:0] ALUOp,
    output reg PCWrite,
    output reg PCCond,
    output reg [1:0] PCSource,
    output reg JALWrite,
    output reg OverflowEnable
);

    localparam S_FETCH  = 4'd0;
    localparam S_DECODE = 4'd1;
    localparam S_REXEC  = 4'd2;
    localparam S_RWB    = 4'd3;
    localparam S_MEMADR = 4'd4;
    localparam S_LW     = 4'd5;
    localparam S_LWWB   = 4'd6;
    localparam S_SW     = 4'd7;
    localparam S_BEQ    = 4'd8;
    localparam S_J      = 4'd9;
    localparam S_ADDI   = 4'd10;
    localparam S_ADDIWB = 4'd11;
    localparam S_JAL    = 4'd12;

    reg [3:0] state, next_state;

    always @(*) begin
        case (state)
            S_FETCH:  next_state = S_DECODE;
            S_DECODE: begin
                case (Op)
                    6'b000000: next_state = S_REXEC;   // R-type
                    6'b100011: next_state = S_MEMADR;   // LW
                    6'b101011: next_state = S_MEMADR;   // SW
                    6'b000100: next_state = S_BEQ;      // BEQ
                    6'b000010: next_state = S_J;        // J
                    6'b001000: next_state = S_ADDI;     // ADDI
                    6'b000011: next_state = S_JAL;      // JAL
                    default:   next_state = S_FETCH;
                endcase
            end
            S_REXEC:  next_state = S_RWB;
            S_RWB:    next_state = S_FETCH;
            S_MEMADR: next_state = (Op == 6'b100011) ? S_LW : S_SW;
            S_LW:     next_state = S_LWWB;
            S_LWWB:   next_state = S_FETCH;
            S_SW:     next_state = S_FETCH;
            S_BEQ:    next_state = S_FETCH;
            S_J:      next_state = S_FETCH;
            S_ADDI:   next_state = S_ADDIWB;
            S_ADDIWB: next_state = S_FETCH;
            S_JAL:    next_state = S_FETCH;
            default:  next_state = S_FETCH;
        endcase
    end

    always @(*) begin
        IRWrite = 0; MemWrite = 0; RegWrite = 0; RegDst = 0;
        MemToReg = 0; ALUSrcB = 2'b00; ALUSrcA = 0; ALUOp = 2'b00;
        PCWrite = 0; PCCond = 0; PCSource = 2'b00;
        JALWrite = 0; OverflowEnable = 0;

        case (state)
            S_FETCH: begin
                IRWrite = 1;
                PCWrite = 1;
                ALUSrcA = 0;
                ALUSrcB = 2'b01; // PC + 4
                ALUOp = 2'b00;
                PCSource = 2'b00;
            end
            S_DECODE: begin
                ALUSrcA = 0;
                ALUSrcB = 2'b11; // branch offset
                ALUOp = 2'b00;
            end
            S_REXEC: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                ALUOp = 2'b10;
                OverflowEnable = 1;
            end
            S_RWB: begin
                RegWrite = 1;
                RegDst = 1;
                MemToReg = 0;
            end
            S_MEMADR: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10; // sign-extended immediate
                ALUOp = 2'b00;
            end
            S_LW: begin
                // Memory read is combinational; address is held in ALUOut.
            end
            S_LWWB: begin
                RegWrite = 1;
                RegDst = 0;
                MemToReg = 1;
            end
            S_SW: begin
                MemWrite = 1;
            end
            S_BEQ: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                PCCond = 1;
                PCSource = 2'b01; // branch target already computed in datapath
            end
            S_J: begin
                PCWrite = 1;
                PCSource = 2'b10;
            end
            S_ADDI: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                OverflowEnable = 1;
            end
            S_ADDIWB: begin
                RegWrite = 1;
                RegDst = 0;
                MemToReg = 0;
            end
            S_JAL: begin
                PCWrite = 1;
                PCSource = 2'b10;
                JALWrite = 1;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_FETCH;
        else
            state <= next_state;
    end
endmodule
