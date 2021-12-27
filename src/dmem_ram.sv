`timescale 1ns / 1ps

`define ADDR_LEN 25
`define TAG_LEN 11
`define INDEX_LEN 12
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
        output logic tx_ready,
        output logic uart_nstall,
        output logic cache_nstall,
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
    logic take_uart;
    always_ff @( posedge clk ) begin 
        if(rst)begin
            //wb_memdata <=0;
            take_uart <= 0;
        end else begin
            if(n_stall)begin
            take_uart <= uart_en;
            end
//            if(n_stall) begin
//                wb_memdata <= uart_en ? {24'b0,rd_d} : cache_data; //for cache!
//            end
        end
    end

    assign wb_memdata = (take_uart ? {24'b0, rd_d} : cache_data);


    //uart
    assign uart_nstall = ~(uart_en && (dec_mre && ~rx_valid || dec_mwe && ~tx_ready));
    logic uart_en ;
    assign uart_en = daddr == 30'b0;
    logic dmem_en ;
    assign dmem_en = daddr[29:25] == 5'b00000 && ~uart_en;


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
    logic [26:0]  rd_addr; // always {daddr[22:0] ,4'b0000}
    logic rd_avalid;
    logic rd_aready;

    //data read from ddr2
    logic [127:0] rd_data;
    logic rd_valid;
    logic rd_dready;

    ddr_master master(.*);


    `ifndef SET_ASSOC
    //(* ram_style = "block" *) logic [31:0] cache00 [1023:0];
    //(* ram_style = "block" *) logic [31:0] cache01 [1023:0];
    //(* ram_style = "block" *) logic [31:0] cache02 [1023:0];
    //(* ram_style = "block" *) logic [31:0] cache03 [1023:0];

    (* ram_style = "distributed" *) logic [12:0] tag_array [1023:0];
    (* ram_style = "distributed" *) logic valid_array [1023:0];
    logic [12:0] tag;
    logic [9:0] index;
    logic [1:0] offset;
    assign {tag, index, offset} = daddr[24:0];

    logic arrive; // missしてたデータが届いたか
    logic [31:0] data_arrived; // 届いたデータ
    
    integer i;
    initial begin 
        for (i=0; i<1024; i=i+1) begin
            tag_array[i] = 0;
            valid_array[i] = 0;
        end
        arrive = 0;
        data_arrived = 0;
    end

    // dram u1(dec_daddr, arrive, data_arrived);
    logic hit;
    assign hit = tag_array[index] == tag && valid_array[index];
    assign cache_nstall = ~dmem_en || ~(dec_mre || dec_mwe) || hit;

    logic [31:0] cache_data;

    logic [1:0] wr_state;  //00 waiting writing operation 01 starting write 10 waiting wr_ready 11 waiting write complete
                            // state で書きなおす
    logic [1:0] rd_state; // 00 waiting 01 starting read 10 waiting rd_aready 11 waiting rd_valid

    logic [31:0] c00,c01,c02,c03;
    assign wr_data = {c03, c02, c01, c00};
    bram bram0(.clk, .rst, .addr(index), .wen(wen[0]), .wr_data(bram_wr_data[0]), .rd_data(c00));
    bram bram1(.clk, .rst, .addr(index), .wen(wen[1]), .wr_data(bram_wr_data[1]), .rd_data(c01));
    bram bram2(.clk, .rst, .addr(index), .wen(wen[2]), .wr_data(bram_wr_data[2]), .rd_data(c02));
    bram bram3(.clk, .rst, .addr(index), .wen(wen[3]), .wr_data(bram_wr_data[3]), .rd_data(c03));
    logic wen[4];
    logic [31:0] bram_wr_data [4];
    logic [1:0] offset_reg;
    always_comb begin 
        wen[0] = (rd_state == 2'b11 && rd_dready && rd_valid) || (dec_mwe && hit && offset==2'b00);
        wen[1] = (rd_state == 2'b11 && rd_dready && rd_valid) || (dec_mwe && hit && offset==2'b01);
        wen[2] = (rd_state == 2'b11 && rd_dready && rd_valid) || (dec_mwe && hit && offset==2'b10);
        wen[3] = (rd_state == 2'b11 && rd_dready && rd_valid) || (dec_mwe && hit && offset==2'b11);
        bram_wr_data[0] = dec_mwe && offset == 2'b00 ?  op2 : rd_data[0+:32] ;
        bram_wr_data[1] = dec_mwe && offset == 2'b01 ?  op2 : rd_data[32+:32] ;
        bram_wr_data[2] = dec_mwe && offset == 2'b10 ?  op2 : rd_data[64+:32] ;
        bram_wr_data[3] = dec_mwe && offset == 2'b11 ?  op2 : rd_data[96+:32] ;
        case (offset_reg)
            2'b00: cache_data = c00;
            2'b01: cache_data = c01;
            2'b10: cache_data = c02;
            2'b11: cache_data = c03;
        endcase
    end
    always_ff @( posedge clk ) begin  
        if(rst) begin
            wr_state <= 2'b00;
            rd_state <= 2'b00;
            wr_addr <= 0;
            rd_addr <= 0;
            wr_valid <= 0;
            rd_avalid <= 0;
            rd_dready <= 0;
            offset_reg <= 0;
        end else begin
            offset_reg <= daddr[1:0];
            //wr_data <= {cache00[index],cache01[index],cache02[index],cache03[index]};
            wr_addr <= {tag_array[index],index,4'b0000}; //16bytes on a cache line
            rd_addr <= {tag, index,4'b0000};

            // 書き込み　読み込みは並行して行われる感じ
            if(wr_state == 2'b01)begin
               wr_valid <= 1;
               wr_state <= 2'b10;
             end 
            if(wr_state == 2'b10 && wr_valid && wr_ready) begin
                wr_valid <= 0;
                wr_state <= 2'b11;
            end 
            if(wr_state == 2'b11 && wr_ready) begin
                wr_state <= 2'b00;
                // writing complete
            end
           
            if(rd_state == 2'b01)begin
                rd_state <= 2'b10;
                rd_avalid <= 1;
            end  
            if(rd_state == 2'b10 && rd_avalid && rd_aready) begin
                rd_avalid <= 0;
                rd_state <= 2'b11;
                rd_dready <= 1;
            end 
            if(rd_state == 2'b11 && rd_dready && rd_valid) begin
                rd_dready <= 0;
                tag_array[index] <= tag;
                valid_array[index] <= 1;
                rd_state <= 2'b00;
                //read complete
            end else 
 
            if((dec_mwe || dec_mre) && ~hit) begin
                //read from ddr and
                //暫定ライトスルー
                //ライトバックぐらいにはしたいね
                if(wr_state == 2'b00 && rd_state == 2'b00) begin
                    wr_state <= 2'b01;
                    rd_state <= 2'b01;
                end
            end
        end
    end

    `else
    // TODO: 2-way set associative
        
    `endif 
endmodule
