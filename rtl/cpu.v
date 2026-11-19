// Multicycle 8-bit CPU with a control FSM and synchronous instruction/data memories.
// See README "Design decisions" for the signal list and ALU control codes.
module cpu #(
    parameter MEM_FILE = "demo.mem"
) (
    input  wire       clk,
    input  wire       rst,        // synchronous, active high
    input  wire       clk_en,     // one board clock high out of every four
    output wire [7:0] mem_addr,   // data address for LD/ST (instruction's low byte)
    output wire [7:0] mem_wdata,  // byte being stored (R[Rd])
    output wire       mem_we,     // high for exactly one board clock per ST
    output wire [7:0] r3_value,   // debug only: R3 for simulation
    output wire       halted      // 1 while in the HALT state
);
    // TODO: Declare the 8-bit PC, 16-bit instruction register, FSM state,
    //       and two 1-bit saved status registers Z and C.
    // TODO: Instantiate alu, regfile, program_rom, and data_ram; use clk throughout
    //       and pass MEM_FILE to program_rom. Decode opcode [15:12], Rd [11:10],
    //       Rs [9:8], and immediate/address [7:0] from the instruction register.
    //       Opcodes: 0 HALT, 1 LDI, 2 ADD, 3 LD, 4 ST, 5 JMP, 6 JNZ, 7 SUB,
    //       8 CMP, 9 JZ, A MUL (optional), B MOV, C ADDI, D AND, E OR, F XOR.
    // TODO: Gate every state change with clk_en: PC, IR, FSM state, register
    //       writes, Z/C writes, and mem_we. Nothing changes when clk_en is 0.
    // TODO: Implement reset, FETCH, CAPTURE, EXECUTE, LOAD_WB, and HALT.
    //       Reset clears PC, instruction register, FSM state, Z, and C.
    //       Reset does NOT clear R0-R3 (README "Reset").
    //       Allow for synchronous ROM and RAM reads; complete LD in LOAD_WB.
    // TODO: Fetch a ROM word, capture it after the synchronous read, and increment
    //       the PC exactly once. PC addresses words, so PC + 1 selects the next word.
    // TODO: ALU inputs: a = R[Rd]; b = imm8 for ADDI and LDI, otherwise R[Rs].
    //       Translate the opcode to alu_op (MOV and LDI use ALU_PASS).
    // TODO: Register write data = RAM read data for LD, otherwise the ALU result.
    // TODO: Save ALU Z and C only for ADD, ADDI, SUB, and CMP. CMP uses subtraction
    //       and preserves both operand registers. Other instructions preserve flags.
    // TODO: Implement JMP, JZ, and JNZ using the address and saved Z, assert mem_we
    //       only for ST, and keep the CPU halted until reset.
endmodule
