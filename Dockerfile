FROM nvidia/cuda:12.8.1-devel-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    git \
    wget \
    curl \
    nginx \
    supervisor \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PORT=8188
ENV COMFYUI_VERSION=v0.3.47

# Create workspace
WORKDIR /workspace
RUN mkdir -p /workspace/logs

# Install ComfyUI
RUN git clone --branch ${COMFYUI_VERSION} https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI

# Create virtual environment and install dependencies
WORKDIR /workspace/ComfyUI
RUN python3 -m venv --system-site-packages venv && \
    . venv/bin/activate && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128 && \
    pip3 install --no-cache-dir xformers && \
    pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir accelerate && \
    pip3 install --no-cache-dir numpy==1.26.4 && \
    pip3 cache purge

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${COMFYUI_PORT}/ || exit 1

# Expose ports
EXPOSE ${COMFYUI_PORT} 80

# Start services
CMD ["/start.sh"]