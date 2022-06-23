#!/bin/bash
. ~/keg-hub/repos/keg-cli/keg

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

docker run --rm -it \
  -e LOCAL_DEV=1 \
  -e GOBLET_TOKEN=123456 \
  -e GOBLET_FOLDER_PATH=herkin \
  -e GIT_TOKEN=$(keg key print) \
  -e GITHUB_WORKSPACE=/home/runner/work/goblet/repo \
  -e GITHUB_REPOSITORY=goblet/repo \
  -e HERKIN_MOUNT_ROOT=/keg/repos \
  -e HERKIN_GIT_TOKEN=$(keg key print) \
  -e GOBLET_GIT_TOKEN=$(keg key print) \
  -v $(pwd):/goblet-action \
  -v $(keg herkin path):/keg/tap \
  -v $(keg sgt path):/home/runner/work/goblet/repo \
  --entrypoint /bin/bash \
  ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION \
