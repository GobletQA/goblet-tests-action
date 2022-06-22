#!/bin/bash

RUNCMD=''
[ "$1" ] && RUNCMD="$1" || RUNCMD="/bin/bash"

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

docker run --rm -it $IMAGE_FULL $RUNCMD