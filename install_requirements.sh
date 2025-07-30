#!/bin/bash
set -euo pipefail

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --no-cache-dir --upgrade pip

# Detect CUDA version and install compatible PyTorch + xformers
CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $6}' | cut -c2- | cut -d'.' -f1,2)

echo "Detected CUDA version: $CUDA_VERSION"

case "$CUDA_VERSION" in
    "12.4")
        echo "Installing PyTorch for CUDA 12.4"
        pip install --no-cache-dir \
            torch==2.6.0+cu124 \
            torchvision==0.21.0+cu124 \
            torchaudio==2.6.0+cu124 \
            --index-url https://download.pytorch.org/whl/cu124
        pip install --no-cache-dir xformers==0.0.29.post3
        ;;
    "12.1")
        echo "Installing PyTorch for CUDA 12.1"
        pip install --no-cache-dir \
            torch==2.6.0+cu121 \
            torchvision==0.21.0+cu121 \
            torchaudio==2.6.0+cu121 \
            --index-url https://download.pytorch.org/whl/cu121
        pip install --no-cache-dir xformers==0.0.29.post3
        ;;
    *)
        echo "Installing default PyTorch (CPU + CUDA 12.1)"
        pip install --no-cache-dir \
            torch==2.6.0+cu121 \
            torchvision==0.21.0+cu121 \
            torchaudio==2.6.0+cu121 \
            --index-url https://download.pytorch.org/whl/cu121
        pip install --no-cache-dir xformers==0.0.29.post3
        ;;
esac

# Install ComfyUI requirements
pip install --no-cache-dir -r requirements.txt

# Install additional useful packages
pip install --no-cache-dir \
    accelerate \
    transformers \
    diffusers

# Clear pip cache
pip cache purge

echo "✅ Dependencies installed successfully!"