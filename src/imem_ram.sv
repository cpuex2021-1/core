`timescale 1ns / 1ps

module imem_ram(
        input  logic clk,rst,
        input  logic [26:0] pc,
        input  logic [26:0] npc,
        input  logic npc_enn,
        input  logic [29:0] daddr,
        input  logic [31:0] dec_op2,
        input  logic dec_mwe,
        input  logic n_stall,
        input  logic flush,
        output logic [31:0] inst,
        output logic [26:0] if_pc

    );

    (*ram_style = "block"*) logic [31:0] mem [4095:0];
    int i=0;
    initial begin
        for(i=0; i<4077; i=i+1)mem[i] = 0;
        $readmemh("inst.mem", mem,0, 1023);
        $readmemh("loader.mem", mem, 4077, 4095);
    end
    //assign inst = rst ? 0 : mem[pc[13:2]];
    always_ff @( posedge clk ) begin 
        if(rst ) begin
            inst <= 0;
            if_pc <= 0;
        end else begin
            if(n_stall) begin
                if(npc_enn) begin
                    inst <= mem[npc[13:2]];
                    if_pc <= npc;
                end else begin
                    inst <= mem[pc[13:2]];
                    if_pc <= pc;
                end
            end
            if (&daddr[29:25] & dec_mwe) begin
                mem[daddr[11:0]] <= dec_op2;
            end
        end
    end

endmodule
