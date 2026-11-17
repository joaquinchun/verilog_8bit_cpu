// Four general-purpose 8-bit registers with two read ports and one write port.
module regfile (
    input  wire       clk,
    input  wire       write_en,
    input  wire [1:0] write_addr,
    input  wire [7:0] write_data,
    input  wire [1:0] read_addr_a,
    input  wire [1:0] read_addr_b,
    output wire [7:0] read_data_a,
    output wire [7:0] read_data_b,
    output wire [7:0] r3_value
);
    // TODO: Declare four 8-bit registers, R0 through R3.
    // TODO: Implement two combinational reads selected by the read addresses.
    // TODO: Write write_data on the rising edge of clk when write_en is asserted.
    // TODO: Expose R3 through r3_value for the board LEDs.
endmodule
