#!/usr/bin/env bash
# Copyleft

# Define environment variables
MINICONDA=~/miniconda3/etc/profile.d/conda.sh
MINICONDA_ENV=snitch
# To activate this environment, use
#
#     $ conda activate snitch
#
# To deactivate an active environment, use
#
#     $ conda deactivate



export BENDER=~/eth/bin/bender

source $MINICONDA
conda activate $MINICONDA_ENV

export PATH=~/eth/bin:~/verible/bin:$PATH
source ~/vivado.sh