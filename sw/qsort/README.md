# Snitch Software Examples

Build and run quick sort example
in folder **sw/qsort**: 
```bash
mkdir build & cd build
cmake -DSNITCH_RUNTIME=snRuntime-cluster  -DHW_SYS=hw/system/snitch_cluster ..
make
../../../hw/system/snitch_cluster/bin/snitch_cluster.vlt  quicksort
```

