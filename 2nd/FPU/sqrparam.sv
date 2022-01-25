module sqrparam(
    input logic clk,rst,
    input logic [9:0] key,
    output logic [35:0] init_grad
);

    initial $readmemh("sqrparam.mem", ram , 0, 1023);
    (* ram_style = "block" *) logic [35:0] ram [1023:0];
    always_ff @( posedge clk ) begin 
        if( rst) begin
            init_grad <= 0;
        end else begin
            init_grad <= ram[key];
        end
        
    end

endmodule