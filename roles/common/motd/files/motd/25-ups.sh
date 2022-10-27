#!/bin/bash

W="\e[0;39m"
G="\e[1;32m"
R="\e[1;31m"
Y="\e[0;33m"

declare -A UPS_STATUS_MAP
declare -A UPS_STATUS_COLOR_MAP

UPS_STATUS_MAP=( ["OL"]="Online" ["LB"]="Low Battery" ["OB"]="On battery" ["RB"]="Replace battery" )
UPS_STATUS_COLOR_MAP=( ["OL"]="$G" ["LB"]="$Y" ["OB"]="$R" ["RB"]="$R" )

if [ -f "/etc/ups" ]; then
    UPS_NAME=$(cat /etc/ups | tr '\n' ' ')
    UPS_RAW_STATUS=$(upsc $UPS_NAME ups.status 2> /dev/null | tr '\n' ' ' | sed 's/ *$//g')

    UPS_STATUS="${UPS_STATUS_MAP[$UPS_RAW_STATUS]}"
    UPS_STATUS_COLOR="${UPS_STATUS_COLOR_MAP[$UPS_RAW_STATUS]}"

    if [ "$UPS_STATUS" == "" ]; then
        UPS_STATUS="Unknown ($UPS_RAW_STATUS)"
        UPS_STATUS_COLOR="$Y"
    fi
else
    UPS_NAME="Unknown (/etc/ups file not found)"
    UPS_STATUS="$(R)Unkwnown$(W)"
    UPS_STATUS_COLOR="$Y"
fi

echo -e "
${W}UPS Status:
$W  Name........: $UPS_NAME
$W  Status......: ${UPS_STATUS_COLOR}$UPS_STATUS$W"