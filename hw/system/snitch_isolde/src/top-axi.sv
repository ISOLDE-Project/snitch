// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51



`include "renode_assign.svh"

// verilog_lint: waive-start package-filename
package top_isolde_pkg;
  import snitch_cluster_pkg::*;

  localparam int unsigned AddrWidth = snitch_cluster_pkg::AddrWidth;
  localparam int unsigned DataWidth = snitch_cluster_pkg::WideDataWidth;
  localparam int unsigned IdWidthIn = snitch_cluster_pkg::WideIdWidthOut;
  localparam int unsigned UserWidth = snitch_cluster_pkg::WideUserWidth;

endpackage

module master (
    input renode_pkg::bus_connection bus_controller,
          mem_axi_if                 axi_conn
);

  renode_axi_if #(
      .AddressWidth(top_isolde_pkg::AddrWidth),
      .DataWidth(top_isolde_pkg::DataWidth),
      .TransactionIdWidth(top_isolde_pkg::IdWidthIn)
  ) m_axi_if (
      .aclk(axi_conn.clk_i)
  );
  assign m_axi_if.areset_n = axi_conn.rst_ni;

  `__RENODE_TO_REQ(axi_conn.req, m_axi_if)
  `__RESP_TO_RENODE(m_axi_if, axi_conn.resp)

  always_ff @(posedge axi_conn.clk_i) begin
    if (!axi_conn.rst_ni) begin
      $display("master::reset asserted");
      // axi_req.aw_valid = 0;
      // axi_req.w_valid  = 0;
      // axi_req.b_ready  = 0;
      // axi_req.ar_valid = 0;
      // axi_req.r_ready  = 0;
    end
  end



  snitch_cluster_wrapper snitch (
      .clk_i(axi_conn.clk_i),
      .rst_ni(axi_conn.rst_ni),
      // .debug_req_i(0),
      //   .meip_i(0),
      //   .mtip_i(0),
      //   .msip_i(0),
      .wide_out_req_o(axi_conn.req),
      .wide_out_resp_i(axi_conn.resp)
  );
endmodule



module top (
    input logic clk_i,
    input logic rst_ni
);


  renode_connection connection = new();
  bus_connection    bus_peripheral = new(connection);
  bus_connection    bus_controller = new(connection);

  mem_axi_if #(
      .AddrWidth(top_isolde_pkg::AddrWidth),
      .DataWidth(top_isolde_pkg::DataWidth),
      .IdWidth  (top_isolde_pkg::IdWidthIn),
      .UserWidth(top_isolde_pkg::UserWidth)
  ) axi_conn (
      clk_i,
      rst_ni
  );

  renode_memory #(
      .AddrWidth(top_isolde_pkg::AddrWidth),
      .DataWidth(top_isolde_pkg::DataWidth),
      .IdWidth  (top_isolde_pkg::IdWidthIn)
  ) mem (
      .bus_peripheral(bus_peripheral),
      .axi_conn
  );

  master ctr (
      .bus_controller(bus_controller),
      .axi_conn
  );
  initial begin
    if ($test$plusargs("trace") != 0) begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dump.vcd");
      $dumpvars();
    end
    $display("[%0t] Model running...\n", $time);
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      bus_peripheral.reset_assert();
    end
  end

  always @(bus_peripheral.reset_assert_response) begin
    if (rst_ni) begin
      bus_peripheral.reset_deassert();
    end
  end



endmodule
