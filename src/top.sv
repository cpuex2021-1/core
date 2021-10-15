`timescale 1ns / 1ps

module top(
        input  logic clk,rst,
        input  logic rxd,
        output logic txd,
        output logic [15:0] LED
    );
    logic pc_en;
    wire [31:0] inst;
    wire [4:0] rs1,rs2,rd;
    wire [31:0] op1, op2;
    wire [6:0] aluctl;
    wire [31:0] res;
    wire [26:0] pc;
    wire [26:0] npc;
    //wire rwe, fwe; //for future need
    wire [24:0] daddr;
    wire [24:0] baddr;
    logic mre;
    wire mwe;
    wire [31:0] memdata;
    logic rx_valid, tx_ready;
    logic stall;

    assign LED = res[15:0];

    assign stall = ~rx_valid && mre && daddr==25'b0 || mwe && daddr==25'b0 && ~tx_ready;


    PC       program_counter(.clk, .rst, .npc, .pc_en(~stall), .pc );
    imem_ram imem(.clk, .rst, .pc, .inst);
    decode decode(.clk, .rst, .inst, .op1, .op2, .aluctl, .rd, .daddr,.mre, .mwe,  .pc,.npc, .res, .memdata, .stall);
    ALU alu(.clk, .rst, .op1, .op2, .aluctl,  .res);
    dmem_ram dmem(.clk, .rst, .daddr, .mre, .mwe , .res, .memdata, .rxd, .txd, .rx_valid, .tx_ready);

endmodule
