`timescale 1ns / 1ps

module PC(
        input  logic clk, rst,
        input  logic [13:0] npc,
        input  logic stall,
        input  logic npc_enn,
        input  logic [31:0] inst1,
        output logic [13:0] pc
    );
    logic [13:0] pc_reg;
    // enable 必要だよねそのうち
    //assign pc = pc_reg;
    assign pc = pc_reg + 1;

    logic [2:0] op,funct;
    assign op = inst1[2:0];
    assign funct = inst1[5:3];
    logic push;
    assign push = inst1[2:0] == 3'b111 && funct[2] == 1'b0;
    logic [13:0] ra;
    logic pop;
    assign pop = inst1[5:0] == 6'b011111;
    rastack ras(.clk, .rst, .pc(pcp1), .push, .ra, .pop);
    logic [13:0] pcp1;
    logic [13:0] addr;
    assign addr = inst1[19:6];
    assign pcp1 = pc_reg+2;
    
    logic jabs, jreg;
    assign jabs = op==3'b111 && funct[2:1] == 2'b00;
    assign jreg = op==3'b111 && funct[2:1] == 2'b01;
    logic ret;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_reg <= -1;
            //pc_reg <= 16344; //loader start;
        end else begin
            if(~stall) begin
                if(jabs) begin
                    pc_reg <= addr;
                end else if (pop) begin
                    pc_reg <= ra;
                end else if(npc_enn) begin
                    pc_reg <= npc;
                end else begin
                    pc_reg <= pc_reg + 1;
                end
            end
        end
    end
    
endmodule
