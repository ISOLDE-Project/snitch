// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51



`include "renode_assign.svh"



// verilog_lint: waive-start package-filename
package renode_aximem_pkg;

//`include "axi/typedef.svh"

  localparam int unsigned AddrWidth = 32;
  localparam int unsigned DataWidth = 32;
  localparam int unsigned IdWidth = 3;
  localparam int unsigned UserWidth = 1;


  typedef logic [AddrWidth-1:0]         addr_t;
  typedef logic [DataWidth-1:0]         data_t;
  typedef logic [DataWidth/8-1:0]   strb_t;
  typedef logic [IdWidth-1:0]           id_t;
  typedef logic [UserWidth-1:0]         user_t;


   `AXI_TYPEDEF_ALL(axi_connection, addr_t, id_t, data_t, strb_t, user_t)


endpackage

module master (
    input  logic                             clk_i,
    input  logic                             rst_ni,
    output  renode_aximem_pkg::axi_connection_req_t  axi_req,
    input   renode_aximem_pkg::axi_connection_resp_t axi_resp
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


  renode_axi_if #(.AddressWidth(32),.DataWidth(64),.TransactionIdWidth(3)) i_axi_if(.aclk(clk_i));
  renode_aximem_pkg::axi_connection_req_t  axi_req;
  renode_aximem_pkg::axi_connection_resp_t axi_resp;
  //
 

  `__RENODE_TO_RESP(axi_resp, i_axi_if)
  `__REQ_TO_RENODE(i_axi_if, axi_req)

  renode_memory mem (
      .s_axi_if(i_axi_if),
      .bus_peripheral(bus_peripheral)
  );

  master ctr (
      .clk_i,
      .rst_ni(i_axi_if.areset_n),
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
    i_axi_if.areset_n = 0;
    $display("[%0t] Model running...\n", $time);
  end

   always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      i_axi_if.areset_n = 0;
      bus_peripheral.reset_assert();
    end
  end

  always @(bus_peripheral.reset_assert_response) begin
    if (rst_ni) begin
      bus_peripheral.reset_deassert();
    end
  end



endmodule
