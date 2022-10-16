#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

# Will update the version in the package.json and action.yaml
# Will then build and push the docker image to github
yarn dvp

# The get the update version from the package.json
UPDATE_VERSION=$(yarn --silent echoVersion)

logMsg "Commiting version $UPDATE_VERSION and pushing to github"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

git add .
git commit -m "chore: Update action to version $UPDATE_VERSION"
git push origin $GIT_BRANCH