// Copyleft
// top file for xilinix ip
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

${disclaimer}
module top_isolde_ip #(
    // **** snitch cluster config
    parameter integer NrDmaMasters = 2 + ${cfg['nr_hives']},
    // ****
		// Parameters of Axi Master Bus Interface M_AXI_WIDE
		parameter integer C_M_AXI_WIDE_ID_WIDTH	   = $clog2(NrDmaMasters) + ${cfg['dma_id_width_in']},
		parameter integer C_M_AXI_WIDE_ADDR_WIDTH	  = ${cfg['addr_width']},
		parameter integer C_M_AXI_WIDE_DATA_WIDTH	  = ${cfg['dma_data_width']},
		parameter integer C_M_AXI_WIDE_AWUSER_WIDTH	= ${cfg['dma_user_width']},
		parameter integer C_M_AXI_WIDE_ARUSER_WIDTH	= ${cfg['dma_user_width']},
		parameter integer C_M_AXI_WIDE_WUSER_WIDTH	= ${cfg['dma_user_width']},
		parameter integer C_M_AXI_WIDE_RUSER_WIDTH	= ${cfg['dma_user_width']},
		parameter integer C_M_AXI_WIDE_BUSER_WIDTH	= ${cfg['dma_user_width']}
) (
//********* M_AXI_WIDE
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
//*********************
);
 // Add user logic here
  snitch_cluster_wrapper ip_cluster(
	.m_axi_wide_error(m_axi_wide_error),
	.m_axi_wide_aclk(m_axi_wide_aclk),
	.m_axi_wide_aresetn(m_axi_wide_aresetn),
	.m_axi_wide_awid(m_axi_wide_awid),
	.m_axi_wide_awaddr(m_axi_wide_awaddr),
	.m_axi_wide_awlen(m_axi_wide_awlen),
	.m_axi_wide_awsize(m_axi_wide_awsize),
	.m_axi_wide_awburst(m_axi_wide_awburst),
	.m_axi_wide_awlock(m_axi_wide_awlock),
	.m_axi_wide_awcache(m_axi_wide_awcache),
	.m_axi_wide_awprot(m_axi_wide_awprot),
	.m_axi_wide_awqos(m_axi_wide_awqos),
	.m_axi_wide_awuser(m_axi_wide_awuser),
	.m_axi_wide_awvalid(m_axi_wide_awvalid),
	.m_axi_wide_awready(m_axi_wide_awready),
	.m_axi_wide_wdata(m_axi_wide_wdata),
	.m_axi_wide_wstrb(m_axi_wide_wstrb),		
	.m_axi_wide_wlast(m_axi_wide_wlast),
	.m_axi_wide_wuser(m_axi_wide_wuser),
	.m_axi_wide_wvalid(m_axi_wide_wvalid),
	.m_axi_wide_wready(m_axi_wide_wready),
	.m_axi_wide_bid(m_axi_wide_bid),
	.m_axi_wide_bresp(m_axi_wide_bresp),
	.m_axi_wide_buser(m_axi_wide_buser),
	.m_axi_wide_bvalid(m_axi_wide_bvalid),
	.m_axi_wide_bready(m_axi_wide_bready),
	.m_axi_wide_arid(m_axi_wide_arid),
	.m_axi_wide_araddr(m_axi_wide_araddr),
	.m_axi_wide_arlen(m_axi_wide_arlen),
	.m_axi_wide_arsize(m_axi_wide_arsize),
	.m_axi_wide_arburst(m_axi_wide_arburst),
	.m_axi_wide_arlock(m_axi_wide_arlock),
	.m_axi_wide_arcache(m_axi_wide_arcache),
	.m_axi_wide_arprot(m_axi_wide_arprot),
	.m_axi_wide_arqos(m_axi_wide_arqos),
	.m_axi_wide_aruser(m_axi_wide_aruser),
	.m_axi_wide_arvalid(m_axi_wide_arvalid),
	.m_axi_wide_arready(m_axi_wide_arready),
	.m_axi_wide_rid(m_axi_wide_rid),
	.m_axi_wide_rdata(m_axi_wide_rdata),
	.m_axi_wide_rresp(m_axi_wide_rresp),
	.m_axi_wide_rlast(m_axi_wide_rlast),
	.m_axi_wide_ruser(m_axi_wide_ruser),
	.m_axi_wide_rvalid(m_axi_wide_rvalid),
	.m_axi_wide_rready(m_axi_wide_rready)
  );


  // User logic ends

endmodule


