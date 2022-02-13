`timescale 1ns / 1ps

module ALU(
        input  logic clk, rst,
        input  logic stall,
        input  logic [31:0] op1, op2,
        input  logic [5:0]  aluctl,
        //input  logic [6:0] dec_branch,  // {do_branch, geu, ltu, ge, lt ,ne, eq}
        //input  logic       dec_jump,
        output logic [31:0] wb_res,
        output logic [31:0] alu_fwd,
        output logic alu_stall
        //output logic npc_enn,
        //output logic flush
    );
    assign alu_fwd = n_res;
    always_ff @( posedge clk ) begin 
        if(rst) begin
            wb_res <= 0;
        end else begin
            if(~stall) begin
                wb_res <= n_res;
            end
        end
    end
    // arithmetic for op= 000 , 100 (including immediate)
    logic [31:0] add, sub, sll, srl, sra, slt, sltu, xorr, andd, orr;
    assign add = op1 +   op2;
    assign sub = op1 -   op2;
    assign sll = op1 <<  op2[4:0];
    assign srl = op1 >>  op2[4:0];
    assign sra = op1 >>> op2[4:0];
    assign slt = {31'b0, $signed(op1) <   $signed(op2)};
    assign sltu= {31'b0, $unsigned(op1) < $unsigned(op2)};
    assign xorr= op1 ^   op2;
    assign andd= op1 &  op2;
    assign orr = op1 |  op2;
    
    //floatint point arithmetic
    //ganbaru
    logic [3:0] cnt;
    //cnt == 1111 count start
    //cnt == 0111 end
    // 
    always_ff @( posedge clk ) begin 
        if(rst) begin
            cnt <= 4'b0000;
        end else begin
            /*if(l1) begin
                if(cnt == 4'b1111) begin
                    cnt <= 4'b0111;
                end else begin
                    cnt <= {cnt[2:0], 1'b1};
                end
            end else if(l2) begin
                if(cnt == 4'b1111) begin
                    cnt <= 4'b0011;
                end else begin
                    cnt <= {cnt[2:0], 1'b1};
                end
            end else if (l3)begin
                if(cnt == 4'b1111) begin
                    cnt <= 4'b0001;
                end else begin
                    cnt <= {cnt[2:0], 1'b1};
                end
            end*/
            cnt <= stall ? {cnt[2:0] ,1'b1} : 4'b0;
        end
    end
    //assign alu_stall = ((l1 || l2 || l3) && cnt!=4'b0111);
    assign alu_stall = l1 && ~|cnt[2:0] || l2 && ~|cnt[2:1] || l3 && ~cnt[2];
    // latency 0: fneg, feq
    // latency 1: flt, fle, fmin, fmax
    // latency 2: fadd,fsub,fmul, fsqr
    // latency 3: fdiv
    logic l1,l2,l3;
    logic [5:0] functop;
    assign functop = aluctl[5:0];
    assign l1 = functop == 6'b011001 || functop == 6'b011010 || functop == 6'b010111 || functop == 6'b011110 || functop == 6'b011111;
    assign l2 = functop == 6'b010000 || functop == 6'b010001 || functop == 6'b010010 || functop == 6'b010100;
    assign l3 = functop == 6'b010011 ;
    logic [31:0] fadd, fsub, fmul, fdiv, fsqrt, fneg, fabs, floor;
    fadd_cy fad(.x1(op1), .x2(op2), .y(fadd), .clk, .rst);
    fsub fsu(.x(op1), .y(op2), .z(fsub), .clk, .rst);
    fmul fmu(.a(op1), .b(op2), .c(fmul), .clk, .rst);
    fdiv fdi(.x(op1), .y(op2), .z(fdiv), .clk, .rst);
    fsqr fsq(.a(op1), .b(op2), .c(fsqrt), .clk, .rst);
    fneg fne(.x(op1), .z(fneg));
    fabs fab(.x(op1), .z(fabs));
    floor flo(.a(op1), .c(floor), .clk, .rst);
    
    //floating point cond, mv
    logic [31:0] feq, flt, fle, fmvxw, fmvwx, fmv, itof, ftoi;
    feq feqq(.x(op1), .y(op2), .z(feq));
    flt fltt(.x(op1), .y(op2), .z(flt), .clk, .rst);
    fle flee(.x(op1), .y(op2), .z(fle), .clk, .rst);
    assign fmvwx= op1;
    assign fmvxw= op1;
    assign fmv  = op1;
    itof itoff(.clk, .rst, .a(op1), .c(itof));
    ftoi ftoii(.clk, .rst, .a(op1), .c(ftoi));
    
    
    // I/L  nearly same with R-type
    logic [31:0] lui;
    assign lui = {op2[31:12], op1[11:0]};
    


    logic [31:0] n_res;
    always_comb begin 
        unique case (aluctl[5:0])
            6'b000000 :  n_res = add;
            6'b000001 :  n_res = sub;

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
            6'b010110 :  n_res = fabs;
            6'b010111 :  n_res = floor; 

            6'b011000 :  n_res = feq;
            6'b011001 :  n_res = flt; 
            6'b011010 :  n_res = fle; 
            6'b011011 :  n_res = fmvwx;
            6'b011100 :  n_res = fmvxw;
            6'b011101 :  n_res = fmv;
            6'b011110 :  n_res = itof;
            6'b011111 :  n_res = ftoi;

            //same with 000xxx
            6'b100000 :  n_res = add;
            6'b100001 :  n_res = sll;
            6'b100010 :  n_res = sra;

            6'b101010 :  n_res = lui; 
            
            default   :  n_res = 32'b0;
        endcase 
    end

endmodule
