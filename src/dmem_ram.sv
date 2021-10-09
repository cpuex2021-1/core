`timescale 1ns / 1ps


module dmem_ram(
        input  logic clk,rst,
        input  logic [24:0] daddr,
        input  logic mwe,
        input  logic [31:0] res,
        output logic [31:0] memdata
    );

    (* ram_style = "distributed" *) logic [31:0] mem [1023:0];
    integer i;
    initial for (i=0; i<1023; i=i+1) mem[i] = 0;

    always_ff @( posedge clk ) begin 
        if(mwe) begin
            mem[daddr[11:2]] <= res;
        end
    end
    assign memdata = mem[daddr[11:2]];
endmodule
