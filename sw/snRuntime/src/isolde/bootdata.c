// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#include <stdint.h>

struct BootData {
    uint32_t boot_addr;
    uint32_t core_count;
    uint32_t hartid_base;
    uint32_t tcdm_start;
    uint32_t tcdm_size;
    uint32_t tcdm_offset;
    uint64_t global_mem_start;
    uint64_t global_mem_end;
    uint32_t cluster_count;
    uint32_t s1_quadrant_count;
    uint32_t clint_base;
};


__attribute__((section(".bootdata"))) 
const struct BootData BOOTDATA = {.boot_addr = 0x1000,
                           .core_count = 2,
                           .hartid_base = 0,
                           .tcdm_start = 0x100000,
                           .tcdm_size = 0x20000,
                           .tcdm_offset = 0x0,
                           .global_mem_start = 0x80000000,
                           .global_mem_end = 0x100000000,
                           .cluster_count = 1,
                           .s1_quadrant_count = 1,
                           .clint_base = 0xffff0000};


