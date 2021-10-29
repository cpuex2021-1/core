module ddr_master 
  
   (
    // System Signals
    input logic clk,rst,
    
    // Master Interface Write Address
    output logic  [27-1:0]      M_AXI_AWADDR,
    output logic  [8-1:0] 			 M_AXI_AWLEN,
    output logic  [3-1:0] 			 M_AXI_AWSIZE,
    output logic  [2-1:0] 			 M_AXI_AWBURST,
    output logic  				 M_AXI_AWLOCK,
    output logic  [4-1:0] 			 M_AXI_AWCACHE,
    output logic  [3-1:0] 			 M_AXI_AWPROT,
    // AXI3 output wire [4-1:0]                  M_AXI_AWREGION,
    output logic [4-1:0] 			 M_AXI_AWQOS,
    output logic                    M_AXI_AWVALID,
    input  logic                    M_AXI_AWREADY,
    
    // Master Interface Write Data
    // AXI3 output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]     M_AXI_WID,
    output logic [128-1:0] 	 M_AXI_WDATA,
    output logic [16-1:0] 	 M_AXI_WSTRB,
    output logic 				 M_AXI_WLAST,
    output logic 				 M_AXI_WVALID,
    input  logic 				 M_AXI_WREADY,
    
    // Master Interface Write Response
    input  logic  [2-1:0] 			 M_AXI_BRESP,
    input  logic  				 M_AXI_BVALID,
    output logic  				 M_AXI_BREADY,
    
    // Master Interface Read Address
    output logic [27-1:0] 	 M_AXI_ARADDR,
    output logic [8-1:0] 			 M_AXI_ARLEN,
    output logic [3-1:0] 			 M_AXI_ARSIZE,
    output logic [2-1:0] 			 M_AXI_ARBURST,
    output logic [2-1:0] 			 M_AXI_ARLOCK,
    output logic [4-1:0] 			 M_AXI_ARCACHE,
    output logic [3-1:0] 			 M_AXI_ARPROT,
    // AXI3 output wire [4-1:0] 		 M_AXI_ARREGION,
    output logic [4-1:0] 			 M_AXI_ARQOS,
    output logic 				 M_AXI_ARVALID,
    input  logic 				 M_AXI_ARREADY,
    
    // Master Interface Read Data 
    input  logic [128-1:0] 	 M_AXI_RDATA,
    input  logic [2-1:0] 			 M_AXI_RRESP,
    input  logic 				 M_AXI_RLAST,
    input  logic 				 M_AXI_RVALID,
    output logic 				 M_AXI_RREADY,

    // from cache
    // data and address to write
    input  logic [127:0] wr_data,
    input  logic [26:0]  wr_addr,
    input  logic wr_valid,
    output logic wr_ready,

    // reading operation issuing
    input  logic [26:0]  rd_addr,
    input  logic rd_avalid,
    output logic rd_aready,

    //data read from ddr2
    output logic [127:0] rd_data,
    output logic rd_valid,
    input  logic rd_dready

    ); 



    //fixed valued wires
    assign M_AXI_AWLEN   = 8'b0; // no burst
    assign M_AXI_AWSIZE  = 3'b100; // 128bits 
    assign M_AXI_AWBURST = 2'b01; // increment addr when burst (使わんけど)
    assign M_AXI_AWLOCK  = 0;
    assign M_AXI_AWCACHE = 4'b0011;
    assign M_AXI_AWPROT  = 3'b0;
    assign M_AXI_AWQOS   = 4'b0;

    assign M_AXI_WSTRB = 16'hffff;

    assign M_AXI_ARLEN = 8'b0;
    assign M_AXI_ARSIZE  = 3'b100; // 128bits 
    assign M_AXI_ARBURST = 2'b01; // increment addr when burst (使わんけど)
    assign M_AXI_ARLOCK  = 0;
    assign M_AXI_ARCACHE = 4'b0011;
    assign M_AXI_ARPROT  = 3'b0;
    assign M_AXI_ARQOS   = 4'b0;

    // wire to use

    // write address
    // awaddr awvalid awready

    // write data
    // wdata wlast wvalid wready

    // write response
    // bresp bvalid bready

    // read address
    // araddr arvalid arready

    // read data
    // rdata rresp rlast rvalid rready



   
    
     always_ff @(posedge clk) begin
        if (~rst) begin
            wr_ready <= 1'b1;
            rd_aready <= 1'b1;
            rd_data <= 128'b0;
            rd_valid <= 1'b0;
            M_AXI_AWADDR <= 27'b0;
            M_AXI_AWVALID <= 1'b0;
            M_AXI_WVALID <= 1'b0;
            M_AXI_WDATA <= 128'b0;
            M_AXI_WLAST <= 1'b0;
            M_AXI_BREADY <= 1'b0;
            M_AXI_ARADDR <= 27'b0;
            M_AXI_ARVALID <= 1'b0;
            M_AXI_RREADY <= 1'b0;
        end else begin
            //write
             if (wr_valid & wr_ready) begin
                wr_ready <= 0;
                M_AXI_AWADDR <= wr_addr;
                M_AXI_AWVALID <= 1;
            end else
            if(M_AXI_AWVALID && M_AXI_AWREADY)begin
                M_AXI_AWVALID <= 0;
                M_AXI_WVALID <= 1;
                M_AXI_WDATA <= wr_data;
                M_AXI_WLAST <= 1;
            end else
            if(M_AXI_WVALID && M_AXI_WREADY)begin
                M_AXI_WVALID <= 0;
                M_AXI_WLAST  <= 0;
                M_AXI_BREADY <= 1;
            end else
            if(M_AXI_BREADY && M_AXI_BVALID) begin
                M_AXI_BREADY <= 0;
                wr_ready <= 1;
            end
            
            //read
            if (rd_avalid && rd_aready) begin
                rd_aready <= 0;
                M_AXI_ARADDR <= rd_addr;
                M_AXI_ARVALID <= 1;
            end
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin
                M_AXI_ARVALID <= 0;
                M_AXI_RREADY <=  1;
            end
            if(M_AXI_RREADY && M_AXI_RVALID) begin
                rd_data <= M_AXI_RDATA;
                rd_valid <= 1;
            end
            if(rd_valid && rd_dready)begin
                rd_valid <= 0;
                rd_aready <= 1;
            end
        end
    end

endmodule