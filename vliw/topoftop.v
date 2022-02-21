`timescale 1ns / 1ps
module topoftop(
    input  wire clk, rst,
    input  wire rxd,
    output wire txd,
    output wire [13:0] pc,
    output wire  [27-1:0]      M_AXI_AWADDR,
    output wire  [8-1:0] 			 M_AXI_AWLEN,
    output wire  [3-1:0] 			 M_AXI_AWSIZE,
    output wire  [2-1:0] 			 M_AXI_AWBURST,
    output wire  				 M_AXI_AWLOCK,
    output wire  [4-1:0] 			 M_AXI_AWCACHE,
    output wire  [3-1:0] 			 M_AXI_AWPROT,
    output wire [4-1:0] 			 M_AXI_AWQOS,
    output wire                    M_AXI_AWVALID,
    input  wire                    M_AXI_AWREADY,
    
    output wire  [128-1:0] 	 M_AXI_WDATA,
    output wire  [16-1:0] 	 M_AXI_WSTRB,
    output wire  				 M_AXI_WLAST,
    output wire  				 M_AXI_WVALID,
    input  wire  				 M_AXI_WREADY,
    
    // Master Interface Write Response
    input  wire   [2-1:0] 			 M_AXI_BRESP,
    input  wire   				 M_AXI_BVALID,
    output wire   				 M_AXI_BREADY,
    
    // Master Interface Read Address
    output wire  [27-1:0] 	 M_AXI_ARADDR,
    output wire  [8-1:0] 			 M_AXI_ARLEN,
    output wire  [3-1:0] 			 M_AXI_ARSIZE,
    output wire  [2-1:0] 			 M_AXI_ARBURST,
    output wire  [2-1:0] 			 M_AXI_ARLOCK,
    output wire  [4-1:0] 			 M_AXI_ARCACHE,
    output wire  [3-1:0] 			 M_AXI_ARPROT,
    output wire  [4-1:0] 			 M_AXI_ARQOS,
    output wire  				 M_AXI_ARVALID,
    input  wire  				 M_AXI_ARREADY,
    
    // Master Interface Read Data 
    input  wire  [128-1:0] 	 M_AXI_RDATA,
    input  wire  [2-1:0] 			 M_AXI_RRESP,
    input  wire  				 M_AXI_RLAST,
    input  wire  				 M_AXI_RVALID,
    output wire  				 M_AXI_RREADY
 
);
    top to(.clk(clk), .rst(rst),  .rxd(rxd), .txd(txd), .pc_(pc),
                        .M_AXI_AWADDR(M_AXI_AWADDR), .M_AXI_AWLEN(M_AXI_AWLEN), .M_AXI_AWSIZE(M_AXI_AWSIZE), .M_AXI_AWBURST(M_AXI_AWBURST),
                        .M_AXI_AWLOCK(M_AXI_AWLOCK), .M_AXI_AWCACHE(M_AXI_AWCACHE), .M_AXI_AWPROT(M_AXI_AWPROT ), .M_AXI_AWQOS(M_AXI_AWQOS ), .M_AXI_AWVALID(M_AXI_AWVALID),
                        .M_AXI_AWREADY(M_AXI_AWREADY ), .M_AXI_WDATA(M_AXI_WDATA), .M_AXI_WSTRB(M_AXI_WSTRB), .M_AXI_WLAST(M_AXI_WLAST), .M_AXI_WREADY(M_AXI_WREADY ),.M_AXI_WVALID(M_AXI_WVALID),
                        .M_AXI_BRESP (M_AXI_BRESP), .M_AXI_BVALID(M_AXI_BVALID), .M_AXI_BREADY(M_AXI_BREADY), .M_AXI_ARADDR(M_AXI_ARADDR), .M_AXI_ARLEN(M_AXI_ARLEN), 
                        .M_AXI_ARSIZE(M_AXI_ARSIZE), .M_AXI_ARBURST(M_AXI_ARBURST),
                        .M_AXI_ARLOCK(M_AXI_ARLOCK), .M_AXI_ARCACHE(M_AXI_ARCACHE), .M_AXI_ARPROT(M_AXI_ARPROT ), .M_AXI_ARQOS(M_AXI_ARQOS ), .M_AXI_ARVALID(M_AXI_ARVALID),
                        .M_AXI_ARREADY(M_AXI_ARREADY ), 
                        .M_AXI_RDATA(M_AXI_RDATA), .M_AXI_RRESP(M_AXI_RRESP), .M_AXI_RLAST(M_AXI_RLAST), .M_AXI_RVALID(M_AXI_RVALID), .M_AXI_RREADY(M_AXI_RREADY));

endmodule