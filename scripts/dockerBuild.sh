#!/bin/bash

BUILD_ARGS=''
[ "$1" == "push" ] && BUILD_ARGS="--platform linux/amd64,linux/arm64 --push" || BUILD_ARGS="--load"

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

# Create the builder if needed, capture the output incse it already exists
IGNORE=$(docker buildx create --name goblet)
docker buildx use goblet
docker buildx build $BUILD_ARGS -t $IMAGE_FULL .
