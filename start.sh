#!/bin/bash
set -euo pipefail

export PYTHONUNBUFFERED=1

echo "Starting ComfyUI Minimal Docker..."
echo "ComfyUI Version: ${COMFYUI_VERSION:-latest}"
echo "Port: ${COMFYUI_PORT:-8188}"

# Create logs directory
mkdir -p /workspace/logs

# Generate SSH host keys if they don't exist (security improvement)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
fi

# Function to handle shutdown gracefully
shutdown_handler() {
    echo "Received shutdown signal, stopping services..."
    supervisorctl stop all
    nginx -s quit
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Start supervisor to manage services
echo "Starting services with supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf