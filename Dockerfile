# Use NVIDIA CUDA base image with cuDNN
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    curl \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Upgrade pip
RUN pip install --upgrade pip

# Set working directory
WORKDIR /root

# Install PyTorch with CUDA 12.1 support
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Install other dependencies
RUN pip install --no-cache-dir \
    timm \
    diffusers \
    accelerate \
    torchdiffeq \
    wandb \
    jupyterlab

# Configure SSH for remote access
RUN mkdir -p /var/run/sshd && \
    echo 'root:vessl' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expose ports for Jupyter and SSH
EXPOSE 8888 22

# Default command
CMD ["/bin/bash"]
