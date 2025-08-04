// Name: André Lamego
// Date: 22/07/2025
// Description: Memory Interface module of SystemVerilog Course

interface mem_if(
    input clk
);

    timeunit 1ns;
    timeprecision 1ns;

    logic read, write;
    logic [7:0] data_in, data_out;
    logic [4:0] addr;

    modport master (
    input  data_out,
           clk,
    output data_in,
           read,
           write,
           addr,
    import read_mem,
           write_mem
    );

    modport slave (
    output data_out,
    input  data_in,
           read,
           write,
           addr,
           clk
    );

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

endinterface //mem_if
