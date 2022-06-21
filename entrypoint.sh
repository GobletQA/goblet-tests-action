#!/bin/bash

# Exit when any command fails
set -e

export GOBLET_TOKEN=$1
export GOBLET_REPORT_NAME=$2
export GOBLET_FOLDER_PATH=$3
export GOBLET_PRE_CMDS=$4
export GOBLET_POST_CMDS=$5

exit_error(){
  echo "::set-output name=error::'$1'"
  echo "::set-output name=result::fail"
  exit 1
}


# Step 0 - Validate the goblet CI token
# TODO: Call goblet API to validate goblet CI token
[[ -z "$GOBLET_TOKEN" ]] && exit_error "Goblet Token is required."

yarn validate:goblet

# Step 1 - Run any pre-test commands
# TODO: Allow for passing multiple pre-test commands

# Step 2 - Ensure the test folder can be found
# Check to ensure goblet folder can be found
[[ ! -d "$GOBLET_FOLDER_PATH" ]] && exit_error "Goblet folder path does not exist."


# Step 3 - Execute the tests in the found test folder
# TODO: Run test command for the found tests ( i.e. yarn goblet ...args )

# Step 4 - Run any post-test commands
# TODO: Allow for passing multiple post-test commands

# Step 5 - Output the result of the executed tests
# TODO: Implment the defined outputs
  # echo "::set-output name=result::$GOBLET_TESTS_RESULTS"
  # echo "::set-output name=report-path::$GOBLET_TESTS_REPORT_PATH"
  # echo "::set-output name=artifacts-path::$GOBLET_TESTS_ARTIFACTS_PATH"


