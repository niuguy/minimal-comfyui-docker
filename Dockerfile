# Multi-stage build for optimization
FROM python:3.12-slim as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 as runtime

# Copy Python from base stage
COPY --from=base /usr/local /usr/local
COPY --from=base /usr/bin/python* /usr/bin/
COPY --from=base /lib/x86_64-linux-gnu/libpython* /lib/x86_64-linux-gnu/

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    nginx \
    supervisor \
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
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip install --no-cache-dir xformers && \
    pip install --no-cache-dir -r requirements.txt && \
    pip cache purge

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