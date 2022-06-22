#!/bin/bash
. ~/keg-hub/repos/keg-cli/keg

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

docker run --rm -it \
  -e GOBLET_TOKEN=123456 \
  -e GOBLET_FOLDER_PATH=herkin \
  -v $(pwd):/goblet-action \
  -v $(keg sgt path):/keg/repos/ci/current \
  --entrypoint /bin/bash \
  ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION \
