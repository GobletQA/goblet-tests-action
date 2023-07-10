#!/bin/bash

__GOBLET_NO_COLOR__='\033[0m'

logColor(){

  local WITH_CLRS="$1"
  local NO_CLRS="$2"
  local CLRS="$GOBLET_TEST_COLORS"

  if [ -z "$CLRS" ] || [ "$CLRS" == "1" ] || [ "$CLRS" == "t" ] || [ "$CLRS" == "true" ]; then
    printf "$WITH_CLRS"
  else
    printf "$NO_CLRS"
  fi

}

logMsg(){
  local MSG="$1"
  local GREEN='\033[0;32m'
  logColor "${GREEN}[Goblet]${__GOBLET_NO_COLOR__} $MSG\n" "[Goblet] $MSG\n"
}

logErr(){
  local MSG="$1"
  local RED='\033[0;31m'
  logColor "${RED}[Goblet]${__GOBLET_NO_COLOR__} $MSG\n" "[Goblet] $MSG\n"
}

logPurpleU(){
  local MSG="$1"
  local PURPLE='\033[4;35m'
  logColor "${PURPLE}${MSG}${__GOBLET_NO_COLOR__}" "$MSG"
}
