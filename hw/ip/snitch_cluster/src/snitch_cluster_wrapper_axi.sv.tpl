// Copyleft
// snitch cluster wrapper axi
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

${disclaimer}


`include "axi/typedef.svh"
//`include "axi/assign.svh"
<%text>
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
 // __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
 // __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
 // __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;

`define __AXI_TO_REQ( __lhs, __rhs)    \
  `__AXI_TO_AW(assign,__lhs``.aw,.,__rhs``_aw, )    \
   assign __lhs``.aw_valid = __rhs``_awvalid;                         \
  `__AXI_TO_W (assign,__lhs``.w, .,__rhs``_w,  )    \
    assign __lhs``.w_valid = __rhs``_wvalid;                           \
  assign __lhs``.b_ready = __rhs``_bready;                           \
  `__AXI_TO_AR(assign,__lhs``.ar,.,__rhs``_ar, )    \
    assign __lhs``.ar_valid = __rhs``_arvalid;                         \
  assign __lhs``.r_ready = __rhs``_rready;

`define __AXI_TO_RESP( __lhs, __rhs)                               \
  assign __lhs``.aw_ready = __rhs``_awready;                         \
  assign __lhs``.ar_ready = __rhs``_arready;                         \
  assign __lhs``.w_ready = __rhs``_wready;                           \
  assign __lhs``.b_valid = __rhs``_bvalid;                           \
  `__AXI_TO_B(assign, wide_out_resp_i.b, ., m_axi_wide_b, )         \
  assign __lhs``.r_valid = __rhs``_rvalid;                            \
  `__AXI_TO_R(assign, wide_out_resp_i.r, ., m_axi_wide_r, )   

</%text>

// verilog_lint: waive-start package-filename
package snitch_cluster_pkg;

  localparam int unsigned NrCores = 2;
  localparam int unsigned NrHives = 1;

  localparam int unsigned AddrWidth = 48;
  localparam int unsigned NarrowDataWidth = 32;
  localparam int unsigned WideDataWidth = 512;

  localparam int unsigned NarrowIdWidthIn = 2;
  localparam int unsigned NrMasters = 3;
  localparam int unsigned NarrowIdWidthOut = $clog2(NrMasters) + NarrowIdWidthIn;

  localparam int unsigned NrDmaMasters = 2 + 1;
  localparam int unsigned WideIdWidthIn = 1;
  localparam int unsigned WideIdWidthOut = $clog2(NrDmaMasters) + WideIdWidthIn;

  localparam int unsigned NarrowUserWidth = 1;
  localparam int unsigned WideUserWidth = 1;

  localparam int unsigned ICacheLineWidth[NrHives] = '{256};
  localparam int unsigned ICacheLineCount[NrHives] = '{128};
  localparam int unsigned ICacheSets[NrHives] = '{2};

  localparam int unsigned Hive[NrCores] = '{0, 0};

  // ****
  // Parameters of Axi Master Bus Interface M_AXI_WIDE
  localparam int unsigned C_M_AXI_WIDE_ID_WIDTH	   = $clog2(NrDmaMasters) + ${cfg['dma_id_width_in']};
  localparam int unsigned C_M_AXI_WIDE_ADDR_WIDTH	  = ${cfg['addr_width']};
  localparam int unsigned C_M_AXI_WIDE_DATA_WIDTH	  = ${cfg['dma_data_width']};
  localparam int unsigned C_M_AXI_WIDE_AWUSER_WIDTH	= ${cfg['dma_user_width']};
  localparam int unsigned C_M_AXI_WIDE_ARUSER_WIDTH	= ${cfg['dma_user_width']};
  localparam int unsigned C_M_AXI_WIDE_WUSER_WIDTH	= ${cfg['dma_user_width']};
  localparam int unsigned C_M_AXI_WIDE_RUSER_WIDTH	= ${cfg['dma_user_width']};
  localparam int unsigned C_M_AXI_WIDE_BUSER_WIDTH	= ${cfg['dma_user_width']};



  typedef struct packed {logic [0:0] reserved;} sram_cfg_t;

  typedef struct packed {
    sram_cfg_t icache_tag;
    sram_cfg_t icache_data;
    sram_cfg_t tcdm;
  } sram_cfgs_t;

  typedef logic [AddrWidth-1:0] addr_t;
  typedef logic [NarrowDataWidth-1:0] data_t;
  typedef logic [NarrowDataWidth/8-1:0] strb_t;
  typedef logic [WideDataWidth-1:0] data_dma_t;
  typedef logic [WideDataWidth/8-1:0] strb_dma_t;
  typedef logic [NarrowIdWidthIn-1:0] narrow_in_id_t;
  typedef logic [NarrowIdWidthOut-1:0] narrow_out_id_t;
  typedef logic [WideIdWidthIn-1:0] wide_in_id_t;
  typedef logic [WideIdWidthOut-1:0] wide_out_id_t;
  typedef logic [NarrowUserWidth-1:0] user_t;
  typedef logic [WideUserWidth-1:0] user_dma_t;

  `AXI_TYPEDEF_ALL(narrow_in, addr_t, narrow_in_id_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_ALL(narrow_out, addr_t, narrow_out_id_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_ALL(wide_in, addr_t, wide_in_id_t, data_dma_t, strb_dma_t, user_dma_t)
  `AXI_TYPEDEF_ALL(wide_out, addr_t, wide_out_id_t, data_dma_t, strb_dma_t, user_dma_t)

  function automatic snitch_pma_pkg::rule_t [snitch_pma_pkg::NrMaxRules-1:0] get_cached_regions();
    automatic snitch_pma_pkg::rule_t [snitch_pma_pkg::NrMaxRules-1:0] cached_regions;
    cached_regions = '{default: '0};
    cached_regions[0] = '{base: 48'h80000000, mask: 48'hffff80000000};
    return cached_regions;
  endfunction

  localparam snitch_pma_pkg::snitch_pma_t SnitchPMACfg = '{
      NrCachedRegionRules: 1,
      CachedRegion: get_cached_regions(),
      default: 0
  };

  localparam fpnew_pkg::fpu_implementation_t FPUImplementation[2] = '{
      '{
          PipeRegs:  // FMA Block
          '{
              '{
                  3,  // FP32
                  3,  // FP64
                  2,  // FP16
                  1,  // FP8
                  2,  // FP16alt
                  1  // FP8alt
              },
              '{1, 1, 1, 1, 1, 1},  // DIVSQRT
              '{1, 1, 1, 1, 1, 1},  // NONCOMP
              '{1, 1, 1, 1, 1, 1},  // CONV
              '{2, 2, 2, 2, 2, 2}  // DOTP
          },
          UnitTypes: '{
              '{
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED
              },  // FMA
              '{
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED
              },  // DIVSQRT
              '{
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL
              },  // NONCOMP
              '{
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED
              },  // CONV
              '{
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED
              }
          },  // DOTP
          PipeConfig: fpnew_pkg::BEFORE
      },
      '{
          PipeRegs:  // FMA Block
          '{
              '{
                  3,  // FP32
                  3,  // FP64
                  2,  // FP16
                  1,  // FP8
                  2,  // FP16alt
                  1  // FP8alt
              },
              '{1, 1, 1, 1, 1, 1},  // DIVSQRT
              '{1, 1, 1, 1, 1, 1},  // NONCOMP
              '{1, 1, 1, 1, 1, 1},  // CONV
              '{2, 2, 2, 2, 2, 2}  // DOTP
          },
          UnitTypes: '{
              '{
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED
              },  // FMA
              '{
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED
              },  // DIVSQRT
              '{
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL,
                  fpnew_pkg::PARALLEL
              },  // NONCOMP
              '{
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED,
                  fpnew_pkg::MERGED
              },  // CONV
              '{
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED,
                  fpnew_pkg::DISABLED
              }
          },  // DOTP
          PipeConfig: fpnew_pkg::BEFORE
      }
  };




endpackage
// verilog_lint: waive-stop package-filename

module  snitch_cluster_wrapper (
    //input  logic                                                                    clk_i,
    //input  logic                                                                    rst_ni,
    input  logic                                  [snitch_cluster_pkg::NrCores-1:0] debug_req_i,
    input  logic                                  [snitch_cluster_pkg::NrCores-1:0] meip_i,
    input  logic                                  [snitch_cluster_pkg::NrCores-1:0] mtip_i,
    input  logic                                  [snitch_cluster_pkg::NrCores-1:0] msip_i,
//********* M_AXI_WIDE
 // Do not modify the ports beyond this line
		input logic  m_axi_wide_init_axi_txn,
		output logic  m_axi_wide_txn_done,
		output logic  m_axi_wide_error,
		input logic  m_axi_wide_aclk,
		input logic  m_axi_wide_aresetn,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_awid,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ADDR_WIDTH-1 : 0] m_axi_wide_awaddr,
		output logic [7 : 0] m_axi_wide_awlen,
		output logic [2 : 0] m_axi_wide_awsize,
		output logic [1 : 0] m_axi_wide_awburst,
		output logic  m_axi_wide_awlock,
		output logic [3 : 0] m_axi_wide_awcache,
		output logic [2 : 0] m_axi_wide_awprot,
		output logic [3 : 0] m_axi_wide_awqos,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_AWUSER_WIDTH-1 : 0] m_axi_wide_awuser,
		output logic  m_axi_wide_awvalid,
		input logic  m_axi_wide_awready,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_DATA_WIDTH-1 : 0] m_axi_wide_wdata,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_DATA_WIDTH/8-1 : 0] m_axi_wide_wstrb,
		output logic  m_axi_wide_wlast,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_WUSER_WIDTH-1 : 0] m_axi_wide_wuser,
		output logic  m_axi_wide_wvalid,
		input logic  m_axi_wide_wready,
		input logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_bid,
		input logic [1 : 0] m_axi_wide_bresp,
		input logic [ snitch_cluster_pkg::C_M_AXI_WIDE_BUSER_WIDTH-1 : 0] m_axi_wide_buser,
		input logic  m_axi_wide_bvalid,
		output logic  m_axi_wide_bready,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_arid,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ADDR_WIDTH-1 : 0] m_axi_wide_araddr,
		output logic [7 : 0] m_axi_wide_arlen,
		output logic [2 : 0] m_axi_wide_arsize,
		output logic [1 : 0] m_axi_wide_arburst,
		output logic  m_axi_wide_arlock,
		output logic [3 : 0] m_axi_wide_arcache,
		output logic [2 : 0] m_axi_wide_arprot,
		output logic [3 : 0] m_axi_wide_arqos,
		output logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ARUSER_WIDTH-1 : 0] m_axi_wide_aruser,
		output logic  m_axi_wide_arvalid,
		input logic  m_axi_wide_arready,
		input logic [ snitch_cluster_pkg::C_M_AXI_WIDE_ID_WIDTH-1 : 0] m_axi_wide_rid,
		input logic [ snitch_cluster_pkg::C_M_AXI_WIDE_DATA_WIDTH-1 : 0] m_axi_wide_rdata,
		input logic [1 : 0] m_axi_wide_rresp,
		input logic  m_axi_wide_rlast,
		input logic [ snitch_cluster_pkg::C_M_AXI_WIDE_RUSER_WIDTH-1 : 0] m_axi_wide_ruser,
		input logic  m_axi_wide_rvalid,
		output logic  m_axi_wide_rready
//*********************
    //  input  snitch_cluster_pkg::narrow_in_req_t     narrow_in_req_i,
    //  output snitch_cluster_pkg::narrow_in_resp_t    narrow_in_resp_o,
    //  output snitch_cluster_pkg::narrow_out_req_t    narrow_out_req_o,
    //  input  snitch_cluster_pkg::narrow_out_resp_t   narrow_out_resp_i,
    //  output snitch_cluster_pkg::wide_out_req_t      wide_out_req_o,
    // input  snitch_cluster_pkg::wide_out_resp_t     wide_out_resp_i,
    //input  snitch_cluster_pkg::wide_in_req_t       wide_in_req_i,
    //output snitch_cluster_pkg::wide_in_resp_t      wide_in_resp_o
);

  localparam int unsigned NumIntOutstandingLoads[2] = '{1, 1};
  localparam int unsigned NumIntOutstandingMem[2] = '{4, 4};
  localparam int unsigned NumFPOutstandingLoads[2] = '{4, 4};
  localparam int unsigned NumFPOutstandingMem[2] = '{4, 4};
  localparam int unsigned NumDTLBEntries[2] = '{1, 1};
  localparam int unsigned NumITLBEntries[2] = '{1, 1};
  localparam int unsigned NumSequencerInstr[2] = '{16, 16};
  localparam int unsigned NumSsrs[2] = '{1, 1};
  localparam int unsigned SsrMuxRespDepth[2] = '{4, 4};

  snitch_cluster_pkg::wide_out_req_t  wide_out_req_o;
  snitch_cluster_pkg::wide_out_resp_t wide_out_resp_i;

`__AXI_TO_REQ(wide_out_req_o,m_axi_wide)

//   `__AXI_TO_AW(assign,wide_out_req_o.aw,.,m_axi_wide_aw, )
//   `__AXI_TO_W(assign,wide_out_req_o.w,.,m_axi_wide_w, )
//   `__AXI_TO_AR(assign,wide_out_req_o.ar,.,m_axi_wide_ar, )
  //response
  `__AXI_TO_RESP(wide_out_resp_i, m_axi_wide) 
  // `__AXI_TO_B(assign, wide_out_resp_i.b, ., m_axi_wide_b, )     
  // //__opt_as __lhs.r_valid = __rhs.r_valid;                           \
  // `__AXI_TO_R(assign, wide_out_resp_i.r, ., m_axi_wide_r, )   
  //request
  //assign wide_out_req_o.aw        = aw;
//   assign wide_out_req_o.aw_valid  = aw_valid;
//   assign wide_out_req_o.w         = w;
//   assign wide_out_req_o.w_valid   = w_valid;
//   assign wide_out_req_o.b_ready   = b_ready;
//   assign wide_out_req_o.ar        = ar;
//   assign wide_out_req_o.ar_valid  = ar_valid;
//   assign wide_out_req_o.r_ready   = r_ready;
  //response
//   assign wide_out_resp_i.aw_ready = aw_ready;
//   assign wide_out_resp_i.ar_ready = ar_ready;
//   assign wide_out_resp_i.w_ready  = w_ready;
//   assign wide_out_resp_i.b_valid  = b_valid;
//   assign wide_out_resp_i.b        = b;
//   assign wide_out_resp_i.r_valid  = r_valid;
//   assign wide_out_resp_i.r        = r;

  // Snitch cluster under test.
  snitch_cluster #(
      .PhysicalAddrWidth(48),
      .NarrowDataWidth(32),
      .WideDataWidth(512),
      .NarrowIdWidthIn(snitch_cluster_pkg::NarrowIdWidthIn),
      .WideIdWidthIn(snitch_cluster_pkg::WideIdWidthIn),
      .NarrowUserWidth(snitch_cluster_pkg::NarrowUserWidth),
      .WideUserWidth(snitch_cluster_pkg::WideUserWidth),
      .BootAddr(32'h1000),
      .narrow_in_req_t(0),  //.narrow_in_req_t (snitch_cluster_pkg::narrow_in_req_t),
      .narrow_in_resp_t(0),  //.narrow_in_resp_t (snitch_cluster_pkg::narrow_in_resp_t),
      //  .narrow_out_req_t (snitch_cluster_pkg::narrow_out_req_t),
      //  .narrow_out_resp_t (snitch_cluster_pkg::narrow_out_resp_t),
      .wide_out_req_t(snitch_cluster_pkg::wide_out_req_t),
      .wide_out_resp_t(snitch_cluster_pkg::wide_out_resp_t),
      .wide_in_req_t(snitch_cluster_pkg::wide_in_req_t),
      .wide_in_resp_t(snitch_cluster_pkg::wide_in_resp_t),
      .NrHives(1),
      .NrCores(2),
      .TCDMDepth(1024),
      .ZeroMemorySize(64),
      .ClusterPeriphSize(64),
      .NrBanks(32),
      .DMAAxiReqFifoDepth(3),
      .DMAReqFifoDepth(3),
      .ICacheLineWidth(snitch_cluster_pkg::ICacheLineWidth),
      .ICacheLineCount(snitch_cluster_pkg::ICacheLineCount),
      .ICacheSets(snitch_cluster_pkg::ICacheSets),
      //.VMSupport (1),
      .VMSupport(0),
      .RVE(2'b00),
      .RVF(2'b00),
      .RVD(2'b00),
      .XDivSqrt(2'b00),
      .XF16(2'b00),
      .XF16ALT(2'b00),
      .XF8(2'b00),
      .XF8ALT(2'b00),
      .XFVEC(2'b00),
      .XFDOTP(2'b00),
      .Xdma(2'b10),
      .Xssr(2'b00),
      .Xfrep(2'b00),
      .FPUImplementation(snitch_cluster_pkg::FPUImplementation),
      .SnitchPMACfg(snitch_cluster_pkg::SnitchPMACfg),
      .NumIntOutstandingLoads(NumIntOutstandingLoads),
      .NumIntOutstandingMem(NumIntOutstandingMem),
      .NumFPOutstandingLoads(NumFPOutstandingLoads),
      .NumFPOutstandingMem(NumFPOutstandingMem),
      .NumDTLBEntries(NumDTLBEntries),
      .NumITLBEntries(NumITLBEntries),
      .NumSsrsMax(0),
      .NumSsrs(NumSsrs),
      .SsrMuxRespDepth(SsrMuxRespDepth),
      //  .SsrRegs (snitch_cluster_pkg::SsrRegs),
      //  .SsrCfgs (snitch_cluster_pkg::SsrCfgs),
      .NumSequencerInstr(NumSequencerInstr),
      .Hive(snitch_cluster_pkg::Hive),
      .Topology(snitch_pkg::LogarithmicInterconnect),
      .Radix(2),
      .RegisterOffloadReq(1),
      .RegisterOffloadRsp(1),
      .RegisterCoreReq(1),
      .RegisterCoreRsp(1),
      .RegisterTCDMCuts(0),
      .RegisterExtWide(0),
      .RegisterExtNarrow(0),
      .RegisterFPUReq(0),
      .RegisterFPUIn(0),
      .RegisterFPUOut(0),
      .RegisterSequencer(0),
      .IsoCrossing(0),
      .NarrowXbarLatency(axi_pkg::CUT_ALL_PORTS),
      .WideXbarLatency(axi_pkg::CUT_ALL_PORTS),
      .WideMaxMstTrans(4),
      .WideMaxSlvTrans(4),
      .NarrowMaxMstTrans(4),
      .NarrowMaxSlvTrans(4),
      .sram_cfg_t(snitch_cluster_pkg::sram_cfg_t),
      .sram_cfgs_t(snitch_cluster_pkg::sram_cfgs_t)
  ) i_cluster (
      .clk_i(m_axi_wide_aclk),
      .rst_ni(m_axi_wide_aresetn),
      .debug_req_i,
      .meip_i,
      .mtip_i,
      .msip_i,
      .hart_base_id_i(10'h0),
      .cluster_base_addr_i(48'h10000000),
      .clk_d2_bypass_i(1'b0),
      .sram_cfgs_i(snitch_cluster_pkg::sram_cfgs_t'('0)),
      //    .narrow_in_req_i,
      //    .narrow_in_resp_o,
      //    .narrow_out_req_o,
      //    .narrow_out_resp_i,
      .wide_out_req_o(wide_out_req_o),
      .wide_out_resp_i(wide_out_resp_i),
      .wide_in_req_i(0)
      //    .wide_in_resp_o
  );
endmodule
