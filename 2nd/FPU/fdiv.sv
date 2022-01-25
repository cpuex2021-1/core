module fdiv(
    input  logic clk,rst,
    input  logic [31:0] x,y,
    output logic [31:0] z
);
//1st stage
    logic [35:0] init_grad ;
    logic xs,ys;
    logic [7:0] xe,ye;
    logic [23:0] xm_1;
    logic [9:0]  key;
    logic [12:0] diff;
    assign {key, diff} = y[22:0];

    always_ff  @(posedge clk) begin
        if(rst) begin
            {xs, xe, xm_1[22:0]} <= 0;
            xm_1[23] <= 0;
            {ys,ye} <= 0;
        end else begin
            {xs, xe, xm_1[22:0]} <= x;
            xm_1[23] <= 1'b1;
            {ys,ye} <= y[31:23];
        end
    end
    invparam invp(.clk, .rst, .key, .init_grad);
    logic unsigned [34:0] init;
    logic unsigned [12:0] grad;
    assign init = {init_grad[35:13], 12'b0} ;
    assign grad = init_grad[12:0];
    logic unsigned [35:0] ym_;
    assign ym_ = init - diff * grad;
    logic [23:0] ym;

    logic s;
    logic [8:0] e_;
    logic [8:0] e_p1 ;
    logic [8:0] n_e_ ;
    assign n_e_=  {1'b0, xe} - {1'b0, ye} + 9'd126;
    logic [23:0] xm_2;
    always_ff @(posedge clk)begin
        if(rst) begin
            xm_2 <= 0;
            ym <= 0;
            s <= 0;
            e_  <= 0;
            e_p1 <= 0;
        end else begin
            xm_2 <= xm_1;
            ym  <= {1'b1, ym_[34:12]};
            s <= xs ^ ys;
            e_  <= n_e_;
            e_p1 <= n_e_ + 1;
        end
    end
    logic [47:0] m_;
    assign m_ = xm_2 * ym;
    logic [22:0] m;
    assign m = m_[47] ? m_[46:24] : m_[45:23];


    logic [7:0] e;
    assign e = m_[47] ? e_p1[7:0] : e_[7:0];
    always_ff @(posedge clk) begin
        if (rst) begin
            z <= 0;
        end else begin
            z <= {s,e,m};
        end
    end



endmodule