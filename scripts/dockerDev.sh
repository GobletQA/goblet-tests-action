#!/bin/bash
. ~/keg-hub/repos/keg-cli/keg

IMAGE_NAME=$npm_package_name
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

TEST_REPO_NAME=goblet/repo
GIT_TOKEN=$(keg key print)
REPO_WORK_DIR=/home/runner/work/$TEST_REPO_NAME

docker run --rm -it \
  --ipc=host \
  -e CI=true \
  -e LOCAL_DEV=1 \
  -e GOBLET_TOKEN=123456 \
  -e GITHUB_ACTIONS=true \
  -e GITHUB_HEAD_REF=main \
  -e GITHUB_ENV=/dev/null \
  -e GITHUB_PATH=/dev/null \
  -e GITHUB_REF_TYPE=branch \
  -e GITHUB_ACTOR=joe-goblet \
  -e GITHUB_JOB=goblet-test-action \
  -e GITHUB_ACTION=__goblet-action \
  -e GITHUB_REPOSITORY_OWNER=goblet \
  -e GITHUB_BASE_REF=local-dev-branch \
  -e GITHUB_REF_NAME=run-goblet-action \
  -e GITHUB_REPOSITORY=$TEST_REPO_NAME \
  -e GITHUB_EVENT_NAME=workflow_dispatch \
  -e GITHUB_WORKFLOW=goblet-action-workflow \
  -e GITHUB_REF=refs/heads/run-goblet-action \
  -e GITHUB_WORKSPACE=$REPO_WORK_DIR \
  --name goblet-action \
  --entrypoint /bin/bash \
  --workdir $REPO_WORK_DIR \
  -v $(pwd):/goblet-action \
  -v $(keg herkin path):/home/runner/tap \
  -v $(keg sgt path):/home/runner/work/$TEST_REPO_NAME \
  $IMAGE_FULL

  # -p 5005:5005 \
  # -p 5006:5006 \
  # -p 19006:19006 \
  # -p 26369:26369 \
  # -p 26370:26370 \