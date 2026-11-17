// Synchronous program ROM containing 256 instruction words of 16 bits each.
module program_rom #(
    parameter MEM_FILE = "demo.mem"
) (
    input  wire        clk,
    input  wire [7:0]  addr,
    output wire [15:0] instruction
);
    // TODO: Declare a 256-word, 16-bit ROM array.
    // TODO: Initialize the ROM array with $readmemh using MEM_FILE.
    // TODO: Register the addressed word on the rising edge of clk for block ROM inference.
endmodule
