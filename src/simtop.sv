`timescale 1ns / 1ps

module simtop();
    logic clk, rst;
    logic rxd, txd;
    logic [15:0] LED;

    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

    initial begin
        rxd = 1;
        rst = 1'b1;
        #25 rst = 1'b0;
        repeat(100) begin
        #100 rxd = 0;
        #100 rxd = 1;
        #100 rxd = 0;
        #100 rxd = 1;
        #100 rxd = 0;
        #100 rxd = 1;
        #100 rxd = 0;
        #100 rxd = 1;
        #100 rxd = 0;
        #100 rxd = 1;
        end
        

    end

    top top(.clk, .rst, .LED, .rxd, .txd);
endmodule