// Combinational 8-bit arithmetic unit; CMP reuses subtraction.
module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] alu_op,
    output wire [7:0] result,
    output wire       zero,
    output wire       overflow
);
    // Planned internal ALU control codes (decoded from CPU instruction opcodes):
    //   3'b000  ALU_ADD  (ADD, ADDI)
    //   3'b001  ALU_SUB  (SUB, CMP)
    //   3'b010  ALU_AND  (AND)
    //   3'b011  ALU_OR   (OR)
    //   3'b100  ALU_XOR  (XOR)
    //   3'b101  Reserved for optional MUL
    //   3'b110 and 3'b111 are unused.
    
    localparam [2:0] ALU_SUB = 3'b001;

    always @* begin
        result = 8'b00000000;
        zero = 1'b0;
        overflow = 1'b0;

        case (alu_op)
            default: begin end
        endcase
    end
    // TODO: Widen alu_op to [2:0] and define named constants for these codes.
    // TODO: Implement combinational addition and subtraction with an 8-bit result.
    // TODO: Calculate zero from the 8-bit result.
    // TODO: Detect signed overflow for addition and subtraction.
endmodule
