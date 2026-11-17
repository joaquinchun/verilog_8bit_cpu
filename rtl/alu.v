// Combinational 8-bit arithmetic unit; CMP reuses subtraction.
module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] alu_op,
    output wire [7:0] result,
    output wire       zero,
    output wire       overflow
);
    // TODO: Assign ALU operation codes; reserve one for optional multiplication.
    // TODO: Implement combinational addition and subtraction with an 8-bit result.
    // TODO: Calculate zero from the 8-bit result.
    // TODO: Detect signed overflow for addition and subtraction.
endmodule
