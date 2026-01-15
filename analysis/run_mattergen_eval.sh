#!/bin/bash -l

# SETUP RESOURCE
#SBATCH --time=2:00:00
#SBATCH --ntasks=16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gjers043@umn.edu
#SBATCH -p msigpu
#SBATCH --gres=gpu:a100:1
#SBATCH --output=msi_output/mattergen-%j.txt

# MatterGen Hyperparameters
# > Note that GENERATION_MODE should be set to either "unconditional" or
# > "property-conditioned" for the two main modes of generation. To condition on
# > multiple properties, simply adjust the PROPERTIES variable according to the
# > repo's README file.

GENERATION_MODE="unconditional"             # generation mode
MODEL_NAME=ml_bulk_modulus                  # model name (check docs)
RESULTS_PATH="analysis/results/bulk_modulus_01_13/440_diamond/" # path to results (check docs)
BATCH_SIZE=16                               # batch size
N_BATCHES=16                                # number of batches
N_SAMPLES=$(($BATCH_SIZE * $N_BATCHES))     # total number of samples

PROPERTIES="{'ml_bulk_modulus':440}"        # property conditions
GAMMA=2.0                                   # gamma parameter in classifier-free diffusion guidance


# Print Hyperparameters to Output
echo "* -------- MatterGen Hyperparameters -------- *"
echo "    GENERATION MODE: $GENERATION_MODE"
echo "    MODEL NAME: $MODEL_NAME"
echo "    PATH TO RESULTS: $RESULTS_PATH"
echo "    ---"
echo "    BATCH SIZE: $BATCH_SIZE"
echo "    NUMBER OF BATCHES: $N_BATCHES"
echo "    TOTAL NUMBER OF SAMPLES: $N_SAMPLES"
echo "    ---"
echo "    (ignore the following if in unconditional mode!)"
echo "    PROPERTIES: $PROPERTIES"
echo "    GAMMA: $GAMMA"
echo "* ------------------------------------------- *"

# Locate Conda Profile and Environment
source ~/.bashrc
source /users/6/gjers043/anaconda3/etc/profile.d/conda.sh
conda activate mattergen-env

# Load Modules
module load cuda/11.8.0-gcc-7.2.0-xqzqlf2

# Run MatterGen Evaluation
cd /users/6/gjers043/mattergen/

# (1) Load Reference Dataset
git config --local credential.helper store
git lfs pull -I data-release/alex-mp/reference_MP2020correction.gz --exclude=""

# (2) Run Evaluation
mattergen-evaluate \
    --structures_path=$RESULTS_PATH \
    --relax=True \
    --structure_matcher='disordered' \
    --save_as="$RESULTS_PATH/metrics.json"