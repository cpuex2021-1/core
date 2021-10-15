`timescale 1ns / 1ps

module decode(
        input  logic clk, rst,
        input  logic [31:0] inst,
        output logic [31:0] op1, op2,
        output logic [6:0] aluctl,
        output logic [4:0] rd,
        output logic mre, mwe,
        input  logic [26:0] pc,
        output logic [26:0] npc,
        input  logic [31:0] res,memdata,
        input  logic stall,
        output logic [24:0] daddr
        //input  logic rwe, fwe
    );
    logic [2:0] op, funct;
    assign op    = inst[2:0];
    assign funct = inst[5:3];

    assign aluctl = {inst[11], op, funct};   // inst[11] : add subとかの区別
                                                        // {op, funct} にすると 10進数で考えて0,1,2...ってなってきれい
                                                        
    assign mwe = op==3'b110 && funct[2:1] == 2'b11;
    assign mre = op==3'b101 && funct[2:1] == 2'b00;
    
    logic [4:0] rs1, rs2;
    assign rs1 = inst[31:27];
    assign rs2 = inst[10:6];
    assign rd  = inst[26:22];
    
    logic [31:0] immIL, immSB;
    assign immIL = {{16{inst[21]}}, inst[21:6]}; //sign extend
    assign immSB = {{16{inst[26]}}, inst[26:11]};//sign extend
   
    logic [31:0] rs1data,rs2data;
    logic [31:0] frs1data, frs2data;
    logic rwe, fwe;
    assign rwe = ~op[1]  ||  // add, mul,  addi, lw..
                (op == 3'b011 && funct[2] == 0) ||
                (op == 3'b110 && funct[2:1] == 2'b11) ; //feq .. fmv.x.w;
    assign fwe = op == 3'b010 || inst[5:0] == 6'b100011; // fadd... , fmv.w.x
    logic [31:0] rddata;
    assign rddata = ~|(funct[2:1]) && op == 3'b101 ? memdata : res;
    register register (.clk, .rst, .rs1, .rs2, .rs1data, .rs2data, .rd, .rddata, .we(rwe & ~stall));   
    register fregister(.clk, .rst, .rs1, .rs2, .rs1data(frs1data), .rs2data(frs2data), .rd, .rddata, .we(fwe & ~stall));
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
            3'b010 : op1 = frs1data;
            3'b011 : op1 = frs1data; //illegal!! for fmv 
            default: op1 = rs1data;
        endcase
        unique case (op)
            3'b000 : op2 = rs2data;
            3'b001 : op2 = rs2data;
            3'b010 : op2 = frs2data;
            3'b011 : op2 = frs2data; //illegal!! for fmv
            3'b100 : op2 = immIL;
            3'b101 : op2 = immIL;
            3'b110 : op2 = rs2data;   
            3'b111 : op2 = immIL; // may be illegal  do-siyo 
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
    assign baddr  = pc + {immSB[24:0], 2'b00};
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
    assign daddr = (op==3'b110) ? SBaddr[24:0] : ILaddr[24:0];
    
endmodule
