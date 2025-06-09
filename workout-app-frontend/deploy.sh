#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
TAG=workout-app-frontend

docker build --platform linux/amd64 -t $TAG .

PROJECT_ID=$(gcloud config get-value project)
IMAGE_NAME=gcr.io/$PROJECT_ID/$TAG

docker tag $TAG $IMAGE_NAME
docker push $IMAGE_NAME

gcloud run deploy $TAG \
  --image $IMAGE_NAME \
  --platform managed \
  --region us-east1 \
  --allow-unauthenticated