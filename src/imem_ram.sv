`timescale 1ns / 1ps

module imem_ram(
        input   logic clk,rst,
        input   logic [26:0] pc,
        output  logic [31:0] inst
    );

    (*ram_style = "distributed"*) logic [31:0] mem [1023:0];
    initial begin
        $readmemh("inst.mem", mem,0, 1023);
    end
    always_ff @( posedge clk ) begin 
        if(rst) begin
            inst <= 0;
        end else begin
            inst <= mem[pc[11:2]];
        end
    end

endmodule
