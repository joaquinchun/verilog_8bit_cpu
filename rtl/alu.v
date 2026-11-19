// Combinational 8-bit arithmetic unit; CMP reuses subtraction.
// Outputs Z (zero) and C (unsigned carry/borrow); see README "Flags".
module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] alu_op,
    output wire [7:0] result,
    output wire       zero,
    output wire       carry
);
    // Planned internal ALU control codes (decoded from CPU instruction opcodes):
    //   3'b000  ALU_ADD  (ADD, ADDI)
    //   3'b001  ALU_SUB  (SUB, CMP)
    //   3'b010  ALU_AND  (AND)
    //   3'b011  ALU_OR   (OR)
    //   3'b100  ALU_XOR  (XOR)
    //   3'b101  ALU_MUL  (optional MUL; low 8 bits)
    //   3'b110  ALU_PASS (MOV, LDI): result = b
    //   3'b111  unused
    
    localparam [2:0] ALU_SUB = 3'b001;

    always @* begin
        result = 8'b00000000;
        zero = 1'b0;
        carry = 1'b0;

        case (alu_op)
            default: begin end
        endcase
    end
    // TODO: Define named constants for all of these codes.
    // TODO: Implement ADD, SUB, AND, OR, XOR, and PASS with an 8-bit result.
    // TODO: Calculate zero from the 8-bit result.
    // TODO: Calculate carry (unsigned):
    //       ADD: bit 8 of the 9-bit sum {1'b0,a} + {1'b0,b}  (1 when a + b > 255)
    //       SUB: bit 8 of the 9-bit difference {1'b0,a} - {1'b0,b}  (1 = borrow, a < b)
    //       Other operations: carry = 0 (the CPU does not save it for them).
endmodule
