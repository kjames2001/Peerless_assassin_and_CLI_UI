#!/bin/bash

# Peerless Assassin LCD Controller - Docker Build & Push Script
# This script automates the process of building and pushing the Docker image

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
read -p "Enter your Docker Hub username: " DOCKER_USERNAME
read -p "Enter image name [peerless-assassin-lcd]: " IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-peerless-assassin-lcd}
read -p "Enter version tag [v1.0]: " VERSION
VERSION=${VERSION:-v1.0}

FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Peerless Assassin LCD - Docker Builder${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Docker Hub User: ${DOCKER_USERNAME}"
echo "  Image Name: ${IMAGE_NAME}"
echo "  Version Tag: ${VERSION}"
echo "  Full Image: ${FULL_IMAGE_NAME}:${VERSION}"
echo ""

# Confirm before proceeding
read -p "Proceed with build? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${YELLOW}Build cancelled.${NC}"
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Dockerfile not found in current directory${NC}"
    exit 1
fi

# Build the image
echo -e "${GREEN}Building Docker image...${NC}"
docker build -t ${FULL_IMAGE_NAME}:${VERSION} .

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"

# Tag as latest
echo -e "${GREEN}Tagging as latest...${NC}"
docker tag ${FULL_IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}:latest

# Ask if user wants to push to Docker Hub
echo ""
read -p "Do you want to push to Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Login to Docker Hub
    echo -e "${GREEN}Logging into Docker Hub...${NC}"
    docker login
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Docker Hub login failed!${NC}"
        exit 1
    fi
    
    # Push the images
    echo -e "${GREEN}Pushing ${FULL_IMAGE_NAME}:${VERSION}...${NC}"
    docker push ${FULL_IMAGE_NAME}:${VERSION}
    
    echo -e "${GREEN}Pushing ${FULL_IMAGE_NAME}:latest...${NC}"
    docker push ${FULL_IMAGE_NAME}:latest
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Success! Images pushed to Docker Hub${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Your images are now available at:"
    echo "  - ${FULL_IMAGE_NAME}:${VERSION}"
    echo "  - ${FULL_IMAGE_NAME}:latest"
    echo ""
    echo "To pull and run:"
    echo "  docker pull ${FULL_IMAGE_NAME}:latest"
    echo "  docker run -d --privileged --device=/dev/bus/usb -v /sys:/sys ${FULL_IMAGE_NAME}:latest"
else
    echo -e "${YELLOW}Skipping push to Docker Hub.${NC}"
    echo ""
    echo "Image built locally:"
    echo "  - ${FULL_IMAGE_NAME}:${VERSION}"
    echo "  - ${FULL_IMAGE_NAME}:latest"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
