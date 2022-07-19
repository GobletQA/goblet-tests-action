#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGES_URI=ghcr.io/gobletqa/$IMAGE_NAME
IMAGE_FULL=$IMAGES_URI:$IMAGE_VERSION

BUILD_ARGS="--load"

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--push)
      logMsg "Add platforms arguments to push image"
      BUILD_ARGS="--platform linux/amd64,linux/arm64 --push"
      shift
    ;;
    -l|--local)
      docker buildx create --name goblet &> /dev/null
      docker buildx use goblet
      shift
    ;;
    -t|--tag|--tags)
      BUILD_ARGS="$BUILD_ARGS -t $IMAGES_URI:$2"
      shift
      shift
    ;;
    *)
      logErr "Unknown option $1"
      shift
    ;;
  esac
done

logMsg "Building image $IMAGE_FULL"
docker buildx build $BUILD_ARGS -t $IMAGE_FULL .
logMsg "Finished Building image"