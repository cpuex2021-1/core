`timescale 1ns / 1ps
module fmul_test;

logic [31:0] a,b;
logic [31:0] c;

fmul fmu(a,b,c);

initial begin
    $dumpfile("fmul.vcd");
    $dumpvars;
    a = 32'b0; b=32'b0;
    
end
endmodule