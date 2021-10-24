`timescale 1ns / 1ps
module topoftop(
    input  wire clk, rst,
    input  wire rxd,
    output wire txd,
    output wire [15:0] pc
);
    top to(.clk(clk), .rst(rst),  .rxd(rxd), .txd(txd), .pc_(pc));

endmodule