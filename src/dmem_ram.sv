`timescale 1ns / 1ps

`define ADDR_LEN 25
`define TAG_LEN 9
`define INDEX_LEN 14
`define OFFSET_LEN 2

// `define SET_ASSOC

//MMIO 
// addr == 0 -> uart lw/sw
// addr != 0 -> cache DRAM
// daddr [29:25] == 5'b11111 -> inst memory
module dmem_ram(
        input  logic clk,rst,
        input  logic n_stall,
        input  logic [29:0] daddr,
        input  logic dec_mre,
        input  logic dec_mwe,
        input  logic [31:0] op2,
        output logic [31:0] wb_memdata,
        input  logic rxd,
        output logic txd,
        output logic rx_valid,
        output logic tx_ready ,
// Master Interface Write Address
    output logic  [27-1:0]      M_AXI_AWADDR,
    output logic  [8-1:0] 			 M_AXI_AWLEN,
    output logic  [3-1:0] 			 M_AXI_AWSIZE,
    output logic  [2-1:0] 			 M_AXI_AWBURST,
    output logic  				 M_AXI_AWLOCK,
    output logic  [4-1:0] 			 M_AXI_AWCACHE,
    output logic  [3-1:0] 			 M_AXI_AWPROT,
    // AXI3 output wire [4-1:0]                  M_AXI_AWREGION,
    output logic [4-1:0] 			 M_AXI_AWQOS,
    output logic                    M_AXI_AWVALID,
    input  logic                    M_AXI_AWREADY,
    
    // Master Interface Write Data
    // AXI3 output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]     M_AXI_WID,
    output logic [128-1:0] 	 M_AXI_WDATA,
    output logic [16-1:0] 	 M_AXI_WSTRB,
    output logic 				 M_AXI_WLAST,
    output logic 				 M_AXI_WVALID,
    input  logic 				 M_AXI_WREADY,
    
    // Master Interface Write Response
    input  logic  [2-1:0] 			 M_AXI_BRESP,
    input  logic  				 M_AXI_BVALID,
    output logic  				 M_AXI_BREADY,
    
    // Master Interface Read Address
    output logic [27-1:0] 	 M_AXI_ARADDR,
    output logic [8-1:0] 			 M_AXI_ARLEN,
    output logic [3-1:0] 			 M_AXI_ARSIZE,
    output logic [2-1:0] 			 M_AXI_ARBURST,
    output logic [2-1:0] 			 M_AXI_ARLOCK,
    output logic [4-1:0] 			 M_AXI_ARCACHE,
    output logic [3-1:0] 			 M_AXI_ARPROT,
    // AXI3 output wire [4-1:0] 		 M_AXI_ARREGION,
    output logic [4-1:0] 			 M_AXI_ARQOS,
    output logic 				 M_AXI_ARVALID,
    input  logic 				 M_AXI_ARREADY,
    
    // Master Interface Read Data 
    input  logic [128-1:0] 	 M_AXI_RDATA,
    input  logic [2-1:0] 			 M_AXI_RRESP,
    input  logic 				 M_AXI_RLAST,
    input  logic 				 M_AXI_RVALID,
    output logic 				 M_AXI_RREADY


    );
    always_ff @( posedge clk ) begin 
        if(rst)begin
            wb_memdata <=0;
        end else begin
            if(n_stall) begin
                wb_memdata <= uart_en ? {24'b0,rd_d} : {5'b0, daddr[24:0], 2'b0}; //for cache!
            end
        end
    end
    //uart
    logic uart_en ;
    assign uart_en = daddr == 30'b0;
    logic dmem_en ;
    assign dmem_en = daddr[29:25] == 5'b00000;


    logic [7:0] rdata;
    logic rvalid;
    logic wr_full;
    logic [7:0] rd_d;
    logic rd_en;
    logic rd_empty;
    uart_rx rx(.clk, .rst, .rxd, .rdata, .rvalid);
    fifo fifo_rx(.clk, .rst, .wr_d(rdata), .wr_en(rvalid),.wr_full(wr_full), .rd_d, .rd_en, .rd_empty(rd_empty));
    assign rd_en = dec_mre & uart_en & ~rd_empty;
    assign rx_valid = ~rd_empty;
    

    logic [7:0] tdata;
    logic tready;
    logic tx_full;
    logic tx_empty;
    uart_tx tx(.clk, .rst, .txd, .tdata, .tvalid(~tx_empty& tready), .tready);
    fifo fifo_tx(.clk, .rst, .wr_d(op2[7:0]), .wr_en(dec_mwe & uart_en & ~tx_full), .wr_full(tx_full), .rd_d(tdata), .rd_en(~tx_empty & tready), .rd_empty(tx_empty));
    assign tx_ready = ~tx_full;



    //cache
        // from cache
    // data and address to write
    logic [127:0] wr_data;
    logic [26:0]  wr_addr;
    logic wr_valid;
    logic wr_ready;

    // reading operation issuing
    logic [26:0]  rd_addr;
    logic rd_avalid;
    logic rd_aready;

    //data read from ddr2
    logic [127:0] rd_data;
    logic rd_valid;
    logic rd_dready;

    ddr_master master(.*);


    `ifndef SET_ASSOC
    (* ram_style = "block" *) logic [31:0] cache [16383:0];
    (* ram_style = "distributed" *) logic [8:0] tag_array [16383:0];
    (* ram_style = "distributed" *) logic valid_array [16383:0];
    logic [8:0] tag;
    logic [13:0] index;
    logic [1:0] offset;
    assign {tag, index, offset} = daddr[24:0];

    logic cache_nstall; // 書き込みによるストール
    logic arrive; // missしてたデータが届いたか
    logic wr_done;
    logic [31:0] data_arrived; // 届いたデータ
    
    integer i;
    initial begin 
        for (i=0; i<16383; i=i+1) begin
            cache[i] = 0;
            tag_array[i] = 0;
            valid_array[i] = 0;
        end
        cache_nstall = 0;
        arrive = 0;
        data_arrived = 0;
    end

    // dram u1(dec_daddr, arrive, data_arrived);
    assign cache_nstall = tag_array[index] == tag && valid_array[index];

    logic [31:0] cache_data;
    always_ff @( posedge clk ) begin 
        cache_data <= cache[index]; // always read data in index

        if(dec_mwe) begin
            if (cache_nstall) begin
                cache[index] <= op2;
            end else begin
                // write to memory
                if(wr_done) begin
                    cache[index] <= op2;
                    tag_array[index] <= tag;
                    valid_array[index] <= 1;
                end
            end
        end

        if(dec_mre)begin
            if(cache_nstall) begin
                // nothing to done
            end else begin
                //read from memory
                if(arrive) begin
                    cache[index] <= data_arrived;
                    tag_array[index] <= tag;
                    valid_array[index] <= 1;
                end
            end
        end
    end

    `else
    // TODO: 2-way set associative
    `endif 
endmodule
