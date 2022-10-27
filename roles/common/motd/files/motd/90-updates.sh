#!/bin/bash

W="\e[0;39m"
G="\e[1;32m"
R="\e[1;31m"
Y="\e[0;33m"

UPDATES=$(/usr/local/bin/apt-check 2>&1)
STANDARD_UPDATES=$(echo $UPDATES | cut -d';' -f1)
SECURITY_UPDATES=$(echo $UPDATES | cut -d';' -f2)

echo -e "${W}Available updates:"

if [ $STANDARD_UPDATES -gt 0 ]; then
    echo -e "  ${Y}$STANDARD_UPDATES updates available${W}"
fi

if [ $SECURITY_UPDATES -gt 0 ]; then
    echo -e "  ${R}$SECURITY_UPDATES updates available${W}"
fi

if [[ $STANDARD_UPDATES -eq 0 && $SECURITY_UPDATES -eq 0 ]]; then
    echo -e "$G  All packages up to date$W"
else
    echo -e "$W  To see these additional updates run: apt list --upgradable"
fi