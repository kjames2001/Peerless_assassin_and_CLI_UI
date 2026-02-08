# Docker Deployment Guide for Peerless Assassin LCD Controller

This guide will help you build and deploy the Peerless Assassin LCD controller as a Docker container.

## Prerequisites

- Docker installed on your system
- Docker Hub account (for pushing the image)
- USB access to the Thermalright LCD device

## Building the Docker Image

### 1. Clone the Repository

```bash
git clone https://github.com/raffa0001/Peerless_assassin_and_CLI_UI.git
cd Peerless_assassin_and_CLI_UI
```

### 2. Copy Docker Files

Copy the `Dockerfile` and `.dockerignore` to the repository root:

```bash
# Place the provided Dockerfile in the root directory
# Place the provided .dockerignore in the root directory
```

### 3. Build the Image

Build the Docker image with your desired tag:

```bash
# Replace 'yourusername' with your Docker Hub username
docker build -t yourusername/peerless-assassin-lcd:latest .
```

Or use a specific version tag:

```bash
docker build -t yourusername/peerless-assassin-lcd:v1.0 .
```

## Running the Container

The container requires privileged access to interact with USB HID devices:

```bash
docker run -d \
  --name peerless-lcd \
  --privileged \
  --device=/dev/bus/usb \
  -v /sys:/sys \
  -v $(pwd)/config.json:/app/config.json \
  yourusername/peerless-assassin-lcd:latest
```

### Docker Run Options Explained

- `--privileged`: Required for USB device access
- `--device=/dev/bus/usb`: Mount USB devices
- `-v /sys:/sys`: Mount system information (needed for temperature/usage readings)
- `-v $(pwd)/config.json:/app/config.json`: Mount your custom configuration

### Alternative: Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  peerless-lcd:
    image: yourusername/peerless-assassin-lcd:latest
    container_name: peerless-lcd
    privileged: true
    devices:
      - /dev/bus/usb
    volumes:
      - /sys:/sys:ro
      - ./config.json:/app/config.json
    restart: unless-stopped
```

Then run:

```bash
docker-compose up -d
```

## Pushing to Docker Hub

### 1. Login to Docker Hub

```bash
docker login
```

Enter your Docker Hub username and password when prompted.

### 2. Push the Image

```bash
docker push yourusername/peerless-assassin-lcd:latest
```

If you built with a version tag:

```bash
docker push yourusername/peerless-assassin-lcd:v1.0
```

### 3. Push Multiple Tags

To push both a versioned tag and latest:

```bash
# Tag the image with latest
docker tag yourusername/peerless-assassin-lcd:v1.0 yourusername/peerless-assassin-lcd:latest

# Push both tags
docker push yourusername/peerless-assassin-lcd:v1.0
docker push yourusername/peerless-assassin-lcd:latest
```

## Quick Build and Push Script

Save this as `docker-deploy.sh`:

```bash
#!/bin/bash

# Configuration
DOCKER_USERNAME="yourusername"
IMAGE_NAME="peerless-assassin-lcd"
VERSION="v1.0"

# Build the image
echo "Building Docker image..."
docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} .
docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

# Login to Docker Hub
echo "Logging into Docker Hub..."
docker login

# Push the images
echo "Pushing images to Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

echo "Done! Images pushed successfully."
echo "Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
```

Make it executable and run:

```bash
chmod +x docker-deploy.sh
./docker-deploy.sh
```

## Troubleshooting

### USB Device Not Detected

If the container cannot access the USB device:

1. Check USB device permissions on the host:
   ```bash
   ls -l /dev/bus/usb/
   ```

2. Find your device:
   ```bash
   lsusb
   ```

3. Add udev rules on the host (from the original install.sh):
   ```bash
   echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="d004", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/99-thermalright.rules
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

### Container Exits Immediately

Check logs:
```bash
docker logs peerless-lcd
```

### Permission Issues

Ensure the container runs with proper USB access:
```bash
docker run -it --rm \
  --privileged \
  --device=/dev/bus/usb \
  yourusername/peerless-assassin-lcd:latest \
  lsusb
```

## Configuration

Edit the `config.json` file to customize display settings before running the container. The file will be mounted into the container at runtime.

## Security Note

Running with `--privileged` gives the container extensive access to the host system. This is required for USB device communication. If security is a concern, consider:

1. Using `--device` flags instead of `--privileged` where possible
2. Running only on trusted systems
3. Implementing additional security measures based on your environment

## Additional Resources

- Original Repository: https://github.com/raffa0001/Peerless_assassin_and_CLI_UI
- Docker Hub: https://hub.docker.com
- Docker Documentation: https://docs.docker.com
