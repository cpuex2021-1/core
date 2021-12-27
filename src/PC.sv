`timescale 1ns / 1ps

module PC(
        input  logic clk, rst,
        input  logic [26:0] npc,
        input  logic n_stall,
        input  logic npc_enn,
        output logic [26:0] pc
    );
    logic [26:0] pc_reg;
    // enable 必要だよねそのうち
    //assign pc = pc_reg;
    assign pc = pc_reg + 4;
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_reg <= 16280;
            //pc_reg <= 27'd16308; // loader start
        end else begin
            if(n_stall) begin
                if(npc_enn) begin
                    pc_reg <= npc;
                end else begin
                    pc_reg <= pc_reg + 4;
                end
            end
        end
    end
    
endmodule
