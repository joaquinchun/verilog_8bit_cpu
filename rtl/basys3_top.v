// Basys 3 FPGA synthesis top: CPU, memory-mapped output, LEDs, and seven-segment display.
module basys3_top #(
    parameter MEM_FILE = "counter.mem"   // or "fibonacci.mem"; one program per build
) (
    input  wire       clk,       // 100 MHz board clock
    input  wire       btnC,      // reset button, active high
    output wire [7:0] led,
    output wire [6:0] seg,
    output wire       dp,
    output wire [3:0] an
);
    // TODO: Synchronize btnC to clk with two flip-flops to make rst.
    // TODO: Clock-enable counter: clk_en is 1 for one board clock out of every 4
    //       (25 M CPU steps per second). Do not make a separate clock.
    // TODO: Instantiate cpu with clk, rst, clk_en, and MEM_FILE.
    //       r3_value is debug only and stays unconnected here.
    // TODO: Instantiate output_port with the CPU's mem_addr, mem_wdata, and mem_we.
    // TODO: Connect output_port's out_value to led[7:0] and to sevenseg's value.
    // TODO: Instantiate sevenseg to drive seg, dp, and an.
endmodule
