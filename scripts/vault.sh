#!/usr/bin/env bash

set -e

printHelp() {
  echo "Usage:"
  echo "\t./secrets edit (lab|prod)"
}

echo "CALLED" > /tmp/vault-log.txt

case "$1" in
 '') # Used by ansible
  gpg --batch --use-agent --decrypt ./.vault-pass.gpg
  exit 0
  ;;
 edit)
  ;;
 create)
  ;;
 view)
  ;;
 *)
  # else
  printHelp
  exit 1
  ;;
esac

if [ -z "$2" ]; then
  printHelp
  exit 1
fi

export EDITOR=nano

ansible-vault $1 --vault-password-file "./scripts/vault.sh" "./environments/$2"