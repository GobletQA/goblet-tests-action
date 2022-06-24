#!/bin/bash

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

# TODO: investigate this to properly set the git user creds 
# updateGitCreds(){
#   GIT_GLOBAL=${GIT_GLOBAL:-false}
#   _GIT_GLOBAL_OPTION=''
#   [ "$GIT_GLOBAL" ] && _GIT_GLOBAL_OPTION='--global'

#   GIT_ALT_EMAIL="${GIT_ALT_EMAIL:-'github-action@users.noreply.github.com'}"
#   GIT_ALT_USER="${GIT_ALT_USER:-'GitHub Action'}"
#   GIT_ALT_USER=${GIT_ALT_USER:-${GITHUB_ACTOR}}

#   git config $_GIT_GLOBAL_OPTION user.email "${GIT_ALT_EMAIL}"
#   git config $_GIT_GLOBAL_OPTION user.name "${GIT_ALT_USER}"
#   git config $_GIT_GLOBAL_OPTION user.password ${GOBLET_GIT_TOKEN}
#   echo "GIT_USER=${GIT_ALT_USER}:${GOBLET_GIT_TOKEN}" >> $GITHUB_ENV
# }

# Runs a yarn command with a prefix when LOCAL_DEV exists
runYarn(){
  if [ "$LOCAL_DEV" ]; then
    yarn dev:$1 $2
  else
    yarn $1 $2
  fi
}

# This should already exist in the image but it seems the publish image it not up to date
[ ! -d "$HOME/.node_modules" ] && ln -s /keg/tap/node_modules $HOME/.node_modules

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
[ -z "$DOC_APP_PATH" ] && export DOC_APP_PATH=/keg/tap

# Goblet test run specific ENVs - customizable
export HERKIN_HEADLESS=1

# Github Action defined envs
[ -z "$GITHUB_REPOSITORY" ] && export GITHUB_REPOSITORY=goblet/repo
# [ -z "$GITHUB_ACTION_REPOSITORY" ] && export GITHUB_ACTION_REPOSITORY=/action/repo


# ---- Step 1 - Validate the goblet CI token
# TODO: Call goblet API to validate goblet CI token
[ -z "$GOBLET_TOKEN" ] && exitError "Goblet Token is required."
cd /goblet-action
# runYarn "goblet:validate"


# ---- Step 2 - Synmlink the workspace folder to the repos folder
# TODO: this is temp, remember to remove this
rm -rf /keg/repos/*

cd /goblet-action
runYarn "goblet:repo"
if [ "$LOCAL_DEV" ]; then
  export GOBLET_CONFIG_BASE=$(ts-node -r tsconfig-paths/register src/goblet/cache.ts paths.mountTo)
else
  export GOBLET_CONFIG_BASE=$(node -r tsconfig-paths/register dist/src/goblet/cache.js paths.mountTo)
fi
echo "[Goblet Action] Repo mount is $GOBLET_CONFIG_BASE"

# Step 3 - Run any pre-test commands
# TODO: Allow for passing multiple pre-test commands

# Step 4 - Run the tests
cd /keg/tap
yarn task bdd run --base $GOBLET_CONFIG_BASE


# Step 5 - Run any post-test commands
# TODO: Allow for passing multiple post-test commands

# Step 6 - Output the result of the executed tests
# TODO: Implment the defined outputs
  # echo "::set-output name=result::$GOBLET_TESTS_RESULTS"
  # echo "::set-output name=report-path::$GOBLET_TESTS_REPORT_PATH"
  # echo "::set-output name=artifacts-path::$GOBLET_TESTS_ARTIFACTS_PATH"

# exec "$@"
