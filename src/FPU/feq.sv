`timescale 1ns / 1ps

// for denormalized and different inputs what should be returned?

module feq(
        input logic [31:0] x,y,
        output logic z
    );
    /*
    logic xs, ys;
    logic [7:0] xe, ye;
    logic [22:0] xm, ym;
    assign xs = x[31];
    assign ys = y[31];
    assign xe = x[30:23];
    assign ye = y[30:23];
    assign xm = x[22:0];
    assign ym = y[22:0];

    logic xzero, yzero;
    assign xzero = ~|xe;
    assign yzero = ~|ye;
    logic bothzero;
    assign bothzero = xzero & yzero;
    logic allsame = x == y;
    assign z = bothzero | allsame;*/
    assign z = x==y;
endmodule

