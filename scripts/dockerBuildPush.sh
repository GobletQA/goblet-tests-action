#!/bin/bash

source $KEG_CLI_PATH/keg
source scripts/logger.sh

# Build goblet first
# keg goblet
# yarn doc build --context bs --push
# yarn doc build --push

# TODO: update version
# node scripts/updateVersion.js

# Then build goblet-action
source scripts/dockerBuild.sh --push
