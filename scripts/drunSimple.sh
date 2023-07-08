#!/bin/bash

#
# Most simple example of running the docker image
# Includes the GOBLET_TOKEN env, and mounts in a local tests folder
# Expects
#   * the mounted tests folder to be a git directory
#   * the mounted tests folder contains a `goblet.config.ts` file
#

source $KEG_CLI_PATH/keg

LOCAL_TESTS_DIR=$(keg uvt path)
IMAGE_NAME=$npm_package_displayName
IMAGE_VERSION=$npm_package_version
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

TEST_REPO_NAME=tests-repo
REPO_WORK_DIR=/goblet/workspace

# Mount this github action repo into the docker container
ACTION_MOUNT="-v $(pwd):/goblet-action"

# Mount the tests repo into the docker container
REPO_MOUNT="-v $LOCAL_TESTS_DIR:$REPO_WORK_DIR"

# Just for testing
MOUNTS="$MOUNTS -v $(keg gob path):/github/app"
# Ingnore mounting node_modules
MOUNTS="$MOUNTS -v /github/app/node_modules"

docker run --rm -it \
  -e GOBLET_TOKEN=Goblet-Token \
  --name goblet-tests-action \
  --workdir $REPO_WORK_DIR \
  --entrypoint /bin/bash \
  $ACTION_MOUNT \
  $REPO_MOUNT \
  $MOUNTS \
  $IMAGE_FULL "${@}"