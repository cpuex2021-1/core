`timescale 1ns / 1ps

module top(
        input  logic clk,rst,
        input  logic rxd,
        output logic txd
    );
    wire [31:0] inst;
    wire [6:0] dec_rd;  // {write enable(1), to freg(1), regiter number(5)}
    wire [31:0] dec_op1, dec_op2;
    logic [6:0] dec_rs1,dec_rs2; // {valid, from freg , register number}
    logic [31:0] dec_imm;
    wire [6:0] aluctl;
    wire [26:0] pc;
    wire [26:0] npc;

    wire [24:0] dec_daddr;
    logic dec_mre;
    logic dec_mwe;
    wire [31:0] wb_memdata;
    logic rx_valid, tx_ready;
    logic dec_alu;
    logic n_stall;

    logic [31:0] alu_fwd;

    logic [31:0] op1, op2;
    logic wb_mre;
    logic [6:0] wb_rd;
    logic [31:0] wb_res;

    assign n_stall = ~(~rx_valid && dec_mre && dec_daddr==25'b0 || dec_mwe && dec_daddr==25'b0 && ~tx_ready);

    //
    PC       program_counter(.clk, .rst, .npc, .n_stall, .pc );
    imem_ram imem(.clk, .rst, .pc, .inst);
    //IF <-> Dec & RF 
    decode decode(.clk, .rst, .inst,.pc, 
                 .dec_op1, .dec_op2,.dec_rs1, .dec_rs2, .dec_imm,  .aluctl, .dec_rd, .dec_daddr, .dec_mre, .dec_mwe, .dec_alu, // to exec
                 .alu_fwd,                                  // forwarding
                 .npc, 
                 .wb_res, .wb_memdata, .wb_mre, .wb_rd,
                  .n_stall );
    // decode output ↓
    // Dec & RF <-> ALU + MA

    exe_fwd fwd(.dec_op1, .dec_op2, .wb_memdata, .dec_rs1, .dec_rs2, .wb_rd, .wb_mre, .op1, .op2);
    ALU alu(.clk, .rst, .n_stall ,.op1, .op2, .aluctl,  .wb_res, .alu_fwd);
    dmem_ram dmem(.clk, .rst, .n_stall ,.dec_daddr, .dec_mre, .dec_mwe , .op2, .wb_memdata, .rxd, .txd, .rx_valid, .tx_ready); //memdata
    writeback wb(.clk, .rst,.n_stall, .dec_rd,  .dec_mre,    .wb_rd, .wb_mre);
    // exec output ↓
    // ALU + MA <-> WB
    // wb_rwe to dec
endmodule
