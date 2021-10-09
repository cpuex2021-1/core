`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2021 12:56:32 AM
// Design Name: 
// Module Name: fmin
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flt(
        input  logic [31:0] x,y,
        output logic [31:0] z
    );
    logic xs, ys;
    logic [7:0] xe, ye;
    logic [22:0] xm, ym;

    logic xeLTye;
    logic xmLTym;
    always_comb begin
        xs = x[31];
        ys = y[31];
        xe = x[30:23];
        ye = y[30:23];
        xm = x[22:0];
        ym = y[22:0];

        xeLTye = xe < ye;
        xmLTym = xm < ym;
    end


endmodule
