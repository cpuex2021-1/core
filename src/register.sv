`timescale 1ns / 1ps

module register(
        input  logic clk,rst,
        input  logic [5:0] rs1, rs2,
        output logic [31:0] rs1data_reg, rs2data_reg,
        input  logic [6:0] wb_rd, // {enable(1bit), register number(6bit)}
        input  logic [31:0] rddata,
        input  logic we
    );
    //0~31 integer
    //32~63 float
    logic [31:0]  register [63:0];

    integer i;
    initial begin for(i=0; i<64; i=i+1) register[i] = 0; register[2] = 32'hfffffffe;end

    assign rs1data_reg = rs1[4:0] == 5'b00000 ? 32'b0 : register[rs1[5:0]];
    assign rs2data_reg = rs2[4:0] == 5'b00000 ? 32'b0 : register[rs2[5:0]];
    always_ff @(posedge clk) begin
        //if(we && wb_rd[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
        if(wb_rd[6] == 1'b1) begin // wb_rd[6:5] means rd is valid and to int register
            register[wb_rd[5:0]] <= rddata;
        end
    end
endmodule
