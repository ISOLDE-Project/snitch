# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

.global _start
.global _start_core
.global __bootdata_start 

.section .bootloader, "ax"  # Define the section with executable attributes

_start:
    csrr  a0, mhartid
    lw    a1, __bootdata_start
    jal   zero, _start_core;
