# KomfyDock 🐳

A containerized ComfyUI setup with dynamic custom node management.

## Features

- **GPU-accelerated** — NVIDIA CUDA 12.1 + PyTorch
- **Dynamic custom nodes** — Edit `custom-nodes.txt`, restart, done
- **Centralized model library** — Mount your existing models folder
- **Persistent everything** — Outputs, nodes, workflows survive container rebuilds

## Quick Start

```bash
# Clone the repo
git clone https://github.com/SilverSix311/KomfyDock.git
cd KomfyDock

# Build and run
docker compose build
docker compose up -d

# Access ComfyUI
open http://localhost:8989
```

## Directory Structure

KomfyDock expects this sibling folder structure:

```
ComfyUI Library/
├── KomfyDock/          ← This repo
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── custom-nodes.txt
├── models/             ← Checkpoints, LoRAs, VAEs, etc.
├── output/             ← Generated images
├── input/              ← img2img sources
├── custom_nodes/       ← Installed nodes (persistent)
├── user/               ← ComfyUI settings
└── workflows/          ← Saved workflows
```

## Managing Custom Nodes

Edit `custom-nodes.txt` to add/remove nodes:

```txt
# One git URL per line
https://github.com/ltdrdata/ComfyUI-Manager.git
https://github.com/ltdrdata/ComfyUI-Impact-Pack.git

# Pin to a specific branch or tag
https://github.com/some/repo.git@v1.0.0
```

Then restart:

```bash
docker compose restart
```

The entrypoint script will install any missing nodes on startup.

## Configuration

### Ports

Default: `8989` → `8188` (container)

Change in `docker-compose.yml`:
```yaml
ports:
  - "YOUR_PORT:8188"
```

### Volume Paths

Adjust paths in `docker-compose.yml` if your folder structure differs.

## Requirements

- Docker with NVIDIA Container Toolkit
- NVIDIA GPU with CUDA support
- ~10GB disk space for base image + nodes

## License

MIT
