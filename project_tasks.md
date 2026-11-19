# Project tasks: Joaquin and Amanda

Build the CPU described in `project_spec.txt`, with both people learning the full hardware, verification, and FPGA workflow. This plan replaces the earlier sum-of-five demo and direct R3-to-LED output with the counter, Fibonacci, and memory-mapped display requirements.

## How we will work

Work through the tasks in order together, rather than implementing separate parts in parallel. The named owner drives the implementation and its first self-checking test; the other person reviews it, adds an edge case, and explains its waveform. Swap the keyboard between the two portions of every task. Do not move on until both can explain the inputs, state changes, outputs, and test result.

The instruction split is eight versus seven because there are 15 core instructions. Balance effort through shared-module work and alternating integration and board responsibilities, rather than instruction count alone. At the end of each session, compare time spent and swap the next implementation portion if needed. Ownership means responsibility for finishing and explaining the work, not exclusive access to a file.

| Area | Joaquin drives | Amanda drives |
|---|---|---|
| Instructions, including execute cases and tests | LDI, ADDI, SUB, ST, JMP, JNZ, AND, XOR | MOV, ADD, CMP, LD, JZ, HALT, OR |
| ALU and flags | Subtraction, AND/XOR, combinational Z, saved Z | Addition, OR, signed V for addition/subtraction, saved V |
| Register file | Rising-edge write port and write qualification | Two combinational read ports and register observation in simulation |
| Fetch and timing | PC, next-address selection, divide-by-four clock enable | Synchronous ROM, instruction capture, FSM transitions |
| Data memory and output | RAM write path, address decode, output capture | Synchronous RAM read, LD writeback, decimal display driver |
| Programs | Counter algorithm; encode/review Fibonacci | Fibonacci algorithm; encode/review counter |
| Board work | Clock/reset constraints; first counter build | Display constraints; first Fibonacci build |

Both people work in `alu.v`, `regfile.v`, `cpu.v`, the memories, testbenches, and board setup. Both perform a complete Vivado build and program the board.

## Week 1: agree on interfaces and run a small program

### Task 1. Define the ISA and update the skeleton — Both

- [ ] Document all 15 core instructions: LDI, MOV, LD, ST, ADD, ADDI, SUB, CMP, AND, OR, XOR, JMP, JZ, JNZ, and HALT. Reserve the remaining opcode for optional MUL.
- [ ] Agree on unique four-bit opcode assignments, operands, destination, immediate/address meaning, and flag behavior. The spec does not assign numeric opcodes. Retain the existing 16-bit field layout unless both explicitly revise it: opcode [15:12], Rd [11:10], Rs [9:8], immediate/address [7:0]. The 8-bit PC addresses instruction words.
- [ ] Use ADD, ADDI, SUB, and CMP to update saved Z and V. ADDI must update Z for the counter's immediate JZ. As a documented project choice, preserve flags for the other core instructions; the spec does not fully define their flag behavior. CMP must preserve both operands.
- [ ] Agree on internal signal names, a sufficiently wide ALU operation selector (three bits supports the planned operations), and a store interface carrying address, data, and a one-cycle write strobe to a separate output module.
- [ ] Plan `rtl/output_port.v` for the output register and `rtl/sevenseg.v` for decimal conversion and digit scanning. Add display ports to `basys3_top.v` and corresponding constraint TODOs. LEDs will show the output register, not R3; R3 may remain a debug signal.
- [ ] Specify reset behavior and reserved-I/O read/write behavior. Suggested choices: clear the output register on reset, ignore writes to unimplemented I/O addresses, and return zero for unimplemented I/O reads. Label these as design choices, not requirements from the spec.
- [ ] Each person documents their instructions, hand-encodes an example in binary, and decodes the other's example. Compare SUB and CMP to explain shared subtraction hardware and different write enables.

**Done when:** both can decode a 16-bit instruction and explain the complete memory map and output interface. Preserve existing smoke/demo files as earlier exercises; they are not the required final demos.

### Task 2. Build and test the ALU — Joaquin: subtraction and logic; Amanda: addition and overflow

- [ ] Joaquin implements subtraction, AND, XOR, and zero detection from the selected eight-bit result.
- [ ] Amanda implements addition, OR, and signed overflow for both addition and subtraction. ADDI reuses addition; CMP reuses subtraction.
- [ ] Agree on default outputs and combinational assignments that avoid latches. Keep the implementation in Verilog-2001.
- [ ] Both extend `alu_tb.v` with self-checking cases: ordinary arithmetic, each logic operation, `5 - 5 = 0` with Z=1, `255 + 1 = 0` with Z=1/V=0, `127 + 1 = 128` with V=1, and signed `-128 - 1` with V=1.

**Cross-review:** Joaquin explains addition overflow; Amanda explains subtraction and zero detection. Calculating ALU flags here is separate from saving CPU flags in Task 6.

### Task 3. Build the register file — Joaquin: writes; Amanda: reads

- [ ] Declare one array containing four eight-bit registers, R0 through R3.
- [ ] Joaquin implements the enabled rising-edge write. Amanda implements two independent combinational reads.
- [ ] Write 7 to R0 and 3 to R1, read both simultaneously, and check that changing write data with writes disabled does not change stored values.
- [ ] Both explain how MOV, arithmetic, and LD will share the write port. Do not rely on uninitialized register values; programs initialize values before use.

**Done when:** both can trace an operand from a read address to the ALU and a result back into the selected register.

### Task 4. Implement fetch and the CPU clock enable — Joaquin: PC/enable; Amanda: ROM/FSM

- [ ] Joaquin generates a one-cycle enable every four 100 MHz clock cycles and implements PC reset, increment, and target selection. Use the board clock throughout; do not create a separate 25 MHz clock.
- [ ] Amanda implements the 256-by-16 synchronous ROM with `$readmemb` and selectable `MEM_FILE`, plus FETCH, CAPTURE, and EXECUTE sequencing.
- [ ] Both inspect synchronous-read timing and ensure the instruction register captures the requested word and PC increments exactly once per instruction.
- [ ] Qualify CPU state changes and write side effects so a state held between enables does not repeatedly write registers, RAM, or the output port. Memories may read on every board clock; account for when their outputs become valid.
- [ ] Add waveform signals for clock enable, state, PC, instruction register, addresses, and write strobes. Check that successive controller steps are 40 ns apart.

**Done when:** each person explains one fetch waveform, including the ROM latency and the four-board-cycle interval between controller steps.

### Task 5. Run a first program — Joaquin: LDI; Amanda: MOV and HALT

- [ ] Joaquin implements immediate selection and register writeback for LDI.
- [ ] Amanda implements MOV and HALT, including remaining halted until reset.
- [ ] Create a binary smoke fixture using the agreed opcode table: load 5 into one register, move it to R3, then halt. The old hexadecimal `smoke.mem` cannot be read unchanged by `$readmemb`; keep it separate or explicitly convert it for this test.
- [ ] Joaquin checks register values; Amanda checks that no architectural writes occur while halted and that reset restarts fetching at address zero. Swap reviewers.

**Week-one milestone:** the binary smoke program passes self-checking simulation at the intended clock-enable cadence. Board display output comes later.

## Week 2: finish the core and memory-mapped display

### Task 6. Integrate arithmetic, logic, and saved flags — Both

- [ ] Joaquin implements SUB, ADDI, AND, and XOR execute cases and the saved Z register.
- [ ] Amanda implements ADD, CMP, and OR execute cases and the saved V register.
- [ ] Agree on a shared flags-write condition for ADD, ADDI, SUB, and CMP. Prevent CMP register writes and preserve flags for instructions designated not to update them.
- [ ] Each owner tests their instructions through fetch, execute, and writeback. Check results in registers, not just at ALU outputs.
- [ ] Cross-test equal-operand CMP without either operand changing, ADDI wraparound setting Z, and arithmetic overflow reaching saved V. Check flag preservation across MOV, LDI, and stores.

**Done when:** both distinguish combinational flags from saved flags and can trace an ADD from fetch through its single register writeback.

### Task 7. Implement branches — Joaquin: JMP/JNZ; Amanda: JZ and timing review

- [ ] Use the agreed target-address field and shared PC target-loading path.
- [ ] Test JMP, both taken and untaken JZ, and both taken and untaken JNZ. Verify the next executed instruction, not just the PC signal.
- [ ] Joaquin writes a CMP-to-JNZ test; Amanda writes SUB-to-JZ and ADDI-to-JZ tests. Review each other's results.
- [ ] Capture a conditional-branch waveform showing saved Z, instruction capture, and the enabled edge where the PC receives its target.

**Done when:** both explain why the counter must execute JZ immediately after ADDI, before any delay-loop arithmetic can replace its flags.

### Task 8. Implement RAM and memory-mapped output — Joaquin: ST/decode; Amanda: LD/readback

- [ ] Implement ordinary RAM at addresses `0x00–0xEF` (240 bytes). Reserve `0xF0–0xFF` for I/O and prevent I/O stores from writing RAM.
- [ ] Joaquin implements rising-edge RAM writes and ST address/data selection. Amanda implements synchronous reads and LOAD_WB so LD writes the returned byte only after it is valid.
- [ ] Joaquin implements `output_port.v`: capture store data only on a qualified write to `0xF2`, and otherwise hold the byte. Amanda writes its self-checking tests and reviews its reset behavior.
- [ ] Test storing 42 at `0x10` and loading it into a different register. Test the RAM boundary at `0xEF` and reserved-I/O handling.
- [ ] Store 170 to `0xF2`, then store/load ordinary RAM. Check that the output remains 170 and that each store causes exactly one intended write event.

**Done when:** both can trace ST to either RAM or the output register and LD through its synchronous read latency. Programs store RAM data before reading it.

### Task 9. Drive the board displays — Amanda: decimal display; Joaquin: wrapper and display tests

- [ ] Amanda implements decimal conversion for 0–255 and multiplexes up to three seven-segment digits. Use the existing board clock with a scan enable, and keep unused digits and the decimal point inactive.
- [ ] Joaquin connects the output register to the low eight LEDs and the decimal driver, synchronizes btnC for CPU reset, and adds clock/reset constraints from the official Basys 3 master XDC.
- [ ] Amanda adds LED, segment, digit-enable, and any decimal-point constraints from the master XDC. Together define the 100 MHz input clock with a 10 ns period and verify board signal polarity.
- [ ] Joaquin tests digit selection and segment patterns over a complete scan for 0, 9, 10, 99, 100, 170, and 255; Amanda reviews the checks. Confirm that the same captured byte drives both displays.
- [ ] Check that CPU HALT does not stop display scanning and that ordinary RAM writes leave the display unchanged.

**Week-two milestone:** a simulated store of 170 produces LED bits `10101010` and decimal digits 170. Both explain the path from the ST instruction to the physical display signals.

## Week 3: required demos, timing, and board verification

### Task 10. Write the counter and measure delays — Joaquin: algorithm; Amanda: encoding and timing

- [ ] Joaquin writes the counter assembly starting at 252. Display the initial value, increment with ADDI, and immediately execute JZ.
- [ ] On nonzero increments, display the count normally. On wraparound, display zero, then briefly display 170, while preserving the count so the next number is 1. Write every displayed value to `0xF2`.
- [ ] Amanda converts the reviewed assembly into `programs/counter.mem`: one 16-bit binary instruction per line. Joaquin decodes selected lines back to assembly to verify them.
- [ ] Both design software delay loops within the four-register and 256-instruction limits. Measure final instruction timings in enabled controller steps and use 40 ns per step to select loop counts giving roughly half-second spacing, including branch and loop overhead.
- [ ] Amanda writes an output-store sequence checker for `252, 253, 254, 255, 0, 170, 1`, followed by continued counting. Joaquin adds checks that no 170 marker appears on the nonzero path.
- [ ] Use shortened software loop counts for fast functional simulation if needed, clearly separating that fixture from the final board program. Verify final delay timing with the actual loop counts and measured instruction costs.

**Done when:** both can explain the taken/untaken branch evidence and how the marker routine preserves the count across display writes and delays.

### Task 11. Write Fibonacci — Amanda: algorithm; Joaquin: encoding and sequence tests

- [ ] Amanda writes assembly that outputs both initial 1 values, calculates later terms, delays between outputs, writes 233, and halts before calculating an unwanted next term.
- [ ] Joaquin encodes `programs/fibonacci.mem` in 16-bit binary lines; Amanda decodes samples and checks targets. Reuse the reviewed delay strategy without corrupting live sequence registers.
- [ ] Joaquin checks output-store events against `1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233`. Observe writes, not just changes of output value, to catch both initial 1s.
- [ ] Amanda checks that the CPU halts after 233, the output holds 233, and reset restarts the sequence from 1. Both review how comparisons and flags terminate the program.

**Done when:** both explain the entire program, including register allocation, termination before the next term, and delay-loop effects on saved flags.

### Task 12. Complete rubric verification and both FPGA builds — Both, alternating drivers

- [ ] Finish a self-checking regression for all 15 core instructions, register/RAM results, CMP operand preservation, arithmetic flags, both outcomes of JZ/JNZ, and HALT/reset. Each person reviews the other's instruction tests.
- [ ] Save representative ADD and conditional-branch waveforms showing state, PC, instruction register, write strobes, and the four-cycle clock-enable interval.
- [ ] Verify the memory-mapped output test: 170 on both displays, followed by an ordinary RAM store/load that does not alter the displayed value.
- [ ] Joaquin drives a complete Vivado counter build and board programming run while Amanda reviews. Amanda then drives a complete Fibonacci build and programming run while Joaquin reviews. Each build selects one complete binary ROM file.
- [ ] Review synthesis, implementation, inferred memory utilization, constraints, and timing together. Confirm a 100 MHz board clock and a 25 MHz effective controller-step rate, not a claim of 25 million instructions per second.
- [ ] On the board, check the counter sequence and readable pace; check Fibonacci reaches and holds 233 and restarts at 1 after reset. Both explain the LED and decimal outputs.

**Final evidence checklist:**

| Rubric category | Weight | Evidence |
|---|---:|---|
| Core instructions and flags | 40% | Passing self-checking tests for all 15 core instructions and required flag/branch/reset cases |
| Multicycle control | 20% | ADD/branch waveforms and four-board-cycle enable spacing |
| Memory-mapped board output | 10% | Store of 170 drives both displays; RAM store/load preserves output |
| Counter demo | 15% | Required output sequence, correct marker behavior, and readable continuing count |
| Fibonacci demo | 15% | All output writes including two initial 1s, halt at 233, and restart on reset |

### Optional Task 13. Add MUL only after the required project passes

Amanda implements the ALU multiplication operation; Joaquin integrates the reserved opcode and writeback. Swap testing roles. Agree explicitly on low-eight-bit result and flag behavior before implementation; the spec does not define MUL semantics. Test `3 * 4 = 12` and `20 * 20 = 400`, whose low byte is 144. If MUL updates Z but preserves V, use separate flag write enables. Rerun the core regression and both demos after the extension.
