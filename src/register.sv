`timescale 1ns / 1ps

module register(
        input  logic clk,rst,
        input  logic [4:0] rs1, rs2,
        output logic [31:0] rs1data, rs2data,
        input  logic [4:0] wb_rd,
        input  logic [31:0] rddata,
        input  logic we
    );
    logic [31:0]  register [31:0];

    integer i;
    initial for(i=0; i<32; i=i+1) register[i] = 0;

    assign rs1data = rs1 == 5'b00000 ? 32'b0 : register[rs1];
    assign rs2data = rs2 == 5'b00000 ? 32'b0 : register[rs2];
    always_ff @(posedge clk) begin
        if(we && |wb_rd) begin
            register[wb_rd] <= rddata;
        end
    end
endmodule
