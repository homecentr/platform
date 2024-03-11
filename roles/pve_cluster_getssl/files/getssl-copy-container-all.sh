#!/usr/bin/env bash

CONTAINER_CONFIGS=$(ls -l /etc/pve/getssl-containers/*.json 2>/dev/null | cut -d' ' -f9)

for CONTAINER_CONFIG in $CONTAINER_CONFIGS
do
    CONTAINER_ID="${CONTAINER_CONFIG%.*}"
    getssl-copy-container $CONTAINER_ID || echo "Failure is ignored on purpose"
done
