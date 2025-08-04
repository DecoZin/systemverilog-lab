// Name: André Lamego
// Date: 14/07/2025
// Description: Typedefs package of SystemVerilog Course

module alu import typedefs::*;
(
    input                 clk   ,
    input  opcode_t [2:0] opcode,
    input  logic    [7:0] data  ,
    input  logic    [7:0] accum ,
    output logic    [7:0] out   ,
    output logic          zero
);

    timeunit 1ns;
    timeprecision 100ps;

    always_comb begin : zero_procedure
        zero = (accum == 0);
    end 

    always_ff @( negedge clk ) begin : alu_procedure
        unique case (opcode)
            ADD : begin
                out <= data + accum;
            end
            AND : begin
                out <= data & accum;
            end
            XOR : begin
                out <= data ^ accum;
            end
            LDA : begin
                out <= data;
            end
            default: begin
                out <= accum;
            end
        endcase
    end
    
endmodule