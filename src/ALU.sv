`timescale 1ns / 1ps

module ALU(
        input  logic clk, rst,
        input  logic n_stall,
        input  logic [31:0] op1, op2,
        input  logic [6:0]  aluctl,
        input  logic [6:0] dec_branch,  // {do_branch, geu, ltu, ge, lt ,ne, eq}
        output logic [31:0] wb_res,
        output logic [31:0] alu_fwd,
        output logic alu_nstall,
        output logic npc_enn,
        output logic flush
    );
    assign alu_fwd = n_res;
    always_ff @( posedge clk ) begin 
        if(rst) begin
            wb_res <= 0;
        end else begin
            if(n_stall) begin
                wb_res <= n_res;
            end
        end
    end
    // arithmetic for op= 000 , 100 (including immediate)
    logic [31:0] add, sub, sll, srl, sra, slt, sltu, xorr, andd, orr;
    assign add = op1 +   op2;
    assign sub = op1 -   op2;
    assign sll = op1 <<  op2;
    assign srl = op1 >>  op2;
    assign sra = op1 >>> op2;
    assign slt = {31'b0, op1 <   op2};
    assign sltu= {31'b0, $unsigned(op1) < $unsigned(op2)};
    assign xorr= op1 ^   op2;
    assign andd= op1 &  op2;
    assign orr = op1 |  op2;
    
    //Mul and div
    //違う！気が！する！
    //logic [63:0] fullmul,fullmulsu, fullmulu   ;
    //assign fullmul   = op1 * op2;
    //assign fullmulsu = op1 * $unsigned(op2);
    //assign fullmulu  = $unsigned(op1) * $unsigned (op2);
    logic [31:0] mul, mulh, mulhsu,mulhu, div , divu, rem, remu;
    //assign mul    = op1[15:0] * op2[15:0];
    //assign mulh   = fullmul[63:32];
    //assign mulhsu = fullmulsu[63:32];
    //assign mulhu   = fullmulu[63:32];
    assign mul   = 32'b0;
    assign mulh  = 32'b0;
    assign mulhsu= 32'b0;
    assign mulhu = 32'b0;
    // not yet implemented
    assign div    = 32'b0;
    assign divu   = 32'b0;
    assign rem    = 32'b0;
    assign remu   = 32'b0;
    
    //floatint point arithmetic
    //ganbaru
    // latency 0: fneg, feq
    // latency 1: flt, fle, fmin, fmax
    // latency 2: fadd,fsub,fmul, fsqr
    // latency 3: fdiv
    logic [31:0] fadd, fsub, fmul, fdiv, fsqrt, fneg, fmin, fmax;
    fadd_cy fad(.x1(op1), .x2(op2), .y(fadd), .clk, .rst);
    fsub fsu(.x(op1), .y(op2), .z(fsub), .clk, .rst);
    fmul fmu(.a(op1), .b(op2), .c(fmul), .clk, .rst);
    fdiv fdi(.x(op1), .y(op2), .z(fdiv), .clk, .rst);
    fsqr fsq(.a(op1), .b(op2), .c(fsqrt), .clk, .rst);
    fneg fne(.x(op1), .z(fneg));
    fmin fmi(.x(op1), .y(op2), .z(fmin), .clk, .rst);
    fmax fma(.x(op1), .y(op2), .z(fmax), .clk, .rst);
    
    //floating point cond, mv
    logic [31:0] feq, flt, fle, fmvxw, fmvwx;
    feq feqq(.x(op1), .y(op2), .z(feq));
    flt fltt(.x(op1), .y(op2), .z(flt), .clk, .rst);
    fle flee(.x(op1), .y(op2), .z(fle), .clk, .rst);
    assign fmvwx= op1;
    assign fmvxw= op1;
    
    // I/L  nearly same with R-type
    logic [31:0] lui;
    assign lui = {op2[15:0], op1[15:0]};
    


    logic [31:0] n_res;
    always_comb begin 
        unique case (aluctl[5:0])
            6'b000000 :  n_res = aluctl[6] ? sub : add;
            6'b000001 :  n_res = sll;
            6'b000010 :  n_res = aluctl[6] ? srl : sra;
            6'b000011 :  n_res = slt;
            6'b000100 :  n_res = sltu;
            6'b000101 :  n_res = xorr;
            6'b000110 :  n_res = orr;
            6'b000111 :  n_res = andd;

            6'b001000 :  n_res = mul;
            6'b001001 :  n_res = mulh;
            6'b001010 :  n_res = mulhsu;
            6'b001011 :  n_res = mulhu;
            6'b001100 :  n_res = div;
            6'b001101 :  n_res = divu;
            6'b001110 :  n_res = rem;
            6'b001111 :  n_res = remu;

    // latency 0: fneg, feq
    // latency 1: flt, fle, fmin, fmax
    // latency 2: fadd,fsub,fmul, fsqr
    // latency 3: fdiv
            6'b010000 :  n_res = fadd;
            6'b010001 :  n_res = fsub;
            6'b010010 :  n_res = fmul;
            6'b010011 :  n_res = fdiv;
            6'b010100 :  n_res = fsqrt;
            6'b010101 :  n_res = fneg;
            6'b010110 :  n_res = fmin;
            6'b010111 :  n_res = fmax; 

            6'b011000 :  n_res = feq;
            6'b011001 :  n_res = flt; 
            6'b011010 :  n_res = fle; 
            6'b011011 :  n_res = fmvwx;
            6'b011100 :  n_res = fmvxw;
            6'b011101 :  n_res = 32'b0; // invalid 
            6'b011110 :  n_res = 32'b0; // invalid
            6'b011111 :  n_res = 32'b0; // invalid

            //same with 000xxx
            6'b100000 :  n_res = add;
            6'b100001 :  n_res = sll;
            6'b100010 :  n_res = aluctl[6] ? sra : srl;
            6'b100011 :  n_res = slt;
            6'b100100 :  n_res = sltu;
            6'b100101 :  n_res = xorr;
            6'b100110 :  n_res = orr;
            6'b100111 :  n_res = andd;

            6'b101000 :  n_res = 32'b0;  //lw
            6'b101001 :  n_res = 32'b0;  //flw
            6'b101010 :  n_res = lui; 
            6'b101011 :  n_res = 32'b0; // invalid
            6'b101100 :  n_res = 32'b0; // invalid
            6'b101101 :  n_res = 32'b0; // invalid 
            6'b101110 :  n_res = 32'b0; // invalid
            6'b101111 :  n_res = 32'b0; // invalid

            6'b110000 :  n_res = 32'b0;  //branch
            6'b110001 :  n_res = 32'b0;  //branch
            6'b110010 :  n_res = 32'b0;  //branch
            6'b110011 :  n_res = 32'b0;  //branch
            6'b110100 :  n_res = 32'b0;  //branch
            6'b110101 :  n_res = 32'b0;  //branch
            6'b110110 :  n_res = op2;    //sw
            6'b110111 :  n_res = op2;    //fsw

            6'b111000 :  n_res = 32'b0;  //jump
            6'b111001 :  n_res = 32'b0;  //jal
            6'b111010 :  n_res = 32'b0;  //jalr
            6'b111011 :  n_res = 32'b0;  //invalid
            6'b111100 :  n_res = 32'b0;  //invalid
            6'b111101 :  n_res = 32'b0;  //invalid
            6'b111110 :  n_res = 32'b0;    //invalid
            6'b111111 :  n_res = 32'b0;    //invalid
        endcase 
    end

    logic [5:0] cond;
    logic eq, lt,ltu;
    logic branch;
    logic [26:0] baddr;

    always_comb begin 
        eq = op1 == op2;
        lt = op1 < op2;
        ltu= $unsigned(op1) < $unsigned(op2);
        cond[0] = eq;
        cond[1] = ~eq;
        cond[2] = lt;
        cond[3] = ~lt;
        cond[4] = ltu;
        cond[5] = ~ltu;
        npc_enn = dec_branch[6] && |(cond & dec_branch[5:0]);
        flush = npc_enn;
    end

endmodule
