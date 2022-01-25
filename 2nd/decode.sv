`timescale 1ns / 1ps

//register 0***** integer register
//         1***** float   register
module decode(
        input  logic clk, rst,
        input  logic [31:0] inst,
        input  logic [24:0] if_pc,

        output logic [127:0] dec_op1, dec_op2,
        output logic [6:0] aluctl,
        output logic [3:0] dec_rd, //   which line of register
        output logic [3:0] dec_mask,
        output logic dec_mre, dec_mwe,
        output logic [6:0] dec_branch,
        output logic dec_jump,
        output logic [24:0] npc,
        output logic [29:0] daddr,
        output logic dec_vmem,

        //forwarding
        input logic [127:0] alu_fwd,

        input  logic [127:0] wb_res,wb_memdata,
        input  logic wb_mre,
        input  logic [3:0] wb_rd,   // which line of register to write
        input  logic [3:0] wb_mask, // register write mask

        input  logic n_stall,
        input  logic flush,
        output logic dec_nstall
        //input  logic rwe, fwe
    );
    logic [2:0] op, funct;
    assign op    = inst[2:0];
    assign funct = inst[5:3];

    
    //logic rs2_valid;
    //assign rs2_valid = ~op[1] || op==3'b110; //rs2 reg is read

    /*logic fromfreg1,fromfreg2 ;
    assign fromfreg1 = op == 3'b010 || {funct[2], op} == 4'b0011 || {funct[2], funct[0], op} == 5'b11011 ; //floatiing point and fmv.w.x assign fromfreg2 = op == 3'b010 || {funct[2], op} == 4'b0011 || {funct[2], funct[0], op} == 5'b11011 || {funct,op} == 6'b111110; //floatiing point ,fmv.w.x and fsw*/

    /*logic tofreg ;
    assign tofreg = op==3'b010 || ({funct[2], op} == 4'b1011 && ~&funct[1:0]) || {funct,op} == 6'b001101  ; //fadd..fmax ,  fmv.w.x, flw*/

   // *TODO*
    logic [31:0] immIL, immSB;
    assign immIL = {{16{inst[21]}}, inst[21:6]}; //sign extend
    assign immSB = {{16{inst[26]}}, inst[26:11]};//sign extend
    logic [31:0] immLUI;
    assign immLUI = {inst[31:26],inst[19:6], 12'b0};
   
    //assign rwe = ~op[1]  ||  // add, mul,  addi, lw..
                //(op == 3'b011 && funct[2] == 0) ||
                //(op == 3'b110 && funct[2:1] == 2'b11) ; //feq .. fmv.x.w;
    logic dec_alu;
    logic [127:0] rddata ;
    assign rddata = wb_mre? wb_memdata : wb_res;

    logic [5:0] rs1, rs2;
    assign rs1 = inst[31:26]; //rs1 is always valid
    assign rs2 = inst[11:6];
    logic [127:0] rs1_reg; 

    logic [127:0] rs2_reg; 

    logic [127:0] rs1data,rs2data;
    register register (.clk, .rst, .rs1, .rs2, .rs1_reg ,.rs2_reg, .wb_rd, .rddata, .wb_mask);   

    //(* TODO *)
    logic [3:0] mask;
    assign mask = inst[15:12];

    //too strict condition for zero and just single register read
    assign rs1data = (rs1[5:2] == dec_rd && rs1[4:0] != 0 && dec_alu) ? alu_fwd : 
                     (rs1[5:2] == wb_rd && rs1[4:0] !=0) ? rddata : rs1_reg; //条件違う気がする
    assign rs2data = (rs2[5:2] == dec_rd && rs2[4:0] != 0 && dec_alu) ? alu_fwd :
                     (rs2[5:2] == wb_rd && rs2[4:0] != 0 )? rddata : rs2_reg; 



    logic [127:0] n_op1, n_op2;
    always_comb begin
        unique case (op) 
            /*3'b000 : op1 = rs1data;
            3'b001 : op1 = rs1data;
            3'b010 : op1 = frs1data;
            3'b011 : ;//to be done
            3'b100 : op1 = rs1data;
            3'b101 : op1 = rs1data;
            3'b110 : op1 = rs1data;
            3'b111 : ; */
            3'b111 : n_op1 = {{7'b0000000,if_pc}, 96'b0};
            default: n_op1 = rs1data;
        endcase
        unique case (op)
            3'b000 : n_op2 = rs2data;
            3'b001 : n_op2 = rs2data;
            3'b010 : n_op2 = rs2data;
            3'b011 : n_op2 = rs2data; //illegal!! for fmv
            3'b100 : n_op2 = {immIL, immIL,immIL,immIL};
            3'b101 : if (funct==3'b010) n_op2 = {immLUI,immLUI, immLUI,immLUI};
                     else n_op2 = {immIL,immIL, immIL, immIL};
            3'b110 : n_op2 = rs2data;   
            3'b111 : n_op2 = 128'd1; // may be illegal  do-siyo 
        endcase
    end                           
    logic [24:0] jaddr ;
    assign jaddr = inst[30:6];
    logic [24:0] jaladdr;
    //assign jaladdr = if_pc + immIL[24:0];
    assign jaladdr =  immIL[24:0];
    logic [24:0] jalraddr;
    assign jalraddr = rs1data[24:0] + immIL[24:0];
    
    //for branch 
    // this may be critical path when multicycled  but for simplicity now calculating in decode stage

    logic jump;
    assign jump = op==3'b111 && funct==3'b000;
    logic jal;
    assign jal = op==3'b111 && funct==3'b001;
    logic jalr;
    assign jalr = op==3'b111 && funct == 3'b010 ;



    //assign baddr  = $signed(pc) + $signed({immSB[24:0], 2'b00});
    

    // for hazard 
    logic lw_hazard;
    //もうちょっと詳しく書くべきだけど今めんどい
    assign lw_hazard = ((aluctl[5:1] == 5'b10100) && (dec_rd == rs1[5:2] || dec_rd == rs2[5:2])); // lw rd -> add .. rd
    
    assign dec_nstall = ~lw_hazard ;
    //logic  lw_nstall; //

    logic [31:0]daddr_;
    logic [31:0] rs10,rs11,rs12,rs13;
    assign rs10 = rs1data[31:0];
    assign rs11 = rs1data[63:32];
    assign rs12 = rs1data[95:64];
    assign rs13 = rs1data[127:96];
    logic [31:0] rs1_single ;
    assign rs1_single = rs1[1] ? (rs1[0] ? rs13 : rs12) : (rs1[0]? rs11 : rs10);
    assign daddr_ = op[2] & op[0] ? rs1_single + immIL : rs1_single+ immSB;


    always_ff @( posedge clk ) begin 
        if(rst || flush || (lw_hazard && n_stall))begin
            dec_op1 <= 0;
            dec_op2 <= 0;
            aluctl <= 0;
            dec_rd <= 0;
            dec_mwe <= 0;
            dec_mre <= 0;
            dec_alu <= 1;
            dec_branch <= 0;
            dec_jump <= 0; daddr <= 0; npc<= 0;
        end else begin
            if(n_stall) begin
                dec_op1 <= n_op1;
                dec_op2 <= n_op2;
                //dec_imm <= op == 3'b110 ? immSB : immIL;
                aluctl <= {inst[11], op, funct};
                //dec_rd  <= {op[2:1] != 2'b11 || jal || jalr,  inst[26:22]}; //rd valid not when branch,sw,jump 
                dec_rd  <= inst[25:22];
                dec_mask<= mask;
                dec_mwe <= (op==3'b110 && funct[2:1] == 2'b11)  ;
                dec_mre <= op==3'b101 && funct[2:1] == 2'b00;
                dec_alu <= ~op[2] || // R style
                            op == 3'b100 ||  //I
                            {funct,op} == 6'b010101;  //LUI やっぱこれだけ汚いね
                dec_branch[0] <= funct==3'b000;//eq
                dec_branch[1] <= funct==3'b001;//ne
                dec_branch[2] <= funct==3'b010;//lt
                dec_branch[3] <= funct==3'b011;//ge
                dec_branch[4] <= funct==3'b100;//ltu
                dec_branch[5] <= funct==3'b101;//geu
                dec_branch[6] <= op==3'b110 && ~&funct[2:1];
                dec_jump <= jump | jalr | jal;
                npc <= jump ? jaddr :
                       jal ? jaladdr :
                       jalr ? jalraddr: if_pc + immSB[24:0];
                daddr <= daddr_[29:0];
                dec_vmem <= {funct,op} == 6'b001101 || {funct,op} == 6'b111110;
            end
        end
    end
    
endmodule
