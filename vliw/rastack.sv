module rastack(
    input  logic clk,rst,
    input  logic [13:0] pc,
    input  logic push,
    input  logic pop,
    output logic [13:0] ra
);
    localparam stacksize = 9;
    logic [13:0] stack [2**stacksize-1:0];
    logic [stacksize-1:0] sp;
    initial begin 
        int i;
        for(i=0; i<2**stacksize; i=i+1)stack[i] = 0;
    end

    assign ra = stack[sp];
    always_ff @( posedge clk ) begin 
        if(rst) begin
            sp <= 0;
        end else begin
            if(push)sp <= sp+1;
            else if(pop) sp <= sp-1;
        end
    end
endmodule