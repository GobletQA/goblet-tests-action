#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

TEST_REPO_NAME=test-repo
REPO_WORK_DIR=/github/workspace
MOUNTS="-v $(pwd):/goblet-action"

GIT_TOKEN=$(keg key print)

GIT_USER=$(git config user.name)
[ -z "$GIT_USER" ] && GIT_USER=$(git log --format='%an' HEAD^!)

GIT_EMAIL=$(git config user.email)
[ -z "$GIT_EMAIL" ] &&  GIT_EMAIL=$(git log --format='%ae' HEAD^!)

DOCKER_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--goblet)
      logMsg "Mounting goblet repo"
      MOUNTS="$MOUNTS -v $(keg goblet path):/github/tap"
      shift
      ;;
    -m|--mount)
      export HAS_WORK_MOUNT_REPO=1
      logMsg "Mounting test repo $1"
      MOUNTS="$MOUNTS -v $1:/github/$TEST_REPO_NAME"
    ;;
    -r|--repo)
      export HAS_WORK_MOUNT_REPO=1
      logMsg "Adding alt repo url - $2"
      export GIT_ALT_REPO="$2"
      shift
      shift
      ;;
    -b|--branch)
      logMsg "Adding alt branch name - $2"
      export GIT_ALT_BRANCH="$2"
      shift
      shift
      ;;
    -u|--user)
      logMsg "Setting alt git user - $2"
      export GIT_USER="$2"
      shift
      shift
      ;;
    -e|--email)
      logMsg "Setting alt git email - $2"
      export GIT_EMAIL="$2"
      shift
      shift
      ;;
    -n|--no-mount)
      export NO_MOUNTS=1
      shift
      ;;
    -p|--report)
      logMsg "Setting ENV \"GOBLET_TEST_REPORT\" to \"$2\""
      export GOBLET_TEST_REPORT="$2"
      shift
      shift
      ;;
    -t|--tracing)
      logMsg "Setting ENV \"GOBLET_TEST_TRACING\" to \"$2\""
      export GOBLET_TEST_TRACING="$2"
      shift
      shift
      ;;
    -v|--video)
      logMsg "Setting ENV \"GOBLET_TEST_VIDEO_RECORD\" to \"$2\""
      export GOBLET_TEST_VIDEO_RECORD="$2"
      shift
      shift
      ;;
    -c|--chrome)
      logMsg "Test with browser - chrome"
      export GOBLET_BROWSERS="chrome"
      shift
      ;;
    -f|--firefox)
      logMsg "Test with browser - firefox"
      export GOBLET_BROWSERS="firefox"
      shift
      ;;
    -w|--webkit)
      logMsg "Test with browser - webkit"
      export GOBLET_BROWSERS="webkit"
      shift
      ;;
    -s|--simulate)
      export LOCAL_SIMULATE_ALT=1
      logMsg "Simulating alt-repo via mount"
      MOUNTS="$MOUNTS -v $(echo $HOME)/goblet/repos/test-action-repo:/github/alt"
      shift
      ;;
    *)
      # Any other args pass on to docker
      DOCKER_ARGS+=("$1")
      shift
      ;;
  esac
done

# If no mount repo was set, then pass in the default mount repo
[ -z "$HAS_WORK_MOUNT_REPO" ] && MOUNTS="$MOUNTS -v $(keg sgt path):$REPO_WORK_DIR"

# If mounts are disabled, set the variable to an empty string
[ "$NO_MOUNTS" ] && MOUNTS=""

logMsg "Runing container from $IMAGE_FULL"

docker run --rm -it \
  --ipc=host \
  -e CI=true \
  -e LOCAL_DEV=1 \
  -e LOCAL_SIMULATE_ALT={LOCAL_SIMULATE_ALT:-0} \
  -e GIT_TOKEN=$GIT_TOKEN \
  -e GIT_ALT_TOKEN=$GIT_TOKEN \
  -e GIT_ALT_USER="$GIT_USER" \
  -e GIT_ALT_EMAIL="$GIT_EMAIL" \
  -e GIT_ALT_REPO="$GIT_ALT_REPO" \
  -e GIT_ALT_BRANCH="$GIT_ALT_BRANCH" \
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
  -e GOBLET_TEST_REPORT=${GOBLET_TEST_REPORT:-0} \
  -e GOBLET_TEST_TRACING=${GOBLET_TEST_TRACING:-0} \
  -e GOBLET_BROWSER_DEBUG=${GOBLET_BROWSER_DEBUG:-0} \
  -e GOBLET_TEST_VIDEO_RECORD=${GOBLET_TEST_VIDEO_RECORD:-0} \
  -e GOBLET_BROWSER_CONCURRENT=${GOBLET_BROWSER_CONCURRENT:-0} \
  --name goblet-action \
  --workdir $REPO_WORK_DIR \
  $MOUNTS \
  $IMAGE_FULL "${DOCKER_ARGS[*]}"
