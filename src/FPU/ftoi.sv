module ftoi(
    input  logic [31:0] a,
    output logic [31:0] c
);
///        1   23   8
/// 00000001mm...mmm000000
///   -----------
///って感じでとってくる
    logic s;
    logic unsigned [7:0] e;
    logic [63:0] m;
    assign m[63:32] = 0;
    assign m[31] = 1;
    assign {s,e,m[30:8]} = a;
    assign m[7:0] = 0;
    logic zero;
    assign zero = e < 8'd126;
    logic one;
    assign one  = e == 8'd126;
    logic over;
    assign over = e > 8'd157;
    logic [7:0] pos_ ;
    assign pos_ = 8'd158 - e;
    logic [5:0] pos;
    assign pos  = pos_[5:0];
    logic [31:0] mn ;
    assign mn = m[pos+:32];
    logic [31:0] mp ;
    assign mp = mn + 1;
    logic [31:0] cm ;
    assign cm  = m[pos-1] ? mp : mn;
    logic [31:0] res;
    assign res = zero ? 0 : 
               one  ? 1 : 
               over ? 32'h80000000 : cm;
    assign c = s ? ~res + 1: res;



endmodule