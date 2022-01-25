`timescale 1ns / 1ps

module imem_ram(
        input  logic clk,rst,
        input  logic [24:0] pc,
        input  logic [24:0] npc,
        input  logic npc_enn,
        input  logic [29:0] daddr,
        input  logic [31:0] dec_op2,
        input  logic dec_mwe,
        input  logic n_stall,
        input  logic flush,
        output logic [31:0] inst,
        output logic [24:0] if_pc

    );

    (*ram_style = "block"*) logic [31:0] mem [16383:0];
    int i=0;
    initial begin
        for(i=0; i<16359; i=i+1)mem[i] = 0;
        $readmemh("inst.mem", mem,0, 11000);
        $readmemh("loader.mem", mem, 16346, 16383); //check pc
    end
    //assign inst = rst ? 0 : mem[pc[13:2]];
    always_ff @( posedge clk ) begin 
        if(rst ) begin
            inst <= 0;
            if_pc <= 0;
        /*end else if (flush)begin
            inst <= 0;*/
        end else begin
            if(n_stall) begin
                if(npc_enn) begin
                    inst <= mem[npc[13:0]];
                    if_pc <= npc;
                end else begin
                    inst <= mem[pc[13:0]];
                    if_pc <= pc;
                end
                if (&daddr[29:25] & dec_mwe) begin
                    mem[daddr[13:0]] <= dec_op2;
                end
            end
        end
    end

endmodule
