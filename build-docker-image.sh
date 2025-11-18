#!/bin/bash

# Build the Arch ISO Builder Docker Image
# Run this once to create a reusable build environment
# This significantly speeds up subsequent ISO builds

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="archiso-builder"
IMAGE_TAG="latest"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Building Arch ISO Builder Docker Image                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${YELLOW}This will build a Docker image that speeds up ISO builds${NC}"
echo -e "${YELLOW}You only need to run this once (or when you want to update)${NC}"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker is not installed!"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC} Docker daemon is not running!"
    exit 1
fi

echo -e "${YELLOW}→${NC} Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo -e "${BLUE}This will take 2-3 minutes...${NC}"
echo ""

# Build the image
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f "$SCRIPT_DIR/Dockerfile.archiso-builder" \
    "$SCRIPT_DIR"

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Docker Image Built Successfully! ✓               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "You can now use ./build-iso-docker.sh for faster ISO builds!"
    echo ""
    echo "To rebuild this image later (e.g., to update packages):"
    echo "  ./build-docker-image.sh"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Docker image build failed!${NC}"
    exit 1
fi
