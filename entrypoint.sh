#!/bin/bash
# /goblet-action/entrypoint.sh

# Exit when any command fails
set -e
set -o pipefail

export DEBUG=pw:api
export GOBLET_RUN_FROM_CI=1
export GOBLET_MOUNT_ROOT=/keg/repos
export GH_WORKSPACE_PARENT_DIR=/home/runner/work
export GOBLET_ACT_REPO_LOCATION=/goblet-action/repo-location

MOUNT_WORK_DIR=$(pwd)

exitError(){
  echo "::set-output name=error::'$1'"
  echo "::set-output name=result::fail"
  local STATUS="${1:-1}"
  exit "${STATUS}"
}

# Runs a yarn command with a prefix when LOCAL_DEV exists
runYarn(){
  if [ "$LOCAL_DEV" ]; then
    yarn dev:$1 $2
  else
    yarn $1 $2
  fi
}

logMsg(){
  GREEN='\033[0;32m'
  NC='\033[0m'
  printf "${GREEN}[Goblet]${NC} $1\n"
}

# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
setRunEnvs(){


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
  [ -z "$DOC_APP_PATH" ] && export DOC_APP_PATH=/keg/tap
  [ -z "$GOBLET_APP_URL" ] && export GOBLET_APP_URL="$APP_URL"
  [ -z "$GOBLET_GIT_TOKEN" ] && export GOBLET_GIT_TOKEN="${GIT_ALT_TOKEN:-$GIT_TOKEN}"

  [ -z "$GOBLET_HEADLESS" ] && export GOBLET_HEADLESS=true
  unset $GOBLET_DEV_TOOLS

}


# ---- Step 1 - Validate the goblet CI token
gobletValidate(){
  cd /goblet-action
  runYarn "goblet:validate"
}


# ---- Step 2 - Synmlink the workspace folder to the repos folder
setupWorkspace(){
  cd /goblet-action
  runYarn "goblet:repo"

  cat $GOBLET_ACT_REPO_LOCATION 2>/dev/null
  local EXIT_STATUS=$?
  [ ${EXIT_STATUS} -ne 0 ] && exitError "$EXIT_STATUS"

  export GOBLET_CONFIG_BASE=$(cat $GOBLET_ACT_REPO_LOCATION)
  echo "[Goblet] Repo mount is $GOBLET_CONFIG_BASE"
}


# ---- Step 3 - Run any pre-test commands
runPreTests(){
  # TODO: Allow for passing multiple pre-test commands
  logMsg "TODO - Execute pre test actions"
}


# ---- Step 4 - Run the tests
runTests(){
  logMsg "Running Tests..."
  # Goblet test run specific ENVs - customizable
  # Switch to the goblet dir and run the bdd test task
  cd /home/runner/tap
  # yarn task bdd run base=$GOBLET_CONFIG_BASE
  # TODO: run this test => strat-collab-close.feature in the browser
  # Figure out why it's failing, could be related to how the node_modules are being loaded
  # It can't seem to find the core-js modules from goblet
  # yarn task bdd run --context strat-props-close-modal.feature --base /home/runner/work/goblet/repo --env $NODE_ENV
  
  # yarn task bdd run base=/home/runner/work/goblet/repo context=/home/runner/work/goblet/repo/herkin/bdd/features/strat-props-close-modal.feature slowMo=100
  # node ./tasks/runTask.js bdd run context=/home/runner/work/goblet/repo/herkin/bdd/features/strat-props-close-modal.feature base=/home/runner/work/goblet/repo slowMo=100 env=$NODE_ENV
  
  yarn task bdd run \
    slowMo=100 \
    env=$NODE_ENV \
    base=/keg/repos/goblet/repo \
    context=strategy-onboarding.feature

}


# ---- Step 5 - Run any post-test commands
runPostTests(){
  # Step 3 - Run any pre-test commands
  if [ -z "$GOBLET_POST_CMDS" ]; then
    return
  fi

  logMsg "TODO - Execute post test actions"
}


# ---- Step 6 - Output the result of the executed tests
setActionOutputs(){
  # TODO: Implment the defined outputs
  echo "TODO - Set envs for github actions outputs"
  echo "::set-output name=result::$GOBLET_TESTS_RESULTS"
  echo "::set-output name=report-path::$GOBLET_TESTS_REPORT_PATH"
  echo "::set-output name=artifacts-path::$GOBLET_TESTS_ARTIFACTS_PATH"
}

init() {(
  set -e
  setRunEnvs "$@"
  # gobletValidate "$@"
  setupWorkspace "$@"
  runPreTests "$@"
  runTests "$@"
  runPostTests "$@"
  setActionOutputs "$@"
)}

init "$@"
EXIT_STATUS=$?
[ ${EXIT_STATUS} -ne 0 ] && exitError "$EXIT_STATUS"