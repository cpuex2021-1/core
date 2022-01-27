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
    logic zero;
    assign zero = e < 8'd126;
    logic big;
    assign big = e > 8'd 149;
    logic [7:0] diff = 8'd149 - e;
    logic [22:0] newm;


    always_comb begin 
        case (diff)
            8'd0: newm = {m[22:1], 1'b0};
            8'd1: newm = {m[22:2], 2'b0};
            8'd2: newm = {m[22:3], 3'b0};
            8'd3: newm = {m[22:4], 4'b0};
            8'd4: newm = {m[22:5], 5'b0};
            8'd5: newm = {m[22:6], 6'b0};
            8'd6: newm = {m[22:7], 7'b0};
            8'd7: newm = {m[22:8], 8'b0};
            8'd8: newm = {m[22:9], 9'b0};
            8'd9: newm = {m[22:9], 9'b0};
            8'd10: newm = {m[22:10], 10'b0};
            8'd11: newm = {m[22:11], 11'b0};
            8'd12: newm = {m[22:12], 12'b0};
            8'd13: newm = {m[22:13], 13'b0};
            8'd14: newm = {m[22:14], 14'b0};
            8'd15: newm = {m[22:15], 15'b0};
            8'd16: newm = {m[22:16], 16'b0};
            8'd17: newm = {m[22:17], 17'b0};
            8'd18: newm = {m[22:18], 18'b0};
            8'd19: newm = {m[22:19], 19'b0};
            8'd20: newm = {m[22:20], 20'b0};
            8'd21: newm = {m[22:21], 21'b0};
            8'd22: newm = {m[22:22], 22'b0};
            default: newm = m;
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
            c <= zero ? (s ?  {1'b1, 8'd127, 23'b0}: 32'b0):
                big ? a :
                {s,e,newm};
        end
        
    end



endmodule