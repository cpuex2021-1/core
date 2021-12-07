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
    wire [6:0] aluctl;
    wire [26:0] pc;
    wire [26:0] npc;
    logic [26:0] if_pc;
    (*mark_debug = "true"*)logic npc_enn;
    logic flush;

    logic [6:0] dec_branch;
    logic dec_jump;


    logic dec_mre;
    logic dec_mwe;
    logic [29:0] daddr;
    wire [31:0] wb_memdata;
    logic rx_valid, tx_ready;
    logic n_stall;
    logic uart_nstall;
    logic cache_nstall;
    logic dec_nstall;
    logic alu_nstall;

    logic [31:0] alu_fwd;


    logic wb_mre;
    logic [6:0] wb_rd;
    logic [31:0] wb_res;

    assign n_stall = uart_nstall && cache_nstall && alu_nstall;

    //
    PC       program_counter(.clk, .rst, .npc, .n_stall(n_stall&&dec_nstall ), .pc, .npc_enn );
    imem_ram imem(.clk, .rst, .pc, .npc, .npc_enn, .inst,.if_pc, .dec_op2, .daddr, .n_stall(n_stall && dec_nstall), .dec_mwe, .flush);
    //IF <-> Dec & RF 
    decode decode(.clk, .rst, .inst,.if_pc, 
                 .dec_op1, .dec_op2, .aluctl, .dec_rd,  .dec_mre, .dec_mwe, // to exec
                 .alu_fwd,                                  // forwarding
                 .dec_branch, .npc, .daddr, .dec_jump,
                 .wb_res, .wb_memdata, .wb_mre, .wb_rd,
                  .n_stall, .flush, .dec_nstall);
    // decode output ↓
    // Dec & RF <-> ALU + MA

    //exe_fwd fwd(.dec_op1, .dec_op2, .wb_memdata,  .wb_rd, .wb_mre, .op1, .op2);
    ALU alu(.clk, .rst, .n_stall ,.op1(dec_op1), .op2(dec_op2), .aluctl, .dec_branch, .dec_jump,  .wb_res,  .alu_fwd, .alu_nstall, .npc_enn,.flush);
    dmem_ram dmem(.clk, .rst, .daddr, .dec_mre, .dec_mwe , .op2(dec_op2), .wb_memdata, .rxd, .txd, .rx_valid, .tx_ready, .*); //memdata
    writeback wb(.clk, .rst,.n_stall, .dec_rd,  .dec_mre,    .wb_rd, .wb_mre);
    // exec output ↓
    // ALU + MA <-> WB
    // wb_rwe to dec
endmodule
