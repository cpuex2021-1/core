`timescale 1ns / 1ps

module decode(
        input  logic clk, rst,
        input  logic [31:0] inst,
        input  logic [26:0] pc,

        output logic [31:0] dec_op1, dec_op2,
        output logic [6:0] dec_rs1, //rs1 can be always replaced by lw when data hazard occurs
        output logic [6:0] dec_rs2, //op2 cannot be replaced when when data hazard seems to occur and op2 is from imm
        output logic [31:0] dec_imm,
        output logic [6:0] aluctl,
        output logic [6:0] dec_rd,
        output logic dec_mre, dec_mwe,
        output logic [26:0] npc,
        output logic [24:0] dec_daddr,
        output logic dec_alu,

        //forwarding
        input logic [31:0] alu_fwd,

        input  logic [31:0] wb_res,wb_memdata,
        input  logic wb_mre,
        input  logic [6:0] wb_rd,

        input  logic n_stall
        //input  logic rwe, fwe
    );
    logic [2:0] op, funct;
    assign op    = inst[2:0];
    assign funct = inst[5:3];

    
    logic rs2_valid;
    assign rs2_valid = ~op[1] || op==3'b110; //rs2 reg is read

    logic fromfreg ;
    assign fromfreg = op == 3'b010 || {funct[2], op} == 4'b0011; //floatiing point and fmv.w.x

    logic tofreg ;
    assign tofreg = op==3'b010 || {funct[2], op} == 4'b1011; //may be illegal;

    logic [6:0] rs1, rs2;
    assign rs1 = {1'b1,fromfreg,inst[31:27]}; //rs1 is always valid
    assign rs2 = {rs2_valid,fromfreg,inst[10:6]};
    
    logic [31:0] immIL, immSB;
    assign immIL = {{16{inst[21]}}, inst[21:6]}; //sign extend
    assign immSB = {{16{inst[26]}}, inst[26:11]};//sign extend
   
    logic [31:0] rs1data_reg,rs2data_reg;
    logic [31:0] rs1data,rs2data;
    logic [31:0] frs1data_reg, frs2data_reg;
    logic [31:0] frs1data, frs2data;
    //assign rwe = ~op[1]  ||  // add, mul,  addi, lw..
                //(op == 3'b011 && funct[2] == 0) ||
                //(op == 3'b110 && funct[2:1] == 2'b11) ; //feq .. fmv.x.w;
    logic [31:0] rddata;
    assign rddata = wb_mre? wb_memdata : wb_res;
    register register (.clk, .rst, .rs1(rs1[5:0]), .rs2(rs1[5:0]), .rs1data_reg, .rs2data_reg, .wb_rd, .rddata, .we( n_stall));   
    fregister fregister(.clk, .rst, .rs1(rs1[5:0]), .rs2(rs2[5:0]), .frs1data_reg, .frs2data_reg, .wb_rd, .rddata, .we( n_stall));
    assign rs1data = (rs1 == dec_rd && rs1 != 0 && dec_alu) ? alu_fwd : rs1data_reg; //条件違う気がする
    assign rs2data = (rs2 == dec_rd && rs2 != 0 && dec_alu) ? alu_fwd : rs2data_reg; 
    // for floting point!
    logic [31:0] n_op1, n_op2;
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
            3'b010 : n_op1 = frs1data;
            3'b011 : n_op1 = frs1data; //illegal!! for fmv 
            default: n_op1 = rs1data;
        endcase
        unique case (op)
            3'b000 : n_op2 = rs2data;
            3'b001 : n_op2 = rs2data;
            3'b010 : n_op2 = frs2data;
            3'b011 : n_op2 = frs2data; //illegal!! for fmv
            3'b100 : n_op2 = immIL;
            3'b101 : n_op2 = immIL;
            3'b110 : n_op2 = rs2data;   
            3'b111 : n_op2 = immIL; // may be illegal  do-siyo 
        endcase
    end                           
    logic [26:0] jaddr ;
    assign jaddr = {inst[30:6], 2'b00};
    
    //for branch 
    // this may be critical path when multicycled  but for simplicity now calculating in decode stage

    logic branch ;
    logic jmp;
    assign branch = op==3'b110 && ~&(funct[2:1]);  // ==定値　って論理にしたほうが早いのかな   ~&(funct[2:1]) :store は違う
    assign jmp = op==3'b111;                       // 同上

    logic eq,ne, lt, ge, ltu, geu;
    logic less, uless;
    assign less  = rs1data < rs2data;
    assign uless = $unsigned(rs1data) < $unsigned(rs2data);

    assign eq  = ~|(rs1data ^ rs2data) && (funct == 3'b000);
    assign ne  = |(rs1data ^ rs2data)  && (funct == 3'b001);
    assign lt  = less                  && (funct == 3'b010);
    assign ge  = ~less                 && (funct == 3'b011);
    assign ltu = uless                 && (funct == 3'b100);
    assign geu = ~uless                && (funct == 3'b101);
    logic match;
    assign match = eq | ne | lt | ge | ltu | geu;

    logic [26:0] baddr ;
    //assign baddr  = $signed(pc) + $signed({immSB[24:0], 2'b00});
    assign baddr  = $signed(pc) + $signed(immSB[26:0]);
    always_comb begin
        case (1'b1)
            (branch & match): npc = baddr;
            (jmp)           : npc = jaddr;
            default         : npc = pc + 4;
        endcase
    end
    
    logic [31:0] SBaddr, ILaddr;
    assign SBaddr = rs1data + immSB;
    assign ILaddr = rs1data + immIL;

    always_ff @( posedge clk ) begin 
        if(rst)begin
            dec_op1 <= 0;
            dec_op2 <= 0;
            dec_rs1 <= 0;
            dec_rs2 <= 0;
            dec_imm <=0;
            aluctl <= 0;
            dec_rd <= 0;
            dec_mwe <= 0;
            dec_mre <= 0;
            dec_daddr <= 0;
            dec_alu <= 1;
        end else begin
            if(n_stall) begin
                dec_op1 <= n_op1;
                dec_op2 <= n_op2;
                dec_rs1 <= rs1;
                dec_rs2 <= rs2;
                dec_imm <= op == 3'b110 ? immSB : immIL;
                aluctl <= {inst[11], op, funct};
                dec_rd  <= {op[2:1] != 2'b11, tofreg, inst[26:22]}; //rd valid when  beq nor jump
                dec_mwe <= op==3'b110 && funct[2:1] == 2'b11;
                dec_mre <= op==3'b101 && funct[2:1] == 2'b00;
                dec_daddr <= (op==3'b110) ? SBaddr[24:0] : ILaddr[24:0];
                dec_alu <= ~op[2] || // R style
                            op == 3'b100 ||  //I
                            {funct,op} == 6'b010101;  //LUI やっぱこれだけ汚いね
            end
        end
    end
    
endmodule
