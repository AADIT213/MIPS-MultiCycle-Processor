module alucontrol(
    input  [1:0] AluOp,
    input  [5:0] FnField,
    output reg [3:0] AluCtrl
);
    always @(*) begin
        case (AluOp)
            2'b00: AluCtrl = 4'b0010; // address calculation / ADD
            2'b01: AluCtrl = 4'b0110; // SUB / BEQ
            2'b10: begin
                case (FnField)
                    6'h20: AluCtrl = 4'b0010; // ADD
                    6'h22: AluCtrl = 4'b0110; // SUB
                    6'h24: AluCtrl = 4'b0000; // AND
                    6'h25: AluCtrl = 4'b0001; // OR
                    6'h2A: AluCtrl = 4'b0111; // SLT
                    default: AluCtrl = 4'b1111; // invalid
                endcase
            end
            default: AluCtrl = 4'b1111;
        endcase
    end
endmodule
