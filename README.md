# verilog_8bit_cpu

## Instruction set architecture (ISA)

This table defines the implementation target for the 15 core instructions in `project_spec.txt`. Opcode assignments and detailed operand/flag conventions are project choices: the spec does not assign them. It preserves the starter's opcodes 0–9 and reservation of A for optional MUL, and assigns B–F to the five additional core instructions. The RTL is still a skeleton and does not yet implement this table.

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
| 2 | 0010 | `ADD Rd, Rs` | `R[Rd] = R[Rd] + R[Rs]`; low byte unused | Update Z, V |
| 3 | 0011 | `LD Rd, [addr8]` | Load the addressed data byte into `R[Rd]`; Rs unused | Preserve |
| 4 | 0100 | `ST Rd, [addr8]` | Store `R[Rd]` to the data address; Rs unused; registers unchanged | Preserve |
| 5 | 0101 | `JMP addr8` | Set PC to addr8; Rd and Rs unused | Preserve |
| 6 | 0110 | `JNZ addr8` | Set PC to addr8 if saved Z=0; otherwise continue; Rd and Rs unused | Preserve |
| 7 | 0111 | `SUB Rd, Rs` | `R[Rd] = R[Rd] - R[Rs]`; low byte unused | Update Z, V |
| 8 | 1000 | `CMP Rd, Rs` | Calculate `R[Rd] - R[Rs]` for flags only; preserve both operands; low byte unused | Update Z, V |
| 9 | 1001 | `JZ addr8` | Set PC to addr8 if saved Z=1; otherwise continue; Rd and Rs unused | Preserve |
| A | 1010 | `MUL Rd, Rs` (optional) | Reserved for multiplication; result and flag rules must be agreed before implementation | Not yet defined |
| B | 1011 | `MOV Rd, Rs` | `R[Rd] = R[Rs]`; low byte unused | Preserve |
| C | 1100 | `ADDI Rd, imm8` | `R[Rd] = R[Rd] + imm8`; Rs unused | Update Z, V |
| D | 1101 | `AND Rd, Rs` | Bitwise AND of the two operands into `R[Rd]`; low byte unused | Preserve |
| E | 1110 | `OR Rd, Rs` | Bitwise OR of the two operands into `R[Rd]`; low byte unused | Preserve |
| F | 1111 | `XOR Rd, Rs` | Bitwise XOR of the two operands into `R[Rd]`; low byte unused | Preserve |

### Flags

ADD, ADDI, SUB, and CMP update the saved one-bit Z and V registers. All other core instructions preserve them, including the bitwise logic instructions. This follows the conventions in `project_tasks.md`; the older CPU skeleton TODO must also include ADDI when implemented.

- **Z (zero):** 1 when the eight-bit arithmetic result is zero, otherwise 0. CMP uses its subtraction result without writing a register.
- **V (signed overflow):** interpret both eight-bit operands as two's-complement values. Addition overflows when the operand signs match and the result sign differs. Subtraction overflows when operand signs differ and the result sign differs from the first operand. ADDI applies the same addition rule to the immediate byte.
- `255 + 1` produces `0x00`, Z=1, V=0. `127 + 1` produces `0x80`, Z=0, V=1. There is no carry flag.
- JZ and JNZ read saved Z. The counter uses ADDI immediately followed by JZ so the branch sees the increment's flags.

### Memory and output

Instruction ROM holds 256 sixteen-bit words and is separate from the data address space. LD and ST use absolute eight-bit data addresses.

| Data address | Purpose |
|---|---|
| `0x00–0xEF` | 240 bytes of RAM; programs store values before reading them |
| `0xF0–0xFF` | Reserved I/O region; must not access ordinary RAM |
| `0xF2` (within I/O) | An ST captures the byte in the output register, driving the low eight LEDs and decimal seven-segment display |

The output register holds its value between writes, including while halted. Read behavior for I/O addresses and behavior at unimplemented I/O addresses must be finalized as described in `project_tasks.md`; the spec only requires output writes to `0xF2`.

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
