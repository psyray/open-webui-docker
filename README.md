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
- **Flexible Configuration**: Customizable hostname and security settings

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

2. Create and configure your environment file:
```bash
cp .env-dist .env
```

Edit `.env` and configure at minimum:
```env
# System Configuration
HOSTNAME="openwebui.local"    # Your preferred hostname

# Security Configuration
WEBUI_SECRET_KEY="your_secret_key"    # Generate with: openssl rand -hex 32
SEARXNG_SECRET="your_searxng_secret"  # Generate with: openssl rand -hex 32
```

3. Initialize the system (requires root privileges):
```bash
sudo ./init-system.sh
```
This script will:
- Configure system limits and kernel parameters
- Set up NVIDIA container runtime
- Generate self-signed SSL certificates for your hostname
- Configure local domain resolution
- Install required dependencies

4. Start the services:
```bash
make up
```

The application will be available at: https://your-configured-hostname
(default: https://openwebui.local)

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

- `HOSTNAME`: Your preferred hostname for accessing the application
- `WEBUI_AUTH`: Enable authentication (recommended: True)
- `WEBUI_SECRET_KEY`: Secret key for session management
- `WEBUI_SESSION_COOKIE_SECURE`: Force HTTPS for cookies
- `DEFAULT_LOCALE`: Interface language (default: "en")
- `ENABLE_RAG_WEB_SEARCH`: Enable web search for RAG
- `RAG_WEB_SEARCH_RESULT_COUNT`: Number of search results to use
- `SEARXNG_SECRET`: SearXNG instance secret key
- `SEARXNG_LIMITER`: Rate limiting (default: False for private instance)
- `SEARXNG_PUBLIC_INSTANCE`: Keep as False for private use

### Ports

- 80: HTTP (redirects to HTTPS)
- 443: Open WebUI
- 8443: SearXNG

## Architecture

The setup consists of four main services:

1. **nginx**: Reverse proxy handling SSL termination and routing
2. **ollama**: AI model serving with GPU support
3. **open-webui**: Web interface for interacting with models
4. **searxng**: Private search engine for RAG capabilities

## Ollama Integrations (Clients)

Once the stack is running (`make up`), the Ollama API is exposed on **`http://localhost:11434`**. The tools below run on your **host machine** and connect to this URL. Install the client you want, then configure it to use `http://localhost:11434` (and `/v1` or `/v1/` where the tool expects it). Many of these tools recommend a context window of at least 64k tokens; see [Ollama context length](https://docs.ollama.com/context-length) to adjust if needed.

### Claude Code

- **Docs**: [Ollama – Claude Code](https://docs.ollama.com/integrations/claude-code)
- **Install**: `curl -fsSL https://claude.ai/install.sh | bash`
- **Config**: Export on your host:
  ```bash
  export ANTHROPIC_AUTH_TOKEN=ollama
  export ANTHROPIC_API_KEY=""
  export ANTHROPIC_BASE_URL=http://localhost:11434
  ```
- **Run**: `claude --model qwen3-coder` (or another model; 64k+ context recommended).

### Codex

- **Docs**: [Ollama – Codex](https://docs.ollama.com/integrations/codex)
- **Install**: `npm install -g @openai/codex`
- **Config**: Use Ollama with `codex --oss`. Optional config in `~/.codex/config.toml` if needed.
- **Run**: `codex --oss` (default model `gpt-oss:20b`), or `codex --oss -m gpt-oss:120b`. 64k+ context recommended.

### OpenCode

- **Docs**: [Ollama – OpenCode](https://docs.ollama.com/integrations/opencode)
- **Install**: `curl -fsSL https://opencode.ai/install | bash`
- **Config**: Add to `~/.config/opencode/opencode.json` (provider options):
  ```json
  "options": { "baseURL": "http://localhost:11434/v1" }
  ```
- **Run**: Use a model defined in that config (e.g. `qwen3-coder`). 64k+ context recommended.

### Droid

- **Docs**: [Ollama – Droid](https://docs.ollama.com/integrations/droid)
- **Install**: `curl -fsSL https://app.factory.ai/cli | sh`
- **Config**: Add to `~/.factory/config.json` (custom_models):
  ```json
  {
    "model_display_name": "qwen3-coder [Ollama]",
    "model": "qwen3-coder",
    "base_url": "http://localhost:11434/v1/",
    "api_key": "not-needed",
    "provider": "generic-chat-completion-api",
    "max_tokens": 32000
  }
  ```
- **Run**: Select the configured model in Droid. 64k+ context recommended.

### Goose Desktop

- **Docs**: [Ollama – Goose](https://docs.ollama.com/integrations/goose), [Goose – Install](https://block.github.io/goose/docs/getting-started/installation/)
- **Install**: Download from the Goose site or `brew install --cask block-goose` (macOS).
- **Config**: In the app: **Settings** → **Configure Provider** → **Ollama** → set **API Host** to `http://localhost:11434`.
- **Run**: Use Goose Desktop as usual with Ollama models.

### Goose CLI

- **Docs**: [Ollama – Goose](https://docs.ollama.com/integrations/goose), [Goose – Install](https://block.github.io/goose/docs/getting-started/installation/)
- **Install**: `curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash`
- **Config**: Run `goose configure`, choose Ollama, and set the host; or export `OLLAMA_HOST=http://localhost:11434`.
- **Run**: `goose session` (or other goose commands).

### Pi

- **Docs**: [Ollama – Pi](https://docs.ollama.com/integrations/pi)
- **Install**: `npm install -g @mariozechner/pi-coding-agent`
- **Config**: In `~/.pi/agent/models.json` set provider baseUrl to `http://localhost:11434/v1`; in `~/.pi/agent/settings.json` set `defaultProvider` and `defaultModel` (e.g. `ollama`, `qwen3-coder`).
- **Run**: Use Pi with the configured Ollama model.

### OpenClaw

- **Docs**: [Ollama – OpenClaw](https://docs.ollama.com/integrations/openclaw)
- **Install**: `npm install -g openclaw@latest` then `openclaw onboard --install-daemon`
- **Config**: Quick setup: `ollama launch openclaw` (configures OpenClaw to use local Ollama). Or point OpenClaw config manually to `http://localhost:11434`.
- **Run**: Use OpenClaw; 64k+ context recommended.

For a quick reference of optional environment variables you can export on the host, see the commented block in [.env-dist](.env-dist).

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

5. Hostname/Certificate issues:
```bash
# Update hostname in .env file
HOSTNAME="your-new-hostname.local"

# Regenerate certificates with new hostname
sudo ./init-system.sh

# Restart services
make down
make up
```

## License

This project builds upon:
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Ollama](https://github.com/ollama/ollama)
- [SearXNG](https://github.com/searxng/searxng)

Please refer to their respective licenses for terms of use. 