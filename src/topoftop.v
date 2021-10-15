`timescale 1ns / 1ps
module topoftop(
    input  wire clk, rst,
    input  wire rxd,
    output wire txd,
    output wire [15:0] LED
);
    top to(.clk(clk), .rst(rst), .LED(LED), .rxd(rxd), .txd(txd));

endmodule