`timescale 1ns / 1ps

module simtop();
    logic clk, rst;
    logic [15:0] led;

    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

    initial begin
        rst = 1'b0;
        #25 rst = 1'b1;
        #1000 $finish;

    end

    top top(.clk, .rst, .led);
endmodule