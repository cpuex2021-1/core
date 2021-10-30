`timescale 1ns / 1ps

module imem_ram(
        input  logic clk,rst,
        input  logic [26:0] pc,
        input  logic [29:0] daddr,
        input  logic [31:0] op2,
        input  logic dec_mwe,
        output logic [31:0] inst

    );

    (*ram_style = "distributed"*) logic [31:0] mem [4095:0];
    int i=0;
    initial begin
        for(i=1024; i<4077; i=i+1)mem[i] = 0;
        $readmemh("inst.mem", mem,0, 1023);
        $readmemh("loader.mem", mem, 4077, 4095);
    end
    assign inst = rst ? 0 : mem[pc[13:2]];
    always_ff @( posedge clk ) begin 
        if(rst) begin
        end else begin
            if (&daddr[29:25] & dec_mwe) begin
                mem[daddr[11:0]] <= op2;
            end
        end
    end

endmodule
