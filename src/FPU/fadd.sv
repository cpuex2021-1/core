`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2021 08:33:31 PM
// Design Name: 
// Module Name: fadd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// HW実験から持ってきたので過剰かも
module fadd (input wire [31:0]  x1,
             input wire [31:0]  x2,
             output wire [31:0] y
             //output wire        ovf
             );

   wire s1 = x1[31];
   wire [7:0] e1 = x1[30:23];
   wire [22:0] m1 = x1[22:0];
   wire s2 = x2[31];
   wire [7:0] e2 = x2[30:23];
   wire [22:0] m2 = x2[22:0];
   wire [24:0] m1a = (e1==0) ? {2'b00, m1} :  {2'b01, m1};
   wire [24:0] m2a = (e2==0) ? {2'b00,m2 } :  {2'b01, m2};
   wire [7:0] e1a  = (e1 == 0) ? 8'd1 : e1;
   wire [7:0] e2a  = (e2 == 0) ? 8'd1 : e2;

   wire [7:0] e2ai = ~e2a;
   wire [8:0] te   = {1'b0, e1a} + {1'b0, e2ai};
   wire ce = te[8] ? 0 : 1;
   wire [8:0]tep1 = te+1;
   wire [8:0] nte  = ~te;
   wire [7:0] tde = te[8] ? tep1[7:0] : nte[7:0];
   wire [4:0] de = (|(tde[7:5]) ) ? 5'd31 : tde[4:0];
   wire sel = (de==0) ? ( (m1a >m2a) ? 0 : 1) : ce;
   wire [24:0] ms = sel ? m2a : m1a;
   wire [24:0] mi = sel ? m1a : m2a;
   wire [7:0] es  = sel ? e2a : e1a;
   wire [7:0] ei  = sel ? e1a : e2a;
   wire ss        = sel ? s2  :  s1;
   wire [55:0] mie = {mi, 31'b0};
   wire [55:0] mia = mie >> de;
   wire tstck = |(mia[28:0]);
   wire [26:0] mye = (s1 == s2) ?  {ms,2'b0} + mia[55:29] : {ms,2'b0} - mia[55:29];
   wire [7:0] esi = es + 1;
   wire [7:0] eyd = (mye[26]) ?( (esi==8'd255) ? 8'd255 : esi )   :  es;
   wire [26:0] myd = (mye[26]) ? ((esi==8'd255) ? {2'b01, 25'b0} : mye>>1) : mye;
   wire stck =     (mye[26]) ? ((esi==8'd255) ? 1'b0 : tstck || mye[0]) : tstck;
   
   wire [25:0] ser = { << {myd[25:0]}};
   wire [25:0] seb = (ser & (-ser)); //あってるのか？
   wire [4:0] se;
   assign se[4] = (seb == 0) ? 1'b1 :  |(seb[25:16]);
   assign se[3] = (seb == 0) ? 1'b1 :  |(seb & 26'h300_FF00);
   assign se[2] = (seb == 0) ? 1'b0 :  |(seb & 26'h0_F0_F0F0);
   assign se[1] = (seb == 0) ? 1'b1 :  |(seb & 26'h0CC_CCCC);
   assign se[0] = (seb == 0) ? 1'b0 :  ~seb[0];
   
   wire [8:0] eyf= {1'b0,eyd} - {4'b0,se};
   
   wire [26:0] myf = ($signed(eyf) > 0) ? myd<<se : myd << (eyd[4:0]-1);
   wire [7:0]  eyr = ($signed(eyf) > 0) ? eyf[7:0] : 8'b0;
   
   wire [24:0] myr = ((myf[1] ==1 && myf[0] == 0 && stck==0 && myf[2] ==1) || (myf[1] ==1&&myf[0] ==0 && s1==s2 && stck==1) || (myf[1] == 1 && myf[0] ==1)) ? myf[26:2] + 25'b1 : myf[26:2]; 
   
   wire [7:0] eyri = eyr + 8'b1;
   wire [7:0] ey = (myr[24]==1) ? eyri : (|(myr[23:0]) ? eyr : 0);
   wire [22:0] my = (myr[24]==1) ? 23'b0 : (|(myr[23:0]) ? myr[22:0] : 23'b0);
   
   wire sy = (ey==0 && my==0) ? s1 && s2 : ss;
   
   wire nzm1 = |(m1[22:0]);
   wire nzm2 = |(m2[22:0]);

    //todo e1=255 e2=255 
   wire e1eq = e1 == 255;
   wire e2eq = e2 == 255;
   assign y =   (e1eq && !e2eq )           ? {s1, 8'd255, nzm1, m1[21:0]}
              : (e2eq  && !e1eq )         ? {s2, 8'd255, nzm2,m2[21:0]} 
              : (e1eq&& e2eq&& nzm2)    ? {s2,8'd255,1'b1,m2[21:0]}
              : (e2eq &&e1eq&& nzm1)     ? {s1, 8'd255, 1'b1, m1[21:0]}
              : (e1eq && e2eq&& s1==s2) ? {s1, 8'd255, 23'b0}
              : (e1eq && e2eq)            ? {1'b1, 8'd255, 1'b1, 22'b0}
              :                                    {sy,ey,my};

   //assign ovf = (e1!=255 && e2!=255 && (esi==255 ||  eyri == 255));
 
  
endmodule