// Multicycle 8-bit CPU with a control FSM and synchronous instruction/data memories.
module cpu #(
    parameter MEM_FILE = "demo.mem"
) (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] r3_value,
    output wire       halted
);
    // TODO: Declare the 8-bit PC, 16-bit instruction register, FSM state,
    //       and two 1-bit status registers Z and V.
    // TODO: Instantiate alu, regfile, program_rom, and data_ram; use clk throughout
    //       and pass MEM_FILE to program_rom. Decode opcode [15:12], Rd [11:10],
    //       Rs [9:8], and immediate/address [7:0] from the instruction register.
    //       Opcodes: 0 HALT, 1 LDI, 2 ADD, 3 LD, 4 ST, 5 JMP, 6 JNZ,
    //       7 SUB, 8 CMP, 9 JZ; reserve A for optional MUL.
    // TODO: Implement reset, FETCH, CAPTURE, EXECUTE, LOAD_WB, and HALTED.
    //       Reset PC, instruction register, FSM state, Z, V, and control outputs.
    //       Allow for synchronous ROM and RAM reads; complete LD in LOAD_WB.
    // TODO: Fetch a ROM word, capture it after the synchronous read, and increment
    //       the PC exactly once. PC addresses words, so PC + 1 selects the next word.
    // TODO: Select register write data from the immediate, ALU result, or RAM.
    // TODO: Save ALU Z and V only for ADD, SUB, and CMP; CMP uses subtraction
    //       and preserves both operand registers. Other instructions preserve flags.
    // TODO: Implement JMP, JZ, and JNZ using the address and saved Z, assert RAM
    //       write enable only for ST, and keep the CPU halted until reset.
endmodule
