`timescale 1ns / 1ps

module ALU(
        input  logic clk, rst,
        input  logic [31:0] op1, op2,
        input  logic [6:0]  aluctl,
        output logic [31:0] res
    );
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
    logic [63:0] fullmul,fullmulsu, fullmulu   ;
    assign fullmul   = op1 * op2;
    assign fullmulsu = op1 * $unsigned(op2);
    assign fullmulu  = $unsigned(op1) * $unsigned (op2);
    logic [31:0] mul, mulh, mulhsu,mulhu, div , divu, rem, remu;
    assign mul    = fullmul[31:0];
    assign mulh   = fullmul[63:32];
    assign mulhsu = fullmulsu[63:32];
    assign mulhu   = fullmulu[63:32];
    // not yes implemented
    assign div    = 32'b0;
    assign divu   = 32'b0;
    assign rem    = 32'b0;
    assign remu   = 32'b0;
    
    //floatint point arithmetic
    //ganbaru
    logic [31:0] fadd, fsub, fmul, fdiv, fsqrt, fneg, fmin, fmax;
    assign fadd = 32'b0;
    assign fsub = 32'b0;
    assign fmul = 32'b0;
    assign fdiv = 32'b0;
    assign fsqrt= 32'b0;
    assign fneg = 32'b0;
    assign fmin = 32'b0;
    assign fmax = 32'b0;
    
    //floating point cond, mv
    logic [31:0] feq, flt, fle, fmvxw, fmvwx;
    assign feq  = 32'b0;
    assign flt  = 32'b0;
    assign fle  = 32'b0;
    assign fmvwx= op1;
    assign fmvxw= op1;
    
    // I/L  nearly same with R-type
    logic [31:0] lui;
    assign lui = {op2[15:0], op1[15:0]};
    
    // branch conditions
    logic beq, bne, blt, bge, bltu, bgeu;
    assign beq = op1 == op2;
    assign bne = op1 != op2;
    assign blt = op1 <  op2;
    assign bge = op1 >= op2;
    assign bltu= $unsigned(op1) < $unsigned(op2);
    assign bgeu= $unsigned(op1) >=$unsigned(op2);


    always_comb begin 
        unique case (aluctl[5:0])
            6'b000000 :  res = aluctl[6] ? sub : add;
            6'b000001 :  res = sll;
            6'b000010 :  res = aluctl[6] ? srl : sra;
            6'b000011 :  res = slt;
            6'b000100 :  res = sltu;
            6'b000101 :  res = xorr;
            6'b000110 :  res = orr;
            6'b000111 :  res = andd;

            6'b001000 : res = mul;
            6'b001001 : res = mulh;
            6'b001010 : res = mulhsu;
            6'b001011 : res = mulhu;
            6'b001100 : res = div;
            6'b001101 : res = divu;
            6'b001110 : res = rem;
            6'b001111 : res = remu;

            6'b010000 : res = fadd;
            6'b010001 : res = fsub;
            6'b010010 : res = fmul;
            6'b010011 : res = fdiv;
            6'b010100 : res = fsqrt;
            6'b010101 : res = fneg;
            6'b010110 : res = fmin;
            6'b010111 : res = fmax; 

            6'b011000 : res = feq;
            6'b011001 : res = flt; 
            6'b011010 : res = fle; 
            6'b011011 : res = fmvwx;
            6'b011100 : res = fmvxw;
            6'b011101 : res = 32'b0; // invalid 
            6'b011110 : res = 32'b0; // invalid
            6'b011111 : res = 32'b0; // invalid

            //same with 000xxx
            6'b100000 :  res = add;
            6'b100001 :  res = sll;
            6'b100010 :  res = aluctl[6] ? sra : srl;
            6'b100011 :  res = slt;
            6'b100100 :  res = sltu;
            6'b100101 :  res = xorr;
            6'b100110 :  res = orr;
            6'b100111 :  res = andd;

            6'b101000 : res = 32'b0;  //lw
            6'b101001 : res = 32'b0;  //flw
            6'b101010 : res = lui; 
            6'b101011 : res = 32'b0; // invalid
            6'b101100 : res = 32'b0; // invalid
            6'b101101 : res = 32'b0; // invalid 
            6'b101110 : res = 32'b0; // invalid
            6'b101111 : res = 32'b0; // invalid

            6'b110000 : res = 32'b0;  //branch
            6'b110001 : res = 32'b0;  //branch
            6'b110010 : res = 32'b0;  //branch
            6'b110011 : res = 32'b0;  //branch
            6'b110100 : res = 32'b0;  //branch
            6'b110101 : res = 32'b0;  //branch
            6'b110110 : res = op2;    //sw
            6'b110111 : res = op2;    //fsw

            6'b111000 : res = 32'b0;  //jump
            6'b111001 : res = 32'b0;  //jal
            6'b111010 : res = 32'b0;  //jalr
            6'b111011 : res = 32'b0;  //invalid
            6'b111100 : res = 32'b0;  //invalid
            6'b111101 : res = 32'b0;  //invalid
            6'b111110 : res = 32'b0;    //invalid
            6'b111111 : res = 32'b0;    //invalid
        endcase 
    end

endmodule
