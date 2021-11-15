`timescale 1ns / 1ps

module fsub(
        input logic [31:0] x,y,
        input logic clk,rst,
        output logic [31:0] z
    );
    logic [31:0] ny;
    assign ny  = {~y[31], y[30:0]};
    fadd_cy fad(.x1(x),.x2(ny), .y(z), .clk, .rst);
endmodule
