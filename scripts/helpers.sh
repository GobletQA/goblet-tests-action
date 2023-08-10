#!/bin/bash

# Logs an error and exists the script
# Ensures the artifacts and outputs are set
exitError(){
  export GOBLET_TESTS_RESULT="fail"

  setOutput "result" "$GOBLET_TESTS_RESULT"
  logErr "Finished running tests for $GOBLET_TESTS_PATH"
  ensureArtifactsDir
  setActionOutputs
  logErr "Test Exit Code: 1"
  echo ""
  exit 1
}

exitCtrlC(){
  export GOBLET_TESTS_RESULT="fail"
  setOutput "result" "$GOBLET_TESTS_RESULT"
  logErr "User force quit test execution"
  ensureArtifactsDir
  setActionOutputs
  logErr "Test Exit Code: 1"
  echo ""
  exit 1
}

# Writes the output to stdout and the $GITHUB_OUTPUT ENV
setOutput() {
  if [ -z "${GOBLET_LOCAL_DEV}" ]; then
    if [ "$GITHUB_ACTION" ]; then
      echo "${1}=${2}" | tee -a "${GITHUB_OUTPUT}"
    fi
  else
    echo "::set-output name=${1}::${2}"
  fi
}

# Finds the value for an ENV and sets it
getENVValue() {
  local ENV_NAME="${1}"
  local FOUND_VAL="${2:-$3}"
  if [ "$FOUND_VAL" ]; then
    eval "export $ENV_NAME=$FOUND_VAL"
  fi
}

# Gets goblet config base path and the parent directory
# Sets both `GOBLET_CONFIG_BASE` and `GOBLET_MOUNT_ROOT` envs
# Defaults to `/github/workspace` and `/github`
# Based on github actions mounted directory
ensureConfigBase(){

  local WORK_DIR=$(pwd)
  local MOUNT_WORK_DIR="${1}"

  if [ -z "$GOBLET_CONFIG_BASE" ]; then
    if [ -z "$GITHUB_WORKSPACE" ]; then
      export GOBLET_CONFIG_BASE="${MOUNT_WORK_DIR:-$WORK_DIR}"
    else
      export GOBLET_CONFIG_BASE="$GITHUB_WORKSPACE"
    fi
  fi
  
  local MOUNT_ROOT="$(dirname "$GOBLET_CONFIG_BASE")"
  [ -z "$GOBLET_MOUNT_ROOT" ] && export GOBLET_MOUNT_ROOT="${MOUNT_ROOT:-/github}"

}

# Pulls the value for an output, escapes it, then sets it as an output
addArtifacts(){
  local NAME="${1}"
  local JQ="${2}"
  local VAL=$(jq -r -M "$JQ" "$GOBLET_TEMP_META_LOC" 2>/dev/null)

  if [ -z "$VAL" ]; then
    setOutput "$NAME" ""
    return
  fi

  # Update the paths to just be relative paths to the workspace root directory
  # If using an alt repo, rewrite the location to the mounted folder
  if [ "$GIT_ALT_REPO" ]; then
    VAL="${VAL//$ARTIFACTS_DIR/$MOUNT_TEMP_DIR}"
  else
    VAL="${VAL//$GITHUB_WORKSPACE\//}"
  fi

  # Log the found artifacts to be uploaded for reference pre-escaping
  logMsg "Test Artifacts found for ${1} output"
  echo "${VAL}"

  # Escape the paths so all paths can be captured by the output
  VAL="${VAL//'%'/'%25'}"
  VAL="${VAL//$'\n'/'%0A'}"
  VAL="${VAL//$'\r'/'%0D'}"
  # Multi-Line string convert to single-line with escaped paths
  setOutput "$NAME" "$VAL"
}

cleanRepoUrl(){
  local URL="$1"

  # Parse the protocol from the alt repo url, so we can enforce https
  local _PARSED_PROTO="$(echo $URL | sed -nr 's,^(.*://).*,\1,p')"
  local _CLEANED_URL="$(echo ${$URL/$_PARSED_PROTO/})"

  local _PARSED_USER="$(echo $_PARSED_PROTO | sed -nr 's,^(.*@).*,\1,p')"
  local _CLEANED_URL="$(echo ${$_CLEANED_URL/$_PARSED_USER/})"

  local _PARSED_PATH="$(echo $_CLEANED_URL | sed -nr 's,[^/:]*([/:].*),\1,p')"
  local _PARSED_HOST="$(echo ${_CLEANED_URL/$_PARSED_PATH/})"

  echo "$_PARSED_HOST/$_PARSED_PATH"
}

# Clones an alternitive repo locally
cloneAltRepo(){
  cd $GOBLET_MOUNT_ROOT

  # Ensure the user is configured with git
  # If git user is not set, use the current user from existing the git log
  [ -z "$GIT_ALT_USER" ] && export GIT_ALT_USER="$(git log --format='%ae' HEAD^!)"
  [ "$GIT_ALT_USER" ] && git config --global user.email "$GIT_ALT_USER"

  # If git email not set, use the current email from existing the git log
  [ -z "$GIT_ALT_EMAIL" ] && export GIT_ALT_EMAIL="$(git log --format='%an' HEAD^!)"
  [ "$GIT_ALT_EMAIL" ] && git config --global user.name "$GIT_ALT_EMAIL"

  # Clone the repo using the passed in token if it exists
  local GIT_CLONE_TOKEN="${GIT_ALT_TOKEN:-$GOBLET_GIT_TOKEN}"
  local GB_CLEANED_URL="$(cleanRepoUrl "$GIT_ALT_REPO")"

  logMsg "Cloning alt repo \"https://$GB_CLEANED_URL\""

  if [ "$GIT_CLONE_TOKEN" ]; then
    git clone "https://$GIT_CLONE_TOKEN@$GB_CLEANED_URL" "$GIT_ALT_REPO_DIR"
  else
    git clone "https://$GB_CLEANED_URL" "$GIT_ALT_REPO_DIR"
  fi

  export GB_GIT_REPO_REMOTE="https://$GB_CLEANED_URL"

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
checkForArtifacts(){

  local ENV_NAME="${1}"
  local ENV_VAL="${!ENV_NAME}"

  # If the env is set to always, then report should exist
  if [ "$ENV_VAL" == "always" ]; then
    addArtifacts "${2}" "${3}"
    logMsg "Test Artifacts found for ${2}"

  # If the tests failed, and the env is set to failed, true, or 1
  # Then a test report should exist
  elif [ "$GOBLET_TESTS_RESULT" == "fail" ]; then
    if [ "$ENV_VAL" == "failed" ] || [ "$ENV_VAL" == true ] || [ "$ENV_VAL" == 1 ]; then
      addArtifacts "${2}" "${3}"
      logMsg "Test Artifacts found for ${2} output"
    fi

  # If no value, or it's disabled then set empty and return
  else
    setOutput "${2}" ""
  fi

}


