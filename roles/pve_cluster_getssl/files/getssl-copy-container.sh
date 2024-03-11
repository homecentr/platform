#!/usr/bin/env bash

set -e

CONTAINER_ID=$1

CONFIG_FILE="/etc/pve/getssl-containers/$CONTAINER_ID.json"
MOUNTPOINTS_ROOT="/var/lib/getssl" # /$CONTAINER_ID

# Check if config file exists
if ! test -f $CONFIG_FILE; then
    exit 0
fi

function getCertField() {
    CERT_NAME=$1
    FIELD_NAME=$2
    CONFIG_FILE=$3

    VALUE=$(jq -r ".[] | select(.name == \"$CERT_NAME\").$FIELD_NAME" $CONFIG_FILE)

    if [ -z "$VALUE" ]; then
        echo "The field $FIELD_NAME is mandatory"
        exit 1
    fi

    echo "$VALUE"
}

CERTIFICATES=$(jq -r '.[].name' $CONFIG_FILE)

for CERT in $CERTIFICATES
do
    CERT_TARGET_NAME=$(getCertField "$CERT" "cert_filename" "$CONFIG_FILE")
    KEY_TARGET_NAME=$(getCertField "$CERT" "key_filename" "$CONFIG_FILE")
    FULLCHAIN_TARGET_NAME=$(getCertField "$CERT" "fullchain_filename" "$CONFIG_FILE")
    OWNER=$(getCertField "$CERT" "user" $CONFIG_FILE)
    GROUP=$(getCertField "$CERT" "group" $CONFIG_FILE)
    PERMS=$(getCertField "$CERT" "mode" $CONFIG_FILE)

    # Copy files with new names
    cp "/etc/pve/getssl/$CERT/fullchain.crt" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$FULLCHAIN_TARGET_NAME.tmp"
    cp "/etc/pve/getssl/$CERT/$CERT.crt" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$CERT_TARGET_NAME.tmp"
    cp "/etc/pve/getssl/$CERT/$CERT.key" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$KEY_TARGET_NAME.tmp"

    # Change permissions
    chown "$OWNER" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$FULLCHAIN_TARGET_NAME.tmp"
    chown "$OWNER" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$CERT_TARGET_NAME.tmp"
    chown "$OWNER" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$KEY_TARGET_NAME.tmp"

    chgrp "$GROUP" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$FULLCHAIN_TARGET_NAME.tmp"
    chgrp "$GROUP" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$CERT_TARGET_NAME.tmp"
    chgrp "$GROUP" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$KEY_TARGET_NAME.tmp"

    # Overwrite the files
    mv "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$FULLCHAIN_TARGET_NAME.tmp" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$FULLCHAIN_TARGET_NAME"
    mv "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$CERT_TARGET_NAME.tmp" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$CERT_TARGET_NAME"
    mv "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$KEY_TARGET_NAME.tmp" "$MOUNTPOINTS_ROOT/$CONTAINER_ID/$KEY_TARGET_NAME"
done