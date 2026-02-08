# Peerless Assassin LCD Controller - Docker Setup

Complete Docker setup for the Peerless Assassin 120 D CPU cooler LCD display controller.

## 📦 What's Included

- **Dockerfile** - Multi-stage Docker image definition
- **docker-compose.yml** - Easy deployment configuration
- **docker-deploy.sh** - Automated build and push script
- **.dockerignore** - Optimized build context
- **DOCKER_DEPLOYMENT.md** - Detailed deployment guide

## 🚀 Quick Start

### Option 1: Using the Automated Script (Recommended)

1. Place all Docker files in your project root directory:
   ```bash
   cd Peerless_assassin_and_CLI_UI
   cp /path/to/Dockerfile .
   cp /path/to/.dockerignore .
   cp /path/to/docker-deploy.sh .
   cp /path/to/docker-compose.yml .
   ```

2. Run the deployment script:
   ```bash
   chmod +x docker-deploy.sh
   ./docker-deploy.sh
   ```

3. Follow the prompts to:
   - Enter your Docker Hub username
   - Set image name and version
   - Build the image
   - Push to Docker Hub (optional)

### Option 2: Manual Build

```bash
# Build the image
docker build -t yourusername/peerless-assassin-lcd:latest .

# Login to Docker Hub
docker login

# Push to Docker Hub
docker push yourusername/peerless-assassin-lcd:latest
```

### Option 3: Using Docker Compose

1. Edit `docker-compose.yml` and replace `yourusername` with your Docker Hub username

2. Choose one:
   ```bash
   # Pull from Docker Hub and run
   docker-compose up -d
   
   # Or build locally and run
   # Uncomment the 'build' section in docker-compose.yml first
   docker-compose up -d --build
   ```

## 🔧 Configuration

### Before Building

The Dockerfile expects these files in your project root:
- `requirements.txt` - Python dependencies
- `pyproject.toml` - Project metadata
- `uv.lock` - Dependency lock file
- `config.json` - Display configuration
- `layout.json` - Display layout
- `peerless_layout.json` - Peerless-specific layout
- `src/` directory - Python source code
- `led_control.sh` - Control script

### Running the Container

Basic run command:
```bash
docker run -d \
  --name peerless-lcd \
  --privileged \
  --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  -v $(pwd)/config.json:/app/config.json:ro \
  yourusername/peerless-assassin-lcd:latest
```

### Environment Variables (Optional)

You can pass environment variables to customize behavior:
```bash
docker run -d \
  --name peerless-lcd \
  --privileged \
  --device=/dev/bus/usb \
  -v /sys:/sys:ro \
  -e DISPLAY_MODE=cpu_temp \
  -e UPDATE_INTERVAL=1 \
  yourusername/peerless-assassin-lcd:latest
```

## 📋 Prerequisites

### On the Host System

1. **Docker installed** (20.10.0 or later recommended)
   ```bash
   docker --version
   ```

2. **USB device permissions** (if not using --privileged)
   ```bash
   # Find your device
   lsusb | grep -i thermal
   
   # Create udev rule (adjust idVendor and idProduct as needed)
   echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="d004", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/99-thermalright.rules
   
   # Reload udev rules
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

3. **Docker Hub account** (for pushing images)
   - Sign up at https://hub.docker.com

## 🏗️ Build Details

### Image Specifications

- **Base Image**: `python:3.11-slim`
- **Size**: ~150-200MB (optimized)
- **Architecture**: amd64 (modify for arm64 if needed)

### Installed Dependencies

System packages:
- libhidapi-dev
- libhidapi-hidraw0
- libhidapi-libusb0
- libudev-dev
- jq
- usbutils

Python packages (from requirements.txt):
- psutil
- hidapi
- pillow
- etc.

## 🐳 Docker Hub

### Pushing to Docker Hub

```bash
# Login
docker login

# Tag your image
docker tag peerless-assassin-lcd:latest yourusername/peerless-assassin-lcd:latest
docker tag peerless-assassin-lcd:latest yourusername/peerless-assassin-lcd:v1.0

# Push
docker push yourusername/peerless-assassin-lcd:latest
docker push yourusername/peerless-assassin-lcd:v1.0
```

### Pulling from Docker Hub

Once pushed, anyone can pull and run:
```bash
docker pull yourusername/peerless-assassin-lcd:latest
docker run -d --privileged --device=/dev/bus/usb -v /sys:/sys yourusername/peerless-assassin-lcd:latest
```

## 🔍 Troubleshooting

### Container Exits Immediately

Check logs:
```bash
docker logs peerless-lcd
```

Common causes:
- USB device not found
- Insufficient permissions
- Configuration file errors

### USB Device Not Detected

1. Verify device on host:
   ```bash
   lsusb
   ls -l /dev/bus/usb/
   ```

2. Check container can see USB:
   ```bash
   docker run --rm --privileged --device=/dev/bus/usb yourusername/peerless-assassin-lcd lsusb
   ```

3. Try running with --privileged flag

### Permission Denied Errors

Ensure udev rules are set up on the host system (see Prerequisites section)

### Build Failures

1. Check all required files are present:
   ```bash
   ls -la requirements.txt pyproject.toml config.json src/
   ```

2. Verify Docker has enough disk space:
   ```bash
   docker system df
   ```

3. Clean up Docker cache if needed:
   ```bash
   docker system prune
   ```

## 📊 Management Commands

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# Stop container
docker stop peerless-lcd

# Start container
docker start peerless-lcd

# Restart container
docker restart peerless-lcd

# Remove container
docker rm peerless-lcd

# View logs
docker logs peerless-lcd
docker logs -f peerless-lcd  # Follow logs

# Execute command in container
docker exec -it peerless-lcd /bin/bash

# View container stats
docker stats peerless-lcd
```

## 🔐 Security Considerations

**Important**: The container runs with `--privileged` flag for USB access. This gives the container extensive host access.

### Best Practices:

1. **Only run on trusted systems**
2. **Use specific device mounting when possible**:
   ```bash
   --device=/dev/bus/usb/001/002  # Specific device
   ```
3. **Keep the image updated**
4. **Review the source code** before building
5. **Use read-only volume mounts** where possible:
   ```bash
   -v /sys:/sys:ro
   ```

## 📚 Additional Resources

- [Original Project](https://github.com/raffa0001/Peerless_assassin_and_CLI_UI)
- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com)

## 🤝 Contributing

If you improve this Docker setup, consider:
1. Forking the original repository
2. Adding your Docker files
3. Submitting a pull request

## 📄 License

This Docker setup follows the same license as the original project (GPL-3.0).

## ✨ Features

- ✅ Optimized multi-stage build
- ✅ Non-root user for security
- ✅ Proper signal handling
- ✅ Health checks (optional)
- ✅ Volume mounts for configuration
- ✅ Logging configuration
- ✅ Auto-restart on failure
- ✅ Easy Docker Compose deployment

---

**Questions or Issues?**
- Check the [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for detailed instructions
- Review container logs: `docker logs peerless-lcd`
- Verify USB permissions on host system
