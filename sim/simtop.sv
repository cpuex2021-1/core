`timescale 1ns / 1ps
import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;
module simtop();
    logic clk, rst;
    wire [15:0] LED;

    
    always  begin
        clk = 1'b1;
        #5 clk = 1'b0;
        #5;
    end

    initial begin
        rst = 1'b1;
        #25 rst = 1'b0;
        #1000 $finish;

    end

    design_1_wrapper design_1_wrapper(.clk(clk), .rst(rst), .LED(LED));
    design_1_axi_vip_0_0_slv_mem_t agent;
    initial begin
        agent = new("AXI Slave Agent", dut.design_1_i.axi_vip_0.inst.IF);
        agent.start_slave();
    end
endmodule