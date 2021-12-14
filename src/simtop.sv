`timescale 1ns / 1ps
//import axi_vip_pkg::*;
//import design_2_axi_vip_0_0_pkg::*;


module simtop();
    logic clk, rst;
    logic rxd, txd;
    logic [15:0] LED;
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
        clk = 1'b0;
        #5 clk = 1'b1;
        #5;
    end

        logic [7:0] data;
    initial begin
        rxd = 1;
        rst = 1'b0;
        #13 rst = 1'b1;        
        //repeat(30) 
        #500;
        uart(3);
        #10 uart(1);
        #10 uart(2);
        #10 uart(3);
        

        //end
                
    end

    design_2_wrapper dut(.sys_clock (clk), .reset (rst), .rxd(rxd), .txd(txd), .LED);
    //design_2_axi_vip_0_0_slv_mem_t agent;
  //  initial begin
  //      agent = new("AXI Slave Agent", dut.design_2_i.axi_vip_0.inst.IF);
   //     agent.start_slave();
  //  end
endmodule