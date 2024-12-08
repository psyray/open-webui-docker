# Open WebUI with SearXNG Integration

A customized deployment of Open WebUI with SearXNG integration for enhanced RAG (Retrieval-Augmented Generation) capabilities.

## Features

- **Open WebUI**: Modern web interface for Ollama
- **SearXNG Integration**: Private search engine for RAG capabilities
- **NVIDIA GPU Support**: Hardware acceleration for model inference
- **Secure by Default**: 
  - HTTPS enabled
  - Authentication required
  - Private instance configuration
  - Secure cookie settings
- **Easy Maintenance**: Makefile for common operations
- **System Optimization**: Automated system configuration for optimal performance

## Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with compatible drivers
- Make (for using Makefile commands)
- Root access (for system initialization)

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/open-webui.git
cd open-webui
```

2. Initialize the system (requires root privileges):
```bash
sudo ./init-system.sh
```
This script will:
- Configure system limits and kernel parameters
- Set up NVIDIA container runtime
- Generate self-signed SSL certificates
- Configure local domain (ollama.local)
- Install required dependencies
- Enable system services

3. Create your environment file:
```bash
cp .env-dist .env
```

4. Configure your environment variables in `.env`:
```env
# Generate a new secret key
WEBUI_SECRET_KEY="your_secret_key"
SEARXNG_SECRET="your_searxng_secret"  # Generate with: openssl rand -hex 32
```

5. Start the services:
```bash
make up
```

The application will be available at: https://ollama.local

## System Requirements

### Recommended Configuration
- Modern CPU (4+ cores)
- 16GB+ RAM
- NVIDIA GPU with 8GB+ VRAM
- SSD storage
- Ubuntu 22.04 or newer

### Optimized Parameters
The initialization script configures:
- Memory management
- CPU scheduling
- Network optimization
- NVIDIA settings
- System security limits

## Available Make Commands

```bash
make pull      # Pull pre-built Docker images from repository
make build     # Build all Docker images locally
make up        # Start all services (after pulling/building)
make down      # Stop and remove all containers
make stop      # Stop all services
make restart   # Restart all services
make logs      # Follow logs from all services
make upgrade   # Full upgrade: down, remove images, rebuild, and start
```

## Configuration

### Environment Variables

- `WEBUI_AUTH`: Enable authentication (recommended: True)
- `WEBUI_SECRET_KEY`: Secret key for session management
- `WEBUI_SESSION_COOKIE_SECURE`: Force HTTPS for cookies
- `DEFAULT_LOCALE`: Interface language (default: "fr")
- `ENABLE_RAG_WEB_SEARCH`: Enable web search for RAG
- `RAG_WEB_SEARCH_RESULT_COUNT`: Number of search results to use
- `SEARXNG_SECRET`: SearXNG instance secret key
- `SEARXNG_LIMITER`: Rate limiting (default: False for private instance)
- `SEARXNG_PUBLIC_INSTANCE`: Keep as False for private use

### Ports

- 80: HTTP (redirects to HTTPS)
- 443: HTTPS
- 8443: Alternative HTTPS port

## Architecture

The setup consists of four main services:

1. **nginx**: Reverse proxy handling SSL termination and routing
2. **ollama**: AI model serving with GPU support
3. **open-webui**: Web interface for interacting with models
4. **searxng**: Private search engine for RAG capabilities

## Security Considerations

- All services run in an isolated Docker network
- Authentication is enabled by default
- HTTPS enforced with auto-generated certificates
- Secure cookie settings
- Private SearXNG instance
- No public metrics endpoints
- Optimized system security limits

## Maintenance

### Daily Operations
```bash
# View logs
make logs

# Restart services
make restart

# Stop services
make stop
```

### Updates and Upgrades
```bash
# Full upgrade (recommended)
make upgrade

# Alternative manual update
make down
make pull
make up
```

### Backup
Important data is stored in Docker volumes:
- `ollama_data`: Model files and configurations
- `open-webui_data`: User data and settings

## Troubleshooting

1. If services fail to start:
```bash
make down
make up
```

2. For image-related issues:
```bash
make upgrade
```

3. To check logs for specific issues:
```bash
make logs
```

4. System-related issues:
```bash
# Verify system settings
sudo sysctl -a | grep -E "vm.swappiness|vm.dirty_ratio|vm.nr_hugepages"

# Check NVIDIA configuration
nvidia-smi
nvidia-container-cli info
```

5. Certificate issues:
```bash
# Regenerate certificates
cd docker
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout certs/cert.key -out certs/cert.crt \
    -subj "/CN=ollama.local" \
    -addext "subjectAltName = DNS:ollama.local"
```

## License

This project builds upon:
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Ollama](https://github.com/ollama/ollama)
- [SearXNG](https://github.com/searxng/searxng)

Please refer to their respective licenses for terms of use. 