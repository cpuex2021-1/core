`timescale 1ns / 1ps
module topoftop(
    input  wire clk, rst,
    input  wire rxd,
    output wire txd
);
    top to(.clk(clk), .rst(rst),  .rxd(rxd), .txd(txd));

endmodule