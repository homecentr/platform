#!/usr/bin/env bash

case "$1" in
 lab)
  INVENTORY="./environments/lab"
  ;;
 prod)
  INVENTORY="./environments/prod"
  ;;
 *)
  # else
  echo "Error, invalid arguments"
  exit 1
  ;;
esac

PLAYBOOK="./playbooks/${2:-_all}.yaml"

if [ ! -f "$PLAYBOOK" ]; then
  printHelp
  echo "Playbook $PLAYBOOK could not be found"
  exit 2
fi

shift
shift

export ANSIBLE_CONFIG="./ansible.cfg"

COMMAND="ansible-playbook -i ./environments/shared -i $INVENTORY $PLAYBOOK ${@:1}"

echo $COMMAND

# Execute playbook
eval $COMMAND