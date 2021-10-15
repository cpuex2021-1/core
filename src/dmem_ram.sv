`timescale 1ns / 1ps

`define ADDR_LEN 25
`define TAG_LEN 9
`define INDEX_LEN 14
`define OFFSET_LEN 2

// `define SET_ASSOC

//MMIO 
// addr == 0 -> uart lw/sw
// addr != 0 -> cache DRAM
module dmem_ram(
        input  logic clk,rst,
        input  logic [24:0] daddr,
        input  logic mre,
        input  logic mwe,
        input  logic [31:0] res,
        output logic [31:0] memdata,
        input  logic rxd,
        output logic txd,
        output logic rx_valid,
        output logic tx_ready 
    );
    assign memdata = uart_en ? {24'b0,rd_d} : 32'hffffffff; //for cache!
    //uart
    logic uart_en ;
    assign uart_en = daddr == 25'b0;


    logic [7:0] rdata;
    logic rvalid;
    logic wr_full;
    logic [7:0] rd_d;
    logic rd_en;
    logic rd_empty;
    uart_rx rx(.clk, .rst, .rxd, .rdata, .rvalid);
    fifo fifo_rx(.clk, .rst, .wr_d(rdata), .wr_en(rvalid),.wr_full(wr_full), .rd_d, .rd_en, .rd_empty(rd_empty));
    assign rd_en = mre & uart_en & ~rd_empty;
    assign rx_valid = ~rd_empty;
    

    logic [7:0] tdata;
    logic tready;
    logic tx_full;
    logic tx_empty;
    uart_tx tx(.clk, .rst, .txd, .tdata, .tvalid(~tx_empty& tready), .tready);
    fifo fifo_tx(.clk, .rst, .wr_d(res[7:0]), .wr_en(mwe & uart_en & ~tx_full), .wr_full(tx_full), .rd_d(tdata), .rd_en(~tx_empty & tready), .rd_empty(tx_empty));
    assign tx_ready = ~tx_full;
    //cache

//    `ifndef SET_ASSOC
//    (* ram_style = "distributed" *) logic [31:0] cache [16383:0];
//    (* ram_style = "distributed" *) logic [8:0] tag_array [16383:0];
//    (* ram_style = "distributed" *) logic valid_array [16383:0];
//    logic [8:0] tag;
//    logic [13:0] index;
//    logic [1:0] offset;
//    assign {tag, index, offset} = daddr;
//
//    logic stall; // outputする
//    logic arrive; // missしてたデータが届いたか
//    logic [31:0] data_arrived; // 届いたデータ
//    
//    integer i;
//    initial begin 
//        for (i=0; i<16383; i=i+1) begin
//            cache[i] = 0;
//            tag_array[i] = 0;
//            valid_array[i] = 0;
//        end
//        stall = 0;
//        arrive = 0;
//        data_arrived = 0;
//    end
//
//    // dram u1(daddr, arrive, data_arrived);
//
//    always_ff @( posedge clk ) begin 
//        if(mwe) begin
//            if (tag_array[index] == tag && valid_array[index]) begin
//                cache[index] <= res;
//            end else begin
//                stall <= 1;
//            end
//        end
//        if (arrive) begin 
//            if (mwe) begin 
//                cache[index] <= data_arrived;
//            end 
//            stall <= 0;
//        end
//    end
//
//    assign memdata = cache[index];
//    `else
//    // TODO: 2-way set associative
//    `endif 
endmodule
