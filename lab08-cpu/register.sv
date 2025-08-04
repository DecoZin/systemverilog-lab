// Name: André Lamego
// Date: 14/07/2025
// Description: Register module of SystemVerilog Course


module register (
    input        clk,
    input        rst_,
    input        enable,
    input  logic [7:0] data,
    output logic [7:0] out
    );

    timeunit 1ns;
    timeprecision 100ps;
    
    always_ff @( posedge clk or negedge rst_ ) begin : register_logic
        if (!rst_) begin
            out <= 8'h00;
        end else if (enable) begin
            out <= data;
        end else begin
            out <= out; 
        end
    end : register_logic

endmodule
