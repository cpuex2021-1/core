`timescale 1ns / 1ps

module register(
        input  logic clk,rst,
        input  logic [5:0] rs1,rs2,
        output logic [127:0] rs1_reg ,
        output logic [127:0] rs2_reg ,
        input  logic [3:0]  wb_rd,
        input  logic [127:0] rddata ,
        input  logic [3:0]  wb_mask
    );
    //0~31 integer
    //32~63 float
    logic [31:0]  register0 [15:0];
    logic [31:0]  register1 [15:0];
    logic [31:0]  register2 [15:0];
    logic [31:0]  register3 [15:0];

    integer i;
    initial 
    begin 
        for(i=0; i<32; i=i+1) begin
            register0[i] = 0;
            register1[i] = 0;
            register2[i] = 0;
            register3[i] = 0;
        end 
        register0[2] = 32'h1ffffff; register0[3] = 32'h01000000; 
    end

    assign rs1_reg = {rs1 == 6'b000000 ? 32'b0 : register0[rs1[5:2]], register1[rs1[5:2]],register1[rs2[5:2]],register3[rs1[5:2]] };
    assign rs2_reg = {rs2 == 6'b000000 ? 32'b0 : register0[rs2[5:2]], register1[rs2[5:2]],register2[rs2[5:2]],register3[rs2[5:2]] };

    always_ff @(posedge clk) begin
        //if(we && wb_rd[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
        if(wb_mask[0]) register0[wb_rd] <= rddata[31:0];
        if(wb_mask[1]) register1[wb_rd] <= rddata[63:32];
        if(wb_mask[2]) register2[wb_rd] <= rddata[95:64];
        if(wb_mask[3]) register3[wb_rd] <= rddata[127:96];
    end
endmodule
