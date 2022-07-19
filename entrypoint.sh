#!/bin/bash

#
# Init script to setup the test environment, then execute the tests based on passed in arguments
# Is expected to be run inside a docker container
# Run Tests Examples:
# * From Repos Root Directory on the Host Machine
#   * `yarn dr` => Runs all tests
#   * `GOBLET_BROWSERS=chrome yarn dr test.feature` => Runs test feature on chrome
# * When attached to the running containers shell
#   * `/goblet-action/entrypoint.sh`
#   * `GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature`
#
# Only Chrome
# GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature
#
# With Video
# GOBLET_TEST_VIDEO_RECORD=1 GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature
#
# With Trace
# GOBLET_TEST_TRACING=1 GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature
#
# With Video && Trace
# GOBLET_TEST_VIDEO_RECORD=1 GOBLET_TEST_TRACING=1 /goblet-action/entrypoint.sh test.feature
#

# Exit when any command fails
set -Eeo pipefail
source /goblet-action/scripts/logger.sh
trap exitError ERR

# Ensure devtools is not turned on
unset GOBLET_DEV_TOOLS
# export DEBUG=pw:api
# Unset the debug ENV so it can be reset via the GOBLET_BROWSER_DEBUG env
unset DEBUG

# Force headless mode in CI environment
export GOBLET_HEADLESS=true
export GIT_ALT_REPO_DIR=alt
export GOBLET_MOUNT_ROOT=/home/runner/work
export GH_WORKSPACE_PARENT_DIR=/home/runner/work
export GOBLET_ACT_REPO_LOCATION=/goblet-action
export GOBLET_CONFIG_BASE="$GITHUB_WORKSPACE"

export GOBLET_RUN_FROM_CI=1
[ "$GOBLET_TEST_NO_CI" ] && unset GOBLET_RUN_FROM_CI

MOUNT_WORK_DIR=$(pwd)
INVALID_TEST_TYPE=0

exitError(){
  setActionOutputs
  echo "::set-output name=result::fail"
  exit 1
}

# Finds the value for an ENV and sets it
getENVValue() {
  local ENV_NAME="${1}"
  local FOUND_VAL="${2:-$3}"
  if [ "$FOUND_VAL" ]; then
    eval "export $ENV_NAME=$FOUND_VAL"
  fi
}

# Pulls the value for an output, escapes it, then sets it as an output
# See https://github.community/t/set-output-truncates-multiline-strings/16852
setOutput(){
  local NAME="${1}"
  local JQ="${2}"
  local VAL=$(jq -r -M "$JQ" /home/runner/tap/temp/testMeta.json 2>/dev/null)

  if [ -z "$VAL" ]; then
    echo "::set-output name=$NAME::"
    return
  fi

  # Escape the paths so all paths can be captured by the output
  VAL="${VAL//'%'/'%25'}"
  VAL="${VAL//$'\n'/'%0A'}"
  VAL="${VAL//$'\r'/'%0D'}"
  echo "::set-output name=$NAME::$VAL"
}

# Clones an alternitive repo locally
cloneAltRepo(){
  cd $GOBLET_MOUNT_ROOT/goblet

  # TODO: Investigate if setting the user is even needed
  # Typeically only needed to push, which we are not doing here
  # If git user and email not set, use the current user from existing the git log
  # [ -z "$GIT_ALT_USER" ] && export GIT_ALT_USER="$(git log --format='%ae' HEAD^!)"
  # [ -z "$GIT_ALT_EMAIL" ] && export GIT_ALT_EMAIL="$(git log --format='%an' HEAD^!)"
  [ "$GIT_ALT_USER" ] && git config --global user.email "$GIT_ALT_USER"
  [ "$GIT_ALT_EMAIL" ] && git config --global user.name "$GIT_ALT_EMAIL"

  # Clone the repo using the passed in token if it exists
  local GIT_CLONE_TOKEN="${GIT_ALT_TOKEN:-$GOBLET_GIT_TOKEN}"

  logMsg "Cloning alt repo \"https://$GIT_ALT_REPO\""
  if [ "$GIT_CLONE_TOKEN" ]; then
    git clone "https://$GIT_CLONE_TOKEN@$GIT_ALT_REPO" "$GIT_ALT_REPO_DIR"
  else
    git clone "https://$GIT_ALT_REPO" "$GIT_ALT_REPO_DIR"
  fi

  # Navigate into the repo so we can get the pull path from (pwd)
  cd ./$GIT_ALT_REPO_DIR

  # If using a diff branch from default, fetch then checkout from origin
  if [ "$GIT_ALT_BRANCH" ]; then
    git fetch origin
    logMsg "Setting alt repo branch to \"$GIT_ALT_BRANCH\""
    git checkout -b $GIT_ALT_BRANCH origin/$GIT_ALT_BRANCH
  fi

  export GOBLET_CONFIG_BASE="$(pwd)"
}

# Helper to check if a generated file should exist, and if we should set it to an output
checkForSaveValue(){

  local ENV_NAME="${1}"
  local ENV_VAL="${!ENV_NAME}"

  # If the env is set to always, then report should exist
  if [ "$ENV_VAL" == "always" ]; then
    setOutput "${2}" "${3}"

  # If the tests failed, and the env is set to failed, true, or 1
  # Then a test report should exist
  elif [ "$GOBLET_TESTS_RESULT" == "fail" ]; then
    if [ "$ENV_VAL" == "failed" ] || [ "$ENV_VAL" == true ] || [ "$ENV_VAL" == 1 ]; then
      setOutput "${2}" "${3}"
    fi

  # If no value, or it's disabled then set empty and return
  else
    echo "::set-output name=${2}::"
  fi

}

# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
setRunEnvs(){

  getENVValue "GOBLET_TESTS_PATH" "${1}" "$GOBLET_TESTS_PATH"
  getENVValue "GIT_TOKEN" "${2}" $GIT_TOKEN
  getENVValue "GOBLET_TOKEN" "${3}" $GOBLET_TOKEN
  # TODO: Enable when goblet tokens are setup
  # [ -z "$GOBLET_TOKEN" ] && Add some exit code here for missing token

  # Alt Repo ENVs
  getENVValue "GIT_ALT_REPO" "${4}" "$GIT_ALT_REPO"
  getENVValue "GIT_ALT_BRANCH" "${5}" "$GIT_ALT_BRANCH"
  getENVValue "GIT_ALT_USER" "${6}" "$GIT_ALT_USER"
  getENVValue "GIT_ALT_EMAIL" "${7}" "$GIT_ALT_EMAIL"
  getENVValue "GIT_ALT_TOKEN" "${8}" "$GIT_ALT_TOKEN"

  # Goblet Test specific ENVs
  getENVValue "GOBLET_TEST_TYPE" "${9}" "$GOBLET_TEST_TYPE"
  getENVValue "GOBLET_TEST_RETRY" "${10}" "$GOBLET_TEST_RETRY"
  getENVValue "GOBLET_TEST_REPORT" "${11}" "$GOBLET_TEST_REPORT"
  getENVValue "GOBLET_TEST_TRACING" "${12}" "$GOBLET_TEST_TRACING"
  getENVValue "GOBLET_TEST_SCREENSHOT" "${13}" "$GOBLET_TEST_SCREENSHOT"
  getENVValue "GOBLET_TEST_VIDEO_RECORD" "${14}" "$GOBLET_TEST_VIDEO_RECORD"
  
  getENVValue "GOBLET_TEST_TIMEOUT" "${15}" "$GOBLET_TEST_TIMEOUT"
  getENVValue "GOBLET_TEST_CACHE" "${16}" "$GOBLET_TEST_CACHE"
  getENVValue "GOBLET_TEST_COLORS" "${17}" "$GOBLET_TEST_COLORS"
  getENVValue "GOBLET_TEST_WORKERS" "${18}" "$GOBLET_TEST_WORKERS"
  getENVValue "GOBLET_TEST_VERBOSE" "${19}" "$GOBLET_TEST_VERBOSE"
  getENVValue "GOBLET_TEST_OPEN_HANDLES" "${20}" "$GOBLET_TEST_OPEN_HANDLES"

  getENVValue "GOBLET_BROWSERS" "${21}" "$GOBLET_BROWSERS"
  getENVValue "GOBLET_BROWSER_DEBUG" "${22}" "$GOBLET_BROWSER_DEBUG"
  getENVValue "GOBLET_BROWSER_SLOW_MO" "${23}" "$GOBLET_BROWSER_SLOW_MO"
  getENVValue "GOBLET_BROWSER_CONCURRENT" "${24}" "$GOBLET_BROWSER_CONCURRENT"
  getENVValue "GOBLET_BROWSER_TIMEOUT" "${25}" "$GOBLET_BROWSER_TIMEOUT"

  # Goblet App specific ENVs
  [ -z "$NODE_ENV" ] && export NODE_ENV=test
  [ -z "$DOC_APP_PATH" ] && export DOC_APP_PATH=/keg/tap
  [ -z "$GOBLET_APP_URL" ] && export GOBLET_APP_URL="$APP_URL"

  getENVValue "GOBLET_GIT_TOKEN" "$GIT_ALT_TOKEN" "$GIT_TOKEN"

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

  local TEST_RUN_ARGS="--env $NODE_ENV --base $GOBLET_CONFIG_BASE"
  [ -z "$GOBLET_TEST_TYPE" ] && export GOBLET_TEST_TYPE="${GOBLET_TEST_TYPE:-bdd}"

  if [ "$GOBLET_TEST_TYPE" == "bdd" ]; then

    export GOBLET_TESTS_PATH="${GOBLET_TESTS_PATH:-$GOBLET_CONFIG_BASE}"
    TEST_RUN_ARGS="$TEST_RUN_ARGS --context $GOBLET_TESTS_PATH"

    # Add special handling for setting browsers option to auto set ---allBrowsers when not set
    if [ -z "$GOBLET_BROWSERS" ]; then
      TEST_RUN_ARGS="$TEST_RUN_ARGS --allBrowsers"
    elif  [ "$GOBLET_BROWSERS" == "all" ]; then
      TEST_RUN_ARGS="$TEST_RUN_ARGS --allBrowsers"
    else
      TEST_RUN_ARGS="$TEST_RUN_ARGS --browsers $GOBLET_BROWSERS"
    fi

    node ./tasks/runTask.js bdd run $TEST_RUN_ARGS
    local TEST_EXIT_STATUS=$?

    [ ${TEST_EXIT_STATUS} -ne 0 ] && export GOBLET_TESTS_RESULT="fail" || export GOBLET_TESTS_RESULT="pass"
    logMsg "Finished running tests for $GOBLET_TESTS_PATH"

  else
    export GOBLET_TESTS_RESULT="fail"
    logErr "Test type $GOBLET_TEST_TYPE not yet supported"
    echo "::set-output name=result::fail"
    echo "::set-output name=video-paths::"
    echo "::set-output name=trace-paths::"
    echo "::set-output name=report-paths::"
    exit 1
  fi
}

# ---- Step 5 - Output the result of the executed tests
# Examples
# jq -r -M '.latest.bdd.reports | map_values(.path)' /home/runner/tap/temp/testMeta.json
# jq -r -M ".latest.bdd.recordings | to_entries | .[].value | to_entries | .[].value.path" /home/runner/tap/temp/testMeta.json
# setOutput "report-paths" ".latest.bdd.reports | to_entries | .[].value.path"
# setOutput "video-paths" ".latest.bdd.recordings | to_entries | .[].value | to_entries | .[].value.path"
setActionOutputs(){

  # Only run the outputs when running in CI
  if [ -z "$GOBLET_RUN_FROM_CI" ]; then
    return
  fi

  # Only set the reports paths, if test reports is turned on
  checkForSaveValue "GOBLET_TEST_REPORT" \
    "report-paths" \
    ".latest.$GOBLET_TEST_TYPE.reports | to_entries | .[].value.path"
  
  # Only set the record paths, if video record is turned on
  checkForSaveValue "GOBLET_TEST_VIDEO_RECORD" \
    "video-paths" \
    ".latest.$GOBLET_TEST_TYPE.recordings | to_entries | .[].value | to_entries | .[].value.path"

  # Only set the trace paths, if tracing record is turned on
  checkForSaveValue "GOBLET_TEST_TRACING" \
    "trace-paths" \
    ".latest.$GOBLET_TEST_TYPE.traces | to_entries | .[].value | to_entries | .[].value.path"

}

# Kick off the test run...
setRunEnvs "$@"
setupWorkspace "$@"
runTests "$@"
setActionOutputs "$@"

# Set the final result state, which should be pass if we get to this point
echo "::set-output name=result::$GOBLET_TESTS_RESULT"

