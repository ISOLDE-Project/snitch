// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51



`include "renode_assign.svh"

// verilog_lint: waive-start package-filename
import renode_memory_pkg::*;

module master (
    input  logic                             clk_i,
    input  logic                             rst_ni,
    output  renode_memory_pkg::axi_connection_req_t  axi_req,
    input   renode_memory_pkg::axi_connection_resp_t axi_resp
);




    always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      $display("master::reset asserted");
      axi_req.aw_valid = 0;
      axi_req.w_valid  = 0;
      axi_req.b_ready  = 0;
      axi_req.ar_valid = 0;
      axi_req.r_ready  = 0;
    end
  end



  snitch_cluster_wrapper snitch(
    .clk_i,
    .rst_ni,
  .debug_req_i(0),
    .meip_i(0),
    .mtip_i(0),
    .msip_i(0),
    .wide_out_req_o(axi_req),
    .wide_out_resp_i(axi_resp)
  );
endmodule



module top (
    input logic clk_i,
    input logic rst_ni
);


  renode_connection                        connection = new();
  bus_connection                           bus_peripheral = new(connection);


  renode_axi_if axi_if (.aclk(clk_i));
  renode_memory_pkg::axi_connection_req_t  axi_req;
  renode_memory_pkg::axi_connection_resp_t axi_resp;
  //
 

  `__RENODE_TO_RESP(axi_resp, axi_if)
  `__REQ_TO_RENODE(axi_if, axi_req)

  renode_memory mem (
      .s_axi_if(axi_if),
      .bus_peripheral(bus_peripheral)
  );

  master ctr (
      .clk_i,
      .rst_ni(axi_if.areset_n),
      .axi_req,
      .axi_resp
  );
  // Print some stuff as an example
  initial begin
    if ($test$plusargs("trace") != 0) begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dump.vcd");
      $dumpvars();
    end
    axi_if.areset_n = 0;
    $display("[%0t] Model running...\n", $time);
  end

   always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      axi_if.areset_n = 0;
      bus_peripheral.reset_assert();
    end
  end

  always @(bus_peripheral.reset_assert_response) begin
    if (rst_ni) begin
      bus_peripheral.reset_deassert();
    end
  end



endmodule
