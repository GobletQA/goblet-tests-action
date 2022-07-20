#!/bin/bash

__GOBLET_NO_COLOR__='\033[0m'

logMsg(){
  GREEN='\033[0;32m'
  printf "${GREEN}[Goblet]${__GOBLET_NO_COLOR__} $1\n"
}

logErr(){
  RED='\033[0;31m'
  printf "${RED}[Goblet]${__GOBLET_NO_COLOR__} $1\n"
}

logPurpleU(){
  PURPLE='\033[4;35m'
  printf "${PURPLE}${1}${__GOBLET_NO_COLOR__}"
}