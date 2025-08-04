// Adapted code

module mem_test (
    mem_if.master  mbus
);

timeunit 1ns;
timeprecision 1ns;


bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking


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
            mbus.write_mem(.waddr(i), .debug(debug), .write(mbus.write), .data_in(mbus.data_in), .read(mbus.read));

        for (int i = 0; i<32; i++)
            begin 
            // Read every address location
            mbus.read_mem(.raddr(i), .debug(debug), .write(mbus.write), .read(mbus.read), .data(rdata));
            // check each memory location for data = 'h00
            error_status += check(.laddr(i), .expected(0), .actual(rdata));
            end

        // print results of test

        $display("Data = Address Test");

        for (int i = 0; i< 32; i++)
            // Write data = address to every address location
            mbus.write_mem(.waddr(i), .data(i), .debug(debug), .data_in(mbus.data_in), .write(mbus.write), .read(mbus.read));

        for (int i = 0; i<32; i++)
            begin
            // Read every address location
            mbus.read_mem(.raddr(i), .debug(debug), .write(mbus.write), .read(mbus.read), .data(rdata));

            // check each memory location for data = address
            error_status += check(.laddr(i), .expected(i), .actual(rdata));

            end

        // print results of test
        printstatus(error_status);
        $finish;
    end

    // add read_mem and write_mem tasks

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
