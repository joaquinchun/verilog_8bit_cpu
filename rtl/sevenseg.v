// Shows an 8-bit value (0-255) in decimal on the Basys 3 seven-segment display.
// Right three digits show hundreds, tens, ones WITH leading zeros (5 -> "005").
// The leftmost digit and all decimal points stay off.
module sevenseg (
    input  wire       clk,        // 100 MHz board clock
    input  wire       rst,
    input  wire [7:0] value,
    output wire [6:0] seg,        // segments a-g; Basys 3 segments are active LOW
    output wire       dp,         // decimal point; active LOW, keep off (1)
    output wire [3:0] an          // digit enables; active LOW, an[3] = leftmost
);
    // TODO: Convert value to three decimal digits (hundreds, tens, ones),
    //       e.g. with double dabble or divide/modulo by 10.
    // TODO: Build a scan enable from clk (about 1 kHz per digit) and cycle
    //       through the right three digits. Keep an[3] off (1).
    // TODO: Decode the selected digit 0-9 into the seven segment pattern.
endmodule
