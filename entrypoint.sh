#!/bin/bash

#
# Init script to setup the test environment, then execute the tests based on passed in arguments
# Is expected to be run inside a docker container
# Run Tests Examples:
# * From Repos Root Directory on the Host Machine
#   * `pnpm dr` => Runs all tests
#   * `GOBLET_BROWSERS=chrome pnpm dr test.feature` => Runs test feature on chrome
# * When attached to the running containers shell
#   * `/goblet-action/entrypoint.sh`
#   * `GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature`
#
# Only Chrome
# GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh Tester.feature
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
# set -Eeo pipefail
source /goblet-action/scripts/logger.sh
source /goblet-action/scripts/helpers.sh
trap exitError ERR
trap exitCtrlC INT

# Ensure devtools is not turned on
unset GOBLET_DEV_TOOLS
# Unset the debug ENV so it can be reset via the GOBLET_BROWSER_DEBUG env
unset DEBUG

# Force headless mode in CI environment
export GOBLET_RUN_FROM_CI=1
export GOBLET_HEADLESS=true
export GIT_ALT_REPO_DIR=alt
export GOBLET_ACT_REPO_LOCATION=/goblet-action
export GOBLET_TEMP_META_LOC="/github/app/temp/testMeta.json"

MOUNT_WORK_DIR=$(pwd)
MOUNT_TEMP_DIR=".goblet-temp"


# ---- Step 0 - Set ENVs from inputs if they don't already exist
# Goblet Action specific ENVs
setRunEnvs(){

  # If the CI env is not set, then set it to 1 by default
  getENVValue "CI" "$CI" "1"
  
  # Ensure the GOBLET_CONFIG_BASE && GOBLET_MOUNT_ROOT envs are set
  ensureConfigBase "$MOUNT_WORK_DIR"

  getENVValue "GOBLET_TESTS_PATH" "${1}" "$GOBLET_TESTS_PATH"
  getENVValue "GIT_TOKEN" "${2}" "$GIT_TOKEN"
  getENVValue "GOBLET_TOKEN" "${3}" "$GOBLET_TOKEN"

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
  getENVValue "GOBLET_TEST_BAIL" "${20}" "$GOBLET_TEST_BAIL"

  getENVValue "GOBLET_BROWSERS" "${21}" "$GOBLET_BROWSERS"
  getENVValue "GOBLET_BROWSER_SLOW_MO" "${22}" "$GOBLET_BROWSER_SLOW_MO"
  getENVValue "GOBLET_BROWSER_CONCURRENT" "${23}" "$GOBLET_BROWSER_CONCURRENT"
  getENVValue "GOBLET_BROWSER_TIMEOUT" "${24}" "$GOBLET_BROWSER_TIMEOUT"
  getENVValue "GOBLET_ARTIFACTS_DEBUG" "${25}" "$GOBLET_ARTIFACTS_DEBUG"
  getENVValue "GOBLET_FEATURE_TAGS" "${26}" "$GOBLET_FEATURE_TAGS"
  getENVValue "GOBLET_TEST_HTML_COMBINE_REPORT" "${27}" "$GOBLET_TEST_HTML_COMBINE_REPORT"
  getENVValue "GOBLET_CONTEXT_REUSE" "${28}" "$GOBLET_CONTEXT_REUSE"

  # Goblet App specific ENVs
  [ -z "$NODE_ENV" ] && export NODE_ENV=test
  [ -z "$GOBLET_APP_URL" ] && export GOBLET_APP_URL="$APP_URL"

  getENVValue "GOBLET_GIT_TOKEN" "$GIT_ALT_TOKEN" "$GIT_TOKEN"

}

# ---- Step 2 - Synmlink the workspace folder to the repos folder
setupWorkspace(){
  if [ "$GOBLET_LOCAL_SIMULATE_ALT" ] && [ "$GOBLET_LOCAL_DEV" ]; then
    export GIT_ALT_REPO=github.com/local/simulate.git
    # Navigate into the repo so we can get the pull path from (pwd)
    cd $GOBLET_MOUNT_ROOT/$GIT_ALT_REPO_DIR
    export GOBLET_CONFIG_BASE="$(pwd)"

  # Check if we should clone down the alt repo and use it
  elif [ "$GIT_ALT_REPO" ]; then
    cloneAltRepo
  fi

  echo ""
  logMsg "Goblet config base is $GOBLET_CONFIG_BASE"
}

logRunArguments(){
  # TODO: either split by argument, or disable and print arguments from bdd-run task in goblet
  logMsg "Running Tests with:"
  logPurpleU "  $TEST_RUN_ARGS"
  echo ""
}

# ---- Step 4 - Run the tests
runTests(){
  # Goblet test run specific ENVs - customizable
  # Switch to the goblet dir and run the bdd test task
  cd /github/app

  local TEST_RUN_ARGS="--env $NODE_ENV --base $GOBLET_CONFIG_BASE"

  [ -z "$GOBLET_TEST_TYPE" ] && export GOBLET_TEST_TYPE="${GOBLET_TEST_TYPE:-bdd}"

  if [ "$GOBLET_TEST_TYPE" == "bdd" ]; then

    # If a tests path is not set, then use the base path to look for tests
    export GOBLET_TESTS_PATH="${GOBLET_TESTS_PATH:-$GOBLET_CONFIG_BASE}"
    
    # For github action, arguments are passed via ENVs, so use the GOBLET_TESTS_PATH env for the context
    # For docker image, assume the context is passed as an argument, (i.e. --context my-test)
    [ "$GITHUB_ACTIONS" ] && TEST_RUN_ARGS="$TEST_RUN_ARGS --context $GOBLET_TESTS_PATH"

    # Add special handling for setting browsers option to auto set ---allBrowsers when not set
    if [ -z "$GOBLET_BROWSERS" ]; then
      TEST_RUN_ARGS="$TEST_RUN_ARGS --allBrowsers"
    elif  [ "$GOBLET_BROWSERS" == "all" ]; then
      TEST_RUN_ARGS="$TEST_RUN_ARGS --allBrowsers"
    else
      TEST_RUN_ARGS="$TEST_RUN_ARGS --browsers $GOBLET_BROWSERS"
    fi


    # If arguments were passed in, then forward them to the command
    if [ "$1" ]; then
      TEST_RUN_ARGS="$TEST_RUN_ARGS $@"
    fi

    # logRunArguments "$TEST_RUN_ARGS"

    # Example commands
    # cd ../app
    # node -r esbuild-register tasks/entry.ts bdd run --env test --base /github/workspace --context Tester.feature --browsers chrome
    # node -r esbuild-register tasks/goblet.ts bdd run --env test --base /github/workspace --context Log-In --browsers chrome
    # node -r esbuild-register tasks/goblet.ts bdd run --env test --base /github/workspace --tags @whitelist
    
    node -r esbuild-register tasks/goblet.ts bdd run "$TEST_RUN_ARGS"
    export TEST_EXIT_STATUS=$?


    if [ ${TEST_EXIT_STATUS} -ne 0 ]; then
      export GOBLET_TESTS_RESULT="fail"
      logErr "Test Exit Code: $TEST_EXIT_STATUS"
      logErr "❌ - One or more of the executed tests failed"
    else
      logMsg "Test Exit Code: $TEST_EXIT_STATUS"
      export GOBLET_TESTS_RESULT="pass"
      logMsg "👍 - All executed tests passed"
    fi

  else
    export GOBLET_TESTS_RESULT="fail"
    logErr "Test type $GOBLET_TEST_TYPE not yet supported"
    setOutput "result" "fail"
    setOutput "video-paths" ""
    setOutput "trace-paths" ""
    setOutput "report-paths" ""
    exit 1
  fi
}

# ---- Step 5 - Ensure the artifacts dir is configured properly
ensureArtifactsDir(){

  ARTIFACTS_DIR="$(jq -r -M ".latest.artifactsDir" "$GOBLET_TEMP_META_LOC" 2>/dev/null)"

  # If using an alt repo, copy over the artifacts dir to the workspace mounted volume
  if [ "$GIT_ALT_REPO" ]; then
    # For alt-repo set artifacts path to the relative path of the copied-to dir
    cp -r "$ARTIFACTS_DIR" "$MOUNT_WORK_DIR/$MOUNT_TEMP_DIR"
    setOutput "artifacts-path" "$MOUNT_TEMP_DIR"
  else
    # By default set artifacts path to the relative path of the $ARTIFACTS_DIR
    RELATIVE_DIR="${ARTIFACTS_DIR//$GITHUB_WORKSPACE\//}"
    setOutput "artifacts-path" "$RELATIVE_DIR"
  fi
}

# ---- Step 6 - Output the result of the executed tests
setActionOutputs(){

  # Only set the reports paths, if test reports is turned on
  checkForArtifacts "GOBLET_TEST_REPORT" \
    "report-paths" \
    ".latest.$GOBLET_TEST_TYPE.reports | to_entries | .[].value.path"
  
  # Only set the record paths, if video record is turned on
  checkForArtifacts "GOBLET_TEST_VIDEO_RECORD" \
    "video-paths" \
    ".latest.$GOBLET_TEST_TYPE.recordings | to_entries | .[].value | to_entries | .[].value.path"

  # Only set the trace paths, if tracing record is turned on
  checkForArtifacts "GOBLET_TEST_TRACING" \
    "trace-paths" \
    ".latest.$GOBLET_TEST_TYPE.traces | to_entries | .[].value | to_entries | .[].value.path"

}

# If running as a github actions pass in the inputs
# Otherwise check for ENVs, and pass the inputs to the runTests command
[ "$GITHUB_ACTIONS" ] && setRunEnvs "$@" || setRunEnvs

setupWorkspace "$@"

[ "$GITHUB_ACTIONS" ] && runTests || runTests "$@"

ensureArtifactsDir
setActionOutputs

if [ ${TEST_EXIT_STATUS} -ne 0 ]; then
  setOutput "result" "$GOBLET_TESTS_RESULT"
  exit 1
else
  # Set the final result state, which should be pass if we get to this point
  logMsg "Finished running tests for $GOBLET_TESTS_PATH"
  setOutput "result" "$GOBLET_TESTS_RESULT"
fi
