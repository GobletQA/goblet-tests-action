#!/bin/bash
. ~/keg-hub/repos/keg-cli/keg

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

# ENV set by github
# GITHUB_WORKSPACE => /home/runner/work/my-repo-name/my-repo-name
# /keg/repos/ci/current

docker run --rm -it \
  -e GOBLET_TOKEN=123456 \
  -e GOBLET_FOLDER_PATH=herkin \
  -e GIT_TOKEN=$(keg key print)
  -e GITHUB_WORKSPACE=/home/runner/work/test-repo/test-repo \
  -e GITHUB_REPOSITORY=goblet/repo
  -v $(pwd):/goblet-action \
  -v $(keg sgt path):/home/runner/work/test-repo/test-repo \
  --entrypoint /bin/bash \
  ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION \
