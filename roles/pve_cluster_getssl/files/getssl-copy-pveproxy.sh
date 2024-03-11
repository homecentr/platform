#!/usr/bin/env bash

UPDATE=false
NODE_NAME=$(hostname)
GETSSL_CERTNAME=$1

PROXY_PEM_HASH=$(sha1sum "/etc/pve/nodes/$NODE_NAME/pveproxy-ssl.pem" 2>/dev/null)
PROXY_KEY_HASH=$(sha1sum "/etc/pve/nodes/$NODE_NAME/pveproxy-ssl.key" 2>/dev/null)

GETSSL_PEM_HASH=$(sha1sum "/etc/pve/getssl/$GETSSL_CERTNAME/fullchain.crt" 2>/dev/null)
GETSSL_KEY_HASH=$(sha1sum "/etc/pve/getssl/$GETSSL_CERTNAME/$GETSSL_CERTNAME.key" 2>/dev/null)

if [ "$PROXY_PEM_HASH" == "" ] || [ "$PROXY_KEY_HASH" == "" ] || [ "$PROXY_PEM_HASH" != "$GETSSL_PEM_HASH" ] || [ "$PROXY_KEY_HASH" != "$GETSSL_KEY_HASH" ]; then
    echo "Updating certificates..."
    cp /etc/pve/getssl/$GETSSL_CERTNAME/fullchain.crt /etc/pve/nodes/$NODE_NAME/pveproxy-ssl.pem
    cp /etc/pve/getssl/$GETSSL_CERTNAME/$GETSSL_CERTNAME.key /etc/pve/nodes/$NODE_NAME/pveproxy-ssl.key

    systemctl restart pveproxy
fi