module floor(
    input logic clk,rst,
    input  logic [31:0] a,
    output logic [31:0] c
);
///        1   23   8
/// 00000001mm...mmm000000
///   -----------
///って感じでとってくる
    logic s;
    logic unsigned [7:0] e;
    logic [22:0] m;
    assign {s,e,m} = a;
    logic unsigned [7:0] ep1;
    assign ep1 = e + 1;
    logic zero;
    assign zero = e < 8'd127;
    logic big;
    assign big = e > 8'd 149;
    logic unsigned [7:0] diff;
    assign diff  = 8'd149 - e;
    logic [23:0] newmneg_;
    logic [22:0] newmpos;
    logic up;
    logic ovf;


    always_comb begin 
        case (diff)
            8'd0:  newmpos = {m[22:1], 1'b0};
            8'd1:  newmpos = {m[22:2], 2'b0};
            8'd2:  newmpos = {m[22:3], 3'b0};
            8'd3:  newmpos = {m[22:4], 4'b0};
            8'd4:  newmpos = {m[22:5], 5'b0};
            8'd5:  newmpos = {m[22:6], 6'b0};
            8'd6:  newmpos = {m[22:7], 7'b0};
            8'd7:  newmpos = {m[22:8], 8'b0};
            8'd8:  newmpos = {m[22:9], 9'b0};
            8'd9:  newmpos = {m[22:10], 10'b0};
            8'd10: newmpos = {m[22:11], 11'b0};
            8'd11: newmpos = {m[22:12], 12'b0};
            8'd12: newmpos = {m[22:13], 13'b0};
            8'd13: newmpos = {m[22:14], 14'b0};
            8'd14: newmpos = {m[22:15], 15'b0};
            8'd15: newmpos = {m[22:16], 16'b0};
            8'd16: newmpos = {m[22:17], 17'b0};
            8'd17: newmpos = {m[22:18], 18'b0};
            8'd18: newmpos = {m[22:19], 19'b0};
            8'd19: newmpos = {m[22:20], 20'b0};
            8'd20: newmpos = {m[22:21], 21'b0};
            8'd21: newmpos = {m[22:22], 22'b0};
            8'd22: newmpos = {          23'b0};
            default: newmpos = m;
        endcase
        newmneg_[23] = 0;
        case (diff)
            8'd0:  begin newmneg_[22:0] = { 1'b0,m[22:1]};   up =  |m[0 :0]; ovf = &m[22:1] ;end
            8'd1:  begin newmneg_[22:0] = { 2'b0,m[22:2]};   up =  |m[1 :0]; ovf = &m[22:2] ;end
            8'd2:  begin newmneg_[22:0] = { 3'b0,m[22:3]};   up =  |m[2 :0]; ovf = &m[22:3] ;end
            8'd3:  begin newmneg_[22:0] = { 4'b0,m[22:4]};   up =  |m[3 :0]; ovf = &m[22:4] ;end
            8'd4:  begin newmneg_[22:0] = { 5'b0,m[22:5]};   up =  |m[4 :0]; ovf = &m[22:5] ;end
            8'd5:  begin newmneg_[22:0] = { 6'b0,m[22:6]};   up =  |m[5 :0]; ovf = &m[22:6] ;end
            8'd6:  begin newmneg_[22:0] = { 7'b0,m[22:7]};   up =  |m[6 :0]; ovf = &m[22:7] ;end
            8'd7:  begin newmneg_[22:0] = { 8'b0,m[22:8]};   up =  |m[7 :0]; ovf = &m[22:8] ;end
            8'd8:  begin newmneg_[22:0] = { 9'b0,m[22:9]};   up =  |m[8 :0]; ovf = &m[22:9] ;end
            8'd9:  begin newmneg_[22:0] = {10'b0,m[22:10]};  up =  |m[9 :0]; ovf = &m[22:10]; end
            8'd10: begin newmneg_[22:0] = {11'b0,m[22:11]};  up =  |m[10:0]; ovf = &m[22:11]; end
            8'd11: begin newmneg_[22:0] = {12'b0,m[22:12]};  up =  |m[11:0]; ovf = &m[22:12]; end
            8'd12: begin newmneg_[22:0] = {13'b0,m[22:13]};  up =  |m[12:0]; ovf = &m[22:13]; end
            8'd13: begin newmneg_[22:0] = {14'b0,m[22:14]};  up =  |m[13:0]; ovf = &m[22:14]; end
            8'd14: begin newmneg_[22:0] = {15'b0,m[22:15]};  up =  |m[14:0]; ovf = &m[22:15]; end
            8'd15: begin newmneg_[22:0] = {16'b0,m[22:16]};  up =  |m[15:0]; ovf = &m[22:16]; end
            8'd16: begin newmneg_[22:0] = {17'b0,m[22:17]};  up =  |m[16:0]; ovf = &m[22:17]; end
            8'd17: begin newmneg_[22:0] = {18'b0,m[22:18]};  up =  |m[17:0]; ovf = &m[22:18]; end
            8'd18: begin newmneg_[22:0] = {19'b0,m[22:19]};  up =  |m[18:0]; ovf = &m[22:19]; end
            8'd19: begin newmneg_[22:0] = {20'b0,m[22:20]};  up =  |m[19:0]; ovf = &m[22:20]; end
            8'd20: begin newmneg_[22:0] = {21'b0,m[22:21]};  up =  |m[20:0]; ovf = &m[22:21]; end
            8'd21: begin newmneg_[22:0] = {22'b0,m[22:22]};  up =  |m[21:0]; ovf = &m[22:22]; end
            8'd22: begin newmneg_[22:0] = {23'b0         };  up =  |m[22:0]; ovf = 1; end
            default: begin newmneg_[22:0] = m; up= 0;ovf = 0;end
        endcase
    end
    logic [23:0] newmp1;
    assign newmp1 = newmneg_+1;
    logic [22:0] newmneg;
    always_comb begin 
        case (diff)
            8'd0:  newmneg = {newmp1[21:0] ,1'b0};
            8'd1:  newmneg = {newmp1[20:0] ,2'b0};
            8'd2:  newmneg = {newmp1[19:0] ,3'b0};
            8'd3:  newmneg = {newmp1[18:0] ,4'b0};
            8'd4:  newmneg = {newmp1[17:0] ,5'b0};
            8'd5:  newmneg = {newmp1[16:0] ,6'b0};
            8'd6:  newmneg = {newmp1[15:0] ,7'b0};
            8'd7:  newmneg = {newmp1[14:0] ,8'b0};
            8'd8:  newmneg = {newmp1[13:0] ,9'b0};
            8'd9:  newmneg = {newmp1[12:0] ,10'b0};
            8'd10: newmneg = {newmp1[11:0],11'b0};
            8'd11: newmneg = {newmp1[10:0],12'b0};
            8'd12: newmneg = {newmp1[ 9:0],13'b0};
            8'd13: newmneg = {newmp1[ 8:0],14'b0};
            8'd14: newmneg = {newmp1[ 7:0],15'b0};
            8'd15: newmneg = {newmp1[ 6:0],16'b0};
            8'd16: newmneg = {newmp1[ 5:0],17'b0};
            8'd17: newmneg = {newmp1[ 4:0],18'b0};
            8'd18: newmneg = {newmp1[ 3:0],19'b0};
            8'd19: newmneg = {newmp1[ 2:0],20'b0};
            8'd20: newmneg = {newmp1[ 1:0],21'b0};
            8'd21: newmneg = {newmp1[ 0:0],22'b0};
            8'd22: newmneg = {23'b0};
            default: newmneg[22:0] = m;
        endcase
 
        
    end

    //invalid for negative ones
    /*assign c = zero ? (s ?  {1'b1, 8'd127, 23'b0}: 32'b0):
                big ? a :
                {s,e,newm};*/
    always_ff @( posedge clk ) begin 
        if(rst) begin
            c <= 0;
        end else begin
            /*c <= zero ? (s ?  {1'b1, 8'd127, 23'b0}: 32'b0):
                big ? a :
                {s,e,newm};*/
            c <= s  ? zero ? {1'b1, 8'd127, 23'b0}
                            : big ? a
                                  : up ? ovf ? {1'b1, ep1, 23'b0}
                                             :  {1'b1, e, newmneg}
                                       :a
                    : zero  ? 32'b0 
                            : big ? a 
                                  : {1'b0, e, newmpos};
        end
        
    end



endmodule