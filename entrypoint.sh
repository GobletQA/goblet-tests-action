#!/bin/bash
# /goblet-action/entrypoint.sh 

# Exit when any command fails
set -e
set -o pipefail

export DEBUG=pw:api
export GOBLET_MOUNT_ROOT=/home/runner/work
export GH_WORKSPACE_PARENT_DIR=/home/runner/work
export GOBLET_ACT_REPO_LOCATION=/goblet-action/repo-location
export GOBLET_CONFIG_BASE="$GITHUB_WORKSPACE"

export GOBLET_RUN_FROM_CI=1
[ "$GOBLET_TEST_NO_CI" ] && unset GOBLET_RUN_FROM_CI

MOUNT_WORK_DIR=$(pwd)

exitError(){
  echo "::set-output name=error::'$1'"
  echo "::set-output name=result::fail"
  local STATUS="${1:-1}"
  exit "${STATUS}"
}

logMsg(){
  GREEN='\033[0;32m'
  NC='\033[0m'
  printf "${GREEN}[Goblet]${NC} $1\n"
}

# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
setRunEnvs(){

  [ -z "$GOBLET_TESTS_PATH" ] && export GOBLET_TESTS_PATH="${1:-$GOBLET_TESTS_PATH}"
  [ -z "$GIT_TOKEN" ] && export GIT_TOKEN="${2:-$GIT_TOKEN}"
  [ -z "$GOBLET_TOKEN" ] && export GOBLET_TOKEN="${3:-$GOBLET_TOKEN}"
  # TODO: Enable when goblet tokens are setup
  # [ -z "$GOBLET_TOKEN" ] && exitError "Goblet Token is required."
  [ -z "$GOBLET_REPORT_NAME" ] && export GOBLET_REPORT_NAME="${4:-$GOBLET_REPORT_NAME}"

  # Alt Repo ENVs
  [ -z "$GIT_ALT_REPO" ] && export GIT_ALT_REPO="${5:-$GIT_ALT_REPO}"
  [ -z "$GIT_ALT_BRANCH" ] && export GIT_ALT_BRANCH="${6:-$GIT_ALT_BRANCH}"
  [ -z "$GIT_ALT_USER" ] && export GIT_ALT_USER="${7:-$GIT_ALT_USER}"
  [ -z "$GIT_ALT_EMAIL" ] && export GIT_ALT_EMAIL="${8:-$GIT_ALT_EMAIL}"
  [ -z "$GIT_ALT_TOKEN" ] && export GIT_ALT_TOKEN="${9:-$GIT_ALT_TOKEN}"

  # Goblet Test specific ENVs
  [ -z "$GOBLET_TEST_RETRY" ] && export GOBLET_TEST_RETRY="${10:-$GOBLET_TEST_RETRY}"
  [ -z "$GOBLET_TEST_TRACING" ] && export GOBLET_TEST_TRACING="${11:-$GOBLET_TEST_TRACING}"
  [ -z "$GOBLET_TEST_SCREENSHOT" ] && export GOBLET_TEST_SCREENSHOT="${12:-$GOBLET_TEST_SCREENSHOT}"
  [ -z "$GOBLET_TEST_VIDEO_RECORD" ] && export GOBLET_TEST_VIDEO_RECORD="${13:-$GOBLET_TEST_VIDEO_RECORD}"
  
  [ -z "$GOBLET_TEST_TIMEOUT" ] && export GOBLET_TEST_TIMEOUT="${14:-$GOBLET_TEST_TIMEOUT}"  
  [ -z "$GOBLET_TEST_CACHE" ] && export GOBLET_TEST_CACHE="${15:-$GOBLET_TEST_CACHE}"
  [ -z "$GOBLET_TEST_COLORS" ] && export GOBLET_TEST_COLORS="${16:-$GOBLET_TEST_COLORS}"
  [ -z "$GOBLET_TEST_WORKERS" ] && export GOBLET_TEST_WORKERS="${7:-$GOBLET_TEST_WORKERS}"
  [ -z "$GOBLET_TEST_VERBOSE" ] && export GOBLET_TEST_VERBOSE="${18:-$GOBLET_TEST_VERBOSE}"
  [ -z "$GOBLET_TEST_OPEN_HANDLES" ] && export GOBLET_TEST_OPEN_HANDLES="${19:-$GOBLET_TEST_OPEN_HANDLES}"

  [ -z "$GOBLET_BROWSERS" ] && export GOBLET_BROWSERS="${20:-$GOBLET_BROWSERS}"
  [ -z "$GOBLET_BROWSER_SLOW_MO" ] && export GOBLET_BROWSER_SLOW_MO="${21:-$GOBLET_BROWSER_SLOW_MO}"
  [ -z "$GOBLET_BROWSER_CONCURRENT" ] && export GOBLET_BROWSER_CONCURRENT="${22:-$GOBLET_BROWSER_CONCURRENT}"
  [ -z "$GOBLET_BROWSER_TIMEOUT" ] && export GOBLET_BROWSER_TIMEOUT="${23:-$GOBLET_BROWSER_TIMEOUT}"

  # Goblet App specific ENVs
  [ -z "$NODE_ENV" ] && export NODE_ENV=test
  [ -z "$DOC_APP_PATH" ] && export DOC_APP_PATH=/keg/tap
  [ -z "$GOBLET_APP_URL" ] && export GOBLET_APP_URL="$APP_URL"
  [ -z "$GOBLET_GIT_TOKEN" ] && export GOBLET_GIT_TOKEN="${GIT_ALT_TOKEN:-$GIT_TOKEN}"

  # Force headless mode in CI environment
  [ -z "$GOBLET_HEADLESS" ] && export GOBLET_HEADLESS=true
  unset $GOBLET_DEV_TOOLS

}

# Clones an alternitive repo locally
cloneAltRepo(){
  cd $GOBLET_MOUNT_ROOT/goblet

  # If git user and email not set, use the current user from existing the git log
  [ -z "$GIT_ALT_USER" ] && export GIT_ALT_USER="$(git log --format='%ae' HEAD^!)"
  [ -z "$GIT_ALT_EMAIL" ] && export GIT_ALT_EMAIL="$(git log --format='%an' HEAD^!)"

  git config --local user.email "$GIT_ALT_USER"
  git config --local user.name "$GIT_ALT_EMAIL"

  # Clone the repo using the passed in token if it exists
  local GIT_CLONE_TOKEN="${GIT_ALT_TOKEN:-$GOBLET_GIT_TOKEN}"
  if [ "$GIT_CLONE_TOKEN" ]; then
    git clone https://$GIT_CLONE_TOKEN@$GIT_ALT_REPO
  else
    git clone https://$GIT_ALT_REPO
  fi

  # Navigate into the repo so we can get the pull path from (pwd)
  cd ./alt-repo

  # If using a diff branch from default, fetch then checkout from origin
  if [ "$GIT_ALT_BRANCH" ]; then
    git fetch origin
    git checkout -b $GIT_ALT_BRANCH origin/$GIT_ALT_BRANCH
  fi

  export GOBLET_CONFIG_BASE="$(pwd)"
}

# ---- Step 2 - Synmlink the workspace folder to the repos folder
setupWorkspace(){
  [ "$GIT_ALT_REPO" ] && cloneAltRepo "$@"

  echo ""
  logMsg "Repo mount is $GOBLET_CONFIG_BASE"
}

# ---- Step 4 - Run the tests
runTests(){
  logMsg "Running Tests..."
  # Goblet test run specific ENVs - customizable
  # Switch to the goblet dir and run the bdd test task
  cd /home/runner/tap

  local BDD_TEST_ARGS="--env $NODE_ENV"

  [ "$GOBLET_CONFIG_BASE" ] && BDD_TEST_ARGS="$BDD_TEST_ARGS --base $GOBLET_CONFIG_BASE"
  [ "$GOBLET_TESTS_PATH" ] && BDD_TEST_ARGS="$BDD_TEST_ARGS --context $GOBLET_TESTS_PATH"

  # Add special handling for setting allBrowsers option when not exists, or set to all 
  [ -z "$GOBLET_BROWSERS" ] && BDD_TEST_ARGS="$BDD_TEST_ARGS --allBrowsers"
  [ "$GOBLET_BROWSERS" == "all" ] && BDD_TEST_ARGS="$BDD_TEST_ARGS --allBrowsers"

  yarn task bdd run $BDD_TEST_ARGS
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
  setupWorkspace "$@"
  runTests "$@"
  setActionOutputs "$@"
)}

init "$@"
EXIT_STATUS=$?
[ ${EXIT_STATUS} -ne 0 ] && exitError "$EXIT_STATUS"