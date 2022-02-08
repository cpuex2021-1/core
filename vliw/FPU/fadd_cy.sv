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
/*  wire [4:0] se_;
   assign se_[4] = (seb_ == 0) ? 1'b1 :  |(seb_[25:16]);
   assign se_[3] = (seb_ == 0) ? 1'b1 :  |(seb_ & 26'h300_FF00);
   assign se_[2] = (seb_ == 0) ? 1'b0 :  |(seb_ & 26'h0_F0_F0F0);
   assign se_[1] = (seb_ == 0) ? 1'b1 :  |(seb_ & 26'h0CC_CCCC);
   assign se_[0] = (seb_ == 0) ? 1'b0 :  |(seb_ & 26'h2AA_AAAA);*/
   reg [7:0] eyd;
   reg [26:0] myd;
   //reg [4:0] se;
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
	       //se <= 0;
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
	       //se <= se_;
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
    wire [4:0] se= myd[25] ? 0 :
                   myd[24] ? 1 :
                   myd[23] ? 2 :
                   myd[22] ? 3 :
                   myd[21] ? 4 :
                   myd[20] ? 5 :
                   myd[19] ? 6 :
                   myd[18] ? 7 :
                   myd[17] ? 8 :
                   myd[16] ? 9 :
                   myd[15] ? 10 :
                   myd[14] ? 11 :
                   myd[13] ? 12 :
                   myd[12] ? 13 :
                   myd[11] ? 14 :
                   myd[10] ? 15 :
                   myd[9] ? 16 :
                   myd[8] ? 17 :
                   myd[7] ? 18 :
                   myd[6] ? 19 :
                   myd[5] ? 20 :
                   myd[4] ? 21 :
                   myd[3] ? 22 :
                   myd[2] ? 23 :
                   myd[1] ? 24 :
                   myd[0] ? 25 : 26;
      /*logic [4:0] se;
      always_comb begin 
         casez(myd[25:0])
            26'b1?????????????????????????: se = 0;
            26'b01????????????????????????: se = 1;
            26'b001???????????????????????: se = 2;
            26'b0001??????????????????????: se = 3;
            26'b00001?????????????????????: se = 4;
            26'b000001????????????????????: se = 5;
            26'b0000001???????????????????: se = 6;
            26'b00000001??????????????????: se = 7;
            26'b000000001?????????????????: se = 8;
            26'b0000000001????????????????: se = 9;
            26'b00000000001???????????????: se = 10;
            26'b000000000001??????????????: se = 11;
            26'b0000000000001?????????????: se = 12;
            26'b00000000000001????????????: se = 13;
            26'b000000000000001???????????: se = 14;
            26'b0000000000000001??????????: se = 15;
            26'b00000000000000001?????????: se = 16;
            26'b000000000000000001????????: se = 17;
            26'b0000000000000000001???????: se = 18;
            26'b00000000000000000001??????: se = 19;
            26'b000000000000000000001?????: se = 20;
            26'b0000000000000000000001????: se = 21;
            26'b00000000000000000000001???: se = 22;
            26'b000000000000000000000001??: se = 23;
            26'b0000000000000000000000001?: se = 24;
            26'b00000000000000000000000001: se = 25;
            default : se = 26;
         endcase
      end*/

   
   wire [8:0] eyf= {1'b0,eyd} - {4'b0,se};

   
   reg [26:0] myf;// = ($signed(eyf) > 0) ? myd<<se : myd << (eyd[4:0]-1);
   reg [7:0]  eyr ;//= ($signed(eyf) > 0) ? eyf[7:0] : 8'b0;
   reg stck3;
   reg s1_3, s2_3;
   reg ss3;
   always_ff @( posedge clk ) begin 
      if(rst)begin
         
      end else begin
         myf <= ($signed(eyf) > 0) ? myd<<se : myd << (eyd[4:0]-1);
         eyr <= ($signed(eyf) > 0) ? eyf[7:0] : 8'b0;
         stck3 <= stck;
         s1_3 <= s1;
         s2_3 <= s2;
         ss3 <= ss;
      end

   end
   
   wire [24:0] myr = ((myf[1] ==1 && myf[0] == 0 && stck3==0 && myf[2] ==1) || (myf[1] ==1&&myf[0] ==0 && s1_3==s2_3 && stck3==1) || (myf[1] == 1 && myf[0] ==1)) ? myf[26:2] + 25'b1 : myf[26:2]; 
   
   wire [7:0] eyri = eyr + 8'b1;
   wire [7:0] ey = (myr[24]==1) ? eyri : (|(myr[23:0]) ? eyr : 0);
   wire [22:0] my = (myr[24]==1) ? 23'b0 : (|(myr[23:0]) ? myr[22:0] : 23'b0);
   
   wire sy =  ss3;
   
   //wire nzm1 = |(m1[22:0]);
   //wire nzm2 = |(m2[22:0]);
   wire [31:0] 			  y_next;
   //wire e1max,e2max;
   //assign e1max = e1==255;
   //assign e2max = e2==255;
   //wire 			  ovf_next;
   //assign y_next =    {sy,ey,my};
   assign y =    {sy,ey,my};

   //assign ovf_next = (e1!=255 && e2!=255 && ey==255);
 
  



   
   /*

   always @(posedge clk) begin
      if (rst) begin
	 y <= 32'b0;
      end else begin
	 y <= y_next;
      end
   end*/
endmodule