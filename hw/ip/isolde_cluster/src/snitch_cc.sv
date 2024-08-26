// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

`include "common_cells/assertions.svh"
`include "common_cells/registers.svh"
`include "snitch_vm/typedef.svh"

/// Snitch Core Complex (CC)
/// Contains the Snitch Integer Core + FPU + Private Accelerators
module snitch_cc #(
  /// Address width of the buses
  parameter int unsigned AddrWidth          = 0,
  /// Data width of the buses.
  parameter int unsigned DataWidth          = 0,
  /// Data width of the AXI DMA buses.
  parameter int unsigned DMADataWidth       = 0,
  /// Id width of the AXI DMA bus.
  parameter int unsigned DMAIdWidth         = 0,
  parameter int unsigned DMAAxiReqFifoDepth = 0,
  parameter int unsigned DMAReqFifoDepth    = 0,
  /// Data port request type.
  parameter type         dreq_t             = logic,
  /// Data port response type.
  parameter type         drsp_t             = logic,
  /// TCDM Address Width
  parameter int unsigned TCDMAddrWidth      = 0,
  /// Data port request type.
  parameter type         tcdm_req_t         = logic,
  /// Data port response type.
  parameter type         tcdm_rsp_t         = logic,
  /// TCDM User Payload
  parameter type         tcdm_user_t        = logic,
  parameter type         axi_req_t          = logic,
  parameter type         axi_rsp_t          = logic,
  parameter type         hive_req_t         = logic,
  parameter type         hive_rsp_t         = logic,
  parameter type         acc_req_t          = logic,
  parameter type         acc_resp_t         = logic,
  parameter type         dma_events_t       = logic,
  parameter fpnew_pkg::fpu_implementation_t FPUImplementation = '0,
  /// Boot address of core.
  parameter logic [31:0] BootAddr           = 32'h0000_1000,
  /// Reduced-register extension
  parameter bit          RVE                = 0,
  /// Enable Snitch DMA
  parameter bit          Xdma               = 0,
  parameter int unsigned NumIntOutstandingLoads = 0,
  parameter int unsigned NumIntOutstandingMem = 0,
  parameter int unsigned NumDTLBEntries = 0,
  parameter int unsigned NumITLBEntries = 0,

  /// Timing Parameters
  /// Insert Pipeline registers into off-loading path (request)
  parameter bit          RegisterOffloadReq = 0,
  /// Insert Pipeline registers into off-loading path (response)
  parameter bit          RegisterOffloadRsp = 0,
  /// Insert Pipeline registers into data memory path (request)
  parameter bit          RegisterCoreReq    = 0,
  /// Insert Pipeline registers into data memory path (response)
  parameter bit          RegisterCoreRsp    = 0,
  parameter snitch_pma_pkg::snitch_pma_t SnitchPMACfg = '{default: 0},
  /// Derived parameter *Do not override*
  parameter int unsigned TCDMPorts =  1,
  parameter type addr_t = logic [AddrWidth-1:0],
  parameter type data_t = logic [DataWidth-1:0]
) (
  input  logic                       clk_i,
  //input  logic                       clk_d2_i,
  input  logic                       rst_ni,
  input  logic                       rst_int_ss_ni,
  input  logic                       rst_fp_ss_ni,
  input  logic [31:0]                hart_id_i,
  input  snitch_pkg::interrupts_t    irq_i,
  output hive_req_t                  hive_req_o,
  input  hive_rsp_t                  hive_rsp_i,
  // Core data ports
  output dreq_t                      data_req_o,
  input  drsp_t                      data_rsp_i,
  // TCDM Streamer Ports
  output tcdm_req_t [TCDMPorts-1:0]  tcdm_req_o,
  input  tcdm_rsp_t [TCDMPorts-1:0]  tcdm_rsp_i,
  // Accelerator Offload port
  // DMA ports
  output axi_req_t                   axi_dma_req_o,
  input  axi_rsp_t                   axi_dma_res_i,
  output logic                       axi_dma_busy_o,
  output axi_dma_pkg::dma_perf_t     axi_dma_perf_o,
  output dma_events_t                axi_dma_events_o,
  // Core event strobes
  output snitch_pkg::core_events_t   core_events_o,
  input  addr_t                      tcdm_addr_base_i
);


  /// Has virtual memory support.
  localparam bit          VMSupport          = 0;
 

  acc_req_t acc_snitch_req;
  acc_req_t acc_snitch_demux;
  acc_resp_t acc_seq;
  acc_resp_t acc_demux_snitch;
  acc_resp_t acc_demux_snitch_q;
  acc_resp_t dma_resp;
  


  logic acc_snitch_demux_qvalid, acc_snitch_demux_qready;
  logic acc_qvalid, acc_qready;
  logic dma_qvalid, dma_qready;


  logic acc_pvalid, acc_pready;
  logic dma_pvalid, dma_pready;
 
 
  logic acc_demux_snitch_valid, acc_demux_snitch_ready;


  fpnew_pkg::roundmode_e fpu_rnd_mode;
  fpnew_pkg::fmt_mode_t  fpu_fmt_mode;
  fpnew_pkg::status_t    fpu_status;

  snitch_pkg::core_events_t snitch_events;


  // Snitch Integer Core
  dreq_t  merged_dreq;
  drsp_t  merged_drsp;

  `SNITCH_VM_TYPEDEF(AddrWidth)

  snitch #(
    .AddrWidth (AddrWidth),
    .DataWidth (DataWidth),
    .acc_req_t (acc_req_t),
    .acc_resp_t (acc_resp_t),
    .dreq_t (dreq_t),
    .drsp_t (drsp_t),
    .pa_t (pa_t),
    .l0_pte_t (l0_pte_t),
    .BootAddr (BootAddr),
    .SnitchPMACfg (SnitchPMACfg),
    .NumIntOutstandingLoads (NumIntOutstandingLoads),
    .NumIntOutstandingMem (NumIntOutstandingMem),
    .VMSupport (VMSupport),
    .NumDTLBEntries (NumDTLBEntries),
    .NumITLBEntries (NumITLBEntries),
    .RVE (RVE),
    .FP_EN (1'b0),
    .Xdma (Xdma),
    .Xssr (1'b0),
    .RVF (1'b0),
    .RVD (1'b0),
    .XDivSqrt (1'b0),
    .XF16 (1'b0),
    .XF16ALT (1'b0),
    .XF8 (1'b0),
    .XF8ALT (1'b0),
    .XFVEC (1'b0),
    .XFDOTP (1'b0),
    .XFAUX (1'b0),
    .FLEN (1'b0)
  ) i_snitch (
    .clk_i ( clk_i ), // if necessary operate on half the frequency
    .rst_i ( ~rst_ni ),
    .hart_id_i,
    .irq_i,
    .flush_i_valid_o (hive_req_o.flush_i_valid),
    .flush_i_ready_i (hive_rsp_i.flush_i_ready),
    .inst_addr_o (hive_req_o.inst_addr),
    .inst_cacheable_o (hive_req_o.inst_cacheable),
    .inst_data_i (hive_rsp_i.inst_data),
    .inst_valid_o (hive_req_o.inst_valid),
    .inst_ready_i (hive_rsp_i.inst_ready),
    .acc_qreq_o ( acc_snitch_demux ),
    .acc_qvalid_o ( acc_snitch_demux_qvalid ),
    .acc_qready_i ( acc_snitch_demux_qready ),
    .acc_prsp_i ( acc_demux_snitch ),
    .acc_pvalid_i ( acc_demux_snitch_valid ),
    .acc_pready_o ( acc_demux_snitch_ready ),
    .data_req_o ( merged_dreq ),
    .data_rsp_i ( merged_drsp ),
    .ptw_valid_o (hive_req_o.ptw_valid),
    .ptw_ready_i (hive_rsp_i.ptw_ready),
    .ptw_va_o (hive_req_o.ptw_va),
    .ptw_ppn_o (hive_req_o.ptw_ppn),
    .ptw_pte_i (hive_rsp_i.ptw_pte),
    .ptw_is_4mega_i (hive_rsp_i.ptw_is_4mega),
    .fpu_rnd_mode_o ( fpu_rnd_mode ),
    .fpu_fmt_mode_o ( fpu_fmt_mode ),
    .fpu_status_i ( fpu_status ),
    .core_events_o ( snitch_events)
  );





  // Accelerator Demux Port
  stream_demux #(
    .N_OUP ( 3 )
  ) i_stream_demux_offload (
    .inp_valid_i  ( acc_snitch_demux_qvalid  ),
    .inp_ready_o  ( acc_snitch_demux_qready  ),
    .oup_sel_i    ( acc_snitch_demux.addr[$clog2(5)-1:0]             ),
    .oup_valid_o  ( { dma_qvalid, hive_req_o.acc_qvalid, acc_qvalid} ),
    .oup_ready_i  ( { dma_qready, hive_rsp_i.acc_qready, acc_qready} )
  );

  // To shared muldiv
  assign hive_req_o.acc_req = acc_snitch_demux;
  assign acc_snitch_req = acc_snitch_demux;

  stream_arbiter #(
    .DATA_T      ( acc_resp_t ),
    .N_INP       ( 3          )
  ) i_stream_arbiter_offload (
    .clk_i       ( clk_i                                   ),
    .rst_ni      ( rst_ni                                  ),
    .inp_data_i  ( { dma_resp,   hive_rsp_i.acc_resp,   acc_seq    } ),
    .inp_valid_i ( { dma_pvalid, hive_rsp_i.acc_pvalid, acc_pvalid } ),
    .inp_ready_o ( { dma_pready, hive_req_o.acc_pready, acc_pready } ),
    .oup_data_o  ( acc_demux_snitch                      ),
    .oup_valid_o ( acc_demux_snitch_valid                ),
    .oup_ready_i ( acc_demux_snitch_ready                )
  );

  if (Xdma) begin : gen_dma
    axi_dma_tc_snitch_fe #(
      .AddrWidth (AddrWidth),
      .DataWidth (DataWidth),
      .DMADataWidth (DMADataWidth),
      .IdWidth (DMAIdWidth),
      .DMAAxiReqFifoDepth (DMAAxiReqFifoDepth),
      .DMAReqFifoDepth (DMAReqFifoDepth),
      .axi_req_t (axi_req_t),
      .axi_res_t (axi_rsp_t),
      .acc_resp_t (acc_resp_t),
      .dma_events_t (dma_events_t)
    ) i_axi_dma_tc_snitch_fe (
      .clk_i            ( clk_i                     ),
      .rst_ni           ( rst_ni                    ),
      .axi_dma_req_o    ( axi_dma_req_o             ),
      .axi_dma_res_i    ( axi_dma_res_i             ),
      .dma_busy_o       ( axi_dma_busy_o            ),
      .acc_qaddr_i      ( acc_snitch_req.addr       ),
      .acc_qid_i        ( acc_snitch_req.id         ),
      .acc_qdata_op_i   ( acc_snitch_req.data_op    ),
      .acc_qdata_arga_i ( acc_snitch_req.data_arga  ),
      .acc_qdata_argb_i ( acc_snitch_req.data_argb  ),
      .acc_qdata_argc_i ( acc_snitch_req.data_argc  ),
      .acc_qvalid_i     ( dma_qvalid                ),
      .acc_qready_o     ( dma_qready                ),
      .acc_pdata_o      ( dma_resp.data             ),
      .acc_pid_o        ( dma_resp.id               ),
      .acc_perror_o     ( dma_resp.error            ),
      .acc_pvalid_o     ( dma_pvalid                ),
      .acc_pready_i     ( dma_pready                ),
      .hart_id_i        ( hart_id_i                 ),
      .dma_perf_o       ( axi_dma_perf_o            ),
      .dma_events_o     ( axi_dma_events_o          )
    );

  // no DMA instanciated
  end else begin : gen_no_dma
    // tie-off unused signals
    assign axi_dma_req_o   =  '0;
    assign axi_dma_busy_o  = 1'b0;

    assign dma_qready      =  '0;
    assign dma_pvalid      =  '0;

    assign dma_resp        =  '0;
    assign axi_dma_perf_o  = '0;
  end


    


 begin : gen_no_fpu
    assign fpu_status = '0;

    assign acc_qready    = '0;
    assign acc_seq.data  = '0;
    assign acc_seq.id    = '0;
    assign acc_seq.error = '0;
    assign acc_pvalid    = '0;

    assign core_events_o.issue_fpu = '0;
    assign core_events_o.issue_fpu_seq = '0;
    assign core_events_o.issue_core_to_fpu = '0;
  end

  // Decide whether to go to SoC or TCDM
  dreq_t data_tcdm_req;
  drsp_t data_tcdm_rsp;
  localparam int unsigned SelectWidth = cf_math_pkg::idx_width(2);
  typedef logic [SelectWidth-1:0] select_t;
  select_t slave_select;
  reqrsp_demux #(
    .NrPorts (2),
    .req_t (dreq_t),
    .rsp_t (drsp_t),
    // TODO(zarubaf): Make a parameter.
    .RespDepth (4)
  ) i_reqrsp_demux (
    .clk_i,
    .rst_ni,
    .slv_select_i (slave_select),
    .slv_req_i (merged_dreq),
    .slv_rsp_o (merged_drsp),
    .mst_req_o ({data_tcdm_req, data_req_o}),
    .mst_rsp_i ({data_tcdm_rsp, data_rsp_i})
  );

  typedef struct packed {
    int unsigned idx;
    logic [AddrWidth-1:0] base;
    logic [AddrWidth-1:0] mask;
  } reqrsp_rule_t;

  reqrsp_rule_t addr_map;
  assign addr_map = '{
    idx: 1,
    base: tcdm_addr_base_i,
    mask: ({AddrWidth{1'b1}} << TCDMAddrWidth)
  };

  addr_decode_napot #(
    .NoIndices (2),
    .NoRules (1),
    .addr_t (logic [AddrWidth-1:0]),
    .rule_t (reqrsp_rule_t)
  ) i_addr_decode_napot (
    .addr_i (merged_dreq.q.addr),
    .addr_map_i (addr_map),
    .idx_o (slave_select),
    .dec_valid_o (),
    .dec_error_o (),
    .en_default_idx_i (1'b1),
    .default_idx_i ('0)
  );

  tcdm_req_t core_tcdm_req;
  tcdm_rsp_t core_tcdm_rsp;

  reqrsp_to_tcdm #(
    .AddrWidth (AddrWidth),
    .DataWidth (DataWidth),
    // TODO(zarubaf): Make a parameter.
    .BufDepth (4),
    .reqrsp_req_t (dreq_t),
    .reqrsp_rsp_t (drsp_t),
    .tcdm_req_t (tcdm_req_t),
    .tcdm_rsp_t (tcdm_rsp_t)
  ) i_reqrsp_to_tcdm (
    .clk_i,
    .rst_ni,
    .reqrsp_req_i (data_tcdm_req),
    .reqrsp_rsp_o (data_tcdm_rsp),
    .tcdm_req_o (core_tcdm_req),
    .tcdm_rsp_i (core_tcdm_rsp)
  );

  
 begin : gen_no_ssrs
    // Connect single TCDM port
    assign tcdm_req_o[0] = core_tcdm_req;
    assign core_tcdm_rsp = tcdm_rsp_i[0];

  end

  // Core events for performance counters
  assign core_events_o.retired_instr = snitch_events.retired_instr;
  assign core_events_o.retired_load = snitch_events.retired_load;
  assign core_events_o.retired_i = snitch_events.retired_i;
  assign core_events_o.retired_acc = snitch_events.retired_acc;

  // --------------------------
  // Tracer
  // --------------------------
  // pragma translate_off
  int f;
  string fn;
  logic [63:0] cycle = 0;
  initial begin
    // We need to schedule the assignment into a safe region, otherwise
    // `hart_id_i` won't have a value assigned at the beginning of the first
    // delta cycle.
    /* verilator lint_off STMTDLY */
    #0;
    /* verilator lint_on STMTDLY */
    $system("mkdir logs -p");
    $sformat(fn, "logs/trace_hart_%05x.dasm", hart_id_i);
    f = $fopen(fn, "w");
    $display("[Tracer] Logging Hart %d to %s", hart_id_i, fn);
  end

  // verilog_lint: waive-start always-ff-non-blocking
  always_ff @(posedge clk_i) begin
    automatic string trace_entry;
    automatic string extras_str;
    automatic snitch_pkg::snitch_trace_port_t extras_snitch;


    if (rst_ni) begin
      extras_snitch = '{
        // State
        source:       snitch_pkg::SrcSnitch,
        stall:        i_snitch.stall,
        exception:    i_snitch.exception,
        // Decoding
        rs1:          i_snitch.rs1,
        rs2:          i_snitch.rs2,
        rd:           i_snitch.rd,
        is_load:      i_snitch.is_load,
        is_store:     i_snitch.is_store,
        is_branch:    i_snitch.is_branch,
        pc_d:         i_snitch.pc_d,
        // Operands
        opa:          i_snitch.opa,
        opb:          i_snitch.opb,
        opa_select:   i_snitch.opa_select,
        opb_select:   i_snitch.opb_select,
        write_rd:     i_snitch.write_rd,
        csr_addr:     i_snitch.inst_data_i[31:20],
        // Pipeline writeback
        writeback:    i_snitch.alu_writeback,
        // Load/Store
        gpr_rdata_1:  i_snitch.gpr_rdata[1],
        ls_size:      i_snitch.ls_size,
        ld_result_32: i_snitch.ld_result[31:0],
        lsu_rd:       i_snitch.lsu_rd,
        retire_load:  i_snitch.retire_load,
        alu_result:   i_snitch.alu_result,
        // Atomics
        ls_amo:       i_snitch.ls_amo,
        // Accelerator
        retire_acc:   i_snitch.retire_acc,
        acc_pid:      i_snitch.acc_prsp_i.id,
        acc_pdata_32: i_snitch.acc_prsp_i.data[31:0],
        // FPU offload
        fpu_offload:
          (i_snitch.acc_qready_i && i_snitch.acc_qvalid_o && i_snitch.acc_qreq_o.addr == 0),
        is_seq_insn:  (i_snitch.inst_data_i inside {riscv_instr::FREP_I, riscv_instr::FREP_O})
      };



      cycle++;
      // Trace snitch iff:
      // we are not stalled <==> we have issued and processed an instruction (including offloads)
      // OR we are retiring (issuing a writeback from) a load or accelerator instruction
      if (
          !i_snitch.stall || i_snitch.retire_load || i_snitch.retire_acc
      ) begin
        $sformat(trace_entry, "%t %1d %8d 0x%h DASM(%h) #; %s\n",
            $time, cycle, i_snitch.priv_lvl_q, i_snitch.pc_q, i_snitch.inst_data_i,
            snitch_pkg::print_snitch_trace(extras_snitch));
        $fwrite(f, trace_entry);
      end

    end else begin
      cycle = '0;
    end
  end

  final begin
    $fclose(f);
  end
  // verilog_lint: waive-stop always-ff-non-blocking
  // pragma translate_on

  `ASSERT_INIT(BootAddrAligned, BootAddr[1:0] == 2'b00)

endmodule
