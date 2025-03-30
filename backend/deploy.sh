#!/bin/bash

# filepath: /Users/zachsmith/workspace/workout-app/server/deploy.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Get the version from package.json
VERSION=$(grep '"version"' package.json | sed -E 's/.*"version": "(.*)".*/\1/')

# Define the image name and tags
PROJECT_ID="workout-app-450914"
IMAGE_NAME="gcr.io/$PROJECT_ID/workout-app"
TAG="$IMAGE_NAME:$VERSION"
LATEST_TAG="$IMAGE_NAME:latest"

# Build the Docker image with the version tag for amd64 architecture
echo "Building Docker image with tag: $TAG for amd64 architecture"
docker build --platform linux/amd64 -t $TAG .

# Tag the image as 'latest'
docker tag $TAG $LATEST_TAG

# Push the versioned image to Google Container Registry
echo "Pushing Docker image with tag: $TAG"
docker push $TAG

# Push the 'latest' tag to Google Container Registry
echo "Pushing Docker image with tag: $LATEST_TAG"
docker push $LATEST_TAG

# Deploy the image to Google Cloud Run
echo "Deploying to Google Cloud Run with image: $TAG"
gcloud run deploy workout-app \
  --image $TAG \
  --platform managed \
  --region us-east1 \
  --allow-unauthenticated

echo "Deployment complete!"