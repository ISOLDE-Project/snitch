// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#include <printf.h>

#include "Vtestharness.h"
#include "Vtestharness__Dpi.h"
#include "logger.hpp"
#include "sim.hh"
#include "tb_lib.hh"

DECLARE_LOGGER(MemAccess, "logs/MemAccess.csv")

namespace sim {

// Number of cycles between HTIF checks.
const int HTIFTimeInterval = 200;
void sim_thread_main(void *arg) { ((Sim *)arg)->main(); }

// Sim time.
// int TIME = 0;

Sim::Sim(int argc, char **argv)
    : htif_t(argc, argv), contextp{new VerilatedContext}, main_time(0) {
    // Search arguments for `--vcd` flag and enable waves if requested
    // Create logs/ directory in case we have traces to put under it
   // Verilated::mkdir("logs");
    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);
}

void Sim::idle() { target.switch_to(); }

/// Execute the simulation.
int Sim::run() {
    host = context_t::current();
    target.init(sim_thread_main, this);
    return htif_t::run();
}

void Sim::main() {
    // intialise csv file
    {
        std::ostringstream asc;
        asc << "mem_port,access,len,address\n";
        MemAccess::getInstance().header(asc);
    }

    // Initialize verilator environment.
    // Verilated::traceEverOn(true);
    // Allocate the simulation state and VCD trace.
    // auto top = std::make_unique<Vtestharness>();
    const std::unique_ptr<Vtestharness> top{
        new Vtestharness{contextp.get(), "TOP"}};
    auto tfp = std::make_unique<VerilatedVcdC>();

    top->trace(tfp.get(), 8);  // Trace 99 levels of hierarchy
    Verilated::mkdir("logs");
    tfp->open("logs/sim.vcd");
    bool clk_i = 0, rst_ni = 0;
    contextp->time(0);
    // Trace 8 levels of hierarchy.
    // if (vlt_vcd) {
    //     top->trace(vcd.get(), 8);
    //     vcd->open("sim.vcd");
    //     vcd->dump(TIME);
    // }
    // TIME += 2;

    while (!contextp->gotFinish()) {
        contextp->timeInc(1);

        clk_i = !clk_i;
        rst_ni = main_time >= 8;
        top->clk_i = clk_i;
        top->rst_ni = rst_ni;
        // Evaluate the DUT.
        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();
        tfp->dump(main_time);
        main_time++;
        // Switch to the HTIF interface in regular intervals.
        if (main_time % HTIFTimeInterval == 0) {
            host->switch_to();
        }
    }

    // Final model cleanup
    top->final();
    tfp->close();
    // printf("main_time=%fns\n",
    //        ((double)main_time) / (-contextp->timeprecision()));
    // Final simulation summary
    contextp->statsPrintSummary();
}
}  // namespace sim

// Verilator callback to get the current time.
//double sc_time_stamp() { return sim::TIME * 1e-9; }

// DPI calls.
void tb_memory_read(const char *inst_name, long long addr, int len,
                    const svOpenArrayHandle data) {
    {
        std::ostringstream out;
        out << inst_name << ",Read," << len * 8 << "," << std::hex << addr
            << std::dec << "\n";
        MemAccess::getInstance().info(out);
    }
    void *data_ptr = svGetArrayPtr(data);
    assert(data_ptr);
    sim::MEM.read(addr, len, (uint8_t *)data_ptr);
}

void tb_memory_write(const char *inst_name, long long addr, int len,
                     const svOpenArrayHandle data,
                     const svOpenArrayHandle strb) {
    {
        std::ostringstream out;
        out << inst_name << ",Write," << len * 8 << "," << std::hex << addr
            << std::dec << "\n";
        MemAccess::getInstance().info(out);
    }
    const void *data_ptr = svGetArrayPtr(data);
    const void *strb_ptr = svGetArrayPtr(strb);
    assert(data_ptr);
    assert(strb_ptr);
    sim::MEM.write(addr, len, (const uint8_t *)data_ptr,
                   (const uint8_t *)strb_ptr);
}

const long long clint_addr = sim::BOOTDATA.clint_base;
const long num_cores = sim::BOOTDATA.core_count;

void clint_tick(const svOpenArrayHandle msip) {
    uint8_t *msip_ptr = (uint8_t *)svGetArrayPtr(msip);
    assert(msip_ptr);
    uint32_t read_val;
    for (int i = 0; i < num_cores; i++) {
        if (i % 32 == 0)
            sim::MEM.read(clint_addr + i / 32, sizeof(uint32_t),
                          (uint8_t *)&read_val);
        msip_ptr[i] = (read_val & (1 << (i % 32))) != 0 ? 1 : 0;
    }
}
