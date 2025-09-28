#!/bin/bash

# Build multi-platform Docker images for ARM64 and AMD64
set -e

IMAGE_NAME="clickup-tui"
TAG=${1:-"latest"}

echo "🏗️  Building multi-platform Docker image: ${IMAGE_NAME}:${TAG}"

# Enable Docker buildx
docker buildx create --name multiarch --use --bootstrap 2>/dev/null || true

# Build for both ARM64 and AMD64
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "${IMAGE_NAME}:${TAG}" \
  --tag "${IMAGE_NAME}:${TAG}-$(date +%Y%m%d)" \
  --file docker/Dockerfile \
  --push \
  .

echo "✅ Multi-platform build complete!"
echo "📦 Available for: linux/amd64, linux/arm64"
echo "🚀 Image: ${IMAGE_NAME}:${TAG}"