#!/bin/bash

#
#
# Most simple example of running the docker image
# Includes the GOBLET_TOKEN env, and mounts in a local tests folder
# Expects
#   * The GOBLET_TOKEN env is set in the current environment
#   * The mounted tests folder is a git directory with a `.git` folder
#   * The mounted tests folder contains a `goblet.config.ts` file in the root directory
#
# Example
# Navigate to the tests repo directory:
#   cd ./use-verb-webapp-tests
# Run the script:
#   GOBLET_TOKEN=<goblet-token> ./docker-dev.sh
#

LOCAL_TESTS_DIR="$(pwd)"
REMOTE_TESTS_DIR=/goblet/workspace
TEST_REPO_NAME="$(basename "$(dirname "$LOCAL_TESTS_DIR")")"


docker run --rm -it \
  -e GOBLET_TOKEN=$GOBLET_TOKEN \
  -v $LOCAL_TESTS_DIR:$REMOTE_TESTS_DIR \
  --workdir $REMOTE_TESTS_DIR \
  --entrypoint /bin/bash \
  ghcr.io/gobletqa/goblet-tests-action:0.0.25
