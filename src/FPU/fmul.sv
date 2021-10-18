`timescale 1ns / 1ps

// レギュレーションに基づく

// (-1) ^ (s1 ^ s2) * 2^ (e1 + e2 - 127) - 127 * (1.m1) * (1.m2)

module fmul(
        input logic [31:0] a,b,
        output logic [31:0] c
    );
    logic s1;
    assign s1 = a[31];
    logic s2 ;
    assign s2= b[31];
    logic s;
    assign s = s1 ^ s2;

    logic [7:0] e1;
    assign e1  = a[30:23];
    logic [7:0] e2;
    assign e2 = b[30:23];
 

    logic [9:0] eadd;
    assign eadd  = {1'b0,e1} + {1'b0, e2};
    logic [9:0] en ;
    assign en = eadd - 9'd127;
    logic [9:0] ep;
    assign ep = eadd - 9'd126;
    // 0   <= eadd <= 126 -> en:11........
    // 127 <= eadd <= 382 -> en:00........
    // 383 <= eadd <= 510 -> en:01........
    // ep も同様

    logic [24:0] m1;
    assign m1  = {2'b01, a[22:0]};
    logic [24:0] m2;
    assign m2  = {2'b01, b[22:0]};

    logic [49:0] mul;
    assign mul = m1 * m2;
    // 1.m1 * 1.m2 = 01.......... or 1............(繰り上がり)
    logic [7:0] e ;
    assign e = mul[47]? (ep[9:8] == 2'b11 ? 8'b00000000 : ep[9:8] == 2'b00 ? ep[7:0] : 8'b11111111) 
                            : (en[9:8] == 2'b11 ? 8'b00000000 : en[9:8] == 2'b00 ? en[7:0] : 8'b11111111) ;


    logic [22:0] m;
    assign m = mul[47] ? mul[46:24] : mul[45:23];

    assign c = {s,e,m};



endmodule
