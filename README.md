# Minimal ComfyUI Docker

A streamlined, production-ready Docker image for ComfyUI with best practices and RunPod optimization.

## Features

✅ **Production Ready**
- Multi-stage build for optimized image size
- Health checks and graceful shutdown
- Comprehensive logging and error handling
- Security headers and proper NGINX configuration

✅ **RunPod Optimized**
- Fast startup times
- Minimal resource usage
- Proper port configuration for RunPod templates

✅ **Always Up-to-Date**
- 🤖 Automatic ComfyUI version updates (daily checks)
- 📦 Weekly builds with latest base images
- 🔄 Auto-merge patch updates, manual review for major changes
- 🏷️ Automatic releases and tags

✅ **Latest Components**
- ComfyUI v0.3.47 (auto-updated)
- CUDA 12.4.1 support
- Python 3.12
- Latest PyTorch and xformers

## Quick Start

### For RunPod

**Ready-to-use image:**
- Image: `ghcr.io/niuguy/minimal-comfyui-docker:latest`
- Expose Port: `80`
- Environment Variables: None required

**Or build your own:**
1. Fork this repository
2. Push to trigger GitHub Actions build
3. Use your image: `ghcr.io/niuguy/minimal-comfyui-docker:latest`

### For Local Development

```bash
docker run -d \
  --gpus all \
  --name comfyui \
  -p 8080:80 \
  ghcr.io/niuguy/minimal-comfyui-docker:latest
```

Access ComfyUI at: http://localhost:8080

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `COMFYUI_PORT` | Internal ComfyUI port | `8188` |
| `COMFYUI_VERSION` | ComfyUI version to install | `v0.3.47` |

### Ports

| Port | Description |
|------|-------------|
| 80 | NGINX proxy (main access point) |
| 8188 | ComfyUI internal port (not exposed) |

## Building

### Quick Build
```bash
# Build default image
docker buildx bake

# Build and push to registry
REGISTRY_USER=your-username docker buildx bake --push

# Build specific variant
docker buildx bake cuda124
```

### Custom Configuration
Edit `docker-bake.hcl` to customize:
- Registry and username
- ComfyUI version
- CUDA version
- Image tags

## Monitoring

### Health Check
```bash
curl http://localhost:8080/health
```

### Logs
```bash
# All logs
docker logs comfyui

# Specific service logs
docker exec comfyui tail -f /workspace/logs/comfyui-access.log
docker exec comfyui tail -f /workspace/logs/nginx-access.log
```

## File Structure

```
minimal-comfyui-docker/
├── Dockerfile              # Multi-stage optimized build
├── docker-bake.hcl         # Build configuration
├── nginx.conf              # NGINX reverse proxy config
├── supervisord.conf        # Process management
├── start.sh                # Startup script with error handling
└── README.md               # This file
```

## Best Practices Implemented

1. **Security**
   - SSH host key regeneration
   - Security headers in NGINX
   - Non-root user execution where possible
   - No hardcoded secrets

2. **Performance**
   - Multi-stage build for smaller images
   - NGINX gzip compression
   - Optimized proxy timeouts
   - Layer caching optimization

3. **Reliability**
   - Health checks
   - Graceful shutdown handling
   - Comprehensive error logging
   - Service management with supervisor

4. **Maintainability**
   - Clear configuration separation
   - Environment variable configuration
   - Modular file structure
   - Comprehensive documentation

## Troubleshooting

### Common Issues

**ComfyUI not starting:**
```bash
docker exec comfyui tail -f /workspace/logs/comfyui-error.log
```

**NGINX errors:**
```bash
docker exec comfyui tail -f /workspace/logs/nginx-error.log
```

**Build failures:**
- Check CUDA driver compatibility
- Ensure sufficient disk space (>10GB)
- Verify internet connectivity for package downloads

### Development

To modify the setup:
1. Edit configuration files
2. Rebuild: `docker buildx bake`
3. Test locally before pushing

## Contributing

1. Fork the repository
2. Create feature branch
3. Test changes thoroughly
4. Submit pull request

## License

MIT License - see LICENSE file for details