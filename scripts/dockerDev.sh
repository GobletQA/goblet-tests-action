#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

TEST_REPO_NAME=goblet/repo
REPO_WORK_DIR=/home/runner/work/$TEST_REPO_NAME
MOUNTS="-v $(pwd):/goblet-action"

GIT_TOKEN=$(keg key print)

GIT_USER=$(git config user.name)
[ -z "$GIT_USER" ] && GIT_USER=$(git log --format='%an' HEAD^!)

GIT_EMAIL=$(git config user.email)
[ -z "$GIT_EMAIL" ] &&  GIT_EMAIL=$(git log --format='%ae' HEAD^!)

while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--goblet)
      logMsg "Mounting goblet repo"
      MOUNTS="$MOUNTS -v $(keg goblet path):/home/runner/tap"
      shift
      ;;
    -m|--mount)
      export HAS_WORK_MOUNT_REPO=1
      logMsg "Mounting test repo $1"
      MOUNTS="$MOUNTS -v $1:/home/runner/work/$TEST_REPO_NAME"
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
    -*|--*)
      logErr "Unknown option $1"
      shift
      ;;
    *)
      logErr "Unknown option $1"
      shift
      ;;
  esac
done

# If no mount repo was set, then pass in the default mount repo
[ -z "$HAS_WORK_MOUNT_REPO" ] && MOUNTS="$MOUNTS -v $(keg sgt path):/home/runner/work/$TEST_REPO_NAME"

logMsg "Runing dev container from $IMAGE_FULL"

docker run --rm -it \
  --ipc=host \
  -e CI=true \
  -e LOCAL_DEV=1 \
  -e GOBLET_TOKEN=123456 \
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
  --name goblet-action \
  --entrypoint /bin/bash \
  --workdir $REPO_WORK_DIR \
  $MOUNTS \
  $IMAGE_FULL
