`timescale 1ns / 1ps

module register(
        input  logic clk,rst,
        input  logic [5:0] rs1, rs2,
        output logic [31:0] rs1data_reg, rs2data_reg,
        input  logic [6:0] wb_rd,
        input  logic [31:0] rddata,
        input  logic we
    );
    logic [31:0]  register [31:0];

    integer i;
    initial for(i=0; i<32; i=i+1) register[i] = 0;

    assign rs1data_reg = rs1[4:0] == 5'b00000 ? 32'b0 : register[rs1[4:0]];
    assign rs2data_reg = rs2[4:0] == 5'b00000 ? 32'b0 : register[rs2[4:0]];
    always_ff @(posedge clk) begin
        if(we && |wb_rd && wb_rd[6:5] == 2'b10) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd[4:0]] <= rddata;
        end
    end
endmodule
