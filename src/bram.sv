module bram 
(
    input logic clk,rst,
    input logic [9:0] addr,
    input logic [31:0] wr_data,
    input logic wen,
    input logic ren,
    output logic [31:0] rd_data
);
    (* ram_style = "block" *) logic [31:0] ram [1023:0];
    integer i;
    initial for(i=0; i<1024; i++)ram[i]=0;

    always_ff @( posedge clk ) begin
        if(rst) begin
            rd_data <= 0;
        end else begin
            if(wen) begin
                ram[addr] <= wr_data;
            end
            if(ren)begin
                rd_data <= ram[addr];
            end
        end
    end
endmodule