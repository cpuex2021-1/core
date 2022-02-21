module fadd_cy (input wire [31:0] x1,
		input wire [31:0] x2,
		output reg [31:0] y,
		input wire 	  clk,
		input wire 	  rst);
   wire s1_ = x1[31];
   wire [7:0] e1_ = x1[30:23];
   wire [22:0] m1_ = x1[22:0];
   wire s2_ = x2[31];
   wire [7:0] e2_ = x2[30:23];
   wire [22:0] m2_ = x2[22:0];
   wire [24:0] m1a = (e1_==0) ? {2'b00, m1_} :  {2'b01, m1_};
   wire [24:0] m2a = (e2_==0) ? {2'b00,m2_ } :  {2'b01, m2_};
   wire [7:0] e1a  = (e1_ == 0) ? 8'd1 : e1_;
   wire [7:0] e2a  = (e2_ == 0) ? 8'd1 : e2_;

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
   wire ss_        = sel ? s2_  :  s1_;
   wire [55:0] mie = {mi, 31'b0};
   wire [55:0] mia = mie >> de;
   wire tstck = |(mia[28:0]);
   wire [26:0] mye = (s1_ == s2_) ?  {ms,2'b0} + mia[55:29] : {ms,2'b0} - mia[55:29];
   wire [7:0] esi = es + 1;
   wire [7:0] eyd_ = (mye[26]) ?( (esi==8'd255) ? 8'd255 : esi )   :  es;
   wire [26:0] myd_ = (mye[26]) ? ((esi==8'd255) ? {2'b01, 25'b0} : mye>>1) : mye;
   wire stck_ =     (mye[26]) ? ((esi==8'd255) ? 1'b0 : tstck || mye[0]) : tstck;
   
  // wire [25:0] ser_ = { << {myd_[25:0]}};
   //wire [25:0] seb_ = (ser_ & (-ser_)); //あってるのか？
   wire [4:0] se_= myd_[25] ? 0 :
                   myd_[24] ? 1 :
                   myd_[23] ? 2 :
                   myd_[22] ? 3 :
                   myd_[21] ? 4 :
                   myd_[20] ? 5 :
                   myd_[19] ? 6 :
                   myd_[18] ? 7 :
                   myd_[17] ? 8 :
                   myd_[16] ? 9 :
                   myd_[15] ? 10 :
                   myd_[14] ? 11 :
                   myd_[13] ? 12 :
                   myd_[12] ? 13 :
                   myd_[11] ? 14 :
                   myd_[10] ? 15 :
                   myd_[9] ? 16 :
                   myd_[8] ? 17 :
                   myd_[7] ? 18 :
                   myd_[6] ? 19 :
                   myd_[5] ? 20 :
                   myd_[4] ? 21 :
                   myd_[3] ? 22 :
                   myd_[2] ? 23 :
                   myd_[1] ? 24 :
                   myd_[0] ? 25 : 26;
 /*  wire [4:0] se_;
   assign se_[4] = (seb_ == 0) ? 1'b1 :  |(seb_[25:16]);
   assign se_[3] = (seb_ == 0) ? 1'b1 :  |(seb_ & 26'h300_FF00);
   assign se_[2] = (seb_ == 0) ? 1'b0 :  |(seb_ & 26'h0_F0_F0F0);
   assign se_[1] = (seb_ == 0) ? 1'b1 :  |(seb_ & 26'h0CC_CCCC);
   assign se_[0] = (seb_ == 0) ? 1'b0 :  |(seb_ & 26'h2AA_AAAA);*/
   reg [7:0] eyd;
   reg [26:0] myd;
   reg [4:0] se;
   reg [25:0] seb;
   reg [25:0] ser;
   reg stck;
   reg s1;
   reg s2;
   reg [7:0] e1;
   reg [7:0] e2;
   reg ss;
   reg [22:0] m1;
   reg [22:0] m2;
      always @(posedge clk) begin
      if (rst) begin
      	   eyd <= 0;
	       myd <= 0;
	       se <= 0;
	       stck <= 0;
	       s1 <= 0;
	       s2 <= 0;
	       e1 <= 0;
	       e2 <= 0;
	       ss <= 0;
	       m1 <= 0;
	       m2 <= 0;      
      end else begin
	       eyd <= eyd_;
	       myd <= myd_;
	       se <= se_;
	       stck <= stck_;
	       s1 <= s1_;
	       s2 <= s2_;
	       e1 <= e1_;
	       e2 <= e2_;
	       ss <= ss_;
	       m1 <= m1_;
	       m2 <= m2_;
      end
   end
   
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
   wire [31:0] 			  y_next;
   wire e1max,e2max;
   assign e1max = e1==255;
   assign e2max = e2==255;
   //wire 			  ovf_next;
   assign y_next =   (e1max && ~e2max)           ? {s1, 8'd255, nzm1, m1[21:0]}
              : (e2max && ~e1max)         ? {s2, 8'd255, nzm2,m2[21:0]} 
              : (e2max&&e1max&& nzm1)     ? {s1, 8'd255, 1'b1, m1[21:0]}
              : (e1max&& e2max&& nzm2)    ? {s2,8'd255,1'b1,m2[21:0]}
              : (e1max&& e2max&& s1==s2) ? {s1, 8'd255, 23'b0}
              : (e1max&& e2max)            ? {1'b1, 8'd255, 1'b1, 22'b0}
              :                                    {sy,ey,my};

   //assign ovf_next = (e1!=255 && e2!=255 && ey==255);
 
  


   
   

   always @(posedge clk) begin
      if (rst) begin
	 y <= 32'b0;
      end else begin
	 y <= y_next;
      end
   end
endmodule