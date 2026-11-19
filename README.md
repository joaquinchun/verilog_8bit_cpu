# verilog_8bit_cpu

## Instruction set architecture (ISA)

This table defines the implementation target for the 15 core instructions in `project_spec.txt`. Opcode assignments and detailed operand/flag conventions are project choices: the spec does not assign them. It preserves the starter's opcodes 0–9 and reservation of A for optional MUL, and assigns B–F to the five additional core instructions. The RTL is still a skeleton and does not yet implement this table. Interface and design decisions are under [Design decisions](#design-decisions-task-1).

### Instruction format

Every instruction is one 16-bit word. There are four eight-bit registers, R0–R3, encoded as `00`, `01`, `10`, and `11`.

| Bits | Field | Meaning |
|---|---|---|
| [15:12] | opcode | Four-bit instruction code |
| [11:10] | Rd | Destination or first operand register; also the source register for ST |
| [9:8] | Rs | Second operand or source register |
| [7:0] | imm8 / addr8 | Eight-bit immediate or absolute address |

Encode unused fields as zero; the decoder ignores them. The eight-bit PC addresses instruction words: normal execution advances to `PC + 1` modulo 256. Branch targets are absolute ROM word addresses, not byte addresses or relative offsets.

### Opcodes and behavior

`R[Rd]` and `R[Rs]` mean the values of the selected registers. Arithmetic writes only the low eight bits. “Preserve” means leave both saved flags unchanged.

| Hex | Binary | Assembly | Operation | Saved flags |
|---|---|---|---|---|
| 0 | 0000 | `HALT` | Stop instruction execution until reset; all operand fields unused | Preserve |
| 1 | 0001 | `LDI Rd, imm8` | `R[Rd] = imm8`; Rs unused | Preserve |
| 2 | 0010 | `ADD Rd, Rs` | `R[Rd] = R[Rd] + R[Rs]`; low byte unused | Update Z, C |
| 3 | 0011 | `LD Rd, [addr8]` | Load the addressed data byte into `R[Rd]`; Rs unused | Preserve |
| 4 | 0100 | `ST Rd, [addr8]` | Store `R[Rd]` to the data address; Rs unused; registers unchanged | Preserve |
| 5 | 0101 | `JMP addr8` | Set PC to addr8; Rd and Rs unused | Preserve |
| 6 | 0110 | `JNZ addr8` | Set PC to addr8 if saved Z=0; otherwise continue; Rd and Rs unused | Preserve |
| 7 | 0111 | `SUB Rd, Rs` | `R[Rd] = R[Rd] - R[Rs]`; low byte unused | Update Z, C |
| 8 | 1000 | `CMP Rd, Rs` | Calculate `R[Rd] - R[Rs]` for flags only; preserve both operands; low byte unused | Update Z, C |
| 9 | 1001 | `JZ addr8` | Set PC to addr8 if saved Z=1; otherwise continue; Rd and Rs unused | Preserve |
| A | 1010 | `MUL Rd, Rs` (optional) | Reserved for multiplication; result and flag rules must be agreed before implementation | Not yet defined |
| B | 1011 | `MOV Rd, Rs` | `R[Rd] = R[Rs]`; low byte unused | Preserve |
| C | 1100 | `ADDI Rd, imm8` | `R[Rd] = R[Rd] + imm8`; Rs unused | Update Z, C |
| D | 1101 | `AND Rd, Rs` | Bitwise AND of the two operands into `R[Rd]`; low byte unused | Preserve |
| E | 1110 | `OR Rd, Rs` | Bitwise OR of the two operands into `R[Rd]`; low byte unused | Preserve |
| F | 1111 | `XOR Rd, Rs` | Bitwise XOR of the two operands into `R[Rd]`; low byte unused | Preserve |

### Flags

ADD, ADDI, SUB, and CMP update the saved one-bit Z and C registers. All other core instructions preserve them, including the bitwise logic instructions, MOV, and LDI.

**Design change from the proposal:** the proposal listed a signed-overflow flag V. We replaced it with an unsigned carry flag C. There is no V flag. The demos only use Z, so they are unaffected; the rubric's `127 + 1` overflow test becomes the carry tests below.

- **Z (zero):** 1 when the eight-bit result is zero, otherwise 0. CMP uses its subtraction result without writing a register.
- **C (carry / borrow):** treat both operands as unsigned (0–255).
  - Addition (ADD, ADDI): C=1 when the true sum is larger than 255, i.e. bit 8 of the nine-bit sum.
  - Subtraction (SUB, CMP): C=1 means a **borrow**, i.e. `R[Rd] < R[Rs]` as unsigned numbers. This is bit 8 of the nine-bit difference `{0, a} - {0, b}`.
- Examples:

| Operation | Result | Z | C |
|---|---|---|---|
| `255 + 1` | `0x00` | 1 | 1 |
| `127 + 1` | `0x80` | 0 | 0 |
| `200 + 100` | `0x2C` (44) | 0 | 1 |
| `5 - 5` | `0x00` | 1 | 0 |
| `5 - 3` | `0x02` | 0 | 0 |
| `3 - 5` | `0xFE` (254) | 0 | 1 |
| `0 - 1` | `0xFF` | 0 | 1 |

- JZ and JNZ read saved Z. No instruction branches on C. The counter uses ADDI immediately followed by JZ so the branch sees the increment's flags.

### Memory and output

Instruction ROM holds 256 sixteen-bit words and is separate from the data address space. LD and ST use absolute eight-bit data addresses.

| Data address | Purpose |
|---|---|
| `0x00–0xEF` | 240 bytes of RAM; programs store values before reading them |
| `0xF0–0xFF` | Reserved I/O region; must not access ordinary RAM |
| `0xF2` (within I/O) | An ST captures the byte in the output register, driving the low eight LEDs and decimal seven-segment display |

The output register holds its value between writes, including while halted. The spec only requires output writes to `0xF2`; the rest of the I/O behavior below is our own design choice:

- A store to `0xF2` updates the output register and does **not** write RAM.
- Stores to any other address in `0xF0–0xFF` are ignored.
- Loads from any address in `0xF0–0xFF` return 0.

## Design decisions (Task 1)

These are project choices, not requirements from the spec.

### ALU control codes

The ALU has its own 3-bit `alu_op`, separate from the 4-bit instruction opcode. The controller translates one into the other during EXECUTE. `alu_op` never appears in a program.

| `alu_op` | Name | ALU result | Used by |
|---|---|---|---|
| `000` | `ALU_ADD` | `a + b` | ADD, ADDI |
| `001` | `ALU_SUB` | `a - b` | SUB, CMP |
| `010` | `ALU_AND` | `a & b` | AND |
| `011` | `ALU_OR` | `a \| b` | OR |
| `100` | `ALU_XOR` | `a ^ b` | XOR |
| `101` | `ALU_MUL` | low 8 bits of `a * b` | MUL (optional) |
| `110` | `ALU_PASS` | `b` | MOV, LDI |
| `111` | — | unused | — |

The ALU's `a` input is always `R[Rd]`. Its `b` input is `imm8` for ADDI and LDI, otherwise `R[Rs]`. Because MOV and LDI go through `ALU_PASS`, register write data is either the ALU result or, for LD, the RAM read data. The ALU always outputs Z and C, but the CPU saves them only for ADD, ADDI, SUB, and CMP.

### Module structure and signals

```
basys3_top
├── clock-enable counter  → clk_en (one 100 MHz clock high, every 4 clocks)
├── reset synchronizer    → rst (btnC through two flip-flops)
├── cpu                   (program_rom, regfile, alu, data_ram inside)
├── output_port           (captures stores to 0xF2)
└── sevenseg              (decimal display)
```

| Signal | Width | Direction | Meaning |
|---|---|---|---|
| `clk` | 1 | into everything | 100 MHz board clock; the only clock |
| `rst` | 1 | top → cpu, output_port, sevenseg | Synchronous, active-high reset from the synchronized btnC |
| `clk_en` | 1 | top → cpu | High for one board clock out of every four; CPU state changes only when it is 1. The testbench drives it directly. |
| `mem_addr` | 8 | cpu → output_port | Data address for LD and ST (the instruction's low byte) |
| `mem_wdata` | 8 | cpu → output_port | Byte being stored (`R[Rd]`) |
| `mem_we` | 1 | cpu → output_port | High for exactly one board clock per ST |
| `mem_rdata` | 8 | data_ram → cpu (internal) | Byte returned for LD |
| `r3_value` | 8 | cpu → top | Debug only: R3 for simulation; not connected to the LEDs |
| `halted` | 1 | cpu → top | 1 while in the HALT state |

The CPU does not know about the display. `output_port` watches `mem_addr`, `mem_wdata`, and `mem_we`, and captures the byte when `mem_we` is 1 and `mem_addr` is `0xF2`.

### Display

- The low eight LEDs show the output register in binary.
- The seven-segment display shows it in decimal on the right three digits, **with leading zeros**: 5 shows as `005`, 170 as `170`. The leftmost digit and all decimal points stay off.

### Reset

`rst` is synchronous and active high, from btnC through a two-stage synchronizer in `basys3_top`. Reset clears the PC, instruction register, FSM state, Z, C, and the output register, so the program restarts at address 0. **R0–R3 are not cleared**; every program sets a register before using it. In simulation the registers start as X until written.

### Encoding examples

Required demo files `counter.mem` and `fibonacci.mem` use one sixteen-character binary word per line and are loaded with `$readmemb`. Hex is shown here only as a compact reference; the existing hexadecimal `smoke.mem` needs conversion before use with `$readmemb`.

| Assembly | Fields: opcode Rd Rs immediate/address | Binary word for .mem | Hex reference |
|---|---|---|---|
| `LDI R3, 5` | `0001 11 00 00000101` | `0001110000000101` | `1C05` |
| `SUB R0, R1` | `0111 00 01 00000000` | `0111000100000000` | `7100` |
| `CMP R0, R1` | `1000 00 01 00000000` | `1000000100000000` | `8100` |
| `ADDI R0, 1` | `1100 00 00 00000001` | `1100000000000001` | `C001` |
| `ST R3, [0xF2]` | `0100 11 00 11110010` | `0100110011110010` | `4CF2` |
| `HALT` | `0000 00 00 00000000` | `0000000000000000` | `0000` |
