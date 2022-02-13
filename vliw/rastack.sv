module rastack(
    input  logic clk,rst,stall,
    input  logic [13:0] npc,
    input  logic push,
    input  logic pop,
    output logic [13:0] ra
);
    localparam stacksize = 9;
    logic [13:0] stack [2**9-1:0];
    logic [9-1:0] sp;
    initial begin 
        int i;
        for(i=0; i<2**stacksize; i=i+1)stack[i] = 0;
    end
    logic [8:0] sp1;
    assign sp1 = sp+9'b1;

    assign ra = stack[sp];
    always_ff @( posedge clk ) begin 
        if(rst) begin
            sp <= -1;
        end else begin
            if(~stall)begin
                if(push)stack[sp1] <= npc;
                if(push)sp <= sp1;
                else if(pop) sp <= sp-1;
            end
        end
    end
endmodule