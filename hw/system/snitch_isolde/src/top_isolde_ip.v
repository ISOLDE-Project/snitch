
`timescale 1 ns / 1 ps

module top_isolde_ip #(
    // Users to add parameters here
    parameter NrCores = 2,
    // User parameters ends
    // Do not modify the parameters beyond this line

		// Parameters of Axi Master Bus Interface M_AXI_WIDE
		parameter  C_M_AXI_WIDE_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M_AXI_WIDE_BURST_LEN	= 16,
		parameter integer C_M_AXI_WIDE_ID_WIDTH	= 3,
		parameter integer C_M_AXI_WIDE_ADDR_WIDTH	= 48,
		parameter integer C_M_AXI_WIDE_DATA_WIDTH	= 512,
		parameter integer C_M_AXI_WIDE_AWUSER_WIDTH	= 1,
		parameter integer C_M_AXI_WIDE_ARUSER_WIDTH	= 1,
		parameter integer C_M_AXI_WIDE_WUSER_WIDTH	= 1,
		parameter integer C_M_AXI_WIDE_RUSER_WIDTH	= 1,
		parameter integer C_M_AXI_WIDE_BUSER_WIDTH	= 1
  
) (
    // Users to add ports here
    //input  wire                        clk_i,
    //input  wire                        rst_ni,
    input wire [NrCores-1:0] debug_req_i,
    input wire [NrCores-1:0] meip_i,
    input wire [NrCores-1:0] mtip_i,
    input wire [NrCores-1:0] msip_i,

    // User ports ends
    // Do not modify the ports beyond this line
		input wire  m_axi_wide_init_axi_txn,
		output wire  m_axi_wide_txn_done,
		output wire  m_axi_wide_error,
		input wire  m_axi_wide_aclk,
		input wire  m_axi_wide_aresetn,
		output wire [C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_awid,
		output wire [C_M_AXI_WIDE_ADDR_WIDTH-1 : 0] m_axi_wide_awaddr,
		output wire [7 : 0] m_axi_wide_awlen,
		output wire [2 : 0] m_axi_wide_awsize,
		output wire [1 : 0] m_axi_wide_awburst,
		output wire  m_axi_wide_awlock,
		output wire [3 : 0] m_axi_wide_awcache,
		output wire [2 : 0] m_axi_wide_awprot,
		output wire [3 : 0] m_axi_wide_awqos,
		output wire [C_M_AXI_WIDE_AWUSER_WIDTH-1 : 0] m_axi_wide_awuser,
		output wire  m_axi_wide_awvalid,
		input wire  m_axi_wide_awready,
		output wire [C_M_AXI_WIDE_DATA_WIDTH-1 : 0] m_axi_wide_wdata,
		output wire [C_M_AXI_WIDE_DATA_WIDTH/8-1 : 0] m_axi_wide_wstrb,
		output wire  m_axi_wide_wlast,
		output wire [C_M_AXI_WIDE_WUSER_WIDTH-1 : 0] m_axi_wide_wuser,
		output wire  m_axi_wide_wvalid,
		input wire  m_axi_wide_wready,
		input wire [C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_bid,
		input wire [1 : 0] m_axi_wide_bresp,
		input wire [C_M_AXI_WIDE_BUSER_WIDTH-1 : 0] m_axi_wide_buser,
		input wire  m_axi_wide_bvalid,
		output wire  m_axi_wide_bready,
		output wire [C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_arid,
		output wire [C_M_AXI_WIDE_ADDR_WIDTH-1 : 0] m_axi_wide_araddr,
		output wire [7 : 0] m_axi_wide_arlen,
		output wire [2 : 0] m_axi_wide_arsize,
		output wire [1 : 0] m_axi_wide_arburst,
		output wire  m_axi_wide_arlock,
		output wire [3 : 0] m_axi_wide_arcache,
		output wire [2 : 0] m_axi_wide_arprot,
		output wire [3 : 0] m_axi_wide_arqos,
		output wire [C_M_AXI_WIDE_ARUSER_WIDTH-1 : 0] m_axi_wide_aruser,
		output wire  m_axi_wide_arvalid,
		input wire  m_axi_wide_arready,
		input wire [C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_rid,
		input wire [C_M_AXI_WIDE_DATA_WIDTH-1 : 0] m_axi_wide_rdata,
		input wire [1 : 0] m_axi_wide_rresp,
		input wire  m_axi_wide_rlast,
		input wire [C_M_AXI_WIDE_RUSER_WIDTH-1 : 0] m_axi_wide_ruser,
		input wire  m_axi_wide_rvalid,
		output wire  m_axi_wide_rready

);

  // Add user logic here
  snitch_cluster_wrapper(
      .clk_i(m_axi_wide_aclk),
      .rst_ni(m_axi_wide_aresetn),
      .debug_req_i(debug_req_i),
      .meip_i(meip_i),
      .mtip_i(mtip_i),
      .msip_i(msip_i),
      .aw({
      	m_axi_wide_awid,
		m_axi_wide_awaddr,
		m_axi_wide_awlen,
		m_axi_wide_awsize,
		m_axi_wide_awburst,
		m_axi_wide_awlock,
		m_axi_wide_awcache,
		m_axi_wide_awprot,
		m_axi_wide_awqos,
		10'b0,
		m_axi_wide_awuser
      })
     
      //.axi_awaddr(M_AXI_AWADDR)
      //.wide_out_req_o(aw_chan_tmp),
      //.wide_out_resp_i(0),
      //.wide_in_req_i(0)
      //.wide_in_resp_o(0)
  );


  // User logic ends

endmodule
