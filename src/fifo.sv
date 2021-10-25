module fifo(
    input  logic clk,rst,
    input  logic [7:0] wr_d,
    input  logic wr_en,
    output logic wr_full,
    output logic [7:0] rd_d,
    input  logic rd_en,
    output logic rd_empty
);
    logic [7:0] mem [4095:0];
    logic [11:0] rd_addr, wr_addr;
    logic [11:0] n_rd_addr, n_wr_addr;
    // data is available in [rd_addr, wr_addr) (semi open)
    // 本当は1byte無駄になっちゃうけど実装がめんどいのでこれで...
    // fullやemptyなのに操作してきたときはあっちの責任です。

    integer i;
    initial begin
        for(i=0; i<4096; i=i+1) mem[i] = 8'b0;
    end

    logic n_rd_empty;
    logic n_wr_full;
    logic [11:0] dif;

    always_comb begin 
        n_rd_addr = rd_en ? rd_addr + 1 : rd_addr;
        n_rd_empty = rd_addr == wr_addr || rd_en && (rd_addr+1) == wr_addr;

        n_wr_addr = wr_en ? wr_addr + 1 : wr_addr;
        dif = rd_addr - wr_addr;
        n_wr_full = rd_addr != wr_addr && dif < 2;
    end

    always_ff @( posedge clk ) begin 
        if(rst) begin
            rd_addr <= 0;
            wr_addr <= 0;
            rd_empty <= 1;
            wr_full <= 1;
            rd_d <= 0;
        end else begin
            if(wr_en) begin
                mem[wr_addr] <= wr_d;
            end
            rd_addr <= n_rd_addr;
            wr_addr <= n_wr_addr;
            rd_empty <=  n_rd_empty;
            wr_full <= n_wr_full;
            //rd_d <= (rd_en) ? mem[rd_addr+1] : mem[rd_addr];
            rd_d <= mem[rd_addr];
        end
        
    end
endmodule