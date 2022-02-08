`timescale 1ns / 1ps

module register(
        input  logic clk,rst,
        input  logic [5:0] rs11, rs12,
        input  logic [5:0] rs21, rs22,
        input  logic [5:0] rs31, rs32,
        input  logic [5:0] rs41, rs42,
        output logic [31:0] rs11data_reg, rs12data_reg,
        output logic [31:0] rs21data_reg, rs22data_reg,
        output logic [31:0] rs31data_reg, rs32data_reg,
        output logic [31:0] rs41data_reg, rs42data_reg,
        input  logic [6:0] wb_rd1,wb_rd2, wb_rd3, wb_rd4, // {enable(1bit), register number(6bit)}
        input  logic [31:0] wb_res1, wb_res2, wb_memdata3,wb_memdata4 
    );
    //0~31 integer
    //32~63 float
    logic [31:0]  register [63:0];

    integer i;
    initial begin for(i=0; i<64; i=i+1) register[i] = 0; register[2] = 32'h1ffffff; register[3] = 32'h01000000; end

    assign rs11data_reg = rs11[5:0] == 6'b00000 ? 32'b0 : register[rs11[5:0]];
    assign rs12data_reg = rs12[5:0] == 6'b00000 ? 32'b0 : register[rs12[5:0]];
    assign rs21data_reg = rs21[5:0] == 6'b00000 ? 32'b0 : register[rs21[5:0]];
    assign rs22data_reg = rs22[5:0] == 6'b00000 ? 32'b0 : register[rs22[5:0]];
    assign rs31data_reg = rs31[5:0] == 6'b00000 ? 32'b0 : register[rs31[5:0]];
    assign rs32data_reg = rs32[5:0] == 6'b00000 ? 32'b0 : register[rs32[5:0]];
    assign rs41data_reg = rs41[5:0] == 6'b00000 ? 32'b0 : register[rs41[5:0]];
    assign rs42data_reg = rs42[5:0] == 6'b00000 ? 32'b0 : register[rs42[5:0]];

    always_ff @(posedge clk) begin
        //if(we && wb_rd[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
        if(wb_rd1[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd1[5:0]] <= wb_res1;
        end
        if(wb_rd2[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd2[5:0]] <= wb_res2;
        end
        if(wb_rd3[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd3[5:0]] <= wb_memdata3;
        end
        if(wb_rd4[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd4[5:0]] <= wb_memdata4;
        end
    end
endmodule
