# Copyright 2020 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
# Florian Zaruba <zarubaf@iis.ee.ethz.ch>

#######################
# Makefile invocation #
#######################

DEBUG          ?= OFF  # ON to turn on debugging symbols
CFG_OVERRIDE   ?=      # Override default config file
SELECT_RUNTIME ?=      # Select snRuntime implementation: "banshee" or "rtl" (default)

.DEFAULT_GOAL := help
.PHONY: all clean
all: sw
clean: clean-sw clean-vsim clean-vlt clean-vcs clean-logs clean-bender

############
# Makefrag #
############

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))
ROOT        := ${MKFILE_DIR}../../..
TARGET       = snitch_cluster
include $(ROOT)/util/Makefrag

############
# Programs #
############

REGGEN          ?= $(shell $(BENDER) path register_interface)/vendor/lowrisc_opentitan/util/regtool.py
CLUSTER_GEN     ?= $(ROOT)/util/clustergen.py
CLUSTER_GEN_SRC ?= $(wildcard $(ROOT)/util/clustergen/*.py)

QUESTA_64BIT = -64
VSIM      	?= vsim ${QUESTA_64BIT}
VLOG      	?= vlog ${QUESTA_64BIT}

#########################
# Files and directories #
#########################

PLATFORM_HEADERS_DIR ?= sw/runtime/shared
BIN_DIR              ?= bin
GENERATED_DIR        ?= $(MKFILE_DIR)generated

# Verilated and compiled snitch cluster
VLT_AR = ${VLT_BUILDDIR}/Vtestharness__ALL.a

# If the configuration file is overriden on the command-line (through
# CFG_OVERRIDE) and this file differs from the least recently used
# (LRU) config, all targets depending on the configuration file have
# to be rebuilt. This file is used to express this condition as a
# prerequisite for other rules.
CFG = cfg/lru.hjson

#####################
# Simulator options #
#####################

VLT_FLAGS  += --trace

VSIM_FLAGS += -t 1ps
VSIM_FLAGS += -voptargs=+acc
VSIM_FLAGS += -do "log -r /*; run -a"

VLOG_FLAGS += -svinputport=compat
VLOG_FLAGS += -override_timescale 1ns/1ps
VLOG_FLAGS += -suppress 2583
VLOG_FLAGS += -suppress 13314
VLOG_FLAGS += ${QUESTA_64BIT}

###############
# C testbench #
###############

TB_CC_SOURCES += \
	${TB_DIR}/common_lib.cc \
	$(GENERATED_DIR)/bootdata.cc

VLT_CC_SOURCES += \
	${TB_DIR}/verilator_lib.cc \
	${TB_DIR}/tb_bin.cc

TB_CC_FLAGS += \
	-std=c++14 \
	-I${MKFILE_DIR}/test \
	-I${FESVR}/include \
	-I${TB_DIR}

#################
# Prerequisites #
#################

CLUSTER_GEN_PREREQ = ${CLUSTER_GEN} ${CLUSTER_GEN_SRC}

$(CFG): FORCE
	@# If the LRU config file doesn't exist, we use the default config.
	@if [ ! -e $@ ] ; then \
		DEFAULT_CFG="cfg/ZynqUltrascalePlus.hjson"; \
		echo "Using default config file: $$DEFAULT_CFG"; \
		cp $$DEFAULT_CFG $@; \
	fi
	@# If a config file is provided on the command-line and it differs
	@# from the LRU config file then we override the LRU file with it
	@if [ $(CFG_OVERRIDE) ] ; then \
		echo "Overriding config file with: $(CFG_OVERRIDE)"; \
		if cmp -s $(CFG_OVERRIDE) $@ ; then \
			echo "Override and LRU config files are equivalent. Nothing to be done."; \
		else \
			cp $(CFG_OVERRIDE) $@; \
		fi \
	fi
FORCE:

test/bootrom.elf test/bootrom.dump test/bootrom.bin: test/bootrom.S test/bootrom.ld
	riscv64-unknown-elf-gcc -mabi=ilp32d -march=rv32imafd -static -nostartfiles -Ttest/bootrom.ld $< -o test/bootrom.elf
	riscv64-unknown-elf-objdump -d test/bootrom.elf > test/bootrom.dump
	riscv64-unknown-elf-objcopy -j .text -O binary test/bootrom.elf test/bootrom.bin

############
# Software #
############

CLUSTER_GEN_HEADERS = snitch_cluster_cfg.h \
					  snitch_cluster_addrmap.h

REGGEN_HEADERS = snitch_cluster_peripheral.h

PLATFORM_HEADERS = $(addprefix $(PLATFORM_HEADERS_DIR)/,$(CLUSTER_GEN_HEADERS) $(REGGEN_HEADERS))

.PHONY: sw clean-headers clean-sw

sw: $(PLATFORM_HEADERS)
	$(MAKE) -C sw/

clean-headers:
	rm -f $(PLATFORM_HEADERS)

clean-sw: clean-headers
	$(MAKE) -C sw/ TARGET=clean

# CLUSTERGEN headers
$(addprefix $(PLATFORM_HEADERS_DIR)/,$(CLUSTER_GEN_HEADERS)): %.h: $(CFG) $(CLUSTER_GEN_PREREQ) %.h.tpl
	@echo "[CLUSTERGEN] Generate $@"
	$(CLUSTER_GEN) -c $< --outdir $(PLATFORM_HEADERS_DIR) --template $@.tpl

# REGGEN headers
$(PLATFORM_HEADERS_DIR)/snitch_cluster_peripheral.h: $(ROOT)/hw/ip/snitch_cluster/src/snitch_cluster_peripheral/snitch_cluster_peripheral_reg.hjson $(REGGEN)
	$(call reggen_generate_header,$@,$<)

#######
# RTL #
#######

$(GENERATED_DIR):
	mkdir -p $@

$(GENERATED_DIR)/snitch_cluster_wrapper.sv: ${CFG} ${CLUSTER_GEN_PREREQ} | $(GENERATED_DIR)
	$(CLUSTER_GEN) -c $< -o $(GENERATED_DIR) --wrapper

$(GENERATED_DIR)/link.ld: ${CFG} ${CLUSTER_GEN_PREREQ} | $(GENERATED_DIR)
	$(CLUSTER_GEN) -c $< -o $(GENERATED_DIR) --linker

$(GENERATED_DIR)/memories.json: ${CFG} ${CLUSTER_GEN_PREREQ} | $(GENERATED_DIR)
	$(CLUSTER_GEN) -c $< -o $(GENERATED_DIR) --memories

$(GENERATED_DIR)/bootdata.cc: ${CFG} ${CLUSTER_GEN_PREREQ} | $(GENERATED_DIR)
	$(CLUSTER_GEN) -c $< -o $(GENERATED_DIR) --bootdata

#############
# Verilator #
#############

.PHONY: clean-vlt clean-generated

# Clean all build directories and temporary files for Questasim simulation
clean-vlt: clean-work
	rm -fv $(VLT_BUILDDIR)/*Vtestharness*.*
	rm -fv $(VLT_BUILDDIR)/files
	rm -fv $(VLT_BUILDDIR)/verilated*
	rm -fv $(BIN_DIR)/$(TARGET).vlt

clean-generated:
	rm -rf generated

$(VLT_BUILDDIR)/files: Bender.yml
	$(BENDER) script verilator $(VLT_BENDER) >$@
	touch $@

$(BIN_DIR)/$(TARGET).vlt: $(VLT_BUILDDIR)/files ${TB_CC_SOURCES} ${VLT_CC_SOURCES} ${VLT_BUILDDIR}/lib/libfesvr.a
	mkdir -p $(dir $@)
	$(VLT) $(VLT_FLAGS) -Mdir $(VLT_BUILDDIR) \
		-f $(VLT_BUILDDIR)/files \
		-CFLAGS "$(VLT_CFLAGS)" \
		-LDFLAGS "-Llib -lfesvr -lpthread" \
		-o ../$@ --cc --exe --top-module testharness $(TB_CC_SOURCES) $(VLT_CC_SOURCES)
	$(MAKE) -C $(VLT_BUILDDIR) -j $(shell nproc) -f Vtestharness.mk

##reports
$(BIN_DIR)/report.json: $(VLT_BUILDDIR)/files ${TB_CC_SOURCES} ${VLT_CC_SOURCES} 
	mkdir -p $(dir $@)
	$(VLT) $(VLT_FLAGS) -Mdir $(VLT_BUILDDIR) \
		-f $(VLT_BUILDDIR)/files \
		-CFLAGS "$(VLT_CFLAGS)" \
		-LDFLAGS "-Llib -lfesvr -lpthread" \
		 --json-only-output $@ --top-module testharness $(TB_CC_SOURCES) $(VLT_CC_SOURCES)

$(BIN_DIR)/report.xml: $(VLT_BUILDDIR)/files ${TB_CC_SOURCES} ${VLT_CC_SOURCES} 
	mkdir -p $(dir $@)
	$(VLT) $(VLT_FLAGS) -Mdir $(VLT_BUILDDIR) \
		-f $(VLT_BUILDDIR)/files \
		-CFLAGS "$(VLT_CFLAGS)" \
		-LDFLAGS "-Llib -lfesvr -lpthread" \
		--xml-output $@ --top-module testharness $(TB_CC_SOURCES) $(VLT_CC_SOURCES)
	

############
# Modelsim #
############

.PHONY: clean-vsim

# Clean all build directories and temporary files for Questasim simulation
clean-vsim: clean-work
	rm -rf bin/snitch_cluster.vsim bin/snitch_cluster.vsim.gui work-vsim vsim.wlf

${VSIM_BUILDDIR}/compile.vsim.tcl: $(VSIM_SOURCES) ${TB_SRCS} ${TB_CC_SOURCES}
	vlib $(dir $@)
	${BENDER} script vsim ${VSIM_BENDER} --vlog-arg="${VLOG_FLAGS} -work $(dir $@) " > $@
	echo '${VLOG} -work $(dir $@) ${TB_CC_SOURCES} -ccflags "$(TB_CC_FLAGS)"' >> $@
	echo 'return 0' >> $@

# Build compilation script and compile all sources for Questasim simulation
bin/snitch_cluster.vsim: ${VSIM_BUILDDIR}/compile.vsim.tcl work/lib/libfesvr.a
	$(call QUESTASIM,tb_bin)

#######
# VCS #
#######

.PHONY: clean-vcs

# Clean all build directories and temporary files for VCS simulation
clean-vcs: clean-work
	rm -rf bin/snitch_cluster.vcs work-vcs

# Build compilation script and compile all sources for VCS simulation
bin/snitch_cluster.vcs: work-vcs/compile.sh work/lib/libfesvr.a $(GENERATED_DIR)/snitch_cluster_wrapper.sv ${TB_DIR}/common_lib.cc $(GENERATED_DIR)/bootdata.cc
	mkdir -p bin
	vcs -Mlib=work-vcs -Mdir=work-vcs -o bin/snitch_cluster.vcs -cc $(CC) -cpp $(CXX) \
		-assert disable_cover -override_timescale=1ns/1ps -full64 tb_bin ${TB_DIR}/rtl_lib.cc ${TB_DIR}/common_lib.cc $(GENERATED_DIR)/bootdata.cc \
		-CFLAGS "-std=c++14 -I${MKFILE_DIR} -I${MKFILE_DIR}/test -I${FESVR}/include -I${TB_DIR}" -LDFLAGS "-L${FESVR}/lib" -lfesvr

##########
# Traces #
##########

$(LOGS_DIR)/perf.csv: $(shell (ls $(LOGS_DIR)/trace_hart_*.dasm 2>/dev/null | sed 's/trace_hart/hart/' | sed 's/.dasm/_perf.json/')) \
		$(ROOT)/util/trace/perf_csv.py
	$(PYTHON) $(ROOT)/util/trace/perf_csv.py -o $@ -i $(LOGS_DIR)/hart_*_perf.json

$(LOGS_DIR)/event.csv: $(shell (ls $(LOGS_DIR)/trace_hart_*.dasm 2>/dev/null | sed 's/trace_hart/hart/' | sed 's/.dasm/_perf.json/')) \
		$(ROOT)/util/trace/perf_csv.py
	$(PYTHON) $(ROOT)/util/trace/perf_csv.py -o $@ -i $(LOGS_DIR)/hart_*_perf.json --filter tstart tend

########
# Util #
########

.PHONY: clean-work clean-bender clean-logs help

clean-work:
	rm -rf work

clean-bender:
	rm -rf Bender.lock .bender/

clean-logs:
	rm -rf logs/

# Help command
Blue=\033[1;34m
Black=\033[0m
help:
	@echo -e "${Blue}Makefile Targets${Black} for the ${Blue}Snitch Cluster${Black}"
	@echo -e "Use 'make <target>' where <target> is one of:"
	@echo -e ""
	@echo -e "${Blue}help           ${Black}Show an overview of all Makefile targets."
	@echo -e ""
	@echo -e "${Blue}bin/snitch_cluster.vcs  ${Black}Build compilation script and compile all sources for VCS simulation."
	@echo -e "${Blue}bin/snitch_cluster.vlt  ${Black}Build compilation script and compile all sources for Verilator simulation."
	@echo -e "${Blue}bin/snitch_cluster.vsim ${Black}Build compilation script and compile all sources for Questasim simulation."
	@echo -e ""
	@echo -e "${Blue}sw             ${Black}Build all software."
	@echo -e ""
	@echo -e "${Blue}clean          ${Black}Clean everything except traces in logs directory."
	@echo -e "${Blue}clean-bender   ${Black}Clean Bender dependencies."
	@echo -e "${Blue}clean-sw       ${Black}Clean all software."
	@echo -e "${Blue}clean-logs     ${Black}Delete all traces in logs directory."
	@echo -e "${Blue}clean-vcs      ${Black}Clean all build directories and temporary files for VCS simulation."
	@echo -e "${Blue}clean-vlt      ${Black}Clean all build directories and temporary files for Verilator simulation."
	@echo -e "${Blue}clean-vsim     ${Black}Clean all build directories and temporary files for Questasim simulation."
	@echo -e ""
	@echo -e "Additional useful targets from the included Makefrag:"
	@echo -e "${Blue}traces         ${Black}Generate the better readable traces in .logs/trace_hart_<hart_id>.txt with spike-dasm."
	@echo -e "${Blue}annotate       ${Black}Annotate the better readable traces in .logs/trace_hart_<hart_id>.s with the source code related with the retired instructions."


$(GENERATED_DIR)/sources.tcl: $(CFG) Makefile
	bender script vivado | tee $(GENERATED_DIR)/sources.tcl


.PHONY: vivado-lint vivado-syn vivado-clean

vivado-lint: $(GENERATED_DIR)/snitch_cluster_wrapper.sv $(GENERATED_DIR)/sources.tcl
	rm -rf vivado && mkdir -p vivado
	@echo "synth_design -rtl -rtl_skip_mlo -name rtl_1" >launch_runs.tcl
	vivado -mode batch -source ./create_project.tcl ./launch_runs.tcl | tee vivado.log

vivado-syn: $(GENERATED_DIR)/snitch_cluster_wrapper.sv $(GENERATED_DIR)/sources.tcl
	rm -rf vivado && mkdir -p vivado
	@echo "launch_runs synth_1" >  launch_runs.tcl
	@echo "wait_on_run synth_1" >> launch_runs.tcl
	vivado -mode batch -source ./create_project.tcl ./launch_runs.tcl | tee vivado.log


vivado-clean:
	rm -fr vivado
	rm -f vivado*.*
	rm -f launch_runs.tcl
	