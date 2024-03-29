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
        input  logic stall,
        input  logic [29:0] daddr3,daddr4,
        input  logic dec_mre3,dec_mre4,
        input  logic dec_mwe3,dec_mwe4,
        input  logic [31:0] op32,op42,
        output logic [31:0] wb_memdata3,wb_memdata4,
        input  logic rxd,
        output logic txd,
        output logic rx_valid,
        output logic tx_ready,
        output logic uart_stall,
        output logic cache_stall,
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
    logic take_uart3, take_uart4;
    logic take_scratch3, take_scratch4;
    always_ff @( posedge clk ) begin 
        if(rst)begin
            //wb_memdata <=0;
            take_uart3 <= 0;
            take_uart4 <= 0;
            take_scratch3 <= 0;
            take_scratch4 <= 0;
        end else begin
            if(~stall)begin
            take_uart3 <= uart_en3;
            take_uart4 <= uart_en4;
            take_scratch3 <= scratch_en3;
            take_scratch4 <= scratch_en4;
            end
//            if(n_stall) begin
//                wb_memdata <= uart_en ? {24'b0,rd_d} : cache_data; //for cache!
//            end
        end
    end
    logic [31:0] scratch_data3, scratch_data4;
    logic scratch_en3, scratch_en4;
    assign scratch_en3 = &daddr3[29:9];
    assign scratch_en4 = &daddr4[29:9];
    logic [8:0] scratch_addr3,scratch_addr4;
    assign scratch_addr3 = daddr3[8:0];
    assign scratch_addr4 = daddr4[8:0];
    // here scratch pad
    scratchpad scratch(
  .clka(clk),    // input wire clka
  .wea(scratch_en3&& dec_mwe3),      // input wire [0 : 0] wea
  .addra(scratch_addr3),  // input wire [8 : 0] addra
  .dina(op32),    // input wire [31 : 0] dina
  .douta(scratch_data3),  // output wire [31 : 0] douta
  .clkb(clk),    // input wire clkb
  .web(scratch_en4 && dec_mwe4),      // input wire [0 : 0] web
  .addrb(scratch_addr4),  // input wire [8 : 0] addrb
  .dinb(op42),    // input wire [31 : 0] dinb
  .doutb(scratch_data4)  // output wire [31 : 0] doutb
);

    assign wb_memdata3 = (take_uart3 ? {24'b0, rd_d} : (take_scratch3 ? scratch_data3 : cache_data3));
    assign wb_memdata4 = (take_uart4 ? {24'b0, rd_d} : (take_scratch4 ? scratch_data4 : cache_data4));


    //uart
    logic uart_en3, uart_en4 ;
    assign uart_en3 = daddr3 == 30'b0;
    assign uart_en4 = daddr4 == 30'b0;
    logic uart_stall3,uart_stall4;
    assign uart_stall3 = (uart_en3 && (dec_mre3 && ~rx_valid || dec_mwe3 && ~tx_ready));
    assign uart_stall4 = (uart_en4 && (dec_mre4 && ~rx_valid || dec_mwe4 && ~tx_ready));
    assign uart_stall = uart_stall3 || uart_stall4;
    logic dmem_en3,dmem_en4 ;
    assign dmem_en3 = daddr3[29:25] == 5'b00000 && ~uart_en3;
    assign dmem_en4 = daddr4[29:25] == 5'b00000 && ~uart_en4;
   logic use3, use4;
    assign use3 = dmem_en3 && (dec_mre3 || dec_mwe3);
    assign use4 = dmem_en4 && (dec_mre4 || dec_mwe4);


    logic [7:0] rdata;
    logic rvalid;
    logic wr_full;
    logic [7:0] rd_d;
    logic rd_en;
    logic rd_empty;
    uart_rx rx(.clk, .rst, .rxd, .rdata, .rvalid);
    fifo fifo_rx(.clk, .rst, .wr_d(rdata), .wr_en(rvalid),.wr_full(wr_full), .rd_d, .rd_en, .rd_empty(rd_empty));
    assign rd_en = ((dec_mre3 & uart_en3) | (dec_mre4 & uart_en4)) & ~rd_empty & ~stall;
    assign rx_valid = ~rd_empty;
    

   logic [7:0] tdata;
   logic tready;
   logic tx_full;
   logic tx_empty;
    uart_tx tx(.clk, .rst, .txd, .tdata, .tvalid(~tx_empty& tready), .tready);
    logic [7:0] wr_d;
    assign wr_d = uart_en3 ? op32[7:0] : op42[7:0];
   logic wr_en;
    assign wr_en = ((dec_mwe3 & uart_en3) | (dec_mwe4 & uart_en4)) & ~tx_full & ~stall;
    fifo fifo_tx(.clk, .rst, .wr_d, .wr_en, .wr_full(tx_full), .rd_d(tdata), .rd_en(~tx_empty & tready), .rd_empty(tx_empty));
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

    (* ram_style = "distributed" *) logic [10:0] tag_array [4095:0];
    (* ram_style = "distributed" *) logic dirty_array [2][4095:0];
    logic [10:0] tag3,tag4;
    logic [11:0] index3, index4;
    logic [1:0] offset3, offset4;
    assign {tag3, index3, offset3} = daddr3[24:0];
    assign {tag4, index4, offset4} = daddr4[24:0];

    
    integer i;
    initial begin 
        for (i=0; i<4096; i=i+1) begin
            tag_array[i] = 0;
            dirty_array[0][i] = 0;
            dirty_array[1][i] = 0;
        end
    end

    // dram u1(dec_daddr, arrive, data_arrived);
    logic hit3_now,hit4_now;
    assign hit3_now = tag_array[index3] == tag3;
    assign hit4_now = tag_array[index4] == tag4;
    logic hit3_past, hit4_past;
    logic hit3,hit4;
    assign hit3 = hit3_now || hit3_past;
    assign hit4 = hit4_now || hit4_past;
    logic cache_stall3, cache_stall4;
    assign cache_stall3 = use3 && ~hit3;
    assign cache_stall4 = use4 && ~hit4;

    logic [31:0] cache_data3, cache_data4;

    logic [1:0] wr_state;  //00 waiting writing operation 01 starting write 10 waiting wr_ready 11 waiting write complete
                            // state で書きなおす
    logic [1:0] rd_state; // 00 waiting 01 starting read 10 waiting rd_aready 11 waiting rd_valid

blk_mem_gen_0 cache(
  .clka(clk),    // input wire clka
  .wea(we3),      // input wire [15 : 0] wea
  .addra(index3),  // input wire [11 : 0] addra
  .dina(din3),    // input wire [127 : 0] dina
  .douta(dout3),  // output wire [127 : 0] douta
  .clkb(clk),    // input wire clkb
  .web(we4),      // input wire [15 : 0] web
  .addrb(index4),  // input wire [11 : 0] addrb
  .dinb(din4),    // input wire [127 : 0] dinb
  .doutb(dout4)  // output wire [127 : 0] doutb
);
// 
    logic [15:0] we3,we4;
    logic [127:0] din3, din4;
    logic [127:0] dout3, dout4;

    
    always_comb begin 
        we3 = 16'h0000;
        we4 = 16'h0000;
        if(daddr3 == daddr4 && dec_mwe3 && dec_mwe4) we3 = 0;
        else if(rd_state == 2'b11 && rd_dready && rd_valid && use3 && ~hit3_now) we3 = 16'hffff; // plus information for 3 or 4 from dram
        else if(use3 && hit3_now && dec_mwe3) begin
            unique case (offset3) 
                2'b00: we3 = 16'h000f;
                2'b01: we3 = 16'h00f0;
                2'b10: we3 = 16'h0f00;
                2'b11: we3 = 16'hf000;
            endcase
        end

        if(rd_state == 2'b11 && rd_dready && rd_valid && use4 && (~use3 || hit3_now) && ~hit4_now) we4 = 16'hffff;
        else if(use4 && hit4_now && dec_mwe4) begin
            unique case (offset4) 
                2'b00: we4 = 16'h000f;
                2'b01: we4 = 16'h00f0;
                2'b10: we4 = 16'h0f00;
                2'b11: we4 = 16'hf000;
            endcase
        end

        if(hit3_now) begin
            unique case(offset3) 
                2'b00 : din3 = {96'b0, op32       };
                2'b01 : din3 = {64'b0, op32, 32'b0};
                2'b10 : din3 = {32'b0, op32, 64'b0};
                2'b11 : din3 = {       op32, 96'b0};
            endcase
        end else begin
            din3 = rd_data;
        end
        if(hit4_now) begin
            unique case(offset4) 
                2'b00 : din4 = {96'b0, op42       };
                2'b01 : din4 = {64'b0, op42, 32'b0};
                2'b10 : din4 = {32'b0, op42, 64'b0};
                2'b11 : din4 = {       op42, 96'b0};
            endcase
        end else begin
            din4 = rd_data;
        end
                    //wr_addr <= {tag_array[index3],index,4'b0000}; //16bytes on a cache line
       
    end
    //output of cache
    always_comb begin 
         case (offset3_reg)
            2'b00: cache_data3 = hit3_reg ? dout3[31 :0]  : cache_hit_data3;
            2'b01: cache_data3 = hit3_reg ? dout3[63 :32] : cache_hit_data3;
            2'b10: cache_data3 = hit3_reg ? dout3[95 :64] : cache_hit_data3;
            2'b11: cache_data3 = hit3_reg ? dout3[127:96] : cache_hit_data3;
        endcase
        case (offset4_reg)
            2'b00: cache_data4 = hit4_reg ? dout4[31 :0]  : cache_hit_data4;
            2'b01: cache_data4 = hit4_reg ? dout4[63 :32] : cache_hit_data4;
            2'b10: cache_data4 = hit4_reg ? dout4[95 :64] : cache_hit_data4;
            2'b11: cache_data4 = hit4_reg ? dout4[127:96] : cache_hit_data4;
        endcase
    end
    logic [10:0] tag;
    logic [11:0] index;
    assign cache_stall = use3&&~hit3_now&&~hit3_past|| use4 && ~hit4_now && ~hit4_past;
    logic [1:0] offset3_reg, offset4_reg;

    logic [31:0] cache_hit_data3,cache_hit_data4;
    logic hit3_reg, hit4_reg;
    logic wr_which;

    always_ff @( posedge clk ) begin  
        if(rst) begin
            wr_state <= 2'b00;
            rd_state <= 2'b00;
            wr_addr <= 0;
            rd_addr <= 0;
            wr_valid <= 0;
            wr_data <= 0;
            wr_which <= 0;
            rd_avalid <= 0;
            rd_dready <= 0;
            offset3_reg <= 0;
            offset4_reg <= 0;
            tag <= 0;
            index <= 0;
            cache_hit_data3 <= 0;
            cache_hit_data4 <= 0;
            hit3_reg <= 0;
            hit4_reg <= 0;
            hit3_past<= 0;
            hit4_past<= 0;
        end else begin
            offset3_reg <= offset3;
            offset4_reg <= offset4;
            if(dmem_en3 && dec_mwe3 && hit3_now) dirty_array[0][index3] <= 1;
            if(dmem_en4 && dec_mwe4 && hit4_now) dirty_array[1][index4] <= 1;
            if(hit3_now) cache_hit_data3 <= cache_data3;
            if(hit4_now) cache_hit_data4 <= cache_data4;
            hit3_reg  <= hit3_now;
            hit4_reg  <= hit4_now;
            hit3_past <= cache_stall ?  hit3_past || hit3_now : 0;
            hit4_past <= cache_stall ?  hit4_past || hit4_now : 0;
            //offset_reg <= daddr[1:0]; //これなんだっけ
            //wr_data <= {cache00[index],cache01[index],cache02[index],cache03[index]};
            //wr_addr <= {tag_array[index3],index,4'b0000}; //16bytes on a cache line
            //rd_addr <= {tag, index,4'b0000};

            // 書き込み　読み込みは並行して行われる感じ
            if(wr_state == 2'b01)begin
               wr_valid <= 1;
               wr_data <= wr_which ? dout4 : dout3;
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
                dirty_array[0][index] <= 0;
                dirty_array[1][index] <= 0;
                rd_state <= 2'b00;
                //read complete
            end else 
 
            if(use3 && ~hit3) begin
                //read from ddr and
                //暫定ライトスルー
                //ライトバックぐらいにはしたいね
                if(wr_state == 2'b00 && rd_state == 2'b00) begin
                    wr_addr <= {tag_array[index3],index3,4'b0000}; //16bytes on a cache line
                    //wr_data <= dout3;
                    wr_which <= 0;
                    rd_addr <= {tag3, index3,4'b0000};
                    tag <= tag3;
                    index <= index3;
                    //if(dirty_array[0][index3] || dirty_array[1][index3]) wr_state <= 2'b01;
                    wr_state <= 2'b01;
                    rd_state <= 2'b01;
                end
            end else if ((~use3 || hit3 ) && use4 && ~hit4 ) begin
                if(wr_state == 2'b00 && rd_state == 2'b00) begin
                    rd_addr <= {tag4, index4,4'b0000};
                    //wr_data <= dout4;
                    wr_which <= 1;
                    wr_addr <= {tag_array[index4],index4,4'b0000}; //16bytes on a cache line
                    tag     <= tag4;
                    index   <= index4;
                    //if(dirty_array[0][index4] || dirty_array[1][index4] || dec_mwe3 && index3==index4 ) wr_state <= 2'b01;
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
