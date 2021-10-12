`timescale 1ns / 1ps

`define ADDR_LEN 25
`define TAG_LEN 9
`define INDEX_LEN 14
`define OFFSET_LEN 2

// `define SET_ASSOC

module dmem_ram(
        input  logic clk,rst,
        input  logic [24:0] daddr,
        input  logic mwe,
        input  logic [31:0] res,
        output logic [31:0] memdata
    );

    `ifndef SET_ASSOC
    (* ram_style = "distributed" *) logic [31:0] cache [16383:0];
    (* ram_style = "distributed" *) logic [8:0] tag_array [16383:0];
    (* ram_style = "distributed" *) logic valid_array [16383:0];
    logic [8:0] tag;
    logic [13:0] index;
    logic [1:0] offset;
    assign {tag, index, offset} = daddr;

    logic stall; // outputする
    logic arrive; // missしてたデータが届いたか
    logic [31:0] data_arrived; // 届いたデータ
    
    integer i;
    initial begin 
        for (i=0; i<16383; i=i+1) begin
            cache[i] = 0;
            tag_array[i] = 0;
            valid_array[i] = 0;
        end
        stall = 0;
        arrive = 0;
        data_arrived = 0;
    end

    // dram u1(daddr, arrive, data_arrived);

    always_ff @( posedge clk ) begin 
        if(mwe) begin
            if (tag_array[index] == tag && valid_array[index]) begin
                cache[index] <= res;
            end else begin
                stall <= 1;
            end
        end
        if (arrive) begin 
            if (mwe) begin 
                cache[index] <= data_arrived;
            end 
            stall <= 0;
        end
    end

    assign memdata = cache[index];
    `else
    // TODO: 2-way set associative
    `endif 
endmodule
