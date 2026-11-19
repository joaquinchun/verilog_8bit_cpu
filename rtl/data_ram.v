// Synchronous data RAM for addresses 0x00-0xEF (240 bytes).
// Addresses 0xF0-0xFF are I/O: never written here, and read as 0.
module data_ram (
    input  wire       clk,
    input  wire [7:0] addr,
    input  wire       write_en,   // the CPU's mem_we (already one board clock per ST)
    input  wire [7:0] write_data,
    output wire [7:0] read_data
);
    // TODO: Declare a 240-entry, 8-bit RAM array (addresses 0x00-0xEF).
    // TODO: Write write_data on the rising edge of clk when write_en is 1
    //       AND addr < 8'hF0. Stores to 0xF0-0xFF must not change RAM.
    // TODO: Implement a synchronous read on the rising edge of clk.
    //       For addr >= 8'hF0, read_data is 0.
endmodule
