`timescale 1ns / 1ps

module simtop();
    logic clk, rst;
    logic rxd, txd;

    parameter STEP = 50; // clk(#10) * 5

    task uart(input logic [7:0] data);
    begin
    #STEP rxd = 0;
    #STEP rxd = data[0];
    #STEP rxd = data[1];
    #STEP rxd = data[2];
    #STEP rxd = data[3];
    #STEP rxd = data[4];
    #STEP rxd = data[5];
    #STEP rxd = data[6];
    #STEP rxd = data[7];
    #STEP rxd = 1;
    end
    endtask
    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

        logic [7:0] data;
    initial begin
        rxd = 1;
        rst = 1'b1;
        #25 rst = 1'b0;



        #15;
        //repeat(30) begin

uart(8'h04);
uart(8'h04);
uart(8'h0c);
uart(8'h40);
uart(8'h01);
uart(8'h76);
uart(8'h01);
uart(8'h00);
uart(8'h00);
uart(8'h44);
uart(8'h00);
uart(8'h40);
uart(8'h29);
uart(8'h06);
uart(8'hc0);
uart(8'hff);
uart(8'h07);

        //end
                
    end

    top top(.clk, .rst, .rxd, .txd);
endmodule