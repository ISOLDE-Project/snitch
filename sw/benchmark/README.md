# Build verilated
In root folder make sure you have:
```
. ./eth.sh
cd hw/system/snitch_cluster
make bin/snitch_cluster.vlt
```
# Build SW
In root folder make sure you have:
```
. ./eth.sh
cd sw/benchmark
mkdir build && cd build
cmake -DSNITCH_RUNTIME=snRuntime-cluster  ..
make benchmark-matmul-all

```

# Run
```
(snitch) sh-5.0$ ../../../hw/system/snitch_cluster/bin/snitch_cluster.vlt benchmark-matmul-all
```
Output should be similar to:   
```
Wrote 36 bytes of bootrom to 0x1000
Wrote entry point 0x800021a0 to bootloader slot 0x1020
Wrote 38 bytes of bootdata to 0x1024
[Tracer] Logging Hart          8 to logs/trace_hart_00008.dasm
[Tracer] Logging Hart          0 to logs/trace_hart_00000.dasm
[Tracer] Logging Hart          1 to logs/trace_hart_00001.dasm
[Tracer] Logging Hart          2 to logs/trace_hart_00002.dasm
[Tracer] Logging Hart          3 to logs/trace_hart_00003.dasm
[Tracer] Logging Hart          4 to logs/trace_hart_00004.dasm
[Tracer] Logging Hart          5 to logs/trace_hart_00005.dasm
[Tracer] Logging Hart          6 to logs/trace_hart_00006.dasm
[Tracer] Logging Hart          7 to logs/trace_hart_00007.dasm
Cycles (Baseline): 2479
Cycles (SSR):      1456
Cycles (SSR+FREP): 1144
```