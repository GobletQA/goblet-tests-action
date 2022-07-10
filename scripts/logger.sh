#!/bin/bash

logMsg(){
  GREEN='\033[0;32m'
  NC='\033[0m'
  printf "${GREEN}[Goblet]${NC} $1\n"
}

logErr(){
  RED='\033[0;31m'
  NC='\033[0m'
  printf "${RED}[Goblet]${NC} $1\n"
}
