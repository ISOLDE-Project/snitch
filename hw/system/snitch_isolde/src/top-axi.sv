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
  logic rst_ni;

  always @(bus_controller.reset_assert_request) begin
    $display("axi_manager::reset_assert_request");
    axi_conn.req.aw_valid = 0;
    axi_conn.req.w_valid = 0;
    axi_conn.req.b_ready = 0;
    axi_conn.req.ar_valid = 0;
    axi_conn.req.r_ready = 0;
    rst_ni = 0;
    //
    // The reset takes 2 cycles to prevent a race condition without usage of a non-blocking assigment.
    repeat (2) @(posedge axi_conn.clk_i);
    bus_controller.reset_assert_respond();
  end

  always @(bus_controller.reset_deassert_request) begin
    $display("axi_manager::reset_deassert_request");
    //bus.areset_n = 1;
    // There is one more wait for the clock edges to be sure that all modules aren't in a reset state.
    repeat (2) @(posedge axi_conn.clk_i);
    bus_controller.reset_deassert_respond();
    rst_ni = 1;
  end


  always_ff @(posedge axi_conn.clk_i) begin
    if (!axi_conn.rst_ni) begin
      rst_ni = 0;

    end
  end

  snitch_cluster_wrapper snitch (
      .clk_i(axi_conn.clk_i),
      .rst_ni(rst_ni),
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
      bus_controller.reset_assert();
    end
  end

  always @(bus_peripheral.reset_assert_response) begin
    if (rst_ni) begin
      bus_peripheral.reset_deassert();
      bus_controller.reset_deassert();
    end
  end



endmodule
