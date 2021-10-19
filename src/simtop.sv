`timescale 1ns / 1ps

module simtop();
    logic clk, rst;
    logic rxd, txd;


    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

    initial begin
        rxd = 1;
        rst = 1'b1;
        #25 rst = 1'b0;

        

    end

    top top(.clk, .rst, .rxd, .txd);
endmodule