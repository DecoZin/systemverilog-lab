// Adapted code 

module mem_test ( input logic clk, 
                  output logic read, 
                  output logic write, 
                  output logic [4:0] addr, 
                  output logic [7:0] data_in,     // data TO memory
                  input  wire [7:0] data_out     // data FROM memory
                );

                timeunit 1ns;
timeprecision 1ns;

bit         debug = 1;
logic [7:0] rdata;

    initial begin
        $timeformat ( -9, 0, " ns", 9 );
        #40000ns $display ( "MEMORY TEST TIMEOUT" );
        $finish;
        end

initial
    begin: memtest
    int error_status;

    $display("Clear Memory Test");

    for (int i = 0; i< 32; i++)
        // Write zero data to every address location
        write_mem(.waddr(i), .debug(debug), .write(write), .data_in(data_in), .read(read));

    for (int i = 0; i<32; i++)
        begin 
        // Read every address location
        read_mem(.raddr(i), .debug(debug), .write(write), .read(read), .data(rdata));
        // check each memory location for data = 'h00
        error_status += check(.laddr(i), .expected(0), .actual(rdata));
        end

    // print results of test

    $display("Data = Address Test");

    for (int i = 0; i< 32; i++)
        // Write data = address to every address location
        write_mem(.waddr(i), .data(i), .debug(debug), .data_in(data_in), .write(write), .read(read));

    for (int i = 0; i<32; i++)
        begin
        // Read every address location
        read_mem(.raddr(i), .debug(debug), .write(write), .read(read), .data(rdata));

        // check each memory location for data = address
        error_status += check(.laddr(i), .expected(i), .actual(rdata));

        end

    // print results of test
        printstatus(error_status);
        $finish;
    end

// add read_mem and write_mem tasks

    task automatic write_mem(
        input  bit   debug =  0,
        input  [4:0] waddr = '0,
        input  [7:0] data  = '0,
        ref    [7:0] data_in,
        ref write,
        ref read
    );

        @(negedge clk);
        write = 1;
        read = 0;
        addr = waddr;
        data_in = data;
        @(negedge clk);
        write = 0;
        if (debug) $display ( "Writing data: %h to address: %d", data, waddr );

    endtask //automatic

    task automatic read_mem(
        input  bit   debug =  0,
        input  [4:0] raddr = '0,
        output [7:0] data,
        ref write,
        ref read
    );

        @(negedge clk);
        write = 0;
        read = 1;
        addr = raddr;
        @(negedge clk);
        data = data_out;
        read = 0;
        if (debug) $display ( "Reading data: %h from address: %d", data, raddr );

    endtask //automatic

    function int check ( 
        input [4:0] laddr, 
        input [7:0] expected, 
        input [7:0] actual 
    );
        if (expected != actual) begin
            $display ("\033[1;31mERROR\033[0m - Address: %d | Expected data: %h | Actual data: %h", laddr, expected, actual);
            return 1;
        end else
            return 0;
        
    endfunction

// add result print function

    function void printstatus (
        input int status
    );
        if (status == 0) 
            $display ("\033[1;32mTEST PASSED!\033[0m");
        else
            $display ("\033[1;31mTEST FAILED\033[0m - %d errors", status);
            
    endfunction

endmodule
