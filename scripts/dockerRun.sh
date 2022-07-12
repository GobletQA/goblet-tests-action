#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

TEST_REPO_NAME=goblet/repo
GIT_TOKEN=$(keg key print)
REPO_WORK_DIR=/home/runner/work/$TEST_REPO_NAME

MOUNTS="-v $(pwd):/goblet-action -v $(keg sgt path):/home/runner/work/$TEST_REPO_NAME"
[ "$1" == "goblet" ] && MOUNTS="$MOUNTS -v $(keg goblet path):/home/runner/tap"

logMsg "Runing container from $IMAGE_FULL"

docker run --rm -it \
  --ipc=host \
  -e CI=true \
  -e LOCAL_DEV=1 \
  -e GIT_TOKEN=$GIT_TOKEN \
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
  -e GOBLET_BROWSERS=${GOBLET_BROWSERS:-all} \
  -e GOBLET_TEST_TRACING=${GOBLET_TEST_TRACING:-0} \
  -e GOBLET_BROWSER_DEBUG=${GOBLET_BROWSER_DEBUG:-0} \
  -e GOBLET_TEST_VIDEO_RECORD=${GOBLET_TEST_VIDEO_RECORD:-0} \
  -e GOBLET_BROWSER_CONCURRENT=${GOBLET_BROWSER_CONCURRENT:-0} \
  --name goblet-action \
  --workdir $REPO_WORK_DIR \
  $MOUNTS \
  $IMAGE_FULL "$@"
