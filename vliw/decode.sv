`timescale 1ns / 1ps

//register 0***** integer register
//         1***** float   register
module decode(
        input  logic clk, rst,
        input  logic [127:0] inst,

        output logic [31:0] dec_op11, dec_op12,
        output logic [31:0] dec_op21, dec_op22,
        output logic [31:0] dec_op31, dec_op32,
        output logic [31:0] dec_op41, dec_op42,
        output logic [5:0] aluctl1,aluctl2,
        output logic [6:0] dec_rd1,dec_rd2, dec_rd3, dec_rd4,
        output logic dec_mre3, dec_mwe3,
        output logic dec_mre4, dec_mwe4,
        output logic beq, bne, blt, bge,
        output logic dec_jumpr,
        output logic [13:0] npc,
        output logic [29:0] daddr3,daddr4,

        //forwarding
        input logic [31:0] alu_fwd1,alu_fwd2,

        input  logic [31:0] wb_res1,wb_res2,
        input  logic [31:0] wb_memdata3, wb_memdata4,
        input  logic [6:0] wb_rd1,wb_rd2, wb_rd3, wb_rd4,

        input  logic stall,
        input  logic flush,
        output logic dec_stall
        //input  logic rwe, fwe
    );
   
    logic [31:0] inst1, inst2, inst3, inst4;
    assign {inst1, inst2, inst3, inst4} = inst;
    logic n_nop1, n_nop2;
    assign n_nop1 = |inst1;
    assign n_nop2 = |inst2;
    logic [5:0] rs11, rs12, rd1;
    logic [5:0] rs21, rs22, rd2;
    logic [5:0] rs31, rs32, rd3;
    logic [5:0] rs41, rs42, rd4;
    assign rs11 = inst1[31:26];
    assign rs12 = inst1[11:6];

    assign rs21 = inst2[31:26];
    assign rs22 = inst2[11:6];

    assign rs31 = inst3[31:26];
    assign rs32 = inst3[11:6];

    assign rs41 = inst4[31:26];
    assign rs42 = inst4[11:6];

    assign rd1  = inst1[25:20];
    assign rd2  = inst2[25:20];
    assign rd3  = inst3[25:20];
    assign rd4  = inst4[25:20];

    logic [2:0] op1, funct1;
    logic [2:0] op2, funct2;
    logic [2:0] op3, funct3;
    logic [2:0] op4, funct4;
    assign op1    = inst1[2:0];
    assign funct1 = inst1[5:3];
    assign op2    = inst2[2:0];
    assign funct2 = inst2[5:3];
    assign op3    = inst3[2:0];
    assign funct3 = inst3[5:3];
    assign op4    = inst4[2:0];
    assign funct4 = inst4[5:3];

    

    
    logic [31:0] immI1, immI2;
    logic [31:0] immL3, immL4;
    assign immI1 = {{18{inst1[19]}}, inst1[19:6]}; //sign extend
    assign immI2 = {{18{inst2[19]}}, inst2[19:6]}; //sign extend
    assign immL3 = {{18{inst3[19]}}, inst3[19:6]};//sign extend
    assign immL4 = {{18{inst4[19]}}, inst4[19:6]};//sign extend

    logic [31:0] immS3, immS4;
    assign immS3 = {{18{inst3[25]}}, inst3[25:12]};
    assign immS4 = {{18{inst4[25]}}, inst4[25:12]};

    logic [31:0] immLUI1, immLUI2;
    assign immLUI1 = {inst1[31:26],inst1[19:6], 12'b0};
    assign immLUI2 = {inst2[31:26],inst2[19:6], 12'b0};
   
    logic [31:0] rs11data_reg,rs12data_reg;
    logic [31:0] rs21data_reg,rs22data_reg;
    logic [31:0] rs31data_reg,rs32data_reg;
    logic [31:0] rs41data_reg,rs42data_reg;
    logic [31:0] rs11data,rs12data;
    logic [31:0] rs21data,rs22data;
    logic [31:0] rs31data,rs32data;
    logic [31:0] rs41data,rs42data;
    //assign rwe = ~op[1]  ||  // add, mul,  addi, lw..
                //(op == 3'b011 && funct[2] == 0) ||
                //(op == 3'b110 && funct[2:1] == 2'b11) ; //feq .. fmv.x.w;
    //logic dec_alu1, dec_alu2;

    register register (.clk, .rst, .rs11, .rs12, .rs21, .rs22, .rs31, .rs32, .rs41, .rs42,
                        .rs11data_reg, .rs12data_reg, .rs21data_reg, .rs22data_reg, .rs31data_reg, .rs32data_reg, .rs41data_reg, .rs42data_reg,
                        .wb_rd1, .wb_rd2, .wb_rd3, .wb_rd4, .wb_res1, .wb_res2, .wb_memdata3, .wb_memdata4);
    always_comb begin
        dec_stall = 0;
        rs11data = 0;
        rs12data = 0;
        rs21data = 0;
        rs22data = 0;
        rs31data = 0;
        rs32data = 0;
        rs41data = 0;
        rs42data = 0;
        if (rs11 == 0)begin
            rs11data = 32'b0;
        end else if (rs11 == dec_rd1[5:0]) begin
            rs11data = alu_fwd1;
        end else if (rs11 == dec_rd2[5:0]) begin
            rs11data = alu_fwd2;
        end else if (rs11 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs11 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs11 == wb_rd1[5:0]) begin
            rs11data = wb_res1;
        end else if (rs11 == wb_rd2[5:0]) begin
            rs11data = wb_res2; 
        end else if (rs11 == wb_rd3[5:0]) begin
            rs11data = wb_memdata3;
        end else if (rs11 == wb_rd4[5:0]) begin
            rs11data = wb_memdata4;
        end else begin
             rs11data = rs11data_reg;
        end

        if (rs12 == 0)begin
            rs12data = 32'b0;
        end else if (rs12 == dec_rd1[5:0]) begin
            rs12data = alu_fwd1;
        end else if (rs12 == dec_rd2[5:0]) begin
            rs12data = alu_fwd2;
        end else if (rs12 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs12 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs12 == wb_rd1[5:0]) begin
            rs12data = wb_res1;
        end else if (rs12 == wb_rd2[5:0]) begin
            rs12data = wb_res2; 
        end else if (rs12 == wb_rd3[5:0]) begin
            rs12data = wb_memdata3;
        end else if (rs12 == wb_rd4[5:0]) begin
            rs12data = wb_memdata4;
        end else rs12data = rs12data_reg;
        
        if (rs21 == 0)begin
            rs21data = 32'b0;
        end else if (rs21 == dec_rd1[5:0]) begin
            rs21data = alu_fwd1;
        end else if (rs21 == dec_rd2[5:0]) begin
            rs21data = alu_fwd2;
        end else if (rs21 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs21 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs21 == wb_rd1[5:0]) begin
            rs21data = wb_res1;
        end else if (rs21 == wb_rd2[5:0]) begin
            rs21data = wb_res2; 
        end else if (rs21 == wb_rd3[5:0]) begin
            rs21data = wb_memdata3;
        end else if (rs21 == wb_rd4[5:0]) begin
            rs21data = wb_memdata4;
        end else rs21data = rs21data_reg;
        

        if (rs22 == 0)begin
            rs22data = 32'b0;
        end else if (rs22 == dec_rd1[5:0]) begin
            rs22data = alu_fwd1;
        end else if (rs22 == dec_rd2[5:0]) begin
            rs22data = alu_fwd2;
        end else if (rs22 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs22 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs22 == wb_rd1[5:0]) begin
            rs22data = wb_res1;
        end else if (rs22 == wb_rd2[5:0]) begin
            rs22data = wb_res2; 
        end else if (rs22 == wb_rd3[5:0]) begin
            rs22data = wb_memdata3;
        end else if (rs22 == wb_rd4[5:0]) begin
            rs22data = wb_memdata4;
        end else rs22data = rs22data_reg;

        if (rs31 == 0)begin
            rs31data = 32'b0;
        end else if (rs31 == dec_rd1[5:0]) begin
            rs31data = alu_fwd1;
        end else if (rs31 == dec_rd2[5:0]) begin
            rs31data = alu_fwd2;
        end else if (rs31 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs31 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs31 == wb_rd1[5:0]) begin
            rs31data = wb_res1;
        end else if (rs31 == wb_rd2[5:0]) begin
            rs31data = wb_res2; 
        end else if (rs31 == wb_rd3[5:0]) begin
            rs31data = wb_memdata3;
        end else if (rs31 == wb_rd4[5:0]) begin
            rs31data = wb_memdata4;
        end else rs31data = rs31data_reg;



         if (rs32 == 0)begin
            rs32data = 32'b0;
        end else if (rs32 == dec_rd1[5:0]) begin
            rs32data = alu_fwd1;
        end else if (rs32 == dec_rd2[5:0]) begin
            rs32data = alu_fwd2;
        end else if (rs32 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs32 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs32 == wb_rd1[5:0]) begin
            rs32data = wb_res1;
        end else if (rs32 == wb_rd2[5:0]) begin
            rs32data = wb_res2; 
        end else if (rs32 == wb_rd3[5:0]) begin
            rs32data = wb_memdata3;
        end else if (rs32 == wb_rd4[5:0]) begin
            rs32data = wb_memdata4;
        end else rs32data = rs32data_reg;
        if (rs41 == 0)begin
            rs41data = 32'b0;
        end else if (rs41 == dec_rd1[5:0]) begin
            rs41data = alu_fwd1;
        end else if (rs41 == dec_rd2[5:0]) begin
            rs41data = alu_fwd2;
        end else if (rs41 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs41 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs41 == wb_rd1[5:0]) begin
            rs41data = wb_res1;
        end else if (rs41 == wb_rd2[5:0]) begin
            rs41data = wb_res2; 
        end else if (rs41 == wb_rd3[5:0]) begin
            rs41data = wb_memdata3;
        end else if (rs41 == wb_rd4[5:0]) begin
            rs41data = wb_memdata4;
        end else rs41data = rs41data_reg;



         if (rs42 == 6'b0)begin
            rs42data = 32'b0;
        end else if (rs42 == dec_rd1[5:0]) begin
            rs42data = alu_fwd1;
        end else if (rs42 == dec_rd2[5:0]) begin
            rs42data = alu_fwd2;
        end else if (rs42 == dec_rd3[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs42 == dec_rd4[5:0]) begin
            //lw hazard
            dec_stall = 1;
        end else if (rs42 == wb_rd1[5:0]) begin
            rs42data = wb_res1;
        end else if (rs42 == wb_rd2[5:0]) begin
            rs42data = wb_res2; 
        end else if (rs42 == wb_rd3[5:0]) begin
            rs42data = wb_memdata3;
        end else if (rs42 == wb_rd4[5:0]) begin
            rs42data = wb_memdata4;
        end else rs42data = rs42data_reg;
 
    end
    logic [31:0] n_op12,n_op22;
    logic [31:0] n_op32,n_op42;
    always_comb begin
        unique case (op1)
            3'b000 : n_op12 = rs12data;
            3'b010 : n_op12 = rs12data;
            3'b011 : n_op12 = rs12data; 
            3'b100 : n_op12 = immI1;
            3'b101 : n_op12 = immLUI1;
            3'b110 : if(funct1==3'b101) n_op12 = {26'b0, rs12};   
                     else              n_op12 = rs12data;
            default: n_op12 = 32'b0;
        endcase
        unique case (op2)
            3'b000 : n_op22 = rs22data;
            3'b010 : n_op22 = rs22data;
            3'b011 : n_op22 = rs22data; 
            3'b100 : n_op22 = immI2;
            3'b101 : n_op22 = immLUI2;
            3'b110 : n_op22 = rs22data;   
            default: n_op22 = 32'b0;
        endcase
        unique case (op3)
            3'b110 : n_op32 = rs32data;   
            default: n_op32 = 32'b0;
        endcase
        unique case (op4)
            3'b110 : n_op42 = rs42data;   
            default: n_op42 = 32'b0;
        endcase
    end                           
    logic [13:0] clsaddr;
    assign clsaddr = rs11data[13:0];
    
    //for branch 
    // this may be critical path when multicycled  but for simplicity now calculating in decode stage

    /*logic jump;
    assign jump = op==3'b111 && funct==3'b000;
    logic jal;
    assign jal = op==3'b111 && funct==3'b001;
    logic jalr;
    assign jalr = op==3'b111 && funct == 3'b010 ;*/
    logic [13:0] immPC;
    assign immPC = inst1[25:12];



    

    logic jumpr;
    assign jumpr = {funct1[2],funct1[0]} == 2'b01 && op1 == 3'b111;
    
    //logic  lw_nstall; //

    logic [31:0]daddr3_, daddr4_;
    assign daddr3_ = op3[2] & op3[0] ? rs31data + immL3 : rs31data + immS3;
    assign daddr4_ = op4[2] & op4[0] ? rs41data + immL4 : rs41data + immS4;


    always_ff @( posedge clk ) begin 
        if(rst || flush || (dec_stall && ~stall))begin
            dec_op11 <= 0;
            dec_op12 <= 0;
            dec_op21 <= 0;
            dec_op22 <= 0;
            dec_op31 <= 0;
            dec_op32 <= 0;
            dec_op41 <= 0;
            dec_op42 <= 0;
            aluctl1 <= 0;
            aluctl2 <= 0;
            dec_rd1 <= 0;
            dec_rd2 <= 0;
            dec_rd3 <= 0;
            dec_rd4 <= 0;
            dec_mre3 <= 0;
            dec_mwe3 <= 0;
            dec_mre4 <= 0;
            dec_mwe4 <= 0;
            beq      <= 0;
            bne      <= 0;
            blt      <= 0;
            bge      <= 0;
            dec_jumpr <= 0;
            daddr3 <= 0;
            daddr4 <= 0;
            npc<= 0;
        end else begin
            if(~stall) begin
                dec_op11 <= rs11data;
                dec_op12 <= n_op12;
                dec_op21 <= rs21data;
                dec_op22 <= n_op22;
                dec_op31 <= rs31data;
                dec_op32 <= n_op32;
                dec_op41 <= rs41data;
                dec_op42 <= n_op42;
                //dec_imm <= op == 3'b110 ? immSB : immIL;
                //dec_imm <= op == 3'b110 ? immSB : immIL;
                aluctl1 <= {op1, funct1};
                aluctl2 <= {op2, funct2};
                dec_rd1  <= {(op1[2]==1'b0 || op1==3'b100 || {funct1,op1} == 6'b010101) && n_nop1, rd1} ; //R LUI CALLCLS
                dec_rd2  <= {(op2[2]==1'b0 || op1==3'b100 ||  {funct2,op2} == 6'b010101) && n_nop2, rd2} ; 
                dec_rd3  <= {op3==3'b101 , rd3};
                dec_rd4  <= {op4==3'b101 , rd4};
                dec_mre3 <= op3==3'b101;
                dec_mre4 <= op4==3'b101;
                dec_mwe3 <= op3==3'b110;
                dec_mwe4 <= op4==3'b110;
                /*dec_alu <= ~op[2] || // R style
                            op == 3'b100 ||  //I
                            {funct,op} == 6'b010101;  //LUI やっぱこれだけ汚いね*/
                beq  <= {funct1,op1} == 6'b000110;
                bne  <= {funct1,op1} == 6'b001110;
                blt  <= {funct1,op1} == 6'b010110;
                bge  <= {funct1,op1} == 6'b011110;
                dec_jumpr <= jumpr;
                npc <= jumpr ? rs11data[13:0] : immPC;
                daddr3 <= daddr3_[29:0];
                daddr4 <= daddr4_[29:0];
            end
        end
    end
    
endmodule
