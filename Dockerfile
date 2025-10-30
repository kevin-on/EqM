# Use NVIDIA CUDA base image with cuDNN
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/conda/bin:$PATH \
    CONDA_AUTO_UPDATE_CONDA=false

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    conda clean -afy

# Set working directory
WORKDIR /root

# Copy environment.yml
COPY environment.yml /root/environment.yml

# Create conda environment from environment.yml
RUN conda env create -f environment.yml && \
    conda clean -afy

# Activate conda environment by default
SHELL ["conda", "run", "-n", "eqm", "/bin/bash", "-c"]

# Install JupyterLab for interactive development
RUN conda run -n eqm pip install jupyterlab

# Configure SSH for remote access
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose ports for Jupyter and SSH
EXPOSE 8888 22

# Default command
CMD ["/bin/bash"]
