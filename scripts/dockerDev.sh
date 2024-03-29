#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:latest

TEST_REPO_NAME=workspace
REPO_WORK_DIR=/github/workspace
MOUNTS="-v $(pwd):/goblet-action"
GITHUB_ACTION=""

GIT_TOKEN=$(keg key print)

GIT_USER=$(git config user.name)
[ -z "$GIT_USER" ] && GIT_USER=$(git log --format='%an' HEAD^!)

GIT_EMAIL=$(git config user.email)
[ -z "$GIT_EMAIL" ] &&  GIT_EMAIL=$(git log --format='%ae' HEAD^!)

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--branch)
      logMsg "Adding alt branch name - $2"
      export GIT_ALT_BRANCH="$2"
      shift
      shift
      ;;
    -c|--chrome)
      logMsg "Test with browser - chrome"
      export GOBLET_BROWSERS="chrome"
      shift
      ;;
    -e|--email)
      logMsg "Setting alt git email - $2"
      export GIT_EMAIL="$2"
      shift
      shift
      ;;
    -f|--firefox)
      logMsg "Test with browser - firefox"
      export GOBLET_BROWSERS="firefox"
      shift
      ;;
    -g|--goblet)
      logMsg "Mounting goblet repo"
      MOUNTS="$MOUNTS -v $(keg gob path):/github/app"
      # Ingnore mounting node_modules
      MOUNTS="$MOUNTS -v /github/app/node_modules"
      shift
      ;;
    -m|--mount)
      export HAS_WORK_MOUNT_REPO=1
      logMsg "Mounting test repo $1"
      MOUNTS="$MOUNTS -v $1:/github/$TEST_REPO_NAME"
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
    -r|--repo)
      export HAS_WORK_MOUNT_REPO=1
      logMsg "Adding alt repo url - $2"
      export GIT_ALT_REPO="$2"
      shift
      shift
      ;;
    -s|--simulate)
      logMsg "Simulating alt-repo via mount"
      export GOBLET_LOCAL_SIMULATE_ALT=1
      export HAS_WORK_MOUNT_REPO=1
      MOUNTS="$MOUNTS -v $(echo $HOME)/goblet/repos/test-action-repo:/github/$TEST_REPO_NAME"
      MOUNTS="$MOUNTS -v $(keg uvt path):/github/alt"
      shift
      ;;
    -t|--tracing)
      logMsg "Setting ENV \"GOBLET_TEST_TRACING\" to \"$2\""
      export GOBLET_TEST_TRACING="$2"
      shift
      shift
      ;;
    -u|--user)
      logMsg "Setting alt git user - $2"
      export GIT_USER="$2"
      shift
      shift
      ;;
    -v|--video)
      logMsg "Setting ENV \"GOBLET_TEST_VIDEO_RECORD\" to \"$2\""
      export GOBLET_TEST_VIDEO_RECORD="$2"
      shift
      shift
      ;;
    -w|--webkit)
      logMsg "Test with browser - webkit"
      export GOBLET_BROWSERS="webkit"
      shift
      ;;
    -a|--action)
      logMsg "Running as Github Action"
      GITHUB_ACTION="-e GITHUB_OUTPUT=/dev/null -e GITHUB_ACTIONS=true -e GITHUB_HEAD_REF=main -e GITHUB_ENV=/dev/null -e GITHUB_PATH=/dev/null -e GITHUB_REF_TYPE=branch -e GITHUB_ACTOR=joe-goblet -e GITHUB_JOB=goblet-test-action -e GITHUB_ACTION=__goblet-action -e GITHUB_REPOSITORY_OWNER=goblet -e GITHUB_WORKSPACE=$REPO_WORK_DIR -e GITHUB_BASE_REF=local-dev-branch -e GITHUB_REF_NAME=run-goblet-action -e GITHUB_REPOSITORY=$TEST_REPO_NAME -e GITHUB_EVENT_NAME=workflow_dispatch -e GITHUB_WORKFLOW=goblet-action-workflow -e GITHUB_REF=refs/heads/run-goblet-action"
      
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
if [ -z "$HAS_WORK_MOUNT_REPO" ]; then
  logMsg "Mounting test repo to github/workspace"
  MOUNTS="$MOUNTS -v $(keg uvt path):/github/$TEST_REPO_NAME"
fi


# If mounts are disabled, set the variable to an empty string
[ "$NO_MOUNTS" ] && MOUNTS=""

logMsg "Runing dev container from $IMAGE_FULL"

docker run --rm -it \
  --ipc=host \
  -e CI=true \
  -e GOBLET_LOCAL_DEV=1 \
  -e GOBLET_LOCAL_SIMULATE_ALT=$GOBLET_LOCAL_SIMULATE_ALT \
  -e GOBLET_TOKEN=$GOBLET_TOKEN \
  -e GIT_TOKEN=$GIT_TOKEN \
  -e GIT_ALT_TOKEN=$GIT_TOKEN \
  -e GIT_ALT_USER="$GIT_USER" \
  -e GIT_ALT_EMAIL="$GIT_EMAIL" \
  -e GIT_ALT_REPO="$GIT_ALT_REPO" \
  -e GIT_ALT_BRANCH="$GIT_ALT_BRANCH" \
  -e GB_GIT_REPO_REMOTE=$GB_GIT_REPO_REMOTE \
  -e GOBLET_BROWSERS=${GOBLET_BROWSERS:-all} \
  -e GOBLET_TEST_REPORT=${GOBLET_TEST_REPORT:-0} \
  -e GOBLET_TEST_TRACING=${GOBLET_TEST_TRACING:-0} \
  -e GOBLET_TEST_VIDEO_RECORD=${GOBLET_TEST_VIDEO_RECORD:-0} \
  -e GOBLET_BROWSER_CONCURRENT=${GOBLET_BROWSER_CONCURRENT:-0} \
  $GITHUB_ACTION \
  --name goblet-action \
  --entrypoint /bin/bash \
  --workdir $REPO_WORK_DIR \
  $MOUNTS \
  $IMAGE_FULL
