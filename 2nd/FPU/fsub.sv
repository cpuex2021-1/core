`timescale 1ns / 1ps

module fsub(
        input logic [31:0] x1,x2,
        input logic clk,rst,
        output logic [31:0] y
    );
    logic [31:0] ny;
    assign ny  = {~x2[31], x2[30:0]};
    fadd_cy fad(.x1,.x2(ny), .y, .clk, .rst);
endmodule
