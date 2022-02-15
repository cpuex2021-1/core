module ifetch(
    input logic clk,rst,stall,flush,
    input logic [13:0] npc,
    input logic npc_enn,

    output logic [127:0] inst,

    input logic [31:0] dec_op32,
    input logic [29:0] daddr3,
    input logic dec_mwe3

);
    (*ram_style = "block"*) logic [127:0] mem [16383:0];
    int i=0;
    initial begin
        for(i=0; i<16359; i=i+1)mem[i] = 0;
        $readmemh("inst.mem", mem,0, 12000);
        //$readmemh("loader.mem", mem, 16346, 16383); //check pc
    end

    logic [13:0] pc;

    logic [1:0] offset;
    assign offset = daddr3[1:0];
    logic [31:0] inst1;
    assign inst1 = inst[127:96];
    logic [2:0] op,funct;
    assign op = inst1[2:0]; // [2:0]
    assign funct = inst1[5:3]; //[5:3]
    logic push;
    assign push = op == 3'b111 && funct[2:1] == 2'b01&& ~npc_enn;
    logic [13:0] ra;
    logic pop;
    assign pop = inst1[5:0] == 6'b100111 && ~npc_enn;
    rastack ras(.clk, .rst,.stall, .npc(pc), .push, .ra, .pop);
    logic [13:0] pcp1;
    logic [13:0] addr;
    assign addr = inst1[19:6];
    assign pcp1 = pc+1;
    logic jabs, jreg;
    assign jabs = op==3'b111 && {funct[2], funct[0]} == 2'b00;
    assign jreg = op==3'b111 && {funct[2], funct[0]} == 2'b01;


    always_ff @( posedge clk ) begin 
        if(rst ) begin
            inst <= 0;
            pc <= 0;
        /*end else if (flush)begin
            inst <= 0;*/
        end else begin
            if(~stall) begin
                if(npc_enn) begin
                    inst <= mem[npc];
                    pc <= npc+1;
                end else if(jabs) begin
                    inst <= mem[addr];
                    pc <= addr+1;
                end else if (pop) begin
                    inst <= mem[ra];
                    pc <= ra+1;
                end else begin
                    inst <= mem[pc];
                    pc <= pcp1;
                end
                // boot loaderは後で考える。
                if (daddr3[29:25] == 5'b11110 & dec_mwe3) begin
                    if(offset == 2'b00)mem[daddr3[15:2]][31:0] <= dec_op32;
                    if(offset == 2'b01)mem[daddr3[15:2]][63:32] <= dec_op32;
                    if(offset == 2'b10)mem[daddr3[15:2]][95:64] <= dec_op32;
                    if(offset == 2'b11)mem[daddr3[15:2]][127:96] <= dec_op32;
                    
                end
            end
        end
    end


endmodule