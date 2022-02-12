`timescale 1ns / 1ps

module imem_ram(
        input  logic clk,rst,
        input  logic [13:0] pc,
        input  logic [13:0] npc,
        input  logic npc_enn,
        input  logic [29:0] daddr3,
        input  logic [31:0] dec_op32,
        input  logic dec_mwe3,
        input  logic stall,
        input  logic flush,
        output logic [127:0] inst,
        output logic [13:0] if_pc

    );

    (*ram_style = "block"*) logic [127:0] mem [16383:0];
    int i=0;
    initial begin
        for(i=0; i<16359; i=i+1)mem[i] = 0;
        $readmemh("inst.mem", mem,0, 11000);
        //$readmemh("loader.mem", mem, 16346, 16383); //check pc
    end
    //assign inst = rst ? 0 : mem[pc[13:2]];
    logic [1:0] offset;
    assign offset = daddr3[1:0];
    always_ff @( posedge clk ) begin 
        if(rst ) begin
            inst <= 0;
            if_pc <= 0;
        /*end else if (flush)begin
            inst <= 0;*/
        end else begin
            if(~stall) begin
                if(npc_enn) begin
                    inst <= mem[npc[13:0]];
                    if_pc <= npc;
                end else begin
                    inst <= mem[pc[13:0]];
                    if_pc <= pc;
                end
                // boot loaderは後で考える。
                if (daddr3[29:25] == 5'b11110 & dec_mwe3) begin
                    if(offset == 2'b00)mem[daddr3[13:0]][31:0] <= dec_op32;
                    if(offset == 2'b01)mem[daddr3[13:0]][63:32] <= dec_op32;
                    if(offset == 2'b10)mem[daddr3[13:0]][95:64] <= dec_op32;
                    if(offset == 2'b11)mem[daddr3[13:0]][127:96] <= dec_op32;
                    
                end
            end
        end
    end

endmodule
