// Adapted code

module mem (
    mem_if.slave sbus	   
);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic data type
logic [7:0] memory [0:31] ;
  
  always @(posedge sbus.clk)
    if (sbus.write && !sbus.read)
// SYSTEMVERILOG: time literals
      #1 memory[sbus.addr] <= sbus.data_in;

// SYSTEMVERILOG: always_ff and iff event control
  always_ff @(posedge sbus.clk iff ((sbus.read == '1)&&(sbus.write == '0)) )
       sbus.data_out <= memory[sbus.addr];

endmodule
