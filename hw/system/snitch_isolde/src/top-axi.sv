// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51



`include "renode_assign.svh"

// verilog_lint: waive-start package-filename
import renode_memory_pkg::*;

module master (
    input  logic                             clk,
    input  logic                             areset_n,
    input  renode_pkg::bus_connection        bus_controller,
    output renode_memory_pkg::mem_out_req_t  mem_out_req_o,
    input  renode_memory_pkg::mem_out_resp_t mem_out_req_i
);

  renode_axi_if m_axi_if (.aclk(clk));
  assign m_axi_if.areset_n = areset_n;

  `__RENODE_TO_REQ( mem_out_req_o,m_axi_if)
  `__RESP_TO_RENODE(m_axi_if, mem_out_req_i)


  renode_axi_manager m_axi_mem (
      m_axi_if,
      bus_controller
  );

  address_t address = 32'h10;
  valid_bits_e data_bits = renode_pkg::Word;
  data_t wdata = 32'h100;
  data_t rdata = 32'h101;
  ;
  bit is_error;


  always_ff @(posedge m_axi_if.aclk) begin

    repeat (8) @(posedge m_axi_if.aclk);
    bus_controller.write(address, data_bits, wdata, is_error);
    repeat (8) @(posedge m_axi_if.aclk);
    bus_controller.read(address, data_bits, rdata, is_error);
    if (wdata != rdata) begin
      string error_msg;
      error_msg = $sformatf("Error! wdata!= rdata\n");
      $error(error_msg);
      $finish;
    end
  end

endmodule



module top (
    input logic clk,
    input logic reset
);


  renode_connection                        connection = new();
  bus_connection                           bus_peripheral = new(connection);
  bus_connection                           bus_controller = new(connection);
  renode_axi_if axi_if (.aclk(clk));
  assign axi_if.areset_n = reset;
  renode_memory_pkg::axi_connection_req_t  axi_req;
  renode_memory_pkg::axi_connection_resp_t axi_resp;
  //
 

  `__RENODE_TO_RESP(axi_resp, axi_if)
  `__REQ_TO_RENODE(axi_if, axi_req)

  renode_memory mem (
      .s_axi_if(axi_if),
      .bus_peripheral(bus_peripheral)
  );

  // master ctr (
  //     .clk(clk),
  //     .areset_n(reset),
  //     .bus_controller(bus_controller),
  //     .mem_out_req_o(axi_req),
  //     .mem_out_req_i(axi_resp)
  // );
  snitch_cluster_wrapper snitch(
    .clk_i(clk),
    .rst_ni(reset),
  .debug_req_i(0),
    .meip_i(0),
    .mtip_i(0),
    .msip_i(0),
    .wide_out_req_o(axi_req),
    .wide_out_resp_i(axi_resp)
  );
  // Print some stuff as an example
  initial begin
    if ($test$plusargs("trace") != 0) begin
      $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
      $dumpfile("logs/vlt_dump.vcd");
      $dumpvars();
    end

    $display("[%0t] Model running...\n", $time);
  end

   always_ff @(posedge clk) begin
    if (!reset) begin
      bus_peripheral.reset_assert();
    end
  end

  always @(bus_peripheral.reset_assert_response) begin
    bus_controller.reset_assert();
  end

  always @(bus_controller.reset_assert_response) begin
    bus_controller.reset_deassert();
  end


endmodule
