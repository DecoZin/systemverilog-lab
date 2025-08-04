// Name: André Lamego
// Date: 14/07/2025
// Description: Counter module of SystemVerilog Course

module counter (
    input        clk,
    input        rst_,
    input        enable,
    input  logic load,
    input  logic [4:0] data,
    output logic [4:0] count
);

    timeunit 1ns;
    timeprecision 100ps;

    always_ff @( posedge clk or negedge rst_ ) begin : counter_procedure
        if (!rst_) begin
            count <= '0;
        end else if (load) begin
            count <= data;
        end else if (enable) begin
            count++;
        end else begin
            count <= count;
        end
    end : counter_procedure
    
endmodule