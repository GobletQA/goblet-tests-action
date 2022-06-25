#!/bin/bash
# /goblet-action/entrypoint.sh

# Exit when any command fails
set -e
set -o pipefail

export GOBLET_RUN_FROM_CI=1
MOUNT_WORK_DIR=$(pwd)

exitError(){
  echo "::set-output name=error::'$1'"
  echo "::set-output name=result::fail"
  exit 1
}

# Runs a yarn command with a prefix when LOCAL_DEV exists
runYarn(){
  if [ "$LOCAL_DEV" ]; then
    yarn dev:$1 $2
  else
    yarn $1 $2
  fi
}

# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
[ -z "$GIT_TOKEN" ] && export GIT_TOKEN="${1:-$GIT_TOKEN}"

[ -z "$GOBLET_TOKEN" ] && export GOBLET_TOKEN="${2:-$GOBLET_TOKEN}"
[ -z "$GOBLET_TOKEN" ] && exitError "Goblet Token is required."

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
[ -z "$NODE_ENV" ] && export NODE_ENV=test
[ -z "$DOC_APP_PATH" ] && export DOC_APP_PATH=/home/runner/tap
[ -z "$GOBLET_APP_URL" ] && export GOBLET_APP_URL="$APP_URL"
[ -z "$GOBLET_MOUNT_ROOT" ] && export GOBLET_MOUNT_ROOT=/home/runner/work
[ -z "$GOBLET_GIT_TOKEN" ] && export GOBLET_GIT_TOKEN="${GIT_ALT_TOKEN:-$GIT_TOKEN}"

[ -z "$GOBLET_HEADLESS" ] && export GOBLET_HEADLESS=true
unset $GOBLET_DEV_TOOLS

# ---- Step 1 - Validate the goblet CI token
# cd /goblet-action
# runYarn "goblet:validate"


# ---- Step 2 - Synmlink the workspace folder to the repos folder
# TODO: this is temp, remember to remove this

# cd /goblet-action
# runYarn "goblet:repo"
# if [ "$LOCAL_DEV" ]; then
#   export GOBLET_CONFIG_BASE=$(ts-node -r tsconfig-paths/register src/goblet/cache.ts paths.repoLoc)
# else
#   export GOBLET_CONFIG_BASE=$(node -r tsconfig-paths/register dist/src/goblet/cache.js paths.repoLoc)
# fi
# echo "[Goblet] Repo mount is $GOBLET_CONFIG_BASE"

# Step 3 - Run any pre-test commands
# TODO: Allow for passing multiple pre-test commands

# Step 4 - Run the tests
# Goblet test run specific ENVs - customizable
# Switch to the goblet dir and run the bdd test task
cd /home/runner/tap
# yarn task bdd run base=$GOBLET_CONFIG_BASE
# TODO: run this test => strat-collab-close.feature in the browser
# Figure out why it's failing, could be related to how the node_modules are being loaded
# It can't seem to find the core-js modules from goblet
yarn task bdd run --context strat-collab-close.feature --base /home/runner/work/goblet/repo --env $NODE_ENV
# yarn task bdd run --base /home/runner/work/goblet/repo --env $NODE_ENV

# Step 5 - Run any post-test commands
# TODO: Allow for passing multiple post-test commands

# Step 6 - Output the result of the executed tests
# TODO: Implment the defined outputs
  # echo "::set-output name=result::$GOBLET_TESTS_RESULTS"
  # echo "::set-output name=report-path::$GOBLET_TESTS_REPORT_PATH"
  # echo "::set-output name=artifacts-path::$GOBLET_TESTS_ARTIFACTS_PATH"

# exec "$@"
