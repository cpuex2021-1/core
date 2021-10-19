`timescale 1ns / 1ps

module PC(
        input  logic clk, rst,
        input  logic [26:0] npc,
        input  logic pc_en,
        output logic [26:0] pc
    );
    logic [26:0] pc_reg;
    // enable 必要だよねそのうち
    //assign pc = pc_reg;
    assign pc = pc_reg;
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_reg <= 27'b0;
        end else begin
            if(pc_en) begin
                pc_reg <= npc;
            end
        end
    end
    
endmodule
