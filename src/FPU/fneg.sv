`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2021 12:55:29 AM
// Design Name: 
// Module Name: fneg
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


module fneg(
        input  logic [31:0] x,
        output logic [31:0] z
    );
    assign z = {~x[31], x[30:0]};
endmodule
