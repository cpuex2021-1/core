module uart_loopback(
    input   logic clk,rst,
    input   logic rxd,
    output  logic txd
);
    logic [7:0] rdata;
    logic [7:0] tdata;
    logic rvalid;
    logic tvalid;
    logic tready;
    logic wr_full, rd_empty;

    

    uart_rx rx(.clk, .rst, .rdata, .rvalid, .rxd);
    uart_tx tx(.clk, .rst, .tdata, .tvalid, .tready,  .txd);

    fifo loop(.clk, .rst, .wr_en(rvalid),.wr_d(rdata), .wr_full, .rd_d(tdata), .rd_en(~rd_empty &tready), .rd_empty);


    always_comb begin 
        tvalid = ~rd_empty & tready;
    end

    always_ff @( posedge clk ) begin 
       
    end
endmodule