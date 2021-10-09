`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2021 08:47:19 PM
// Design Name: 
// Module Name: fsub
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


module fsub(
        input logic [31:0] x,y,
        output logic [31:0] z
    );
    logic [31:0] ny = {~y[31], y[30:0]};
    fadd fad(x,ny, z);
endmodule
