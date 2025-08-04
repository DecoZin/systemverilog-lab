// Name: André Lamego
// Date: 14/07/2025
// Description: MUX module of SystemVerilog Course

module scale_mux #(
    WIDTH = 1
) (
    input  logic sel_a,
    input  logic [WIDTH-1:0] in_a,
    input  logic [WIDTH-1:0] in_b,
    output logic [WIDTH-1:0] out
);

    timeunit 1ns;
    timeprecision 100ps;

    always_comb begin : mux_procedure
        unique case (sel_a)
            1'b1:    out = in_a; 
            1'b0:    out = in_b; 
            default: out = 'x; 
        endcase
    end : mux_procedure
    
endmodule