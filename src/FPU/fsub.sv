`timescale 1ns / 1ps

module fsub(
        input logic [31:0] x,y,
        output logic [31:0] z
    );
    logic [31:0] ny = {~y[31], y[30:0]};
    fadd fad(x,ny, z);
endmodule
