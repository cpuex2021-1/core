`timescale 1ns / 1ps

module fmax(
        input  logic clk,rst,
        input  logic [31:0] x,y,
        output logic [31:0] z
    );
    logic [31:0]lt;
    flt fl(.x,.y,.z(lt), .clk, .rst);


    assign z = lt[0] ? y_ : x_;
    logic [31:0] x_, y_;
    always_ff @(posedge clk) begin
        if(rst) begin 
            x_ <= 0;
            y_ <= 0;
        end else begin
            x_ <= x;
            y_ <= y;
        end
    end
endmodule
