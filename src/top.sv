`timescale 1ns / 1ps

module top(
        input  logic clk,rst,
        input  logic rxd,
        output logic txd
    );
    logic pc_en;
    wire [31:0] inst;
    wire [4:0] dec_rd;
    wire [31:0] op1, op2;
    wire [6:0] aluctl;
    wire [31:0] res;
    wire [26:0] pc;
    wire [26:0] npc;
    wire dec_rwe, dec_fwe; //for future need
    wire [24:0] dec_daddr;
    wire [24:0] baddr;
    logic dec_mre;
    logic dec_mwe;
    wire [31:0] wb_memdata;
    logic rx_valid, tx_ready;
    logic dec_alu;
    logic n_stall;

    logic [31:0] alu_fwd;
    logic exe_mre;
    logic exe_mwe;

    logic wb_rwe, wb_fwe, wb_mre;
    logic [4:0] wb_rd;
    logic [31:0] wb_res;

    assign n_stall = ~(~rx_valid && dec_mre && dec_daddr==25'b0 || dec_mwe && dec_daddr==25'b0 && ~tx_ready);

    //
    PC       program_counter(.clk, .rst, .npc, .n_stall, .pc );
    imem_ram imem(.clk, .rst, .pc, .inst);
    //IF <-> Dec & RF 
    decode decode(.clk, .rst, .inst,.pc, 
                 .op1, .op2, .aluctl, .dec_rd, .dec_daddr, .dec_mre, .dec_mwe, .dec_rwe, .dec_fwe, .dec_alu, // to exec
                 .alu_fwd,                                  // forwarding
                 .npc, 
                 .wb_res, .wb_memdata, .wb_rwe, .wb_fwe, .wb_mre, .wb_rd,
                  .n_stall );
    // decode output ↓
    // Dec & RF <-> ALU + MA
    ALU alu(.clk, .rst, .n_stall ,.op1, .op2, .aluctl,  .wb_res, .alu_fwd);
    dmem_ram dmem(.clk, .rst, .n_stall ,.dec_daddr, .dec_mre, .dec_mwe , .op2, .wb_memdata, .rxd, .txd, .rx_valid, .tx_ready); //memdata
    writeback wb(.clk, .rst,.n_stall, .dec_rd, .dec_rwe, .dec_fwe, .dec_mre,  .wb_rwe, .wb_fwe,  .wb_rd, .wb_mre);
    // exec output ↓
    // ALU + MA <-> WB
    // wb_rwe to dec
endmodule
