module bram 
(
    input logic clk,rst,
    input logic [9:0] addr,
    input logic [31:0] wr_data,
    input logic wen,
    output logic [31:0] rd_data
);
    (* ram_style = "block" *) logic [31:0] ram [1023:0];
    always_ff @( posedge clk ) begin
        if(wen) begin
            ram[addr] <= wr_data;
        end
        rd_data <= ram[addr];
        
    end
endmodule