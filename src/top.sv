`timescale 1ns / 1ps

module top(
        input logic clk,rst,
        output wire [15:0] LED
    );
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
    wire mwe;
    wire [31:0] memdata;

    assign LED = res[15:0];


    PC       program_counter(.clk, .rst, .npc, .pc );
    imem_ram imem(.clk, .rst, .pc, .inst);
    decode decode(.clk, .rst, .inst, .op1, .op2, .aluctl, .rd, .pc,.npc, .res, .memdata);
    ALU alu(.clk, .rst, .op1, .op2, .aluctl,  .res,.daddr);
    dmem_ram dmem(.clk, .rst, .daddr, .mwe , .res, .memdata);

endmodule
