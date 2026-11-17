// Synchronous 256-byte data RAM; programs store data before reading it.
module data_ram (
    input  wire       clk,
    input  wire [7:0] addr,
    input  wire       write_en,
    input  wire [7:0] write_data,
    output wire [7:0] read_data
);
    // TODO: Declare a 256-entry, 8-bit RAM array.
    // TODO: Implement a synchronous read on the rising edge of clk.
    // TODO: Write write_data on the rising edge of clk when write_en is asserted.
endmodule
