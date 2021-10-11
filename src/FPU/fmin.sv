`timescale 1ns / 1ps

module fmin(
        input  logic [31:0] x,y,
        output logic [31:0] z
    );

    logic [31:0] lt;

    flt fl(x,y,lt);
    always_comb begin 
        unique if (lt[0]) begin
            z = x;
        end else begin
            z = y;
        end
        
    end
endmodule
