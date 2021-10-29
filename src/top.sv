`timescale 1ns / 1ps

module top(
        input  logic clk,rst,
        input  logic rxd,
        output logic txd,
        output logic [15:0] pc_,
        output logic  [27-1:0]      M_AXI_AWADDR,
        output logic  [8-1:0] 			 M_AXI_AWLEN,
        output logic  [3-1:0] 			 M_AXI_AWSIZE,
        output logic  [2-1:0] 			 M_AXI_AWBURST,
        output logic  				 M_AXI_AWLOCK,
        output logic  [4-1:0] 			 M_AXI_AWCACHE,
        output logic  [3-1:0] 			 M_AXI_AWPROT,
        output logic [4-1:0] 			 M_AXI_AWQOS,
        output logic                    M_AXI_AWVALID,
        input  logic                    M_AXI_AWREADY,
        
        output logic [128-1:0] 	 M_AXI_WDATA,
        output logic [16-1:0] 	 M_AXI_WSTRB,
        output logic 				 M_AXI_WLAST,
        output logic 				 M_AXI_WVALID,
        input  logic 				 M_AXI_WREADY,
        
        // Master Interface Write Response
        input  logic  [2-1:0] 			 M_AXI_BRESP,
        input  logic  				 M_AXI_BVALID,
        output logic  				 M_AXI_BREADY,
        
        // Master Interface Read Address
        output logic [27-1:0] 	 M_AXI_ARADDR,
        output logic [8-1:0] 			 M_AXI_ARLEN,
        output logic [3-1:0] 			 M_AXI_ARSIZE,
        output logic [2-1:0] 			 M_AXI_ARBURST,
        output logic [2-1:0] 			 M_AXI_ARLOCK,
        output logic [4-1:0] 			 M_AXI_ARCACHE,
        output logic [3-1:0] 			 M_AXI_ARPROT,
        output logic [4-1:0] 			 M_AXI_ARQOS,
        output logic 				 M_AXI_ARVALID,
        input  logic 				 M_AXI_ARREADY,
        
        // Master Interface Read Data 
        input  logic [128-1:0] 	 M_AXI_RDATA,
        input  logic [2-1:0] 			 M_AXI_RRESP,
        input  logic 				 M_AXI_RLAST,
        input  logic 				 M_AXI_RVALID,
        output logic 				 M_AXI_RREADY
    );
    assign pc_ = pc[15:0];
    wire [31:0] inst;
    wire [6:0] dec_rd;  // {write enable(1), to freg(1), regiter number(5)}
    wire [31:0] dec_op1, dec_op2;
    logic [6:0] dec_rs1,dec_rs2; // {valid, from freg , register number}
    logic [31:0] dec_imm;
    wire [6:0] aluctl;
    wire [26:0] pc;
    wire [26:0] npc;
    (*mark_debug = "true"*)logic npc_enn;
    logic flush;

    logic [6:0] dec_branch;
    logic [26:0] dec_pc;

    logic dec_mre;
    logic dec_mwe;
    logic [29:0] daddr;
    wire [31:0] wb_memdata;
    logic rx_valid, tx_ready;
    logic n_stall;

    logic [31:0] alu_fwd;

    logic [31:0] op1, op2;
    logic wb_mre;
    logic [6:0] wb_rd;
    logic [31:0] wb_res;

    assign n_stall = ~(~rx_valid && dec_mre && daddr==30'b0 || dec_mwe && daddr==30'b0 && ~tx_ready);

    //
    PC       program_counter(.clk, .rst, .npc, .n_stall, .pc, .npc_enn );
    imem_ram imem(.clk, .rst, .pc, .inst, .op2, .daddr, .dec_mwe);
    //IF <-> Dec & RF 
    decode decode(.clk, .rst, .inst,.pc, 
                 .dec_op1, .dec_op2,.dec_rs1, .dec_rs2, .dec_imm,  .aluctl, .dec_rd,  .dec_mre, .dec_mwe, // to exec
                 .alu_fwd,                                  // forwarding
                 .dec_branch, .dec_pc,
                 .wb_res, .wb_memdata, .wb_mre, .wb_rd,
                  .n_stall, .flush);
    // decode output ↓
    // Dec & RF <-> ALU + MA

    exe_fwd fwd(.dec_op1, .dec_op2, .wb_memdata, .dec_rs1, .dec_rs2, .wb_rd, .wb_mre, .op1, .op2);
    ALU alu(.clk, .rst, .n_stall ,.op1, .op2, .aluctl, .dec_branch, .dec_pc, .dec_imm, .wb_res, .daddr, .alu_fwd, .npc, .npc_enn,.flush);
    dmem_ram dmem(.clk, .rst, .n_stall ,.daddr, .dec_mre, .dec_mwe , .op2, .wb_memdata, .rxd, .txd, .rx_valid, .tx_ready, .*); //memdata
    writeback wb(.clk, .rst,.n_stall, .dec_rd,  .dec_mre,    .wb_rd, .wb_mre);
    // exec output ↓
    // ALU + MA <-> WB
    // wb_rwe to dec
endmodule
