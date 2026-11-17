// Basys 3 FPGA synthesis top connecting the CPU's R3 to eight board LEDs.
module basys3_top (
    input  wire       clk,
    input  wire       btnC,
    output wire [7:0] led
);
    // TODO: Synchronize the active-high reset button btnC to clk with two stages.
    // TODO: Instantiate cpu using clk and the synchronized reset; use one clock throughout.
    // TODO: Connect the CPU's r3_value output to led[7:0].
endmodule
