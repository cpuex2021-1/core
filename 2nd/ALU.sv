`timescale 1ns / 1ps

module ALU(
        input  logic clk, rst,
        input  logic n_stall,
        input  logic [127:0] op1, op2,
        input  logic [3:0] dec_mask,
        input  logic [6:0]  aluctl,
        input  logic [6:0] dec_branch,  // {do_branch, geu, ltu, ge, lt ,ne, eq}
        input  logic       dec_jump,
        output logic [127:0] wb_res,
        output logic [127:0] alu_fwd,
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
    logic [31:0] op10, op11, op12, op13;
    logic [31:0] op20, op21, op22, op23;
    assign op10 = op1[31:0];
    assign op11 = op1[63:32];
    assign op12 = op1[95:64];
    assign op13 = op1[127:96];
    logic [31:0] op1_single,op2_single;
    assign op1_single = dec_mask[0] ? op10:
                        dec_mask[1] ? op11:
                        dec_mask[2] ? op12:
                                      op13;
    assign op2_single = dec_mask[0] ? op20:
                        dec_mask[1] ? op21:
                        dec_mask[2] ? op22:
                                      op23;

    assign op20 = op2[31:0];
    assign op21 = op2[63:32];
    assign op22 = op2[95:64];
    assign op23 = op2[127:96];

    logic [127:0] add, sub, sll, srl, sra ;
    assign add = {op10 +   op20, op11+op21 , op12+op22 , op13 + op23};
    assign sub = {op10 -   op20, op11-op21 , op12-op22 , op13 - op23};
    assign sll = {op10 <<    op20[4:0], op11 <<  op21[4:0]  , op12<< op22[4:0] , op13<<op23[4:0]};
    assign srl = {op10 >>    op20[4:0], op11 >>  op21[4:0]  , op12>> op22[4:0] , op13>>op23[4:0]};
    assign sra = {op10 >>>   op20[4:0], op11 >>> op21[4:0]  , op12>>>op22[4:0] , op13>>>op23[4:0]};
    
    
    //floatint point arithmetic
    //stall logic
    //ganbaru <- ?
    logic [3:0] cnt;
    //cnt == 1111 count start
    //cnt == 0111 end
    // 
    always_ff @( posedge clk ) begin 
        if(rst) begin
            cnt <= 4'b1111;
        end else begin
            if(l1) begin
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
            end
        end
    end
    assign alu_nstall = ~((l1 || l2 || l3) && cnt!=4'b0111);
    // latency 0: fneg, feq
    // latency 1: flt, fle, fmin, fmax
    // latency 2: fadd,fsub,fmul, fsqr
    // latency 3: fdiv
    logic l1,l2,l3;
    logic [5:0] functop;
    assign functop = aluctl[5:0];
    assign l1 = functop == 6'b011001 || functop == 6'b011010 || functop == 6'b010110 || functop == 6'b010111;
    assign l2 = functop == 6'b010000 || functop == 6'b010001 || functop == 6'b010010 || functop == 6'b010100;
    assign l3 = functop == 6'b010011 ;

    logic [127:0] fadd, fsub, fmul, fneg, fmin, fmax;
    logic [31:0]  fdiv,fsqrt;

    fadd_cy fad0(.x1(op10), .x2(op20), .y(fadd[31:0]), .clk, .rst);
    fadd_cy fad1(.x1(op11), .x2(op21), .y(fadd[63:32]), .clk, .rst);
    fadd_cy fad2(.x1(op12), .x2(op22), .y(fadd[95:64]), .clk, .rst);
    fadd_cy fad3(.x1(op13), .x2(op23), .y(fadd[127:96]), .clk, .rst);

    fsub fsu0(.x1(op10), .x2(op20), .y(fsub[31:0]), .clk, .rst);
    fsub fsu1(.x1(op11), .x2(op21), .y(fsub[63:32]), .clk, .rst);
    fsub fsu2(.x1(op12), .x2(op22), .y(fsub[95:64]), .clk, .rst);
    fsub fsu3(.x1(op13), .x2(op23), .y(fsub[127:96]), .clk, .rst);

    fmul fmu0(.a(op10), .b(op20), .c(fsub[31:0]), .clk, .rst);
    fmul fmu1(.a(op11), .b(op21), .c(fsub[63:32]), .clk, .rst);
    fmul fmu2(.a(op12), .b(op22), .c(fsub[95:64]), .clk, .rst);
    fmul fmu3(.a(op13), .b(op23), .c(fsub[127:96]), .clk, .rst);

    fdiv fdi(.x(op1_single), .y(op2_single), .z(fdiv), .clk, .rst);
    fsqr fsq(.a(op1_single), .b(op2_single), .c(fsqrt), .clk, .rst);

    fneg fne0(.x(op10), .z(fsub[31:0]  ));
    fneg fne1(.x(op11), .z(fsub[63:32] ));
    fneg fne2(.x(op12), .z(fsub[95:64] ));
    fneg fne3(.x(op13), .z(fsub[127:96]));
    
    //floating point cond, mv
    //logic [31:0] fmvwx;
    logic [31:0] feq, flt, fle,   fmv, itof, ftoi;
    feq feqq(.x(op1_single), .y(op2_single), .z(feq));
    flt fltt(.x(op1_single), .y(op2_single), .z(flt), .clk, .rst);
    fle flee(.x(op1_single), .y(op2_single), .z(fle), .clk, .rst);
    //assign fmvwx= op1_single;
    //assign fmv  = op1;
    itof itoff(.a(op1_single), .c(itof));
    ftoi ftoii(.a(op1_single), .c(ftoi));
    
    
    // I/L  nearly same with R-type
    logic [127:0] lui;
    assign lui = op2;
    


    logic [127:0] n_res;
    always_comb begin 
        unique case (aluctl[5:0])
            6'b000000 :  n_res = add;
            6'b000001 :  n_res = sub;
            6'b000010 :  n_res = 128'b0;
            6'b000011 :  n_res = 128'b0;
            6'b000100 :  n_res = 128'b0;
            6'b000101 :  n_res = 128'b0;
            6'b000110 :  n_res = 128'b0;
            6'b000111 :  n_res = 128'b0;

            6'b001000 :  n_res = 128'b0;
            6'b001001 :  n_res = 128'b0;
            6'b001010 :  n_res = 128'b0;
            6'b001011 :  n_res = 128'b0;
            6'b001100 :  n_res = 128'b0;
            6'b001101 :  n_res = 128'b0;
            6'b001110 :  n_res = 128'b0;
            6'b001111 :  n_res = 128'b0;

    // latency 0: fneg, feq
    // latency 1: flt, fle, fmin, fmax
    // latency 2: fadd,fsub,fmul, fsqr
    // latency 3: fdiv
            6'b010000 :  n_res = fadd;
            6'b010001 :  n_res = fsub;
            6'b010010 :  n_res = fmul;
            6'b010011 :  n_res = {4{fdiv}};
            6'b010100 :  n_res = {4{fsqrt}};
            6'b010101 :  n_res = fneg;
            6'b010110 :  n_res = 128'b0;
            6'b010111 :  n_res = 128'b0;

            6'b011000 :  n_res = {4{feq}};
            6'b011001 :  n_res = {4{flt}}; 
            6'b011010 :  n_res = {4{fle}}; 
            6'b011011 :  n_res = 128'b0;
            6'b011100 :  n_res = 128'b0;
            6'b011101 :  n_res = 128'b0;
            6'b011110 :  n_res = {4{itof}};
            6'b011111 :  n_res = {4{ftoi}};

            //same with 000xxx
            6'b100000 :  n_res = add;
            6'b100001 :  n_res = sll;
            6'b100010 :  n_res = sra;
            6'b100011 :  n_res = 128'b0;
            6'b100100 :  n_res = 128'b0;
            6'b100101 :  n_res = 128'b0;
            6'b100110 :  n_res = 128'b0;
            6'b100111 :  n_res = 128'b0;

            6'b101000 :  n_res = 128'b0;  //lw
            6'b101001 :  n_res = 128'b0;  //flw
            6'b101010 :  n_res = lui; 
            6'b101011 :  n_res = 128'b0; // invalid
            6'b101100 :  n_res = 128'b0; // invalid
            6'b101101 :  n_res = 128'b0; // invalid 
            6'b101110 :  n_res = 128'b0; // invalid
            6'b101111 :  n_res = 128'b0; // invalid

            6'b110000 :  n_res = 128'b0;  //branch
            6'b110001 :  n_res = 128'b0;  //branch
            6'b110010 :  n_res = 128'b0;  //branch
            6'b110011 :  n_res = 128'b0;  //branch
            6'b110100 :  n_res = 128'b0;  //branch
            6'b110101 :  n_res = 128'b0;  //branch
            6'b110110 :  n_res = op2;    //sw
            6'b110111 :  n_res = op2;    //fsw

            6'b111000 :  n_res = 128'b0;  //jump
            6'b111001 :  n_res = add;  //jal
            6'b111010 :  n_res = add;  //jalr
            6'b111011 :  n_res = 128'b0;  //invalid
            6'b111100 :  n_res = 128'b0;  //invalid
            6'b111101 :  n_res = 128'b0;  //invalid
            6'b111110 :  n_res = 128'b0;    //invalid
            6'b111111 :  n_res = 128'b0;    //invalid
        endcase 
    end

    logic [5:0] cond;
    logic eq, lt,ltu;

    always_comb begin 
        eq = op1_single == op2_single;
        lt = $signed(op1_single) < $signed(op2_single);
        ltu= $unsigned(op1_single) < $unsigned(op2_single);
        cond[0] = eq;
        cond[1] = ~eq;
        cond[2] = lt;
        cond[3] = ~lt;
        cond[4] = ltu;
        cond[5] = ~ltu;
        npc_enn = (dec_branch[6] && |(cond & dec_branch[5:0])) | dec_jump;
        flush = npc_enn;
    end

endmodule
