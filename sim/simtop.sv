`timescale 1ns / 1ps

module simtop();
    logic clk, rst;
    wire [15:0] LED;

    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

    initial begin
        rst = 1'b1;
        #25 rst = 1'b0;
        #1000 $finish;

    end

    top top(.clk(clk), .rst(rst), .LED(LED));
endmodule