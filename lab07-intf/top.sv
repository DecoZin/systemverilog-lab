// Adapted code

module top;

timeunit 1ns;
timeprecision 1ns;

bit    clk;
mem_if bus(clk);

mem_test test (.mbus(bus));

mem memory (.sbus(bus));

always #5 clk = ~clk;
endmodule
