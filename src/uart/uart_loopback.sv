module uart_loopback(
    input   logic clk,rst,
    input   logic rxd,
    output  logic txd
);
    logic [7:0] rdata;
    logic [7:0] tdata, n_tdata;
    logic rvalid;
    logic tvalid, n_tvalid;
    logic tready;

    uart_rx rx(.clk, .rst, .rdata, .rvalid, .rxd);
    uart_tx tx(.clk, .rst, .tdata, .tvalid, .tready,  .txd);

    always_comb begin 
        n_tvalid = tvalid;
        n_tdata  = tdata;
        if(rvalid) begin
            n_tvalid = 1;
            n_tdata  = rdata;
        end
        if(tvalid && tready) begin
            n_tvalid = 0;
        end
        
    end

    always_ff @( posedge clk ) begin 
        if (rst) begin
            tdata  <= 8'b0;
            tvalid <= 0;
        end else begin
            tdata  <= n_tdata;
            tvalid <= n_tvalid;
        end
        
    end
endmodule