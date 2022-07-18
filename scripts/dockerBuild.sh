#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

BUILD_ARGS=''
[ "$1" == "push" ] && BUILD_ARGS="--platform linux/amd64,linux/arm64 --push" || BUILD_ARGS="--load"

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

logMsg "Building image $IMAGE_FULL"

# Only run if the second argument is not CI
# This is not needed in github actions
if [ -z "$2" ]; then
  # Create the builder if needed, capture the output incase it already exists we don't want to exit on error
  IGNORE=$(docker buildx create --name goblet)
fi
docker buildx use goblet
docker buildx build $BUILD_ARGS -t $IMAGE_FULL .
