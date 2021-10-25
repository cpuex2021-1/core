`timescale 1ns / 1ps
module fmul_test;

logic [31:0] x,y;
logic [31:0] z;
logic [31:0] zans;
logic clk,rst;

fdiv fdi(.clk, .rst, .x, .y, .z);
shortreal xr,yr,zr;
always begin
    #10 clk = 1;
    #10 clk = 0;
end

int zi, ansi;
initial begin
    repeat(100) begin
        #100;
        x = $urandom;
        y = $urandom;
        xr = $bitstoshortreal(x);
        yr = $bitstoshortreal(y);
        zr = xr / yr;
        zans = $shortrealtobits(zr);
        if(zans[30:23] != 8'd0 && zans[30:23] != 8'd255)begin
        
        end
       
    end
    $finish;
    
    
end
endmodule