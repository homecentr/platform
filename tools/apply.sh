#!/usr/bin/env bash

PLAYBOOK="./playbooks/${1:-_all}.yaml"

if [ ! -f "$PLAYBOOK" ]; then
  echo "Playbook $PLAYBOOK could not be found"
  exit 2
fi

export ANSIBLE_CONFIG="./ansible.cfg"

shift

COMMAND="ansible-playbook -i ./inventory $PLAYBOOK ${@:1}"

# Execute playbook
eval $COMMAND