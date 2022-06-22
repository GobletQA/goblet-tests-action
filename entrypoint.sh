#!/bin/bash

# Exit when any command fails
set -e
set -o pipefail

MOUNT_WORK_DIR=$(pwd)

exitError(){
  echo "::set-output name=error::'$1'"
  echo "::set-output name=result::fail"
  exit 1
}

# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
[ -z "$GIT_TOKEN" ] && export GIT_TOKEN="${1:-$GIT_TOKEN}"
[ -z "$GOBLET_TOKEN" ] && export GOBLET_TOKEN="${2:-$GOBLET_TOKEN}"
[ -z "$GOBLET_REPORT_NAME" ] && export GOBLET_REPORT_NAME="${3:-$GOBLET_REPORT_NAME}"
[ -z "$GOBLET_PRE_CMDS" ] && export GOBLET_PRE_CMDS="${4:-$GOBLET_PRE_CMDS}"
[ -z "$GOBLET_POST_CMDS" ] && export GOBLET_POST_CMDS="${5:-$GOBLET_POST_CMDS}"

# Alt Repo ENVs
[ -z "$GIT_ALT_REPO" ] && export GIT_ALT_REPO="${6:-$GIT_ALT_REPO}"
[ -z "$GIT_ALT_BRANCH" ] && export GIT_ALT_BRANCH="${7:-$GIT_ALT_BRANCH}"
[ -z "$GIT_ALT_USER" ] && export GIT_ALT_USER="${8:-$GIT_ALT_USER}"
[ -z "$GIT_ALT_EMAIL" ] && export GIT_ALT_EMAIL="${9:-$GIT_ALT_EMAIL}"
[ -z "$GIT_ALT_TOKEN" ] && export GIT_ALT_TOKEN="${10:-$GIT_ALT_TOKEN}"

# Goblet App specific ENVs
[ -z "$GOBLET_GIT_TOKEN" ] && export GOBLET_GIT_TOKEN="${GIT_ALT_TOKEN:-$GIT_TOKEN}"
[ -z "$NODE_ENV" ] && NODE_ENV=test
[ -z "$HERKIN_APP_URL" ] && export HERKIN_APP_URL="$APP_URL"
[ -z "$HERKIN_MOUNT_ROOT" ] && export HERKIN_MOUNT_ROOT=/keg/repos
[ -z "$HERKIN_GIT_TOKEN" ] && export HERKIN_GIT_TOKEN=$GOBLET_GIT_TOKEN

# Github Action defined envs
[ -z "$GITHUB_REPOSITORY" ] && export GITHUB_REPOSITORY=goblet/repo
# [ -z "$GITHUB_ACTION_REPOSITORY" ] && export GITHUB_ACTION_REPOSITORY=/action/repo


# ---- Step 1 - Validate the goblet CI token
# TODO: Call goblet API to validate goblet CI token
[ -z "$GOBLET_TOKEN" ] && exitError "Goblet Token is required."
cd /goblet-action
yarn validate:goblet


# ---- Step 2 - Synmlink the workspace folder to the repos folder
cd /goblet-action

[ ! -d "$GITHUB_WORKSPACE" ] && exitError "The 'GITHUB_WORKSPACE' ENV is not a valid folder path"
ln -s $GITHUB_WORKSPACE $HERKIN_MOUNT_ROOT/$GITHUB_REPOSITORY

# Step 2 - Run any pre-test commands
# TODO: Allow for passing multiple pre-test commands


# Step 3 - Ensure the test folder can be found
# Check to ensure goblet folder can be found
# [[ ! -d "$GOBLET_REPO_PATH" ]] && exitError "Goblet folder path does not exist."


# ENV set by github
# GITHUB_WORKSPACE => /home/runner/work/my-repo-name/my-repo-name

# Step 4 - Execute the tests in the found test folder
# TODO: Run test command for the found tests ( i.e. yarn goblet ...args )

# Step 5 - Run any post-test commands
# TODO: Allow for passing multiple post-test commands

# Step 6 - Output the result of the executed tests
# TODO: Implment the defined outputs
  # echo "::set-output name=result::$GOBLET_TESTS_RESULTS"
  # echo "::set-output name=report-path::$GOBLET_TESTS_REPORT_PATH"
  # echo "::set-output name=artifacts-path::$GOBLET_TESTS_ARTIFACTS_PATH"

exec "$@"
