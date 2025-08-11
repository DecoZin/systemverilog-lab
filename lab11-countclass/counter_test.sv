// Name: André Lamego
// Date: 08/11/2025
// Description: Testbench module for Class Counter

timeunit 1ns;
timeprecision 100ps;

module counter_test;

    counterclass counter = new();

    initial begin
        $display("Count: %d", counter.getcount());
        counter.load(5);
        $display("Count: %d", counter.getcount());
        $finish;
    end

endmodule