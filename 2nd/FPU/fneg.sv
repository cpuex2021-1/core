`timescale 1ns / 1ps

module fneg(
        input  logic [31:0] x,
        output logic [31:0] z
    );
    assign z = {~x[31], x[30:0]};
endmodule
