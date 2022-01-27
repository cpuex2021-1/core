module itof(
    input logic clk,rst,
    input logic [31:0] a,
    output logic [31:0] c
);
    logic s;
    assign s = a[31];
    logic [31:0] neg;
    assign neg = ~a + 32'd1;
    logic [31:0] abs;
    assign abs  = s ? neg : a;


    //ひっどい

logic a01  ;
logic a23  ;
logic a45  ;
logic a67  ;
logic a89  ;
logic a1011 ;
logic a1213 ;
logic a1415 ;
logic a1617 ;
logic a1819 ;
logic a2021 ;
logic a2223 ;
logic a2425 ;
logic a2627 ;
logic a2829 ;
logic a3031 ;







    assign a01 = abs[0] | abs[1];
    assign a23 = abs[2] | abs[3];
    assign a45 = abs[4] | abs[5];
    assign a67 = abs[6] | abs[7];
    assign a89 = abs[8] | abs[9];
    assign a1011 = abs[10] | abs[11];
    assign a1213 = abs[12] | abs[13];
    assign a1415 = abs[14] | abs[15];
    assign a1617 = abs[16] | abs[17];
    assign a1819 = abs[18] | abs[19];
    assign a2021 = abs[20] | abs[21];
    assign a2223 = abs[22] | abs[23];
    assign a2425 = abs[24] | abs[25];
    assign a2627 = abs[26] | abs[27];
    assign a2829 = abs[28] | abs[29];
    assign a3031 = abs[30] | abs[31];

logic a03;
logic a47;
logic a811 ;
logic a1215;
logic a1619;
logic a2023;
logic a2427;
logic a2831;


    assign a03 = a01 | a23;
    assign a47 = a45 | a67;
    assign a811 = a89 | a1011;
    assign a1215 = a1213 | a1415;
    assign a1619 = a1617 | a1819;
    assign a2023 = a2021 | a2223;
    assign a2427 = a2425 | a2627;
    assign a2831 = a2829 | a3031;

logic a07  ;
logic a815  ;
logic a1623 ;
logic a2431 ;

    assign a07 = a03 | a47;
    assign a815 = a811 | a1215;
    assign a1623 = a1619 | a2023;
    assign a2431 = a2427 | a2831;

    logic a015 ;
    logic a1631 ;
    assign a015 = a07 | a815;
    assign a1631 = a1623 | a2431;

    logic a031 ;
    assign a031 = a015 | a1631;

    //ひっどい2
    logic [4:0] e_;
    logic zero;
    assign zero = ~|a;
    assign e_ = 
                a1631 ? 
                    a2431 ?
                        a2831 ?
                              a3031 ? (abs[31] ? 31 : 30) : (abs[29] ? 29 : 28)
                            : a2627 ? (abs[27] ? 27 : 26) : (abs[25] ? 25 : 24)
                        : a2023 ?
                              a2223 ? (abs[23] ? 23 : 22) : (abs[21] ? 21 : 20)
                            : a1819 ? (abs [19] ? 19: 18) : (abs[17] ? 17 : 16)
                    : a815 ?
                        a1215 ? 
                              a1415 ? (abs[15] ? 15 : 14) : (abs[13] ? 13 : 12)
                            : a1011 ? (abs[11] ? 11 : 10) : (abs[9] ? 9 : 8)
                        :a47 ? 
                              a67 ? (abs[7] ? 7 : 6) : (abs[5] ? 5 : 4)
                            : a23 ? (abs[3] ? 3 : 2) : (abs[1] ? 1 : 0);

    logic [63:0] m_ext;
    assign m_ext = {abs, 32'b0};
    logic [22:0] m_cut;
    assign m_cut = m_ext[31+e_-:23];
    logic up ;
    assign up= m_ext[8+e_];
    logic [22:0] m_cutp;
    assign m_cutp = m_cut + 1;
    logic over;
    assign over = &m_cut;

    logic [7:0] e;
    assign e = {3'b0,e_} + 8'd127;
    logic [7:0] ep;
    assign ep = e + 1;

    /*assign c = zero? 0 : 
                up ? 
                over ? {s, ep, 23'b0} : {s, e, m_cutp}
              : {s, e, m_cut};*/
    always_ff @( posedge clk ) begin
        if(rst) begin
            c <= 0;
        end  else begin
            c <=zero? 0 : 
                up ? 
                over ? {s, ep, 23'b0} : {s, e, m_cutp}
              : {s, e, m_cut};

        end
        
    end
    


endmodule
