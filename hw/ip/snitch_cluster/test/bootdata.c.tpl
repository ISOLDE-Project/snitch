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
const struct BootData BOOTDATA = {.boot_addr = ${hex(cfg['cluster']['boot_addr'])},
                           .core_count = ${cfg['cluster']['nr_cores']},
                           .hartid_base = ${cfg['cluster']['cluster_base_hartid']},
                           .tcdm_start = ${hex(cfg['cluster']['cluster_base_addr'])},
                           .tcdm_size = ${hex(cfg['cluster']['tcdm']['size'] * 1024)},
                           .tcdm_offset = ${hex(cfg['cluster']['cluster_base_offset'])},
                           .global_mem_start = ${hex(cfg['dram']['address'])},
                           .global_mem_end = ${hex(cfg['dram']['address'] + cfg['dram']['length'])},
                           .cluster_count = ${cfg['s1_quadrant']['nr_clusters']},
                           .s1_quadrant_count = ${cfg['nr_s1_quadrant']},
                           .clint_base = ${hex(cfg['peripherals']['clint']['address'])}};


