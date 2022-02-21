module ifetch(
    input logic clk,rst,stall,flush,dec_stall,
    input logic [13:0] npc,
    input logic npc_enn,

    output logic [127:0] inst,

    input logic [31:0] dec_op32,
    input logic [29:0] daddr3,
    input logic dec_mwe3,
    output logic [13:0] pc_led

);
    localparam DATA_WIDTH = 32;
assign pc_led = pc;
    (*ram_style = "block"*) logic [127:0] mem [16383:0];
/*blk_mem_gen_1 imem(
  .clka(clk),    // input wire clka
  .ena(~stall),
  .wea(daddr3[29:25] == 5'b11110 & dec_mwe3),      // input wire [0 : 0] wea
  .addra({daddr3[15:2], ~daddr3[1:0]}),  // input wire [15 : 0] addra
  .dina(dec_op32),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(~stall),
  .addrb(naddr),  // input wire [13 : 0] addrb
  .doutb(inst)  // output wire [127 : 0] doutb
);*/
    int i=0;
    initial begin
        for(i=0; i<16384; i=i+1)mem[i] = 0;
        //$readmemh("inst.mem", mem,0, 12000);
        $readmemh("loader.mem", mem, 16353, 16383); //check pc
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
    rastack ras(.clk, .rst,.stall(stall||dec_stall), .npc(pc), .push, .ra, .pop);
    logic [13:0] pcp1;
    logic [13:0] addr;
    assign addr = inst1[19:6];
    assign pcp1 = pc+1;
    logic jabs, jreg;
    assign jabs = op==3'b111 && {funct[2], funct[0]} == 2'b00;
    assign jreg = op==3'b111 && {funct[2], funct[0]} == 2'b01;

    logic [13:0] iaddr;
    assign iaddr = daddr3[15:2];

    logic we[4];
    assign we[0] = offset == 2'b11;
    assign we[1] = offset == 2'b10;
    assign we[2] = offset == 2'b01;
    assign we[3] = offset == 2'b00;
    /*logic [13:0] naddr;
    always_comb begin if(npc_enn)    naddr = npc;
        else if (jabs) naddr = npc;
        else if (pop)  naddr = ra;
        else           naddr = pc;
    end*/

    logic [13:0] memaddr;
    logic [13:0] n_pc;
    always_comb begin
        memaddr = pc;
        n_pc = pc;
            if(npc_enn)begin
                memaddr = npc;
                n_pc = npc+1;
            end else if(~dec_stall) begin
                if(jabs) begin
                    memaddr = addr;
                    n_pc = addr+1;
                end else if (pop) begin
                    memaddr = ra;
                    n_pc = ra+1;
                end else begin
                    n_pc = pc+1;
                end
            end
    end

    always_ff @( posedge clk ) begin 
        if(rst ) begin
            inst <= 0;
            pc <= 16351;
            //pc <= -1;
        end else begin
            /*if(~stall) begin
                inst <= mem[memaddr];
                pc <= n_pc;
                if (daddr3[29:25] == 5'b11110 & dec_mwe3) begin
                        if(we[3])mem[iaddr][DATA_WIDTH*4-1:DATA_WIDTH*3] <= dec_op32;
                        if(we[2])mem[iaddr][DATA_WIDTH*3-1:DATA_WIDTH*2] <= dec_op32;
                        if(we[1])mem[iaddr][DATA_WIDTH*2-1:DATA_WIDTH*1] <= dec_op32;
                        if(we[0])mem[iaddr][DATA_WIDTH*1-1:DATA_WIDTH*0] <= dec_op32;
                end

            end */
            if(~stall && (npc_enn || ~dec_stall)) begin
                if(npc_enn) begin
                    inst <= mem[npc];
                    pc <= npc+1;
                end else if(jabs && ~dec_stall)begin
                    inst <= mem[addr];
                    pc <= addr+1;
                end else if (pop && ~dec_stall) begin
                    inst <= mem[ra];
                    pc <= ra+1;
                end else begin
                    inst <= mem[pc];
                    pc <= pcp1;
                end 
                // boot loaderは後で考える。
                if (daddr3[29:25] == 5'b11110 & dec_mwe3) begin
                    if(we[3])mem[iaddr][DATA_WIDTH*4-1:DATA_WIDTH*3] <= dec_op32;
                    if(we[2])mem[iaddr][DATA_WIDTH*3-1:DATA_WIDTH*2] <= dec_op32;
                    if(we[1])mem[iaddr][DATA_WIDTH*2-1:DATA_WIDTH*1] <= dec_op32;
                    if(we[0])mem[iaddr][DATA_WIDTH*1-1:DATA_WIDTH*0] <= dec_op32;
                end
            end
        end
    end


endmodule