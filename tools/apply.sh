#!/usr/bin/env bash

printHelp() {
  echo "Usage: apply (lab|prod) <category> <playbook>"
}

case "$1" in
 lab)
  INVENTORY="./environments/lab"
  ;;
 prod)
  INVENTORY="./inventories/prod"
  ;;
 *)
  # else
  printHelp
  exit 1
  ;;
esac

PLAYBOOK="./playbooks/${2:-_all}.yml"

if [ ! -f "$PLAYBOOK" ]; then
  printHelp
  echo "Playbook $PLAYBOOK could not be found"
  exit 2
fi

shift
shift

export ANSIBLE_CONFIG="./ansible.cfg"

# Install Ansible dependencies (roles and collections)
ansible-galaxy install -r ./requirements.yml

COMMAND="ansible-playbook -i $INVENTORY $PLAYBOOK ${@:1}"

echo $COMMAND

# Execute playbook
eval $COMMAND