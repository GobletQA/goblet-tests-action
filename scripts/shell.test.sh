#!/bin/bash

source ./scripts/helpers.sh
source ./scripts/logger.sh

# cleanRepoUrl "https://github.com/My-Org/Some-repo-Name"
# cleanRepoUrl "https://user@something:proto/My-Org/Some-repo-Name.git"
# cleanRepoUrl "git@github.com:Goblet/Test-Reoi.git"

# cleanRepoUrl "https://oauth2:12345@github.com/My-Org/Some-repo-Name.git"
# cleanRepoUrl "sftp://odroid@gmail.com:mypass@home@192.168.2.162:1/home/odroid/dump::1.txt"

# return `${url.protocol}//${token}@${url.host}${url.pathname}`
#     `${url.protocol}//oauth2:${token}@${url.host}${url.pathname}`
# URL1=$(cleanRepoUrl "https://github.com/My-Org/Some-repo-Name")
# logMsg "URL-1 => $URL1"



# URL2=$(cleanRepoUrl "https://github.com/My-Org/Some-repo-Name.git")
# logMsg "URL-2 => $URL2"


# URL3=$(cleanRepoUrl "https://user@something:proto/My-Org/Some-repo-Name.git")
# logMsg "URL-3 => $URL3"


# URL4=$(cleanRepoUrl "git@github.com:Goblet/Test-Reoi.git")
# logMsg "URL-4 => $URL4"
