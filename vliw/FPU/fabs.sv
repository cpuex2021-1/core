
`timescale 1ns / 1ps

module fabs(
        input  logic [31:0] x,
        output logic [31:0] z
    );
    assign z = {1'b0, x[30:0]};
endmodule
