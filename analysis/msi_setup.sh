# This script contains the steps taken to install prerequisites for MatterGen.

# For setup, get interactive GPU (A40 or A100) on MSI
# srun -N 1 -t 04:00:00 --ntasks-per-node=1 -p interactive-gpu --mem-per-cpu=20gb --gres=gpu:a40:1 --pty bash
# srun -N 1 -t 04:00:00 --ntasks-per-node=1 -p msigpu --mem-per-cpu=20gb --gres=gpu:a100:1 --pty bash

# Load CUDA 11.8 and GCC 9.2.0 modules
module load gcc/9.2.0
module load cuda/11.8.0-gcc-7.2.0-xqzqlf2

# Create new Conda environment
conda create --name mattergen-env python=3.10

# Activate environment
conda activate mattergen-env

# Set CUDA Architecture for A100 or A40
export TORCH_CUDA_ARCH_LIST="8.0;8.6"

# Add CUDA Path to environment
export CUDA_HOME=/common/software/install/spack/linux-centos7-ivybridge/gcc-7.2.0/cuda-11.8.0-xqzqlf2v77opht3bv4onsqt7uuiomqec
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Force build system to use loaded GCC
export CC=$(which gcc)
export CXX=$(which g++)
export CUDAHOSTCXX=$(which g++)

# Disable build isolation
export PIP_NO_BUILD_ISOLATION=1

# Ensure Intel MKL Compatibility
export MKL_THREADING_LAYER=GNU
echo "export MKL_THREADING_LAYER=GNU" >> ~/.bashrc

# Install PyTorch with CUDA 11.8
pip install torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 -i https://download.pytorch.org/whl/cu118

# Ensure Compatible NumPy before PyG Installation
pip install 'numpy<2.0'

# Install PyG build dependencies
pip install setuptools wheel ninja meson-python pybind11 cython pythran
conda install -c conda-forge openblas

# Install PyG
pip install --no-build-isolation --verbose git+https://github.com/pyg-team/pyg-lib.git
pip install --no-build-isolation --no-binary :all: --no-cache-dir torch-scatter
pip install --no-build-isolation --no-binary :all: --no-cache-dir torch-sparse
pip install --no-build-isolation --no-binary :all: --no-cache-dir torch-cluster
pip install --no-build-isolation --no-binary :all: --no-cache-dir torch-spline-conv
pip install torch-geometric

# Install MatterGen without dependencies
pip install --no-deps -e .

# Install MatterGen dependencies
pip install 'ase<=3.25.0' autopep8 cachetools contextlib2 'emmet-core>=0.84.2' \
    fire huggingface-hub 'hydra-core==1.3.1' 'hydra-joblib-launcher==1.1.5' \
    'jupyterlab>=4.2.5' lmdb 'matplotlib==3.8.4' 'matscipy>=0.7.0' \
    'mattersim>=1.1' 'monty==2024.7.30' 'notebook>=7.2.2' 'numpy<2.0' \
    'omegaconf==2.3.0' 'pymatgen>=2024.6.4' pylint pytest \
    'pytorch-lightning==2.0.6' 'seaborn>=0.13.2' setuptools SMACT \
    'sympy>=1.11.1' tqdm 'wandb>=0.10.33'

# Test for Git LFS
git lfs --version

# If necessary, install Git LFS
conda install -c conda-forge git-lfs
git lfs install
