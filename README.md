[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# ISOLDE Project
## Python environment
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh
bash Miniconda3-py310_24.3.0-0-Linux-x86_64.sh 
```
create a Conda environment  
```
source ~/miniconda3/etc/profile.d/conda.sh
conda create --name snitch python=3.10
conda activate snitch
pip3 install -r python-requirements.txt
```
## Bender
Based on your linux version, select something from **https://github.com/pulp-platform/bender/releases**  

```
mkdir ~/eth && cd ~/eth
wget https://github.com/pulp-platform/bender/releases/download/v0.28.0/bender-0.28.0-x86_64-linux-gnu-ubuntu20.04.tar.gz
tar xzf bender-0.28.0-x86_64-linux-gnu-ubuntu20.04.tar.gz
mkdir bin && mv bender bin/
mkdir doc && cd doc
wget https://github.com/pulp-platform/bender/blob/master/README.md
```
## Vivado 
In home folder create  **vivado.sh** with the following content:  
```
export  XILINXD_LICENSE_FILE=<vivado licence server>   
source <instal path>/Vivado/2022.1/.settings64-Vivado.sh
```
## Verible
```
mkdir ~/verible && cd ~/verible
wget https://github.com/chipsalliance/verible/releases/download/v0.0-3640-gec69caeb/verible-v0.0-3640-gec69caeb-linux-static-x86_64.tar.gz
tar xzf verible-v0.0-3640-gec69caeb-linux-static-x86_64.tar.gz
ln -s verible-v0.0-3640-gec69caeb/bin/ bin
```
### Vivado project
in console type:
```
source ./eth.sh
cd hw/system/snitch_isolde/
make vivado-lint
```

The folder hw/system/snitch_isolde/vivado will contain the vivado project
### Vivado IP

in console type:
```
source ./eth.sh
cd hw/system/snitch_isolde/
make vivado-package-ip
```

The folder hw/system/snitch_isolde/vivado will contain the vivado project
The folder hw/system/snitch_isolde/ip will contain the vivado IP  
# Github 
## git configuration
```
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```
## github cli  
[Take GitHub to the command line](https://github.com/cli/cli#installation)  
[GitHub CLI commands](https://cli.github.com/manual/gh)  
## Instalation  
```
source ./eth.sh
conda install gh --channel conda-forge
```
## auth
```
gh auth login
gh auth setup-git
....
git push
```

# PULP Info

 Development on Snitch-related projects continues in the following new dedicated repositories:

* Snitch cluster: https://github.com/pulp-platform/snitch_cluster
* Occamy: https://github.com/pulp-platform/occamy
* Banshee: https://github.com/pulp-platform/banshee

# Snitch System

This monolithic repository hosts software and hardware for the Snitch generator and generated systems.

## Getting Started

To get started, check out the [getting started guide](https://pulp-platform.github.io/snitch/ug/getting_started/).

## Content

What can you expect to find in this repository?

- The [Snitch integer core](https://pulp-platform.github.io/snitch/rm/snitch/). This can be useful stand-alone if you are just
  interested in re-using the core for your project, e.g., as a tiny control core
  or you want to make a peripheral smart. The sky is the limit.
- The [Snitch cluster](https://pulp-platform.github.io/snitch/ug/snitch_cluster/). A highly configurable cluster containing one to many
  integer cores with optional floating-point capabilities as well as our custom
  ISA extensions `Xssr`, `Xfrep`, and `Xdma`.
- Any other system that is based on Snitch compute elements. Right now, we do not
  have any open-sourced yet, but be sure that this is going to change.

## Tool Requirements

* `verilator = v4.100`
* `bender >= v0.21.0`

## License

Snitch is being made available under permissive open source licenses.

The following files are released under Apache License 2.0 (`Apache-2.0`) see `LICENSE`:

- `sw/`
- `util/`

The following files are released under Solderpad v0.51 (`SHL-0.51`) see `hw/LICENSE`:

- `hw/`

The `sw/vendor` directory contains third-party sources that come with their own
licenses. See the respective folder for the licenses used.

- `sw/vendor/`

## Publications

If you use Snitch in your work, you can cite us:

<details>
<summary><b>Snitch: A tiny Pseudo Dual-Issue Processor for Area and Energy Efficient Execution of Floating-Point Intensive Workloads</b></summary>
<p>

```
@article{zaruba2020snitch,
  title={Snitch: A tiny Pseudo Dual-Issue Processor for Area and Energy Efficient Execution of Floating-Point Intensive Workloads},
  author={Zaruba, Florian and Schuiki, Fabian and Hoefler, Torsten and Benini, Luca},
  journal={IEEE Transactions on Computers},
  year={2020},
  publisher={IEEE}
}
```

</p>
</details>

<details>
<summary><b>Stream semantic registers: A lightweight risc-v isa extension achieving full compute utilization in single-issue cores</b></summary>
<p>

```
@article{schuiki2020stream,
  title={Stream semantic registers: A lightweight risc-v isa extension achieving full compute utilization in single-issue cores},
  author={Schuiki, Fabian and Zaruba, Florian and Hoefler, Torsten and Benini, Luca},
  journal={IEEE Transactions on Computers},
  volume={70},
  number={2},
  pages={212--227},
  year={2020},
  publisher={IEEE}
}
```

</p>
</details>

---

Other work which can be found in or contributed to this repository:

<details>
<summary><b>Banshee: A Fast LLVM-Based RISC-V Binary Translator</b></summary>
<p>

```
@INPROCEEDINGS{9643546,
  author={Riedel, Samuel and Schuiki, Fabian and Scheffler, Paul and Zaruba, Florian and Benini, Luca},
  booktitle={2021 IEEE/ACM International Conference On Computer Aided Design (ICCAD)}, 
  title={Banshee: A Fast LLVM-Based RISC-V Binary Translator}, 
  year={2021},
  volume={},
  number={},
  pages={1-9},
  doi={10.1109/ICCAD51958.2021.9643546}
}
```

</p>
</details>

<details>
<summary><b>Manticore: A 4096-Core RISC-V Chiplet Architecture for Ultraefficient Floating-Point Computing</b></summary>
<p>

```
@ARTICLE{9296802,
  author={Zaruba, Florian and Schuiki, Fabian and Benini, Luca},
  journal={IEEE Micro}, 
  title={Manticore: A 4096-Core RISC-V Chiplet Architecture for Ultraefficient Floating-Point Computing}, 
  year={2021},
  volume={41},
  number={2},
  pages={36-42},
  doi={10.1109/MM.2020.3045564}
}
```

</p>
</details>

<details>
<summary><b>Indirection Stream Semantic Register Architecture for Efficient Sparse-Dense Linear Algebra</b></summary>
<p>

```
@INPROCEEDINGS{9474230,
  author={Scheffler, Paul and Zaruba, Florian and Schuiki, Fabian and Hoefler, Torsten and Benini, Luca},
  booktitle={2021 Design, Automation & Test in Europe Conference & Exhibition (DATE)}, 
  title={Indirection Stream Semantic Register Architecture for Efficient Sparse-Dense Linear Algebra}, 
  year={2021},
  volume={},
  number={},
  pages={1787-1792},
  doi={10.23919/DATE51398.2021.9474230}
}
```

</p>
</details>

