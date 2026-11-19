// Memory-mapped output register at data address 0xF2.
// Watches the CPU's store signals; drives the LEDs and the seven-segment display.
module output_port (
    input  wire       clk,
    input  wire       rst,        // synchronous, active high; clears the output
    input  wire [7:0] mem_addr,
    input  wire [7:0] mem_wdata,
    input  wire       mem_we,     // high for exactly one board clock per ST
    output wire [7:0] out_value   // held until the next store to 0xF2
);
    // TODO: Declare an 8-bit output register.
    // TODO: On reset, clear it to 0.
    // TODO: On a rising edge of clk with mem_we = 1 and mem_addr = 8'hF2,
    //       capture mem_wdata. Otherwise hold the value (including while halted).
    // TODO: Drive out_value from the register.
endmodule
