`timescale 1ns / 1ps

module top(
        input  logic clk,rst,
        input  logic rxd,
        output logic txd,
        output logic [13:0] pc_,
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
    assign pc_ = pc;
    wire [127:0] inst;
    wire [13:0] pc;
    wire [13:0] npc;
    logic [13:0] if_pc;
    logic npc_enn;
    logic flush;

    logic [31:0] dec_op11, dec_op12;
    logic [31:0] dec_op21, dec_op22;
    logic [31:0] dec_op31, dec_op32;
    logic [31:0] dec_op41, dec_op42;
    logic [5:0] aluctl1,aluctl2;
    logic [6:0] dec_rd1,dec_rd2, dec_rd3, dec_rd4;
    logic dec_mre3, dec_mwe3;
    logic dec_mre4, dec_mwe4;
    logic [29:0] daddr3,daddr4;

    logic beq, bne, blt , bge;
    logic dec_jumpr;

    logic [31:0] alu_fwd1,alu_fwd2;

    logic [31:0] wb_res1,wb_res2;
    logic [31:0] wb_memdata3, wb_memdata4;
    logic [6:0] wb_rd1,wb_rd2, wb_rd3, wb_rd4;

 

    logic rx_valid, tx_ready;
    logic stall;
    logic uart_stall;
    logic cache_stall;
   logic dec_stall;
    logic alu_stall1, alu_stall2;




    assign stall = uart_stall || cache_stall || alu_stall1 || alu_stall2;

    //
    //PC       program_counter(.clk, .rst, .npc, .stall(stall||dec_stall ), .pc, .npc_enn , .inst1(inst[127:96]));
    //imem_ram imem(.clk, .rst, .pc, .npc, .npc_enn, .inst,.if_pc, .dec_op32, .daddr3, .stall(stall || dec_stall), .dec_mwe3, .flush);
    ifetch ife(.clk, .rst, .stall(stall||dec_stall), .flush, .npc, .npc_enn, .inst, .dec_op32, .daddr3, .dec_mwe3, .pc_led(pc_));
    //IF <-> Dec & RF 
    decode decode(.clk, .rst, .inst,
                    .dec_op11, .dec_op12, .dec_op21, .dec_op22, .dec_op31, .dec_op32, .dec_op41, .dec_op42,
                    .aluctl1, .aluctl2, 
                    .dec_rd1, .dec_rd2, .dec_rd3, .dec_rd4,
                    .dec_mre3, .dec_mwe3, .dec_mre4, .dec_mwe4,
                    .beq , .bne, .blt, .bge, .dec_jumpr,
                    .npc,
                    .daddr3, .daddr4,
                    .alu_fwd1, .alu_fwd2,.wb_res1, .wb_res2,
                    .wb_memdata3, .wb_memdata4,
                    .wb_rd1, .wb_rd2, .wb_rd3, .wb_rd4,
                    .stall, .flush,.dec_stall);
    branchjump bj(.op11(dec_op11), .op12(dec_op12), .beq, .bne, .blt, .bge, .dec_jumpr,.npc_enn, .flush, .stall(alu_stall2 || uart_stall || cache_stall));

    // decode output ↓
    // Dec & RF <-> ALU + MA

    //exe_fwd fwd(.dec_op1, .dec_op2, .wb_memdata,  .wb_rd, .wb_mre, .op1, .op2);
    ALU alu1(.clk, .rst, .stall ,.op1(dec_op11), .op2(dec_op12), .aluctl(aluctl1),  .wb_res(wb_res1),  .alu_fwd(alu_fwd1), .alu_stall(alu_stall1) );
    ALU alu2(.clk, .rst, .stall ,.op1(dec_op21), .op2(dec_op22), .aluctl(aluctl2),  .wb_res(wb_res2),  .alu_fwd(alu_fwd2), .alu_stall(alu_stall2) );
    dmem_ram dmem(.clk, .rst, .stall, 
                  .daddr3, .dec_mre3, .dec_mwe3, .op32(dec_op32), .wb_memdata3,
                  .daddr4, .dec_mre4, .dec_mwe4, .op42(dec_op42), .wb_memdata4,
                  .*);
    writeback wb(.clk, .rst,.stall,
                  .dec_rd1, .dec_rd2, .dec_rd3, .dec_rd4,
                  .wb_rd1, .wb_rd2, .wb_rd3, .wb_rd4);
    // exec output ↓
    // ALU + MA <-> WB
    // wb_rwe to dec
endmodule
